import argparse
import threading
import time

import paho.mqtt.client as mqtt


class RateCounter:
    def __init__(self) -> None:
        self._lock = threading.Lock()
        self._current_second_count = 0
        self.total_count = 0

    def increment(self) -> None:
        with self._lock:
            self._current_second_count += 1
            self.total_count += 1

    def pop_second_count(self) -> int:
        with self._lock:
            second_count = self._current_second_count
            self._current_second_count = 0
            return second_count


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Listen for SLAM BSM MQTT messages and print receive rate (msg/s)."
    )
    parser.add_argument("--host", default="localhost", help="MQTT broker host")
    parser.add_argument("--port", type=int, default=1883, help="MQTT broker port")
    parser.add_argument(
        "--topic",
        action="append",
        default=[],
        help=(
            "Topic filter to subscribe to. Can be provided multiple times. "
            "Default subscribes to both 'v1/g32/#' and '/v1/g32/#'."
        ),
    )
    return parser.parse_args()


def main() -> None:
    args = parse_args()
    topics = args.topic if args.topic else ["v1/g32/#", "/v1/g32/#"]

    counter = RateCounter()

    def on_connect(client: mqtt.Client, userdata, flags, reason_code, properties):
        if reason_code != 0:
            print(f"MQTT connect failed with code: {reason_code}")
            return
        for topic_filter in topics:
            client.subscribe(topic_filter)
            print(f"Subscribed to: {topic_filter}")

    def on_message(client: mqtt.Client, userdata, message: mqtt.MQTTMessage):
        counter.increment()

    client = mqtt.Client(mqtt.CallbackAPIVersion.VERSION2)
    client.on_connect = on_connect
    client.on_message = on_message

    client.connect(args.host, args.port, keepalive=60)
    client.loop_start()

    print(f"Listening on {args.host}:{args.port}")
    print("Press Ctrl+C to stop.")

    try:
        while True:
            time.sleep(1)
            received = counter.pop_second_count()
            print(f"rate={received} msg/s total={counter.total_count}")
    except KeyboardInterrupt:
        print("Stopping listener...")
    finally:
        client.loop_stop()
        client.disconnect()


if __name__ == "__main__":
    main()