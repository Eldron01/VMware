#############################################################################################################
# Script Name: Get_All_Info_By_vCenter.ps1
#
# Created On: 12/30/15
#
# Author: Ron Tayler
#
# Purpose: This script will gather VM information by vCenter. The script will connect to a vCenter, gather
# a list of VMs and process each one. The data is sent to a custom object and then that object is exported 
# to a CSV. The vCenter is diconnected and the loop begins again for the next vCenter.
#
# Input File: The input file is a text file with the vCenter names only.
# 
# Version: 1.0
# 	Initial Release
#
# Version 1.1 - 1/11/16
#	Automaticly grab the date, convert it to a useful format and use it for the export. This is only day
#	and not time. Also set the script to automatically load the VMware snapin.
#
# Version 1.2 - 1/26/16
#	Added VM status, snapshot and snapshot creation infomation.
# 
# Version 1.3 - 3/10/16
#	Added DNS Name
#
# Version 1.4 - 6/14/16
#	Added the conversion of the output CSV to HTML. That HTML file is copied to the wwwroot directory
#	to make the list availbe over HTTP.
#
# Version 1.5 - 8/11/16
#   Removed provisioned storage, because it was not always reporting the right info. Add drive mount point,
#   total size and free space for seven drives.
#
# Version 1.6 - 9/8/16
#	Added a new field to show if a VM is protected by SRM. This aids in understanding why so many VMs are
#	powered off.
#
# Version 1.7 - 12/13/16
#	Added a field to show what folder the VM is in.
#
# Version 1.8 - 12/14/17
#	Added NT_LAST_BACKUP annotation as the Backup column.
#
# Version 1.9 - 02/21/18
#	Changed the way the date is gathered so it uses leading zeros.
#
#############################################################################################################

add-pssnapin vmware.vimautomation.core -ea silentlycontinue

# Get and Format date for export file
$dateMonth = Get-Date -Format MM
$dateDay = Get-Date -Format dd
$dateYear = Get-Date -Format yyyy
$csvdate = "$dateMonth-$dateDay-$dateYear"

# Get the list of vCetners 
$vcenters = gc c:\vcenters.txt

