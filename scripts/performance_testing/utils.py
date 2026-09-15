import json
import paho.mqtt.client as mqtt
import pygeohash as geohash
import requests
import threading
from requests.adapters import HTTPAdapter
import J2735_BSM


_thread_local = threading.local()


def _get_serializer_session() -> requests.Session:
    session = getattr(_thread_local, "serializer_session", None)
    if session is None:
        session = requests.Session()
        # Reuse a persistent localhost connection per sender thread.
        adapter = HTTPAdapter(pool_connections=1, pool_maxsize=1, max_retries=0, pool_block=True)
        session.mount("http://", adapter)
        _thread_local.serializer_session = session
    return session


def get_hash_for_coordinates(lat: float, lon: float, precision: int = 8) -> str:
    return geohash.encode(lat, lon, precision)


def get_geo_hash(geo_hash: str, wildcard_char: str) -> str:
    if len(geo_hash) < 8:
        geo_hash = geo_hash + wildcard_char * (8 - len(geo_hash))
    topic_start_geohash = "/".join(geo_hash)
    return topic_start_geohash


def check_j2735_serializer() -> bool:
    try:
        response = requests.get(
            url="http://localhost:4000/health",
            headers={"Content-Type": "application/json"},
            timeout=2,
        )
    except Exception as e:
        return False
    if response.text == "I am in good health, thanks for checking.":
        return True
    else:
        return False


def get_bsm_asn1_hex(bsm: J2735_BSM) -> str:
    response = _get_serializer_session().post(
        url="http://localhost:4000/jer/uper/hex",
        data=J2735_BSM.bsm_to_json(bsm),
        headers={"Content-Type": "application/json"},
        timeout=3,
    )
    response.raise_for_status()
    return response.text


def decode_asn1_hex(hex: str) -> dict:
    if not check_j2735_serializer():
        raise ValueError(
            "J2735 serializer is not running, please refer to the README.md file for instructions on how to start the serializer"
        )

    response = requests.post(
        url="http://localhost:4000/uper/hex/jer",
        data=hex,
        headers={"Content-Type": "text/plain"},
        timeout=3,
    )

    if response.status_code == 200:
        json_response = json.loads(response.text)
        return json_response
    else:
        return {}
 
