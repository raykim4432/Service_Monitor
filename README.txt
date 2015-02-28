
See what services are running on your Microsoft OS computer in color coded fashion. 

Service_Status_Policy_Monistor.ps1 references currently running services to a white list of services (Service_Staus_policy.csv)
in order to generate a color coded report on:

* services that should be running on your system, but are not running (displayed in yellow)
* services that should not be running on your system, but are running (displayed in red)


Service_Status_Policy_Monistor.ps1 can also run in an intermittent mode where it checks the status of services at
intervals determined by the user.

Note: log_destination_directory.txt must be updated on your local system before running this script so that 
logs are configured to save to the appropriate directory of your choosing.

Requires PowerShell (version 3.0 and up)