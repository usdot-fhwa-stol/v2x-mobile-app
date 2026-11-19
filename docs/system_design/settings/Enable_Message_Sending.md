# Enable Message Sending Design

For some users, it may be preferable that the V2X-Mobile-App does not broadcast BSM / PSM messages on the user's behalf. Possible reasons include
- Disabling location broadcasting for privacy sensitive users
- Disable sending BSM messages if the vehicle already has another BSM source
- Disable BSM sending for simulated "ghost" vehicles that do not actually exist
- Disable BSM broadcasting if another source is providing the location of the vehicle to the system (such as an SDSM equipped corridor)


To support these use cases, a new setting is added to the V2X-Mobile-App Settings menu. This setting will allow for users to enable or disable BSM and PSM broadcasting. When enabled, this setting will cause the MAP page to disable generating and transmitting BSM or PSM messages. Note - Since messages generation is blocked as well as transmission, no log entries will be created for sent messages while this setting is enabled.


## Setting Configuration
The BSM Enable / Disable setting is configured by the following environment variables

ENABLE_BSM_PSM_MESSAGES - Configure if BSM / PSM broadcasting is enabled by default for a clean installation of the app. This value defaults to true if not explicitly set to false. 

SHOW_BSM_PSM_MESSAGE_SENDING - Configures whether the settings option to enable or disable BSM traffic is available for users to switch at runtime. When set to false, users will not have the option to disable BSM / PSM transmission from the settings menu. In this case, message transmission will be dictated by the ENABLE_BSM_PSM_MESSAGES env variable.


### Interaction with BSM / PSM broadcast Rate
If BSM / PSM broadcasting is disabled, the message broadcast rate does not matter (no message will be sent so effective broadcast rate is 0). In this situation, the message broadcast rate box will be hidden in the settings menu to reduce clutter in the settings menu.

**Edge Cases**
- If SHOW_BSM_PSM_MESSAGE_SENDING is disabled and ENABLE_BSM_PSM_MESSAGES is enabled the user will not have the option to disable BSM / PSM sending and will be required to broadcast BSM / PSM messages

- If SHOW_BSM_PSM_MESSAGE_SENDING is disabled but SHOW_BROADCAST_RATE and ENABLE_BSM_PSM_MESSAGES are enabled, the user will be able to change the BSM broadcast rate, but not stop the broadcast entirely.

- If SHOW_BSM_PSM_MESSAGE_SENDING is disabled and ENABLE_BSM_PSM_MESSAGES is disabled the value of SHOW_BROADCAST_RATE will be ignored since this setting will always be hidden and no message broadcasting will ever be enabled

- SHOW_BSM_PSM_MESSAGE_SENDING is enabled but SHOW_BROADCAST_RATE is disabled, the user will be able to toggle BSM / PSM transmission On / Off, but will not be allowed to change the broadcast rate. Only the "Enable BSM Broadcast" setting will be available in the settings menu


### Interactions with ETX
The ETX uniquely requires BSM / PSM messages to be sent in order to function properly. Without BSM / PSM sending the ETX will not route most CV messages to the V2X-Mobile-App. If a user attempts to enable the ETX while BSM transmission is disabled. Or if a user tries to disable BSM transmission while the ETX broker is enabled, they will receive a warning indicating that things may not work correctly. 

## Additional Considerations
- Why not disable ETX entirely while BSM / PSM broadcast is not active? - Most ETX messages cannot work while BSM / PSM broadcasting is disabled, however a few niche cases still work. As a result the ETX is allowed to remain enabled while BSM / PSM broadcast is disabled.
- Why not Disable TUM broadcasting when BSM / PSM broadcast is not active? - Users should change the TOLLING_ENABLED setting if they wish to disable TUM messages
- Why not retain BSM / PSM generation and logging so that the mobile app logs keep a trail of its locations in the send log. - The send log should be for messages sent, not for generic position logging. Additionally, if users are disabling this setting because of privacy concerns. This also prevents the app from logging their position in the send log which may be a privacy concern.





