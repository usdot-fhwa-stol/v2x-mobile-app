
# Modular MQTT Connections
The V2X-Mobile-App application is designed to connect to multiple different [MQTT](https://mqtt.org/ "https://mqtt.org/") systems concurrently. This enables the app to be used for testing out multiple different data sources. As of version 67 of the V2X-Mobile-App application, the V2X-Mobile-App application is not dependent on any one MQTT Broker. However, in order to send or receive any messages at least one broker must be enabled in the settings menu. It is recommend that as new brokers are introduced to the application, additional configuration is added to the settings menu in order to streamline testing. V2X-Mobile-App also supports sending and receiving on multiple brokers concurrently. This allows the V2X-Mobile-App app to communicate effectively even with apps that are only capable of listening on a single broker. For example the [ISS Traffic Auth](https://www.ghsiss.com/ta-mobile/ "https://www.ghsiss.com/ta-mobile/") app can only communicate using the ISS MQTT Platform, and the Arizona Drive App (not yet, publicly available). However V2X-Mobile-App can communicate with both 3rd party applications.

To facilitate long term maintainability with multiple brokers, Version 67 of the V2X-Mobile-App application restructures the existing MQTT connections into multiple independent “agents“. Each agent inherits core features from a common [mqtt_agent](https://github.com/usdot-fhwa-stol/v2x-mobile-app/blob/develop/cv_mec/lib/models/mqtt/mqtt_agent.dart "https://github.com/usdot-fhwa-stol/v2x-mobile-app/blob/develop/cv_mec/lib/models/mqtt/mqtt_agent.dart")  parent which allows the agent to be managed by the [mqtt_agent_manager](https://github.com/usdot-fhwa-stol/v2x-mobile-app/blob/develop/cv_mec/lib/models/mqtt/mqtt_agent_manager.dart "https://github.com/usdot-fhwa-stol/v2x-mobile-app/blob/develop/cv_mec/lib/models/mqtt/mqtt_agent_manager.dart"). Programmatically, defining an agent requires three critical things to be defined.  
  

1.  CONNECT - How can the Agent connect to its MQTT Broker? This behavior is encapsulated in the connect function and should include all required steps to form a connection with the broker including:
    
    1.  Locating the Broker Host Address - Load from settings? Load from Remote API?        
    2.  Download or load any required certificates - Are certs bundled with the app? Or retrieved remotely?        
    3.  configuring the MQTT connection information - What port, security settings, and QOS are needed for the connection?        
    4.  connecting to the MQTT broker - Calling the actual connect method to form a connection with the agent. Setting up Ping callbacks for keep alive if required.
        
2.  SUBSCRIBE - Sets up all subscriptions needed by the agent to receive data from the MQTT broker. This may optionally also include assigning specific callback functions to preprocess the data before it is passed back to the main message decoding pipeline.
    
3.  SEND - Defines the behavior for how this MQTT agent should send messages. This may include selecting topics to broadcast messages on and adding additional encodings to the message before it is sent over the network.
