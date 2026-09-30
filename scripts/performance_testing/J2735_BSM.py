import json
import os
import time


def create_bsm(
    latitude: float,
    longitude: float,
    msg_count: int,
    elevation: float = -409.6,
    speed: float = None,
    heading: float = None,
    id: int = None,
):
    device_id = int.from_bytes(os.urandom(4), "big") if id == None else id
    return {
        "messageId": 20,
        "value": {
            "BasicSafetyMessage": {
                "coreData": {
                    "msgCnt": msg_count,
                    "id": f"{format(device_id, '08X')}",
                    "secMark": int(time.time() * 1000) % 60000,
                    "lat": int(latitude * 10000000),
                    "long": int(longitude * 10000000),
                    "elev": (int(min(elevation * 10, 6143.9)) if (elevation > -409.6) else -4096),
                    "accuracy": {"semiMajor": 255, "semiMinor": 255, "orientation": 65535},
                    "transmission": "unavailable",
                    "speed": (
                        int(min(speed / 0.02, 8191)) if speed != None else min(int(0 * 50), 8191)
                    ),
                    "heading": int(heading / 0.0125) if heading != None else 28800,
                    "angle": 127,
                    "accelSet": {"long": 2001, "lat": 2001, "vert": -127, "yaw": 0},
                    "brakes": {
                        "wheelBrakes": "80",
                        "traction": "unavailable",
                        "abs": "unavailable",
                        "scs": "unavailable",
                        "brakeBoost": "unavailable",
                        "auxBrakes": "unavailable",
                    },
                    "size": {"width": 230, "length": 519},
                }
            }
        },
    }


def bsm_to_json(bsm):
    return json.dumps(bsm)


def main():
    latitude = 34.0554976
    longitude = -84.2760438
    speed = 20  # meters per second

    bsm = create_bsm(latitude, longitude, speed)
    json_bsm = bsm_to_json(bsm)
    print(json_bsm)


if __name__ == "__main__":
    main()