# Start the vCenter loop. It will disconnect any existing sessions.
foreach ($vcenter in $vcenters) {
# Disconnect any VI Servers. This throws an error the first time because there are no connected servers. It is not a problem
Disconnect-VIServer * -confirm:$false
	Connect-VIServer $vcenter
	
# Start the VM processing loop by gathering a list of VMs and using get-view to pull properties.
	$vmlist = Get-VM
		foreach ($vm in $vmlist)
{
			$vmobjectinfo = $null
			$vmobjectinfo = get-view –viewtype VirtualMachine –filter @{“Name”=”$vm”}
			$vmsummary = $vmobjectinfo.Summary;
			$hostinfo = $null
			$hostinfo = Get-VIObjectByVIView -Server $vcenter $vmsummary.Runtime.Host
			$vmobjectinfo.UpdateViewData('Network.Name')
			$vmHostName = $hostinfo.Name
			$FolderName = $vmobjectinfo | Select Name,@{N="Folder";E={Get-View $_.Parent | Select -ExpandProperty Name}} | foreach {$_.Folder}
			$vmClusterName = $hostinfo.Parent
			$vmPath = $vmsummary.Config.VmPathName
			$vmRAMAllocated =  $vmsummary.Config.MemorySizeMB
			$vmMemUsage = $vmsummary.QuickStats.GuestMemoryUsage
			$vmCPUAllocated = $vmsummary.Config.NumCpu
			$vmCPUUsage = $vmsummary.QuickStats.OverallCpuUsage
			$vmSRM = $vmobjectinfo.Config.ManagedBy | foreach {$_.Type}
#Disks Start
			$DisksInfo = $vmobjectinfo.Guest.Disk | select DiskPath,Capacity,FreeSpace
			$disksArray = @($DisksInfo)
			$Disk1_MP = $disksArray[0] | foreach {$_.DiskPath}
			$Disk1_FreePre = $disksArray[0] | foreach {$_.FreeSpace / 1024 / 1024 / 1024}
			$Disk1_Free = "{0:N0}" -f $Disk1_FreePre
			$Disk1_SizePre = $disksArray[0] | foreach {$_.Capacity / 1024 / 1024 / 1024}
			$Disk1_Size = "{0:N0}" -f $Disk1_SizePre
			$Disk2_MP = $disksArray[1] | foreach {$_.DiskPath}
			$Disk2_FreePre = $disksArray[1] | foreach {$_.FreeSpace / 1024 / 1024 / 1024}
			$Disk2_Free = "{0:N0}" -f $Disk2_FreePre
			$Disk2_SizePre = $disksArray[1] | foreach {$_.Capacity / 1024 / 1024 / 1024}
			$Disk2_Size = "{0:N0}" -f $Disk2_SizePre
			$Disk3_MP = $disksArray[2] | foreach {$_.DiskPath}
			$Disk3_FreePre = $disksArray[2] | foreach {$_.FreeSpace / 1024 / 1024 / 1024}
			$Disk3_Free = "{0:N0}" -f $Disk3_FreePre
			$Disk3_SizePre = $disksArray[2] | foreach {$_.Capacity / 1024 / 1024 / 1024}
			$Disk3_Size = "{0:N0}" -f $Disk3_SizePre
			$Disk4_MP = $disksArray[3] | foreach {$_.DiskPath}
			$Disk4_FreePre = $disksArray[3] | foreach {$_.FreeSpace / 1024 / 1024 / 1024}
			$Disk4_Free = "{0:N0}" -f $Disk4_FreePre
			$Disk4_SizePre = $disksArray[3] | foreach {$_.Capacity / 1024 / 1024 / 1024}
			$Disk4_Size = "{0:N0}" -f $Disk4_SizePre
			$Disk5_MP = $disksArray[4] | foreach {$_.DiskPath}
			$Disk5_FreePre = $disksArray[4] | foreach {$_.FreeSpace / 1024 / 1024 / 1024}
			$Disk5_Free = "{0:N0}" -f $Disk5_FreePre
			$Disk5_SizePre = $disksArray[4] | foreach {$_.Capacity / 1024 / 1024 / 1024}
			$Disk5_Size = "{0:N0}" -f $Disk5_SizePre
			$Disk6_MP = $disksArray[5] | foreach {$_.DiskPath}
			$Disk6_FreePre = $disksArray[5] | foreach {$_.FreeSpace / 1024 / 1024 / 1024}
			$Disk6_Free = "{0:N0}" -f $Disk6_FreePre
			$Disk6_SizePre = $disksArray[5] | foreach {$_.Capacity / 1024 / 1024 / 1024}
			$Disk6_Size = "{0:N0}" -f $Disk6_SizePre
			$Disk7_MP = $disksArray[6] | foreach {$_.DiskPath}
			$Disk7_FreePre = $disksArray[6] | foreach {$_.FreeSpace / 1024 / 1024 / 1024}
			$Disk7_Free = "{0:N0}" -f $Disk7_FreePre
			$Disk7_SizePre = $disksArray[6] | foreach {$_.Capacity / 1024 / 1024 / 1024}
			$Disk7_Size = "{0:N0}" -f $Disk7_SizePre
#Disks End			
			$vmPortGroup = $vmobjectinfo.LinkedView.Network.Name
			$vmIP = $vmsummary.Guest.IpAddress
			$vmHWVersion = $vmobjectinfo.Config.Version
			$vmEVC = $vmobjectinfo.Summary.Runtime.MinRequiredEVCModeKey
			$vmOSname = $vmobjectinfo.Guest.GuestFullName
			$vmToolRunStatus = $vmobjectinfo.Guest.ToolsRunningStatus
			$vmToolsVerStatus = $vmobjectinfo.Guest.ToolsVersionStatus
			$vmPowerStatus = $vmobjectinfo.Runtime.PowerState
			$vmSnapShot = $vmobjectinfo.snapshot.RootSnapshotList.Name
			$vmSnapShotTime = $vmobjectinfo.snapshot.RootSnapshotList.CreateTime
			$vmSnapShotSizeGB = Get-Snapshot $vm | select @{Label="Size";Expression={"{0:N2} GB" -f ($_.SizeGB)}} | foreach {$_.Size}
			$vmDNSName = $vmobjectinfo.guest.hostname
			$Backup = Get-Annotation -Entity $vm -Name 'NB_LAST_BACKUP' | foreach  {$_.Value}
		# Create the custom oject in a ordered hash table. Objects are exported in the order of the list below starting from the top.
							[PSCustomObject] @{
							VMname = $vm
							Power_Status = $vmPowerStatus
					    	Cluster = $vmClusterName
							VMhost = $vmHostName
							vCenter = $vcenter
							SRM_Placeholder = $vmSRM
							OS = $vmOSname
							RAM_Allocated = $vmRAMAllocated
							Guest_Memory_Usage = $vmMemUsage
							Guest_CPU_Usage = $vmCPUUsage
							CPU_Allocated = $vmCPUAllocated							
							Disk1 = $Disk1_MP
							Disk1_Size_GB = $Disk1_Size
							Disk1_Available_GB = $Disk1_Free
							Disk2 = $Disk2_MP
							Disk2_Size_GB = $Disk2_Size
							Disk2_Available_GB = $Disk2_Free
							Disk3 = $Disk3_MP
							Disk3_Size_GB = $Disk3_Size
							Disk3_Available_GB = $Disk3_Free
							Disk4 = $Disk4_MP
							Disk4_Size_GB = $Disk4_Size
							Disk4_Available_GB = $Disk4_Free
							Disk5 = $Disk5_MP
							Disk5_Size_GB = $Disk5_Size
							Disk5_Available_GB = $Disk5_Free
							Disk6 = $Disk6_MP
							Disk6_Size_GB = $Disk6_Size
							Disk6_Available_GB = $Disk6_Free
							Disk7 = $Disk7_MP
							Disk7_Size_GB = $Disk7_Size
							Disk7_Available_GB = $Disk7_Free
							Port_Group = $vmPortGroup
							VM_Folder = $FolderName
							IP_Address = $vmIP
							DNS_Name = $vmDNSName
							VM_Hardware_Version = $vmHWVersion
							EVC_Mode = $vmEVC
							VM_Path = $vmPath
							Snapshot = $vmSnapShot
							SnapshotTime = $vmSnapShotTime
							SnapshotSize = $vmSnapShotSizeGB
							VM_Tools_Running = $vmToolRunStatus
							VM_Tools_Version_Status = $vmToolsVerStatus
							Backup = $Backup
		
				# Export the custom ojbect to a CSV														
						} | Export-Csv -Path C:\Master_VM_List_$csvdate.csv -NoTypeInformation -Append
		}

}

