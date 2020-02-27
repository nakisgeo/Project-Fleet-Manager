// PortsForm_Methods.prg
// Created by    : JJV-PC
// Creation Date : 1/24/2020 1:04:13 PM
// Created for   : 
// WorkStation   : DESKTOP-8HPCFRC


USING System
USING System.Collections
USING System.Collections.Generic
USING System.Data
USING System.Data.Common
USING System.Drawing
USING System.Text
USING DevExpress.XtraGrid.Views.Grid
USING DevExpress.XtraGrid.Columns
USING DevExpress.Utils
USING DevExpress.XtraEditors.Repository
USING DevExpress.XtraPrinting
USING DevExpress.XtraPrintingLinks


PUBLIC PARTIAL CLASS PortsForm INHERIT DevExpress.XtraEditors.XtraForm
	PRIVATE oDTPorts AS DataTable
	//PRIVATE lSuspendNotification AS LOGIC
	PRIVATE oEditColumn AS GridColumn
	PRIVATE oEditRow AS DataRowView
	
	
METHOD PortsForm_OnLoad() AS VOID
	oSoftway:ReadFormSettings_DevExpress(SELF, NULL, oMainForm:alForms, oMainForm:alData)
	
	SELF:GridViewPorts:OptionsBehavior:AllowIncrementalSearch := TRUE
	SELF:GridViewPorts:OptionsPrint:PrintDetails := TRUE
	SELF:GridViewPorts:OptionsSelection:EnableAppearanceFocusedCell := FALSE
	SELF:GridViewPorts:OptionsSelection:MultiSelect := FALSE
	SELF:GridViewPorts:OptionsView:ColumnAutoWidth := FALSE
	
	SELF:CreateGridPorts_Columns()
	
	
	
	SELF:CreateGridPorts()
	
	RETURN
	
	METHOD CreateGridPorts_Columns() AS VOID
		LOCAL oColumn AS GridColumn
		LOCAL nVisible := 0, nAbsIndex := 0 AS INT
		
		oColumn:=oMainForm:CreateDXColumn("ID", "PORT_UID", FALSE, ;
											DevExpress.Data.UnboundColumnType.Boolean, ;
											nAbsIndex++, nVisible++, 50, SELF:GridViewPorts)
		oColumn:Visible := FALSE
		
		oColumn:AppearanceCell:TextOptions:HAlignment := DevExpress.Utils.HorzAlignment.Center
		oColumn:=oMainForm:CreateDXColumn("Port Name", "Port", FALSE, ;
											DevExpress.Data.UnboundColumnType.String, ;
											nAbsIndex++, nVisible++, 200, SELF:GridViewPorts)
