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