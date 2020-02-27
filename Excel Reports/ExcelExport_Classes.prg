// ExcelExport_Classes.prg
// Created by    : JJV-PC
// Creation Date : 2/12/2020 3:48:28 PM
// Created for   : 
// WorkStation   : DESKTOP-8HPCFRC


USING OfficeOpenXml
USING OfficeOpenXml.Style
USING System
USING System.Collections
USING System.Collections.Generic
USING System.Data
USING System.Drawing
USING System.Data.Common
USING System.IO
USING System.Linq
USING System.Text

PUBLIC CLASS ExcelGenerator
	
	PRIVATE cStatement AS STRING
	
	PRIVATE cVesselUID	AS STRING
	PRIVATE cReportUID	AS STRING
	PRIVATE cDateFrom	AS DateTime
	PRIVATE cDateTo		AS DateTime
	PRIVATE oDTFMItems	AS DataTable
	PRIVATE dIUidOrd	AS Dictionary<STRING, INT>
	
	PUBLIC CONSTRUCTOR(vesselUID AS STRING, reportUID AS STRING, dateFrom AS DateTime, dateTo AS DateTime, dTFMItems AS DataTable, dUidsOrd AS Dictionary<STRING, INT>)
		cVesselUID	:= vesselUID
		cReportUID	:= reportUID
		cDateFrom	:= dateFrom
		cDateTo		:= dateTo
		oDTFMItems	:= dTFMItems
		dIUidOrd	:= dUidsOrd
		RETURN
	
	PUBLIC METHOD ExportFile(filePath AS STRING, includeRelatives AS LOGIC) AS VOID
		LOCAL xp AS ExcelPackage
		
		BEGIN USING xp := ExcelPackage{} 
		TRY
		LOCAL oRelationships := GetRelationships() AS List<ItemRelationship>
		LOCAL oColumns := GetColumnsInfo() AS List<Column>
		LOCAL whereClause AS STRING
		IF oRelationships:Count:Equals(0) || !includeRelatives
			whereClause := i" AND a.REPORT_UID={cReportUID} "
		ENDIF
		
		LOCAL oFMData := GetPackagesAndData(whereClause) AS List<PackageAndData>
		LOCAL oFMDataDistinctUID := oFMData:Select({i => i:PACKAGE_UID}):Distinct():ToList() AS List<INT>
		LOCAL oFilteredFMData AS List<PackageAndData>
		
		VAR ws := xp:Workbook:Worksheets:Add("Reports")
		
		LOCAL cColNum := 2 AS INT
		LOCAL cRowNum := 2 AS INT
		
		IF oColumns:ANY({i => i:OrderNum < 999})
			oColumns := oColumns:OrderBy({i => i:OrderNum}):ToList() //:ThenBy({i => i:ItemCaption}):ToList()
		ENDIF
		
		FOREACH oColumn AS Column IN oColumns
			SetColumnCaption(ws, cColNum, oColumn:ItemCaption)
			
			FOREACH cPUID AS INT IN oFMDataDistinctUID
				oFilteredFMData := oFMData:Where({i => i:PACKAGE_UID:Equals(cPUID)}):ToList()
				
				IF oFilteredFMData:ANY({i => i:ITEM_UID:Equals(oColumn:ITEM_UID)}) //same report type
					SetReportName(ws, cRowNum, oFilteredFMData:First({i => i:ITEM_UID:Equals(oColumn:ITEM_UID)}))
					SetCellValue(ws, cRowNum, cColNum, oColumn:ItemType, oFilteredFMData:First({i => i:ITEM_UID:Equals(oColumn:ITEM_UID)}):Data)
				ELSE //related report
					VAR related := SeparateRelated(oRelationships, oFilteredFMData, oColumn:ITEM_UID)
					IF related:Count > 0
						SetReportName(ws, cRowNum, related:First())
						SetCellValue(ws,cRowNum, cColNum, oColumn:ItemType, related:First():Data)
					ENDIF
				ENDIF
				
				SetCellFormat(oColumn, ws, cRowNum, cColNum)
				
				cRowNum++
			NEXT
			
			cColNum++
			cRowNum := 2
		NEXT
		
		DeleteEmptyRows(ws)		
		
		
		ws:Cells[ws:Dimension:Address]:AutoFitColumns()
		
		ws:Cells[ws:Dimension:Address]:Style:Border:Top:Style := ExcelBorderStyle:Thin
		ws:Cells[ws:Dimension:Address]:Style:Border:Bottom:Style := ExcelBorderStyle:Thin
		ws:Cells[ws:Dimension:Address]:Style:Border:Left:Style := ExcelBorderStyle:Thin
		ws:Cells[ws:Dimension:Address]:Style:Border:Right:Style := ExcelBorderStyle:Thin

		xp:SaveAs(FileInfo{filePath})
		
		CATCH ex AS Exception
			ErrorBox(ex:Message, "")
		END TRY
		END USING
		
		RETURN
		
	PRIVATE METHOD SetColumnCaption(ws AS ExcelWorksheet, cColNum AS INT, cName AS STRING) AS VOID
		ws:Cells[1, cColNum]:Value := cName
		ws:Cells[1, cColNum]:Style:Font:Bold := TRUE
		ws:Cells[1, cColNum]:Style:HorizontalAlignment := ExcelHorizontalAlignment:Center
		RETURN
		
	PRIVATE METHOD SetReportName(ws AS ExcelWorksheet, cRowNum AS INT, data AS PackageAndData) AS VOID
		IF ws:Cells[cRowNum, 1]:Value == NULL_OBJECT
			ws:Cells[cRowNum, 1]:Value := data:ReportName
			ws:Cells[cRowNum, 1]:Style:Font:Italic := TRUE
		ENDIF
		RETURN
		
	PRIVATE METHOD SetCellValue(ws AS ExcelWorksheet, cRowNum AS INT, cColNum AS INT, cItemType AS STRING, oData AS OBJECT) AS VOID
		TRY
			ws:Cells[cRowNum, cColNum]:Value := oData
					
			IF cItemType:Equals("D")
				ws:Cells[cRowNum, cColNum]:Value := Convert.ToDateTime(oData)
				ws:Cells[cRowNum, cColNum]:Style:Numberformat:Format := "dd-MM-yyyy HH:mm"
			ENDIF
			IF cItemType:Equals("N")
				ws:Cells[cRowNum, cColNum]:Value := IIF(string.IsNullOrEmpty(oData:ToString()), 0, Convert.ToDouble(oData))
				ws:Cells[cRowNum, cColNum]:Style:Numberformat:Format := "#,##0.00"
			ENDIF
		CATCH ex AS Exception
			ws:Cells[cRowNum, cColNum]:Value := oData
		END TRY
		
		RETURN
	
	PRIVATE METHOD SetCellFormat(oColumn AS Column, ws AS ExcelWorksheet, cRowNum AS INT, cColNum AS INT) AS VOID
		LOCAL oColor AS System.Drawing.Color
		oColor := oMainForm:AssignColor(oColumn:ColumnColor)
		IF oColor:Name != "ffffffff"
			ws:Cells[cRowNum, cColNum]:Style:Fill:PatternType := ExcelFillStyle:Solid
			ws:Cells[cRowNum, cColNum]:Style:Fill:BackgroundColor:SetColor(oColor)
			ws:Cells[cRowNum, cColNum]:Style:Font:Color:SetColor(Color:FromArgb(255 - oColor:R, 255 - oColor:G, 255 - oColor:B))
			