//		oColumn:AppearanceCell:TextOptions:HAlignment := DevExpress.Utils.HorzAlignment.Center
		oColumn:AppearanceHeader:TextOptions:HAlignment := DevExpress.Utils.HorzAlignment.Center
		oColumn:=oMainForm:CreateDXColumn("Country", "Country", FALSE, ;
											DevExpress.Data.UnboundColumnType.String, ;
											nAbsIndex++, nVisible++, 50, SELF:GridViewPorts)
		oColumn:AppearanceCell:TextOptions:HAlignment := DevExpress.Utils.HorzAlignment.Center
		oColumn:AppearanceHeader:TextOptions:HAlignment := DevExpress.Utils.HorzAlignment.Center
		oColumn:=oMainForm:CreateDXColumn("Summer GMT", "SummerGMT_DIFF", FALSE, ;
											DevExpress.Data.UnboundColumnType.String, ;
											nAbsIndex++, nVisible++, 80, SELF:GridViewPorts)
		oColumn:AppearanceCell:TextOptions:HAlignment := DevExpress.Utils.HorzAlignment.Center
		oColumn:AppearanceHeader:TextOptions:HAlignment := DevExpress.Utils.HorzAlignment.Center
		oColumn:=oMainForm:CreateDXColumn("Winter GMT", "WinterGMT_DIFF", FALSE, ;
											DevExpress.Data.UnboundColumnType.String, ;
											nAbsIndex++, nVisible++, 80, SELF:GridViewPorts)
		oColumn:AppearanceCell:TextOptions:HAlignment := DevExpress.Utils.HorzAlignment.Center
		oColumn:AppearanceHeader:TextOptions:HAlignment := DevExpress.Utils.HorzAlignment.Center
		oColumn:=oMainForm:CreateDXColumn("Latitude", "Latitude", FALSE, ;
											DevExpress.Data.UnboundColumnType.String, ;
											nAbsIndex++, nVisible++, 80, SELF:GridViewPorts)
		oColumn:AppearanceCell:TextOptions:HAlignment := DevExpress.Utils.HorzAlignment.Center
		oColumn:AppearanceHeader:TextOptions:HAlignment := DevExpress.Utils.HorzAlignment.Center
		oColumn:=oMainForm:CreateDXColumn("Longtitude", "Longtitude", FALSE, ;
											DevExpress.Data.UnboundColumnType.String, ;
											nAbsIndex++, nVisible++, 80, SELF:GridViewPorts)
		oColumn:AppearanceCell:TextOptions:HAlignment := DevExpress.Utils.HorzAlignment.Center
		oColumn:AppearanceHeader:TextOptions:HAlignment := DevExpress.Utils.HorzAlignment.Center
		
		oColumn:=oMainForm:CreateDXColumn("EUPort", "EUPort", FALSE, ;
											DevExpress.Data.UnboundColumnType.String, ;
											nAbsIndex++, nVisible++, 50, SELF:GridViewPorts)
		oColumn:AppearanceCell:TextOptions:HAlignment := DevExpress.Utils.HorzAlignment.Center
		oColumn:AppearanceHeader:TextOptions:HAlignment := DevExpress.Utils.HorzAlignment.Center
		
		RETURN
	
	
	METHOD CreateGridPorts AS VOID
		LOCAL cStatement AS STRING
		cStatement := "SELECT [PORT_UID],[Port],[Country],[POSITION_UNIQUEID],[SummerGMT_DIFF] " +;
						  ",[WinterGMT_DIFF],[Synonyms],[COUNTRY_UNIQUEID],[Latitude] " +;
						  ",[Longtitude],[MaxDraft],[MAINPORT_UID],[EUPort] " +;
					  "FROM [VEPorts] " +;
					  "ORDER BY [Port] "
		SELF:oDTPorts := oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement)
		SELF:oDTPorts:TableName := "VEPorts"
		
		oSoftway:CreatePK(SELF:oDTPorts, "PORT_UID")
		
		SELF:GridPorts:DataSource := SELF:oDTPorts
		RETURN
		
	METHOD Ports_Refresh() AS VOID
		LOCAL cUID AS STRING

		LOCAL oRow AS DataRowView
		oRow := (DataRowView)SELF:GridViewPorts:GetRow(SELF:GridViewPorts:FocusedRowHandle)

		IF oRow <> NULL
			cUID := oRow:Item["PORT_UID"]:ToString()
		ENDIF

		SELF:CreateGridPorts()

		IF oRow <> NULL
			LOCAL col AS DevExpress.XtraGrid.Columns.GridColumn
			LOCAL nFocusedHandle AS INT

			col := SELF:GridViewPorts:Columns["PORT_UID"]
			nFocusedHandle := SELF:GridViewPorts:LocateByValue(0, col, Convert.ToInt32(cUID))
			IF nFocusedHandle == DevExpress.XtraGrid.GridControl.InvalidRowHandle
				RETURN
			ENDIF

			SELF:GridViewPorts:ClearSelection()
			SELF:GridViewPorts:FocusedRowHandle := nFocusedHandle
			SELF:GridViewPorts:SelectRow(nFocusedHandle)
		ENDIF
	
		RETURN


