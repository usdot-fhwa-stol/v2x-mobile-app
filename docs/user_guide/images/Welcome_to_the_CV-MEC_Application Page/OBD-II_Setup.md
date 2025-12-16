# OBD-II Setup
The CV-MEC application is able to connect to the On-Board Diagnostics (OBD-II) System to get additional information about the current state of the vehicle including the vehicle make, model, year as well as the speed and engine RPM. This functionality is only available on Android and Linux devices.

**Adding an OBD-II sensor to the vehicle**

Plug a Bluetooth OBD-II Fob into the 16 pin port generally located under the dashboard of the vehicle. An OBDLinkMX+ was used for implementation and testing.

![OBDII_Port](OBDII_Port.png)
![OBDII_Bluetooth Fob](OBDII_Bluetooth_Fob.png) 

**Initial Pairing of OBD-II to an Android Device**

1.  Tap on the Bluetooth pairing button on the OBD-II Bluetooth Fob. Make sure the vehicle is turned on in order to connect.    
2.  Open the Bluetooth menu by clicking on the Bluetooth button in the quick settings panel.    
3.  Click on “Pair New Device” and connect to the OBD-II device.    
4.  The OBD-II device should now appear in your saved devices list in the Bluetooth menu.

![Bluetooth_Connect_Button](Bluetooth_Connect_Button.png)
![Cell_Phone_Bluetooth_Button](Cell_Phone_Bluetooth_Button.png)
![Cell_Phone_Pair_New_Device](Cell_Phone_Pair_New_Device.png)

**Connecting to the OBD-II through CV-MEC Android Application**

1.  Open the CV-MEC application and navigate to the map page 
2.  Click on the carrot dropdown on the “Vehicle Stats” Tab    
3.  Click the “Connect to OBD-II” Button    
4.  If this is the first time the device is connecting, allow the CV-MEC application to connect to nearby devices

![Vehicle_Stats](Vehicle_Stats.png)
![Connect_to_OBD-II](Connect_to_OBD-II.png)
![Connect_to_Nearby_Devices](Connect_to_Nearby_Devices.png)

5.  If an OBD-II device hasn’t already been selected, the Bluetooth device selection will pop up. Click on the OBD-II device from the list.    
6.  The OBD-II display will pop up showing the vehicle make, model, and year and the current vehicle speed and engine rpm.

![Selecting_Bluetooth_Device](selecting_bluetooth_device.png)
![OBD-II_Display](obd-ii_display.png)

**Initial Pairing of OBD-II to a Linux Device**

1.  Tap on the Bluetooth pairing button on the OBD-II Bluetooth Fob. Make sure the vehicle is turned on in order to connect.    
2.  Open up the Bluetooth menu in settings.    
3.  The OBD-II device should appear in the list of devices, click on it to pair.

![Bluetooth_Connect_Button](Bluetooth_Connect_Button.png)
![Bluetooth_Menu](Bluetooth_Menu.png)
![List_of_Bluetooth_Devices](List_of_Bluetooth_Devices.png)

**Connecting to the OBD-II through CV-MEC Linux Application**

1.  Open the CV-MEC application with **root permissions** and navigate to the map page    
2.  Click on the carrot dropdown on the “Vehicle Stats” Tab    
3.  Click the “Connect to OBD-II” Button    
4.  If an OBD-II device hasn’t already been selected, the Bluetooth device selection will pop up. Click on the OBD-II device from the list    
5.  The OBD-II display will pop up showing the vehicle make, model, and year and the current vehicle speed and engine rpm

![Vehicle_Stats](Vehicle_Stats.png)
![Connect_to_OBD-II_Button](Connect_to_OBD-II_Button.png)
![Select_a_Device](Select_a_Device.png)

**Saving OBD-II to a saved vehicle**

Users can connect the OBD-II to a vehicle in their vehicle list.

1.  From the main page, tap on Vehicle, and then “Add New” or click on the side carrot of a pre-existing vehicle to get to the “Vehicle Configuration” page.

![Main_Page_Vehicle](Main_Page_Vehicle.png)
![Add_New](Add_New.png)
![Vehicle_Configuration](Vehicle_Configuration.png)

2. Scroll down to OBD-II Connection and click on the Bluetooth icon. Select the OBD-II from the Bluetooth device list. Make sure your vehicle is on.

![Bluetooth_Device_List](Bluetooth_Device_List.png)
![Select_a_Device](Select_a_Device.png)
![Save](Save.png)










