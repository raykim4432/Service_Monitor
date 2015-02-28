#$ADMIN_EMAIL = ""
#$FROM_EMAIL_ADDRESS = ""
#$SMTP_SERVER = 
#$email_subject = ""
#$email_body = ""


#prompt user for "view only mismatch" or "full view" mode
do {
    Write-Host ""
    Write-Host "(1) View Services not installed according to Service_Status_Policy.csv"
    Write-Host "(2) View Option(1) and mismatches"
    Write-Host "(3) View mismatches amongst installed Services"
    Write-Host "(4) View all"
    Write-Host "(5) Keep this script consistently running"
    [int]$mode = Read-Host "`n`nSelect an Option from above"
} until ($mode -gt 0 -and $mode -lt 6)

#prompt for intervals that this script is run at
if ($mode -eq 5) {
    Write-Host "`nHow frequently should this script run?"
    [int]$delay_between_intervals = Read-Host "`n`tIndicate in seconds"

    #save $mode and $delay_between_intervals to domain admin restricted txt file
    New-Item -ItemType file -Path $PSScriptRoot -Name "mode.txt" -Force
    Add-Content "$PSScriptRoot/mode.txt" $mode
    Add-Content "$PSScriptRoot/mode.txt" $delay_between_intervals
    #set file restrictions
    $acl = Get-Acl -path "$PSScriptRoot/mode.txt"
    foreach ($user in $acl.access) {
        #get the name of each user
        foreach ($name in $user.identityReference.Value) {
            #remove user from ACL if they are not domain admin or system
            if ($name -ne $DOMAIN_ADMIN -or $name -ne "NT AUTHORITY\SYSTEM") {
                $acl.RemoveAccessRule($user) | Out-Null
                #restrict privileges using ICACL, which trumps ACL
                #ICACLS "$PSScriptRoot/mode.txt" /remove $name
            }
        }
        
    } 
    #set acl for text file
    Set-Acl -path "$PSScriptRoot/mode.txt" -AclObject $acl

}

Remove-Variable acl -ErrorAction SilentlyContinue
Remove-Variable delay_between_intervals -ErrorAction SilentlyContinue
Remove-Variable name -ErrorAction SilentlyContinue
Remove-Variable user -ErrorAction SilentlyContinue