# Convert CSV to HTML for web viewing

$body = Import-CSV C:\Master_VM_List_$csvdate.csv
$title = "Date Generated: $csvdate --- Orginal files <YOUR CSV LOCATION>"
$head = $head + "<style>"
$head = $head + "BODY{background-color:white;}"
$head = $head + "TABLE{border-width: 1px;border-style: solid;border-color: black;border-collapse: collapse;}"
$head = $head + "TH{font-family: Tahoma;font-size: 12px;border-width: 1px;padding: 3px;border-style: solid;border-color: black;background-color:lightblue}"
$head = $head + "TD{font-family: Tahoma;font-size: 12px;border-width: 1px;padding: 3px;border-style: solid;border-color: black;background-color:lightgrey}"
$head = $head + "</style>"
$head = $head + "<font face='tahoma' color='#003399' size='2'><strong>$title</strong></font>"
$body | Convertto-html -Property VMname,Power_Status,Cluster,VMhost,SRM_Placeholder,vCenter,OS,RAM_Allocated,Guest_Memory_Usage,Guest_CPU_Usage,CPU_Allocated,Disk1,Disk1_Size_GB,Disk1_Available_GB,Disk2,Disk2_Size_GB,Disk2_Available_GB,Disk3,Disk3_Size_GB,Disk3_Available_GB,Disk4,Disk4_Size_GB,Disk4_Available_GB,Disk5,Disk5_Size_GB,Disk5_Available_GB,Disk5,Disk6_Size_GB,Disk6_Available_GB,Disk7,Disk7_Size_GB,Disk7_Available_GB,Port_Group,VM_Folder,IP_Address,DNS_Name,VM_Hardware_Version,EVC_Mode,VM_Path,Snapshot,SnapshotTime,SnapshotSize,VM_Tools_Running,VM_Tools_Version_Status,Backup -head $head -title $title | Out-File c:\inetpub\wwwroot\Master_VM_List.html
