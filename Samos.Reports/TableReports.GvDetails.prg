// TablesReports.prg
// TableReports.prg
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
#USING System.Reflection
#Using System.Diagnostics
#USING System.Web.Script.Serialization
#using DevExpress.XtraEditors.Repository
#using DevExpress.XtraGrid.Views.Grid
#using DevExpress.XtraGrid.Views.Grid.ViewInfo
#using DevExpress.Utils
#using DevExpress.Utils.Menu
#using System

PARTIAL CLASS TableReportsSelectionForm INHERIT System.Windows.Forms.Form

PRIVATE METHOD gvDetailsMouseDown( sender AS System.Object, e AS System.Windows.Forms.MouseEventArgs ) AS System.Void
       IF e:Button == MouseButtons.Right
                LOCAL view := (GridView)sender AS GridView
                LOCAL hitInfo := view:CalcHitInfo(e:Location) AS GridHitInfo
                IF hitInfo:InRow
                    view:FocusedColumn := hitInfo:Column
                    view:FocusedRowHandle := hitInfo:RowHandle
                    self:contexMenuDetails:Show(view:GridControl,Point{e:X,e:Y})
                ENDIF
       ENDIF 
RETURN

PRIVATE METHOD ShowMenuToolStripMenuItemClick( sender AS system.Object,e AS EventArgs ) AS system.void
		LOCAL drDetails := (DataRow)gvDetails:GetFocusedDataRow() AS DataRow
        LOCAL cPACKAGE_UID := drDetails["PACKAGE_UID"]:ToString() AS STRING
		oMyMainForm:locateReport(cPACKAGE_UID)
		oMyMainForm:Focus()
		oMyMainForm:BringToFront()
RETURN

PRIVATE METHOD LocateFinding() as Void

	LOCAL drDetails := (DataRow)gvDetails:GetFocusedDataRow() AS DataRow
    LOCAL cPACKAGE_UID := drDetails["PACKAGE_UID"]:ToString() AS STRING
    LOCAL cCommentsUID := drDetails["CommentsUID"]:ToString() AS STRING
	
	oMyMainForm:locateReport(cPACKAGE_UID)
	oMyMainForm:Focus()
	oMyMainForm:BringToFront()
	Application.DoEvents()
	oMyMainForm:myReportTabForm:locateControlByNameAndUID("TextBoxMultiline",cCommentsUID)
				
RETURN

PRIVATE METHOD editResultsToolStripMenuItemClick( sender AS System.Object, e AS System.EventArgs ) AS System.Void
	LOCAL oRow  AS system.data.datarow 
	oRow := oMainForm:returnUserSetting(oUser:USER_UNIQUEID) 
				
	IF oRow == NULL
		MessageBox.Show("No Users rights set.","Error.")
	ENDIF
	IF oRow["CanEditReportResults"]:ToString():Trim() == "True"	

		SELF:gvDetails:OptionsBehavior:ReadOnly := FALSE
		SELF:gvDetails:OptionsBehavior:Editable := TRUE
		SELF:gvDetails:Columns["Vessel"]:OptionsColumn:ReadOnly := TRUE 
		SELF:gvDetails:Columns["Date"]:OptionsColumn:ReadOnly := TRUE 
		SELF:gvDetails:Columns["HeldBy"]:OptionsColumn:ReadOnly := TRUE 
		SELF:gvDetails:Columns["Question"]:OptionsColumn:ReadOnly := TRUE 
        SELF:gvDetails:Columns["CommentsUID"]:OptionsColumn:ReadOnly := TRUE
        SELF:gvDetails:Columns["CA"]:OptionsColumn:ReadOnly := TRUE

        SELF:gvDetails:Columns["Comments"]:OptionsColumn:AllowEdit := TRUE
		SELF:gvDetails:Columns["PACKAGE_UID"]:OptionsColumn:ReadOnly := FALSE 
	ELSE
		MessageBox.Show("You can not edit the Report results.","Not permitted.")
	ENDIF

RETURN


PRIVATE METHOD gvDetailsCellValueChanged( sender AS System.Object, e AS DevExpress.XtraGrid.Views.Base.CellValueChangedEventArgs ) AS System.Void
	Local cStatement, cPACKAGE_UID, cItem_UID, cField, cValue, cReplace, cPrev as string
	LOCAL charSpl1 := (char)169 AS Char
	LOCAL charSpl2 := (char)168 AS Char
	LOCAL cMemo AS STRING
	LOCAL iFind, iFindEnd as int
	
	LOCAL oRow AS DataRowView
	oRow:=(DataRowView)SELF:gvDetails:GetRow(e:RowHandle)

	cPACKAGE_UID := oRow:Item["PACKAGE_UID"]:ToString()
	cItem_UID := oRow:Item["CommentsUID"]:ToString()
	
	cStatement:=" SELECT Memo FROM FMDataPackages"+oMainForm:cNoLockTerm+;
				" WHERE PACKAGE_UID="+cPACKAGE_UID
	cMemo := oSoftway:RecordExists(oMainForm:oGFH, oMainForm:oConn, cStatement, "Memo")
			
	iFind := cMemo:IndexOf(cItem_UID+charSpl2:ToString())
	iFindEnd := cMemo:IndexOf(charSpl1,iFind)
	cPrev := cMemo:Substring(iFind,iFindEnd-iFind)
	
	cField := e:Column:FieldName
	cValue := e:Value:ToString():Trim()

	cReplace := cItem_UID+charSpl2:ToString()+cValue

	cMemo := cMemo:Replace(cPrev,cReplace)

	cMemo := "'"+oSoftway:ConvertWildCards(cMemo, FALSE)+"'"
	
	LOCAL cTable := "FMDataPackages" AS STRING

	// Validate cValue
	
	// Update Fleet or EconFleet
	cStatement:=" UPDATE "+cTable+" SET"+;
				" Memo ="+cMemo+;
				" WHERE PACKAGE_UID="+cPACKAGE_UID
	IF ! oSoftway:AdoCommand(oMainForm:oGFH, oMainForm:oConn, cStatement)
		RETURN
	ENDIF

	
RETURN

END CLASS