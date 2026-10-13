import glob
import utils
import time
from datetime import datetime, timezone

def load_sample_spat_json():
    spats = []
    for file_name in glob.glob("sample_data/spat/*.txt"):
        with open(file_name, "r") as f:
            spat_hex = f.read()
            spat_json = utils.decode_asn1_hex(spat_hex)
            
            spats.append(spat_json)
    return spats


def increment_spat_phases(spat):
    for intersection in spat.get("value",{}).get("SPAT",{}).get("intersections",[]):
        for state in intersection.get("state",[]):
            for statePhase in state.get("state-time-speed",[]):
                light_phase = statePhase.get("eventState")
                if light_phase == "protected-Movement-Allowed":
                    statePhase["eventState"] = "protected-clearance"
                elif light_phase == "protected-clearance":
                    statePhase["eventState"] = "stop-and-remain"
                else:
                    statePhase["eventState"] = "protected-Movement-Allowed"
        intersection["revision"] = (intersection.get("revision", 0) + 1) % 128
    
    return spat

def update_timestamp(spat):
    now = datetime.now(timezone.utc)
    year_start = datetime(now.year, 1, 1, tzinfo=timezone.utc)
    moy = int((now - year_start).total_seconds() /60)
    dSecond = int(now.timestamp() * 1000) % 60000  # Current time in milliseconds

    
    for intersection in spat.get("value",{}).get("SPAT",{}).get("intersections",[]):
        intersection["moy"] = moy
        intersection["timeStamp"] = dSecond
    
    return spat


if __name__ == "__main__":
    spats = load_sample_spat_json()
    for spat in spats:
        increment_spat_phases(spat)
        update_timestamp(spat)
        break




