import random
from J2735_BSM import create_bsm
from J2735_MAP import load_map_hex
from J2735_SPAT import increment_spat_phases
from J2735_SPAT import load_sample_spat_json
from J2735_SPAT import update_timestamp
import utils
import time
import threading
import paho.mqtt.client as mqtt
import requests

"""
This is a simple python script which creates a large number BSM messages around a specified location. The purpose of this script is to inundate the system with BSM messages for performance testing.
"""


MQTT_BROKER_HOST = "172.250.250.26"
MQTT_BROKER_PORT = 1883
BSM_PSID = 20
MAP_PSID = 18
SPAT_PSID = 19
SERIALIZER_MAX_CONCURRENCY = 8


def get_topic(latitude: float, longitude: float, psid: int) -> str:
    geo_hash = utils.get_hash_for_coordinates(latitude, longitude, precision=7)
    segments = "/".join(geo_hash[:7])
    return f"v1/g32/{segments}/{psid}"


def map_sender(
    map_payloads: list[bytes],
    topic: str,
    mqtt_client: mqtt.Client,
    stop_event: threading.Event,
) -> None:
    if not map_payloads:
        print("MAP sender disabled: no MAP sample payloads found")
        return

    next_send_time = time.time()

    while not stop_event.is_set():
        sleep_duration = next_send_time - time.time()
        if sleep_duration > 0:
            time.sleep(sleep_duration)

        for map in map_payloads:
            mqtt_client.publish(topic, map)
        next_send_time += 1.0


def spat_sender(
    spat_index: int,
    spat_message: dict,
    topic: str,
    mqtt_client: mqtt.Client,
    stop_event: threading.Event,
    serializer_gate: threading.BoundedSemaphore,
) -> None:
    # Stagger thread start times to reduce serializer contention bursts.
    next_send_time = time.time() + random.uniform(0.0, 0.1)
    next_timestamp_update = next_send_time + 1.0
    next_phase_update = next_send_time + random.uniform(5.0, 15.0)

    try:
        with serializer_gate:
            spat_payload = bytes.fromhex(utils.get_messageframe_asn1_hex(spat_message))
    except (requests.RequestException, ValueError) as exc:
        print(f"SPaT sender {spat_index}: initial encoding failed: {exc}")
        return

    while not stop_event.is_set():
        now = time.time()
        updated = False

        if now >= next_timestamp_update:
            update_timestamp(spat_message)
            # Advance in 1 second steps to avoid drift during transient delays.
            while now >= next_timestamp_update:
                next_timestamp_update += 1.0
            updated = True

        if now >= next_phase_update:
            increment_spat_phases(spat_message)
            next_phase_update = now + random.uniform(5.0, 15.0)
            updated = True

        if updated:
            try:
                with serializer_gate:
                    spat_payload = bytes.fromhex(utils.get_messageframe_asn1_hex(spat_message))
            except (requests.RequestException, ValueError) as exc:
                print(f"SPaT sender {spat_index}: update encoding failed: {exc}")

        mqtt_client.publish(topic, spat_payload)

        next_send_time += 0.1
        send_sleep_duration = next_send_time - time.time()
        if send_sleep_duration > 0:
            time.sleep(send_sleep_duration)
        else:
            # Reset schedule so overloaded senders recover quickly.
            next_send_time = time.time()