//			ws:Cells[cRowNum, cColNum]:Style:Border:Top:Style := ExcelBorderStyle:Thin
//			ws:Cells[cRowNum, cColNum]:Style:Border:Bottom:Style := ExcelBorderStyle:Thin
//			ws:Cells[cRowNum, cColNum]:Style:Border:Left:Style := ExcelBorderStyle:Thin
//			ws:Cells[cRowNum, cColNum]:Style:Border:Right:Style := ExcelBorderStyle:Thin
		ENDIF
		RETURN
		
		
	PRIVATE METHOD DeleteEmptyRows(ws AS ExcelWorksheet) AS VOID
		LOCAL lIsEmpty AS LOGIC
		LOCAL i, j AS INT
		FOR i := ws:Dimension:Start:Row TO ws:Dimension:END:Row
			lIsEmpty := TRUE
			FOR j := ws:Dimension:Start:Column TO ws:Dimension:END:Column
				IF ws:Cells[i, j]:Value != NULL_OBJECT
					lIsEmpty := FALSE
					ENDIF
			NEXT
			IF lIsEmpty
				ws:DeleteRow(i)
			ENDIF
		NEXT
		RETURN
	
	PRIVATE METHOD SeparateRelated(oRelationships AS List<ItemRelationship>, oFilteredFMData AS List<PackageAndData>, cItemUID AS INT) AS List<PackageAndData>
		RETURN (FROM a IN oRelationships ;
				JOIN b IN oFilteredFMData ON a:Item2UID EQUALS b:ITEM_UID ;
				WHERE a:Item1UID:Equals(cItemUID) ;
				SELECT b):ToList()
	
	PRIVATE METHOD GetColumnsInfo() AS List<Column>
		RETURN (FROM a IN oDTFMItems:AsEnumerable() SELECT Column{Convert.ToInt32(a["ITEM_UID"]:ToString()), Convert.ToInt32(a["ItemNO"]:ToString()), IIF(string.IsnullOrEmpty(a["ItemCaption"]:ToString()), a["ItemName"]:ToString(), a["ItemCaption"]:ToString()), a["ColumnColor"]:ToString(), a["ItemType"]:ToString(), dIUidOrd[a["ITEM_UID"]:ToString()]}):ToList()
		
	PRIVATE METHOD GetRelationships() AS List<ItemRelationship>
		cStatement := "SELECT a.* "+;
					  "FROM [FMRelatedData] a "+;
					  "JOIN [FMReportItems] b ON a.Item1UID=b.ITEM_UID "+;
					  i"WHERE b.REPORT_UID={cReportUID}"
		LOCAL oDTFMReldata := oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement) AS DataTable
		RETURN (FROM a IN oDTFMReldata:AsEnumerable() SELECT ItemRelationship{Convert.ToInt32(a["FMRD_UID"]:ToString()), Convert.ToInt32(a["Item1UID"]:ToString()), Convert.ToInt32(a["Item2UID"]:ToString())}):ToList()
		
	
	PRIVATE METHOD GetPackagesAndData(whereClause AS STRING) AS List<PackageAndData>
		
		cStatement := "SELECT a.[PACKAGE_UID] "+;
						  " ,a.[VESSEL_UNIQUEID] ,a.[REPORT_UID] ,a.[DateTimeGMT] ,b.[ReportName] ,c.[ITEM_UID] ,c.[Data] "+;
						" FROM [FMDataPackages] a "+;
						" JOIN [FMReportTypes] b ON a.REPORT_UID=b.REPORT_UID "+;
						" JOIN [FMData] c on a.PACKAGE_UID=c.PACKAGE_UID "+;
						" WHERE  "+;
						i" a.VESSEL_UNIQUEID={cVesselUID} "+;
						" and a.Visible=1 "+;
						" AND a.DateTimeGMT BETWEEN '"+cDateFrom:ToString("yyyy-MM-dd HH:mm")+"' AND '"+cDateTo:ToString("yyyy-MM-dd HH:mm")+"'"+;
						i" AND b.[ReportType]=(select [ReportType] from [FMReportTypes] where [REPORT_UID]={cReportUID}) " +;
						i" {whereClause} " +;
						" order BY [DateTimeGMT] "
		LOCAL oDTFMData := oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement) AS DataTable
		
		VAR packages := (FROM a IN oDTFMData:AsEnumerable() ;
						SELECT PackageAndData{Convert.ToInt32(a["PACKAGE_UID"]:ToString()), ;
											Convert.ToInt32(a["VESSEL_UNIQUEID"]:ToString()), ;
											Convert.ToInt32(a["REPORT_UID"]:ToString()), ;
											Convert.ToDateTime(a["DateTimeGMT"]:ToString()), ;
											a["ReportName"]:ToString(), ;
											Convert.ToInt32(a["ITEM_UID"]:ToString()), ;
											a["Data"]}):ToList()
															
		IF packages:Count:Equals(0)
			THROW Exception{"No Data found for the sepcified period"}
			RETURN NULL_OBJECT
		ENDIF
		
		RETURN packages
	
	
	
