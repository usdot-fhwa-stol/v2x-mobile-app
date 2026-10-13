enum MsgType { UNKNOWN, MAP, SPAT, TIM, BSM, SSM, PSM, SRM, SDSM, TAM, TUM, TUMACK}

MsgType? msgTypeFromName(String name) {
  for (final MsgType type in MsgType.values) {
    if (type.name == name) {
      return type;
    }
  }
  return null;
}
