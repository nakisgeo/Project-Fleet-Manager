FleetManager.EXE versions:
--------------------------
1.0.0.01:	10/04/14: (Build 302)
	Starting Econ Development

1.0.0.02:	27/04/14: (Build 302)
	AutoUpdate:
	- Check for updates
	ItemsForm:
	- New button PreviewForm to show the Item changes immediately
	- Specify mandatory fields
	- Calculated fields

1.0.0.03:	30/04/14: (Build 302)
	ItemsForm:
	- Rename ItemNo and apply change into CalculatedField formulas
	VesselsForm:
	- New column: PropellerPitch added
	The Slip Item is calculated using the formula: 100 * ((RPM * 60 * PropellerPitch / 1852) - GPSSpeed) / (RPM * 60 * PropellerPitch / 1852)
	ItemCategories:
	- Drag-Drop Category to change the Sort order

1.0.0.04:	04/04/14: (Build 302)
	Create the new Tables:
	- FMDataPackages <PACKAGE_UID, VESSEL_UNIQUEID, REPORT_UID, DateTimeGMT, GmtDiff, Latitude, N_OR_S, Longitude, W_OR_E, MSG_UNIQUEID, Memo>
	- FMData			 <PACKAGE_UID, ITEM_UID, Data>

1.0.0.05:	06/04/14: (Build 302)
	Add consecutive numbers to PreviewForm
	ItemForm:
	- Validate numeric Items using Min, Max values

1.0.0.06:	11/04/14: (Build 302)
	ItemForm:
	- Re-number	ItemID: apply changes to BodyText

1.0.0.07:	14/04/14: (Build 302)
	Show Report Form:
	- Show Report Items in Report Form

1.0.0.08:	20/04/14: (Build 302)
	Show Report Form:
	- Show GmtDiff as well as DateTimeGMT correctly	

1.0.0.09:	08/09/14: (Build 302)
	Excel Report:
	- Excel Report Items

1.0.0.10:	02/10/14: (Build 302)
	Voyages added:
	- All required Voyage Tables (Econ Tables) will be created if not exists
	Bing Maps:
	- Apart the main Map (ontaining all checked Vessels), the button 'Show voyage routing on new Map' added
	Custom Reports:
	- New Function (Sum) added
	Individual license:
	- If FleetManager.license exists into the startup path the program use this license else it asks the RemoteObjectServer

1.0.0.11:	08/10/14: (Build 302)
	Vessel panel moved above the Reports panel
	Communicator Editor:
	- Hyperlink Subject -> Locate FleetManager Report
	Export data to Vessel:
	- Shared XML folder, Lock opened XML
	- LogDir: Position of previous Reports created
	- Allow to set the LogDir to a network folder
	- If LogDir is not specified the program will create a LogDir under the program's path
	- If LogDir is specified the program will act as multi-user by locking the currently displayed Report

1.0.0.12:	06/11/14: (Build 302)
	Support for ComboBox control

1.0.0.13:	11/11/14: (Build 302)
	Bing Maps:
	- Show the Lat/Lon as the mouse moves over the Map
	Table: FMDataPackages, Index: FMDataPackagesReport:
	- Remove the UniqueIndex property from Database Index


1.1.0.01: 19/11/14: (Build 303) - .NET 4
	Vulcan 3.0.303f: New DLLs:
	- VulcanRT.DLL
	- VulcanRTFuncs.DLL
	New EconFleet Table:
	- Group the Vessels by Fleet
	- Remove the Vessel's VesselName prefix (VslCode)

1.1.0.02: 30/01/15: (Build 303) - .NET 4
	- Many UI Changes


1.1.0.03: 12/02/16: (Build 404) - .NET 4
	- AutoFit Columns on Excel

1.1.0.04: 11/10/16: (Build 404) - .NET 4
	- Export to Excel For Report
	- BlobData Database Creation


1.1.0.05: 23/10/16: (Build 404) - .NET 4

	- Ability to Print Empty Report from "Report Items" window -> "Export To Excel" Option

	- Ability to add Data from Excel report 
		When Creating a new report there is a new "Load From Excel" option.
		This option will load the data from excel file after validating the 
		report type, then close the form, and add it to the Reports 'tree'

	- Ability to Cancel the creation of a new form
		When Creating a new report a cancel button is present

	- When a form is exported to Excel labels can not be changed
	using validation.

	- When a form is exported to Excel dates are validated so they correspond
	to Date Format.

1.1.0.06: 23/10/16: (Build 404) - .NET 4

	- Fix Issue with Files more than 1GB on Select Query

1.2.0.01: 31/06/17:

	- New Loading Method load tabs when opened by user

1.2.0.02: 03/07/17:

	- Edit Comments from Results
	- Show report from Comments
	- Fix the Date of the report if imported from Excel 

1.2.0.03: 18/07/17:

	- Edit Comments from Results : User Right set
	- Show report from Comments : Focus on the Report
	- Locate finding from Results
	- On cancel do not load the whole form again
	- Bug Fix : Comments were not shown on  Certificates

1.2.0.04: 24/08/17:

	- If user has no right to "Edit Reports", he can not access "Reports", "Report Items" menu items.
	- Fixed : When Duplicating an Item it always comes as mandatory
	- Fixed : PerRole report fixed for specific vessels and only for submitted reports
	- Fixed : Free questions issue on results.

1.2.0.05: 26/10/17:
	- Added : Print Table function 
	- Fixed : "No data" print out when no data is applicable on export 


1.2.0.06: 17/11/17:
	- Added : Coloring based on combobox values
	- Added : Revision Log on Report changes. Edit-Add-Delete Logs possible.
	- Added : New property on Items in order to Expand on columns 
	- Added : New Form to display Approval History on office forms

1.2.0.07: 08/12/17:
	- Added : New Report Findings per Category per Vessel
	- Added : New Report Findings per Category per Sup/ent

1.2.1.01: 18/01/18
	- Changed : only Softway user is used for logon
	- Changed : DevExpress to 16.2.12 version

1.2.1.02: 20/03/18
	- Added : Numeric Validation When Exporting Templates
	- Added : Added Version on excel printing of office reports/templates
	- Added : Rigth Click on Findings-Details Grid to Export to Excel File
	- Added : Now the user is able to select multiple rows (categories) in order to see all findings 
			  of the selected rows on the Findings-Details Grid
	- Added : New Columng "Category" to Findings-Details Grid


1.2.1.05: 06/02/19
	- Changed VoyageNo to Double
	- Changed Ordering on the Voyages tree list 

1.2.1.06: 30/03/19
	- If Combobox Items start from "NotStrict:" then user can add
	  a value and not choose from the list.
	- Fixed the export of xml version in order to be displayed on Vessel's title.

1.2.1.07: 18/04/19
	- MRV Report Finalized

1.2.1.08: 07.06.19
	- Added : Check/Unchek all items when exporting to excel

Mode:
- Use Common Items in Reports
- Show all Items
- CheckedList for Reports

Other Reports:
- Rename ItemNo when Description starts with "_Item"


TODO: Check Creation of Database and the UserGroups tables and transfer data