METHOD CustomUnboundColumnData_Ports(e AS DevExpress.XtraGrid.Views.Base.CustomColumnDataEventArgs) AS VOID
// Provides data for the UnboundColumns
//	IF ! e:IsGetData
//		RETURN
//	ENDIF
//
//	LOCAL oRow AS DataRow
//
//	DO CASE
//		CASE e:Column:FieldName == "uFleet"
//			oRow := SELF:oDTPorts:Rows[e:ListSourceRowIndex]
//			// Remove the leading 'u' from FieldName
//			//cField := oRow:Item[e:Column:FieldName:Substring(1)]:ToString()
//			e:Value := oRow["Fleet"]:ToString()
//	ENDCASE
RETURN


METHOD SetEditModeOff_Common(oGridView AS GridView) AS VOID
	TRY
		IF oGridView:FocusedColumn <> NULL .AND. oGridView:FocusedColumn:UnboundType == DevExpress.Data.UnboundColumnType.Boolean
			IF ! oGridView:OptionsSelection:EnableAppearanceFocusedCell
				oGridView:OptionsSelection:EnableAppearanceFocusedCell := TRUE
			ENDIF
			oGridView:FocusedColumn:OptionsColumn:AllowEdit := TRUE
			BREAK
		ENDIF

		IF ! oGridView:OptionsSelection:EnableAppearanceFocusedCell
			BREAK
		ENDIF

		oGridView:OptionsSelection:EnableAppearanceFocusedCell := FALSE

		IF SELF:oEditColumn <> NULL
			SELF:oEditColumn:OptionsColumn:AllowEdit := FALSE
			SELF:oEditColumn := NULL
		ENDIF

		IF SELF:oEditRow <> NULL
			SELF:oEditRow := NULL
		ENDIF
	CATCH
	END TRY

	RETURN


METHOD BeforeLeaveRow_Ports(e AS DevExpress.XtraGrid.Views.Base.RowAllowEventArgs ) AS VOID
	LOCAL oRow AS DataRowView
	oRow := (DataRowView)SELF:GridViewPorts:GetRow(e:RowHandle)
	IF oRow == NULL
		RETURN
	ENDIF
	SELF:SetEditModeOff_Common(SELF:GridViewPorts)
RETURN

METHOD Ports_Add() AS VOID
	IF QuestionBox("Do you want to create a new Port ?", ;
					"Add new") <> System.Windows.Forms.DialogResult.Yes
		RETURN
	ENDIF

	LOCAL cStatement, cUID  AS STRING

	cStatement := "INSERT INTO VEPorts ([Port]) VALUES ('_New_Port_')"
	IF ! oSoftway:AdoCommand(oMainForm:oGFH, oMainForm:oConn, cStatement)
		SELF:Ports_Refresh()
		RETURN
	ENDIF
	cUID:=oSoftway:GetLastInsertedIdentityFromScope(oMainForm:oGFH, oMainForm:oConn, "VEPorts", "PORT_UID")

	SELF:Ports_Refresh()

	LOCAL nFocusedHandle AS INT
	nFocusedHandle := SELF:GridViewPorts:LocateByValue(0, SELF:GridViewPorts:Columns["PORT_UID"], Convert.ToInt32(cUID))
	IF nFocusedHandle == DevExpress.XtraGrid.GridControl.InvalidRowHandle
		RETURN
	ENDIF
	SELF:GridViewPorts:ClearSelection()
	SELF:GridViewPorts:FocusedRowHandle := nFocusedHandle
	SELF:GridViewPorts:SelectRow(nFocusedHandle)
	RETURN
