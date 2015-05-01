**************************************
What is Service_Status_Policy_Monistor
**************************************

See what services are running on your Microsoft OS computer in color coded fashion. 

Service_Status_Policy_Monistor.ps1 references currently running services to a white list of services (Service_Staus_policy.csv)
in order to generate a color coded report on:

* services that should be running on your system, but are not running (displayed in yellow)
* services that should not be running on your system, but are running (displayed in red)


Service_Status_Policy_Monistor.ps1 can also run in an intermittent mode where it checks the status of services at
intervals determined by the user.


*************
Installation:
*************

Place the Service_Status_Policy_Monistor directory in any location.

Create a directory where logs will be saved.

Update log_destination_directory.txt with the location of the directory to which
logs will be saved.

Right Click on Service_Status_Policy_Monistor.ps1 and run as Administrator.


************
Requirements
************

Admin account on local system

PowerShell (version 3.0 and up)

******
Credit
******

A large portion of this project is not my original work. The base Service Monitor script is taken
from a tutorial at overworkedadmin.com. The additional features I have added to this script include:

* the ability to differentiate between services that are installed but not running and services that are not installed at all
* the report color code scheme
* the ability to filter reports to display only certain information
* the ability to run the script continuously at custom intervals
* the clean up of PowerShell variables after each execution/cycle of the script
* the ability to turn report logging to disk on/off and designate what location to save logs
