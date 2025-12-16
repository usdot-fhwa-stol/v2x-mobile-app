# Adding additional TIM messages
The CV-MEC application currently supports all of the TIM messages outlined in the TIM message guidance document put together by the interoperability technical working group. These TIM messages are configured in a file called tims.json located in the assets folder of the CV-MEC application. To add support for additional TIM messages, itis sequences, and images, developers can modify the tims.json file and the corresponding assets/images/tims directory to expand the existing TIM dictionary. Below is a description of the tims.json file format and how to add new tim messages.

## Wildcards and Template Parsing

The tims.json functions as a sort of template file which maps series of ITIS codes to corresponding graphics and edit operations needed to properly show that graphic. For example, if the CV-MEC mobile application receives a TIM message with ITIS codes 769, 9478, 7747 (in that order) and a message type of advisory. It will show the graphic “closed_to_traffic.png” from the assets/images/tims directory.

```json
{
    "tims":[
        { // Sample Static TIM Message. Codes are constant values
            "name": "closed-to-traffic, local-traffic, only",
            "source": "guidance",
            "type": "advisory",
            "codes": ["769","9478","7747"],
            "graphic":"closed_to_traffic.png"
        }
      ]
  }
```
In addition to supporting static code orders, users can also use a limited set of symbols and wildcards to match broader patterns. For example, the message

```json
{
  "name": "right, <small number>, lanes, closed-ahead",
  "source": "guidance",
  "type": "workZone",
  "codes": ["13579", "*", "13588", "771"],
  "graphic":"right_lane_closed_ahead.png"
}
```

uses a * wildcard to indicate that any value can be filled into that slot of the message. Alternatively, a select set of itis codes can be specified by setting the value to a list of allowed values. In the example below, either the value 1025 or the value 1028 can be used for the First ITIS code that this pattern will match.

```json
{
  "name": "road-construction/construction-work ahead",
  "source": "guidance",
  "type": "workZone",
  "codes": ["[1025,1028]","13569"],
  "graphic":"road_work_ahead.png"
}
```

When parsing a TIM message, it is possible for a single TIM message to match multiple template definitions. This may be caused because a wildcard allows for a message to match more than one definition, or if two identical definitions are specified with different images. In the event that a TIM matches multiple definitions, the following rules will dictate which item is selected.

1.  Static definitions are prioritized over dynamic definitions
    
    1.  Definitions that have no wildcard symbols (*, #, [list]) will always be used before definitions that do        
    2.  In the case that multiple static definitions match a TIM the first one in the list will be taken. The code will log an error when the messages are loaded since the second definition will never be used.
        
2.  When two definitions both match a TIM. The first one in the list will be taken. No error will be logged if at least one of the message is dynamic, since it is theoretically possible they map to different items as well.

## Dynamically Generating Graphics

Some TIM messages may have different graphics depending on the value of the ITIS codes provided. For example, speed limit TIMS may change the speed limit of a sign based upon what codes are provided. While this functionality could be achieved by defining hundreds of possible speed limit graphics individually, it is far easier to read the itis code and edit it onto the image instead. By embedding the # symbol into a TIM message definition, the user specifies that the value in that field of the ITIS codes of the TIM should be drawn on the graphic. When specifying a number symbol, you must also specify instructions on how that graphic should be drawn on the image. For example:

```json
{
    "tims":[
        { // Sample Dynamic TIM Message. Codes include wildcards and symbols
              "name": "alert, gusty-winds, may-exceed, <number>, mph",
              "source": "guidance",
              "type": "advisory",
              "codes": ["6916", "*", "7759", "#", "8720"]
              "graphic":"gusty_winds.png",
              "overlays":[
                  {
                      "majorFontSize": 20,
                      "minorFontSize": 12,
                      "xPos": 157,
                      "yPos": 230
                  }
              ]
          }
      ]
  }
  ```

## **Message Breakdown**

Below is a breakdown of each field in a TIM definition.

```json
{
    "tims":[ // TIM field used to dictate the list of tim messages
        { 
              "name": "alert, gusty-winds, may-exceed, <number>, mph", // (Required) Friendly name for this TIM, unused in code, but helps to make the TIM more human readable.
              "source": "guidance", // (Required) The source of the TIM message, this value is unused in code, but helps to identify where this TIM definition came from. For example, USDOT, WYDOT, Caltrans, etc.
              "type": "advisory", // (Required) The category of the TIM. Must be one of workZone, exitService, genericSign, speedLimit, advisory
              "codes": ["6916", "*", "7759", "#", "8720"] // (Required) The ITIS pattern this message matches
              "graphic":"gusty_winds.png", // (Required) What image to show when this pattern matches
              "overlays":[ // (Optional) This field is a list of instructions on where to overlay text when generating images. It is optional if no # signs are specified in codes. If # are specified in codes, this field must have a length equal to the number of #.
                  {
                      "majorFontSize": 20, // (Required) Font size to use for short text (2 digit numbers or less)
                      "minorFontSize": 12, // (Required) Font size to use for large text (3 digits or more)
                      "xPos": 157, // (Required) X Position to show text at
                      "yPos": 230 // (Required) Y Position to show text at
                  }
              ]
          }
      ]
  }
    ```
