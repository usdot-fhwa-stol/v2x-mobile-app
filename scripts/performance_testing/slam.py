import random
from J2735_BSM import create_bsm
import utils
import time
import threading
import paho.mqtt.client as mqtt
import requests

"""
This is a simple python script which creates a large number BSM messages around a specified location. The purpose of this script is to inundate the system with BSM messages for performance testing.
"""


MQTT_BROKER_HOST = "172.250.250.130"
MQTT_BROKER_PORT = 1883
BSM_PSID = 20
SERIALIZER_MAX_CONCURRENCY = 8


def get_bsm_topic(latitude: float, longitude: float, psid: int = BSM_PSID) -> str:
    geo_hash = utils.get_hash_for_coordinates(latitude, longitude, precision=7)
    segments = "/".join(geo_hash[:7])
    return f"v1/g32/{segments}/{psid}"


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

        topic = get_bsm_topic(vehicle_lat, vehicle_lon)

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
    latitude = 40.47392
    longitude = -104.969251

    # Specify the number of BSM messages to generate per second
    num_vehicles = 200
    broadcast_rate = 10

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

    print(f"Started {num_vehicles} sender threads at {broadcast_rate} Hz per vehicle")

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

   