END CLASS

PUBLIC CLASS ItemRelationship
	PROPERTY FMRD_UID AS INT AUTO
	PROPERTY Item1UID AS INT AUTO
	PROPERTY Item2UID AS INT AUTO
		
	PUBLIC CONSTRUCTOR()
		RETURN
	PUBLIC CONSTRUCTOR(uid AS INT, i1uid AS INT, i2uid AS INT)
		FMRD_UID := uid
		Item1UID := i1uid
		Item2UID := i2uid
		RETURN
	PUBLIC METHOD ToString() AS STRING
		RETURN i"I1UID: {Item1UID} - I2UID: {Item2UID}"
		
END CLASS
	
PUBLIC CLASS PackageAndData
	PROPERTY PACKAGE_UID		AS INT AUTO
	PROPERTY VESSEL_UNIQUEID	AS INT AUTO
	PROPERTY REPORT_UID			AS INT AUTO
	PROPERTY DateTimeGMT		AS DateTime AUTO
	PROPERTY ReportName			AS STRING AUTO
	PROPERTY ITEM_UID			AS INT AUTO
	PROPERTY Data				AS OBJECT AUTO
		
	PUBLIC CONSTRUCTOR()
		RETURN
		
	PUBLIC CONSTRUCTOR(pUID AS INT, vUID AS INT, rUID AS INT, dtGMT AS DateTime, rName AS STRING, iUID AS INT, _data_ AS OBJECT)
		PACKAGE_UID		:= pUID
		VESSEL_UNIQUEID	:= vUID
		REPORT_UID		:= rUID
		DateTimeGMT		:= dtGMT
		ReportName		:= rName
		ITEM_UID		:= iUID
		Data			:= _data_
		RETURN
	PUBLIC METHOD ToString() AS STRING
		RETURN i"PUID: {PACKAGE_UID} - {ReportName} - IUID: {ITEM_UID}"
		
END CLASS

PUBLIC CLASS Column
	PROPERTY ITEM_UID AS INT AUTO
	PROPERTY ItemNO AS INT AUTO
	PROPERTY ItemCaption AS STRING AUTO
	PROPERTY ItemType AS STRING AUTO
	PROPERTY ColumnColor AS STRING AUTO
	PROPERTY relatedList AS List<STRING> AUTO
	PROPERTY OrderNum AS INT AUTO 
	
	CONSTRUCTOR()
		RETURN
	CONSTRUCTOR(uid AS INT, no AS INT, caption AS STRING, bkColor AS STRING, type AS STRING, ordNum AS INT)
		ITEM_UID	:= uid
		ItemNo		:= no
		ItemCaption := caption
		ItemType	:= type
		ColumnColor := bkColor
		OrderNum	:= ordNum
		RETURN
		
	PUBLIC METHOD ToString() AS STRING
		RETURN i"{ITEM_UID} :: {ItemCaption}"
	
	END CLASS
	
	