METHOD Ports_Edit(oRow AS DataRowView, oColumn AS GridColumn) AS VOID
	IF oRow == NULL
		RETURN
	ENDIF

	LOCAL cField := oColumn:FieldName AS STRING

	SELF:oEditColumn := oColumn
	SELF:oEditRow := oRow

	SELF:oEditColumn:OptionsColumn:AllowEdit := TRUE
    SELF:GridViewPorts:OptionsSelection:EnableAppearanceFocusedCell := TRUE
	SELF:GridViewPorts:ShowEditor()
	RETURN
	
	
METHOD Ports_Delete() AS VOID
	LOCAL oRow AS DataRowView	
	LOCAL nRowHandle := SELF:GridViewPorts:FocusedRowHandle AS INT
	oRow := (DataRowView)SELF:GridViewPorts:GetRow(nRowHandle)
	LOCAL portId := oRow:Item["PORT_UID"]:ToString() AS STRING
	IF oRow == NULL
		RETURN
	ENDIF

	IF QuestionBox("Do you want to Delete the current Port:" + CRLF + CRLF +;
					oRow:Item["Port"]:ToString()+" ?", ;
					"Delete") <> System.Windows.Forms.DialogResult.Yes
		RETURN
	ENDIF

	LOCAL cStatement, cExistedValue AS STRING
	cStatement:= "SELECT [PortFrom_UID] as PortId FROM [EconVoyages] where [PortFrom_UID] = " + portId + ;
				 " UNION all " +;
				 " SELECT [PortTo_UID] AS PortId FROM [EconVoyages] WHERE [PortTo_UID] = " + portId
	cStatement := oSoftway:SelectTop(cStatement)
	cExistedValue := oSoftway:RecordExists(oMainForm:oGFH, oMainForm:oConn, cStatement, "PortId")

	IF cExistedValue <> ""
		ErrorBox("The current Port already Exists in Data", ;
					"Delete aborded")
		RETURN
	ENDIF

	cStatement:="DELETE FROM VEPorts"+;
				" WHERE PORT_UID=" + portId
	IF ! oSoftway:AdoCommand(oMainForm:oGFH, oMainForm:oConn, cStatement)
		ErrorBox("Cannot Delete current row", "Deletion aborted")
		RETURN
	ENDIF
  
	IF SELF:GridViewPorts:DataRowCount == 1
		SELF:oDTPorts:Clear()
		RETURN
	ENDIF
	
	IF nRowHandle == 0
		SELF:GridViewPorts:MoveNext()
	ELSE
		SELF:GridViewPorts:MovePrev()
	ENDIF
	
	LOCAL oDataRow AS DataRow
	oDataRow := SELF:oDTPorts:Rows:Find(oRow:Item["PORT_UID"]:ToString())
	IF oDataRow <> NULL
		SELF:oDTPorts:Rows:Remove(oDataRow)
	ENDIF
	RETURN
		
