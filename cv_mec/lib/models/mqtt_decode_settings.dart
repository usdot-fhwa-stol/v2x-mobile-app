import 'package:cv_mec/controllers/settings_controller.dart';

class MqttDecodeSettings {
  MqttDecodeSettings({
    this.enableBSM = true,
    this.enablePSM = true,
    this.enableSPAT = true,
    this.enableMAP = true,
    this.enableTIM = true,
    this.enableSDSM = true,
    this.enableTAM = true,
    this.enableTUMACK = true,
  });

  bool enableBSM = true;
  bool enablePSM = true;
  bool enableSPAT = true;
  bool enableMAP = true;
  bool enableTIM = true;
  bool enableSDSM = true;
  bool enableTAM = true;
  bool enableTUMACK = true;


  MqttDecodeSettings.fromSettingsController(SettingsController settingsController) {
    enableBSM = true;
    enablePSM = true;
    enableSPAT = true;
    enableMAP = true;
    enableTIM = settingsController.showTims.value;
    enableSDSM = true;
    enableTAM = settingsController.tollingEnabled.value;
    enableTUMACK = settingsController.tollingEnabled.value;
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'enableBSM': enableBSM,
      'enablePSM': enablePSM,
      'enableSPAT': enableSPAT,
      'enableMAP': enableMAP,
      'enableTIM': enableTIM,
      'enableSDSM': enableSDSM,
      'enableTAM': enableTAM,
      'enableTUMACK': enableTUMACK,
    };
  }

  factory MqttDecodeSettings.fromMap(Map<String, dynamic> map) {
    return MqttDecodeSettings(
      enableBSM: map['enableBSM'] as bool? ?? true,
      enablePSM: map['enablePSM'] as bool? ?? true,
      enableSPAT: map['enableSPAT'] as bool? ?? true,
      enableMAP: map['enableMAP'] as bool? ?? true,
      enableTIM: map['enableTIM'] as bool? ?? true,
      enableSDSM: map['enableSDSM'] as bool? ?? true,
      enableTAM: map['enableTAM'] as bool? ?? true,
      enableTUMACK: map['enableTUMACK'] as bool? ?? true,
    );
  }
}