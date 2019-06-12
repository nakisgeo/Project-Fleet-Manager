// MainForm_Methods.prg
#Using System.Data
#Using System.Data.Common
#Using System.Windows.Forms
#Using System.Drawing
#using System.Drawing.Printing
#Using System.IO
#Using System.Collections
#USING System.Threading
#USING System.Collections.Generic
#using System.ComponentModel

#Using DevExpress.XtraEditors
#using DevExpress.LookAndFeel
#Using DevExpress.XtraGrid.Views.Grid
#Using DevExpress.XtraGrid.Views.Base
#using DevExpress.XtraPrinting
#Using DevExpress.XtraPrintingLinks
#using DevExpress.XtraGrid.Columns
#using DevExpress.XtraTreeList
#using DevExpress.XtraTreeList.Nodes
#using DevExpress.XtraBars

PARTIAL CLASS MainForm INHERIT DevExpress.XtraEditors.XtraForm

	PRIVATE oMyTableReportsSelectionForm AS TableReportsSelectionForm

PUBLIC METHOD RestartTimerAndFormToNull() AS VOID
		myTimer:Tag := "1"
		myTimer:Start()
		oMyTableReportsSelectionForm := NULL
RETURN

 PRIVATE METHOD showReportSelectionForm(cReportUID := "" AS STRING, lPerRole := FALSE AS LOGIC) AS System.Void
			IF oMyTableReportsSelectionForm != NULL			
				oMyTableReportsSelectionForm:BringToFront()	
				RETURN			
			ENDIF

			myTimer:Stop()
			myTimer:Tag := "0"
			IF cReportUID==""
				cReportUID := SELF:LBCReports:SelectedValue:ToString()
			ENDIF
			//LOCAL cReportName := SELF:LBCReports:GetDisplayItemValue(SELF:LBCReports:SelectedIndex):ToString() AS STRING
			LOCAL cReportName := "" AS STRING
			/*IF cReportName:ToUpper():StartsWith("MODE")
				wb("You must select a specific report, current selection is: "+cReportName)
				RETURN
			ENDIF*/
			LOCAL cVesselUID := oMainForm:GetVesselUID AS STRING
			IF cVesselUID:StartsWith("Fleet") || cVesselUID =="0"
				cVesselUID := "0"
				//wb("Please select a Vessel")
				//RETURN
			ENDIF
			LOCAL cVesselName := "All" AS STRING
			LOCAL oSelectDatesSimpleForm := TableReportsSelectionForm{} AS TableReportsSelectionForm
			oSelectDatesSimpleForm:DateFrom:DateTime := Datetime.Today
			oSelectDatesSimpleForm:DateTo:DateTime := TimeZoneInfo.ConvertTime(Datetime.Now, TimeZoneInfo.Utc)
			//oSelectDatesSimpleForm:oItemsTable := oDTFMItems
			oSelectDatesSimpleForm:cMyReportUID := cReportUID
			oSelectDatesSimpleForm:cVesselUid := cVesselUID
			oSelectDatesSimpleForm:cTempDocDir := cTempDocDIr
			oSelectDatesSimpleForm:cVesselName := cVesselName
			oSelectDatesSimpleForm:lisSEReport := lPerRole
			oSelectDatesSimpleForm:oMyMainForm := SELF

			IF cReportUID=="21" // Wet
				IF lPerRole
					oSelectDatesSimpleForm:Text := "Per Role Report for Wet"
				ELSE
					oSelectDatesSimpleForm:Text := "Findings Report for Wet"
				ENDIF
			ELSEIF cReportUID=="18" // Dry
				IF lPerRole
					oSelectDatesSimpleForm:Text := "Per Role Report for Dry"
				ELSE
					oSelectDatesSimpleForm:Text := "Findings Report for Dry"
				ENDIF
			ENDIF

			oMyTableReportsSelectionForm := oSelectDatesSimpleForm
			oSelectDatesSimpleForm:Show()
			IF oSelectDatesSimpleForm:DialogResult <> DialogResult.OK
					myTimer:Tag := "1"
					myTimer:Start()
					RETURN
			ENDIF
RETURN




END CLASS
