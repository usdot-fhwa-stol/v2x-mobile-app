## Feature List
-   Message Support
    
    -   TIM Support
        
        -   Receive TIM messages via remote MQTT Broker            
        -   Show active TIM zones on a map            
        -   Provide Visual (graphic) alert for TIM message conditions            
        -   Provide System Notification for TIM message conditions            
        -   Read TIM ITIS content aloud to users            
        -   Supports over the air TIM message updates by downloading new TIM dictionary from the cloud
            
    -   BSM Support
        
        -   Send BSM Messages including vehicle type (Car, Truck, etc)            
        -   Receive BSM Messages            
        -   Show BSM on a Map (Graphic depends on Vehicle type)            
        -   Encode Vehicle light data into BSM Part-II
            
    -   PSM Support
        
        -   Send PSM messages including pedestrian type            
        -   Receive PSM messages            
        -   Show PSM on a map (Graphic depends on Pedestrian type)
            
    -   SDSM Support
        
        -   Receive SDSM messages            
        -   Show SDSM on a map (graphic depends on SDSM type)
            
    -   MAP Support
        
        -   Receive MAP messages            
        -   Show MAP messages on a map
            
    -   SPaT Support
        
        -   Receive SPaT messages            
        -   Show active light state on the map in real-time            
        -   Show countdown to green icon when App is in a valid ingress lane
            
-   MQTT Broker Support
    
    -   Supports transmitting and receiving on one or more of the following data sources concurrently:
        
        -   Verizon ETX
            
            -   Requires Active license with Verizon                
            -   Prioritized communication for Verizon users using VZ mode
                
        -   ISS MQTT
            
            -   Generic MQTT broker                
            -   Messages should be signed and verified
                
        -   PC5 via Ettifos OBU
            
            -   Allows loading PC5 data into CV-MEC by forwarding it directly from a connected ettifos OBU unit.
                
-   Signing Support:
    
    -   CV-MEC supports sending Signed messages using the ISS signing SDK. Available only on Android and IOS
        
-   GPS Source Support:
    
    -   CV-MEC supports connecting to remote GPS or local GPS devices. This includes the following
        
        -   Mobile Phone GPS            
        -   OBU GPS (only available with configured Ettifos OBU)            
        -   Cradlepoint GPS            
        -   Path Support - CV-MEC can run vehicles along predefined paths downloaded from the Partner API
            
-   Logging Support
    
    -   Automatically Captures all messages sent and received in log files on system        
    -   Log files can be accessed manually through android or IOS file systems        
    -   Log files can be uploaded automatically to a connected S3 Bucket specified by the Partner API
        
-   Platform Support
    
    -   IOS        
    -   Android        
    -   Linux Desktop (Ubuntu). Requires external GPS