def vehicle_sender(
    vehicle_index: int,
    vehicle_id: int,
    base_latitude: float,
    base_longitude: float,
    broadcast_rate: float,
    mqtt_client: mqtt.Client,
    stop_event: threading.Event,
    serializer_gate: threading.BoundedSemaphore,
) -> None:
    msg_count = 0
    repeats_per_second = max(1, int(round(broadcast_rate)))
    send_delta = 1.0 / repeats_per_second
    generation_delta = 1.0
    # Add jitter so all threads do not hit the serializer at the exact same instant.
    next_generation_start = time.time() + random.uniform(0, generation_delta)

    print(f"Vehicle Sender {vehicle_index}!")
    while not stop_event.is_set():
        current_time = time.time()
        sleep_duration = next_generation_start - current_time
        if sleep_duration > 0:
            time.sleep(sleep_duration)
        else:
            next_generation_start = current_time

        lat_offset = random.uniform(-0.001, 0.001)
        lon_offset = random.uniform(-0.001, 0.001)
        vehicle_lat = base_latitude + lat_offset
        vehicle_lon = base_longitude + lon_offset

        bsm_message = create_bsm(vehicle_lat, vehicle_lon, msg_count, id=vehicle_id)
        try:
            with serializer_gate:
                encoded_bsm = utils.get_bsm_asn1_hex(bsm_message)
        except requests.RequestException as exc:
            print(f"Vehicle {vehicle_index}: serializer request failed: {exc}")
            msg_count = (msg_count + 1) % 128
            next_generation_start += generation_delta
            continue

        topic = get_topic(vehicle_lat, vehicle_lon, BSM_PSID)

        try:
            bsm_payload = bytes.fromhex(encoded_bsm)
        except ValueError:
            print(f"Vehicle {vehicle_index}: invalid BSM hex payload")
            msg_count = (msg_count + 1) % 128
            next_generation_start += generation_delta
            continue

        next_send_time = next_generation_start
        sent_count = 0
        while sent_count < repeats_per_second and not stop_event.is_set():
            now = time.time()
            send_sleep_duration = next_send_time - now
            if send_sleep_duration > 0:
                time.sleep(send_sleep_duration)
            mqtt_client.publish(topic, bsm_payload)
            sent_count += 1
            next_send_time += send_delta

        msg_count = (msg_count + 1) % 128
        next_generation_start += generation_delta





if __name__ == "__main__":

    if not utils.check_j2735_serializer():
        raise ValueError(
            "J2735 serializer is not running, please refer to the README.md file for instructions on how to start the serializer"
        )

     # Specify the location around which to generate BSM messages
    latitude = 42.3290503
    longitude = -83.0460734

    # Specify the number of BSM messages to generate per second
    num_vehicles = 100
    broadcast_rate = 10

    map_topic = get_topic(latitude, longitude, MAP_PSID)
    spat_topic = get_topic(latitude, longitude, SPAT_PSID)

    map_payloads = []
    for map_hex in load_map_hex():
        cleaned_map_hex = map_hex.strip()
        if not cleaned_map_hex:
            continue
        try:
            map_payloads.append(bytes.fromhex(cleaned_map_hex))
        except ValueError:
            print("Skipping invalid MAP hex payload")

    spat_messages = load_sample_spat_json()
    for spat in spat_messages:
        update_timestamp(spat)

    device_ids = [random.randrange(0,2**32) for _ in range(num_vehicles)]

    mqtt_client = mqtt.Client(mqtt.CallbackAPIVersion.VERSION2)
    mqtt_client.connect(MQTT_BROKER_HOST, MQTT_BROKER_PORT, keepalive=60)
    mqtt_client.loop_start()
    stop_event = threading.Event()
    serializer_gate = threading.BoundedSemaphore(SERIALIZER_MAX_CONCURRENCY)
    threads = []

    for i in range(num_vehicles):
        sender_thread = threading.Thread(
            target=vehicle_sender,
            args=(
                i,
                device_ids[i],
                latitude,
                longitude,
                broadcast_rate,
                mqtt_client,
                stop_event,
                serializer_gate,
            ),
            daemon=True,
        )
        sender_thread.start()
        threads.append(sender_thread)

    map_thread = threading.Thread(
        target=map_sender,
        args=(
            map_payloads,
            map_topic,
            mqtt_client,
            stop_event,
        ),
        daemon=True,
    )
    map_thread.start()
    threads.append(map_thread)

    if not spat_messages:
        print("SPaT sender disabled: no SPaT sample payloads found")
    else:
        for spat_index, spat_message in enumerate(spat_messages):
            spat_thread = threading.Thread(
                target=spat_sender,
                args=(
                    spat_index,
                    spat_message,
                    spat_topic,
                    mqtt_client,
                    stop_event,
                    serializer_gate,
                ),
                daemon=True,
            )
            spat_thread.start()
            threads.append(spat_thread)

    print(
        f"Started {num_vehicles} BSM sender threads at {broadcast_rate} Hz per vehicle, "
        f"MAP at 1 Hz, and {len(spat_messages)} SPaT sender threads at 10 Hz each"
    )

    try:
        while True:
            time.sleep(1)
    except KeyboardInterrupt:
        print("Stopping sender threads...")
        stop_event.set()

    for sender_thread in threads:
        sender_thread.join(timeout=2)

    mqtt_client.loop_stop()
    mqtt_client.disconnect()

   