#run script
do {

#constants
$DOMAIN_ADMIN = "3POINTI\Administrator"

#import policies
$SERVICE_CONFIGS = Import-Csv "$PSScriptRoot\Service_Status_Policy.csv"

#initialize object array
[array]$objRowArray = @()


    #save processes to variables
    foreach ($service in $SERVICE_CONFIGS) {
    
        #retrieve current status of $SERVICE, if no status if found, it is not installed
        $service_on_computer = Get-Service -Name $service.ServiceName -ErrorAction SilentlyContinue
        if ($service_on_computer -eq $null) {
            $service_status = "Not_Installed"
        } else {
            $service_status = $service_on_computer.Status
        }


        #variable for spacing
        $spacing = 30 - $service.ServiceName.Length + $service.DesiredStatus.Length
        $spacing2 = 37 - $service.DesiredStatus.Length 
    
        #format desired and current status and save to $ROW
        $ROW = "{0}{1,$spacing}{2,$spacing2}" -f $service.ServiceName,$service.DesiredStatus,$service_status
    
        #save service, desired status and current status as fields of an object
        $objRow = New-Object -TypeName PSObject -Property @{Service=$service.ServiceName;Desired_Status=$service.DesiredStatus;Current_Status=$SERVICE_STATUS}
        $objRowArray += $objROW

        #all matching policies go into matches array. all else false into inconsistency
        #this helps avoid false negatives
        if ($service_status -eq $service.DesiredStatus) {
            $matches += $row
            $matches += "`n"
        } elseif ($service_status -eq "Not_Installed") {
            $not_installed += $row
            $not_installed += "`n"
        } else {
            $inconsistencies += $row
            $inconsistencies += "`n"
        }
    
    
    }

    ####################  display results  ####################
    #create column headers
    $HEADERS = "{0}{1, 37}{2, 23}" -f "SERVICE","DESIRED STATUS","CURRENT STATUS"

    #show not installed (if cases 1, 2 and 4 are selected)
    if ($mode -eq 1 -or $mode -eq 2 -or $mode -eq 4) {
        if ($not_installed -eq $null) {
            Write-Host "All Services are installed according to Service_Status_Policy.csv`n" -ForegroundColor Green 
        } else {
            Write-Host $HEADERS -ForegroundColor Gray
            [bool]$header_turned_on = 1
            Write-Host $not_installed -ForegroundColor Yellow
        }
    }

    #show inconsistencies (if cases 2, 3 and 4 are selcted)
    if ($mode -eq 2 -or $mode -eq 3 -or $mode -eq 4) { 
    
        #check if $inconsistencies is empty
        if ($inconsistencies -eq $null) {
            Write-Host "no inconsistencies were found" -ForegroundColor Green
        } else {
            #print header if it is not already printed
            if ($HEADER_TURNED_ON -eq $null) {
                Write-Host $HEADERS -ForegroundColor Gray
                [bool]$header_turned_on = 1
            }
            Write-Host $inconsistencies -ForegroundColor Red
        
        }
    } 

    #show matches (if case 4 is selected)
    if ($mode -eq 4 -and $matches -ne $null) { 
        #print header if it is not already printed
        if ($header_turned_on -eq $null) {
            Write-Host $HEADERS -ForegroundColor Gray
        }
        Write-Host $matches
    }

    #show message indicating the script has cycled 
    if ($mode -eq 5) {
        Write-Host "`nCurrent state of processes has been logged"
    } else { #else print * key
        Write-Host "* Yellow denotes a service not installed according to Service_Status_Policy.csv" -ForegroundColor Yellow
        Write-Host "* Red denotes an inconsistency to policy according to Service_Status_Policy.csv" -ForegroundColor Red
    }

    ####################  log results  ####################
    #determine in there is a save location for logs
    $LOG_SAVE_LOCATION = Get-Content "$PSScriptRoot\log_destination_directory.txt"
    if ($LOG_SAVE_LOCATION -ne $null) {
        #aggregate log data
        $log_output += $not_installed
        $log_output += $inconsistencies
        $log_output += $matches

        #create name for csv
        $FILE_NAME = Get-Date -Format "MM-dd-yyyy HH, mm, ss"

        #write output to csv
        #New-Item -ItemType directory -Path $LOG_SAVE_LOCATION -Name $FILE_NAME -Force
        for ([int]$i = 0; $i -lt $objRowArray.Length; $i++) {
            $csv_line = ConvertTo-Csv -InputObject $objRowArray[$i] -NoTypeInformation
        

            #strip all headers after first iteration
            if ($i -gt 0) {
                $csv_line = $csv_line | Select-Object -Skip 1
            }
            #add new CSV entry
            $export_csv += $csv_line
        }

        $export_csv | Out-File -FilePath "$LOG_SAVE_LOCATION\$FILE_NAME.csv"
    }

    #remove variables (as opposed to clear) to get rid of variable names
    #this may prevent others from seeing what variables this script uses

    #Remove-Variable ADMIN_EMAIL
    #Remove-Variable ADMIN_EMAIL
    #Remove-Variable FROM_EMAIL_ADDRESS
    #Remove-Variable SMTP_SERVER
    #Remove-Variable email_subject
    #Remove-Variable email_body

    Remove-Variable csv_line
    Remove-Variable DOMAIN_ADMIN
    Remove-Variable export_csv
    Remove-Variable FILE_NAME -ErrorAction SilentlyContinue
    Remove-Variable SERVICE_CONFIGS
    Remove-Variable service
    Remove-Variable service_on_computer
    Remove-Variable service_status
    Remove-Variable spacing
    Remove-Variable spacing2
    Remove-Variable HEADERS
    Remove-Variable header_turned_on -ErrorAction SilentlyContinue
    Remove-Variable i
    Remove-Variable LOG_SAVE_LOCATION -ErrorAction SilentlyContinue
    Remove-Variable log_output
    Remove-Variable matches -ErrorAction SilentlyContinue
    Remove-Variable inconsistencies -ErrorAction SilentlyContinue
    Remove-Variable not_installed -ErrorAction SilentlyContinue
    Remove-Variable row
    Remove-Variable objRow
    Remove-Variable objRowArray

    #initiate delay before running script again
    if ($mode -eq 5) {
        Remove-Variable mode
        Start-Sleep -Seconds (Get-Content "$PSScriptRoot\mode.txt")[1]
        
        $mode = (Get-Content "$PSScriptRoot\mode.txt")[0]
    }
} while ($mode -eq 5)

#if option 5 is not selected, $mode variable is still in memory
Remove-Variable mode

#Get-Item Variable:*