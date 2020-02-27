// RLTItemsAddForm_Methods.prg
// Created by    : JJV-PC
// Creation Date : 2/12/2020 12:35:09 PM
// Created for   : 
// WorkStation   : DESKTOP-8HPCFRC


USING System
USING System.Collections.Generic
USING System.Data
USING System.Data.Common
USING System.Linq
USING System.Text
USING DevExpress.XtraGrid.Views.Grid
USING DevExpress.XtraGrid.Columns
USING DevExpress.XtraGrid.Views.Base

PUBLIC PARTIAL CLASS RLTItemsAddForm INHERIT System.Windows.Forms.Form
	PRIVATE oParent AS ItemsForm
	PRIVATE cItemUID AS STRING
	
	PRIVATE METHOD InitGridView AS VOID
		SELF:GridViewItems:OptionsView:ShowGroupPanel := FALSE
		SELF:GridViewItems:OptionsBehavior:AllowIncrementalSearch := TRUE
		SELF:GridViewItems:OptionsPrint:PrintDetails := TRUE
		SELF:GridViewItems:OptionsSelection:MultiSelect := TRUE
		SELF:GridViewItems:OptionsView:ColumnAutoWidth := TRUE
		SELF:GridViewItems:OptionsView:ShowFilterPanel := TRUE
		SELF:GridViewItems:OptionsView:ShowFilterPanelMode := ShowFilterPanelMode:Default
		SELF:CreateGridItems_Columns()
		RETURN
		
	PRIVATE METHOD CreateGridItems_Columns() AS VOID

		SELF:GridItems:DataSource := NULL
		SELF:GridViewItems:Columns:Clear()

		LOCAL oColumn AS GridColumn
		LOCAL nVisible:=0, nAbsIndex:=0 AS INT
		
		oColumn := oMainForm:CreateDXColumn("REPORT_UID", "REPORT_UID",FALSE, DevExpress.Data.UnboundColumnType.String, nAbsIndex++, nVisible++, 70, SELF:GridViewItems)
		oColumn:Visible:=FALSE
		oColumn := oMainForm:CreateDXColumn("Report Name", "ReportName",FALSE, DevExpress.Data.UnboundColumnType.String, nAbsIndex++, nVisible++, 70, SELF:GridViewItems)
		oColumn := oMainForm:CreateDXColumn("ITEM_UID", "ITEM_UID",FALSE, DevExpress.Data.UnboundColumnType.String, nAbsIndex++, nVisible++, 70, SELF:GridViewItems)
		oColumn:Visible:=FALSE
		oColumn := oMainForm:CreateDXColumn("Item No", "ItemNo",FALSE, DevExpress.Data.UnboundColumnType.String, nAbsIndex++, nVisible++, 70, SELF:GridViewItems)
		oColumn := oMainForm:CreateDXColumn("Item Name", "ItemName",FALSE, DevExpress.Data.UnboundColumnType.String, nAbsIndex++, nVisible++, 70, SELF:GridViewItems)

		RETURN
		

	PRIVATE METHOD GetItems() AS VOID
		VAR cStatement := "select "+;
							"a.REPORT_UID, a.ReportName, b.ITEM_UID, b.ItemNo, b.ItemName "+;
							"FROM [FMReportTypes] a "+;
							"JOIN [FMReportItems] b ON a.REPORT_UID=b.REPORT_UID "+;
							"WHERE  "+;
							"a.ReportBaseNum > 0 "+;
							i"and b.ITEM_UID not IN (SELECT Item2UID FROM [FMRelatedData] WHERE Item1UID={cItemUID}) "+;
							i"and a.REPORT_UID not IN (SELECT REPORT_UID FROM [FMReportItems] WHERE ITEM_UID={cItemUID}) "+;
							i"and a.ReportType=(select top 1 b.ReportType from [FMReportItems] a join [FMReportTypes] b on a.REPORT_UID=b.REPORT_UID where a.ITEM_UID={cItemUID}) " +;
							"order by ReportName, ItemNo "
		VAR DTRItems := oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement)
		
		oSoftway:CreatePK(DTRItems, "ITEM_UID")
		
		GridItems:DataSource := DTRItems
		
		RETURN
		
	PRIVATE METHOD Save() AS VOID
		TRY
			VAR iIndexes := GridViewItems:GetSelectedRows():ToList()
			
			IF iIndexes:Count:Equals(0)
				RETURN
			ENDIF
			
			LOCAL oRow AS DataRowView
			LOCAL cRelItemUID AS STRING
			VAR cStatement := "Insert into [FMRelatedData]([Item1UID], [Item2UID]) values "
			var listValues := List<STRING>{}
			
			FOREACH i AS INT IN iIndexes
				oRow := (DataRowView)SELF:GridViewItems:GetRow(i)
				cRelItemUID := oRow:Item["ITEM_UID"]:ToString()
				listValues:Add(i"({cItemUID}, {cRelItemUID})")
			NEXT
			cStatement := cStatement + string.Join(",", listValues)
			
			IF oSoftway:Exec(oMainForm:oGFH, oMainForm:oConn, cStatement, Dictionary<STRING, object>{}, FALSE) < 1
				errorbox("Failed to save related items!", "")
				RETURN
			ENDIF	
			
		CATCH ex AS Exception
		END TRY
		
		RETURN
		
END CLASS