METHOD Ports_Save(e AS DevExpress.XtraGrid.Views.Base.CellValueChangedEventArgs) AS VOID
	LOCAL cStatement, cUID, cField, cValue, cReplace, cDuplicate AS STRING
	LOCAL oRow AS DataRowView
	oRow:=(DataRowView)SELF:GridViewPorts:GetRow(e:RowHandle)
	cUID := oRow:Item["PORT_UID"]:ToString()
	cField := e:Column:FieldName
	cValue := e:Value:ToString():Trim()
	LOCAL cTable := "VEPorts" AS STRING
	
	DO CASE
	CASE InListExact(cField, "Port") && cValue:Length > 128
		ErrorBox("The field '" + cField + "' must contain up to 128 characters", "Editing aborted")
		SELF:Ports_Refresh()
		RETURN
	CASE InListExact(cField, "Port") && string.IsNullOrEmpty(cValue)
		ErrorBox("The field '" + cField + "' can't be empty", "Editing aborted")
		SELF:Ports_Refresh()
		RETURN
	CASE InListExact(cField, "Country") && cValue:Length > 3
		ErrorBox("The field '" + cField + "' must contain up to 3 characters", "Editing aborted")
		SELF:Ports_Refresh()
		RETURN
	CASE InListExact(cField, "Latitude") && cValue:Length > 20
		ErrorBox("The field '" + cField + "' must contain up to 20 characters", "Editing aborted")
		SELF:Ports_Refresh()
		RETURN
	CASE InListExact(cField, "Longtitude") && cValue:Length > 20
		ErrorBox("The field '" + cField + "' must contain up to 20 characters", "Editing aborted")
		SELF:Ports_Refresh()
		RETURN
	END CASE
	
	IF cField:Equals("Port") || cField:Equals("Country") || cField:Equals("Latitude") || cField:Equals("Longtitude")
		cReplace := "'" + oSoftway:ConvertWildCards(cValue, FALSE) + "'"
	ELSEIF cField:Equals("SummerGMT_DIFF") || cField:Equals("WinterGMT_DIFF")
		cReplace := cValue:Replace(',', '.')
	ENDIF
	
	cStatement:="UPDATE " + cTable + " SET" +;
				" " + cField + "=" + cReplace +;
				" WHERE PORT_UID=" + cUID
	
	IF ! oSoftway:AdoCommand(oMainForm:oGFH, oMainForm:oConn, cStatement)
		SELF:Ports_Refresh()
		RETURN
	ENDIF
	
	LOCAL oDataRow:=SELF:oDTPorts:Rows:Find(oRow:Item["PORT_UID"]:ToString()) AS DataRow
	IF oDataRow == NULL
		ErrorBox("Cannot access current row", "Not changed")
		RETURN
	ENDIF
	oDataRow:Item[cField] := cValue
	SELF:oDTPorts:AcceptChanges()
	SELF:GridViewPorts:Invalidate()
	RETURN

METHOD Ports_Print AS VOID
	// Check whether the XtraGrid control can be previewed.
	IF ! SELF:GridPorts:IsPrintingAvailable
		ErrorBox("The 'DevExpress.XtraPrinting' Library is not found")
		RETURN
	ENDIF

	// Opens the Preview window.
	//Self:GridCompanies:ShowPrintPreview()

	// Create a PrintingSystem component.
	LOCAL oPS := PrintingSystem{} AS DevExpress.XtraPrinting.PrintingSystem
	// Create a link that will print a control.
	LOCAL oLink := PrintableComponentLink{oPS} AS DevExpress.XtraPrinting.PrintableComponentLink
	// Specify the control to be printed.
	oLink:Component := SELF:GridPorts
	// Set the paper format.
	oLink:PaperKind := System.Drawing.Printing.PaperKind.A4
	oLink:Landscape:=TRUE
	// Subscribe to the CreateReportHeaderArea event used to generate the report header.
	oLink:CreateReportHeaderArea += CreateAreaEventHandler{SELF, @PrintableComponentLinkPorts_CreateReportHeaderArea()}
	// Generate the report.
	oLink:CreateDocument()
	// Hide Send via eMail TooBar Button
	oPS:SetCommandVisibility(PrintingSystemCommand.SendFile, CommandVisibility.None)
	// Show the report.
	oLink:ShowPreview()
	RETURN
	
METHOD PrintableComponentLinkPorts_CreateReportHeaderArea(sender AS OBJECT, e AS CreateAreaEventArgs) AS VOID
LOCAL cReportHeader := "Ports - Printed on "+Datetime.Now:ToString(ccDateFormat)+", "+Datetime.Now:ToString("HH:mm:ss")+" - User: "+oUser:UserID AS STRING

	e:Graph:StringFormat := BrickStringFormat{StringAlignment.Center}
	e:Graph:Font := Font{"Tahoma", 14, FontStyle.Bold}

	LOCAL rec := RectangleF{0, 0, e:Graph:ClientPageSize:Width, 50} AS RectangleF
	e:Graph:DrawString(cReportHeader, Color.Black, rec, DevExpress.XtraPrinting.BorderSide.None)
RETURN

END CLASS