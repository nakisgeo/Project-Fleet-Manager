// FStructureProvider.prg
// Created by    : JJV-PC
// Creation Date : 1/28/2020 12:28:58 PM
// Created for   : 
// WorkStation   : DESKTOP-8HPCFRC
//Folder Structure

USING System
USING System.Collections.Generic
USING System.Data
USING System.Text
USING System.Linq
USING Newtonsoft.Json

CLASS FStructureController
	PRIVATE _Text AS STRING
	PRIVATE _Delimeter := Environment.NewLine AS STRING
	PRIVATE _TextType AS TextType
	PRIVATE _FolderStructure := List<Folder>{} AS List<Folder>
	PUBLIC IsValidStructure AS LOGIC
	PUBLIC SettingUID AS STRING
	PUBLIC VoyageFolderName AS STRING
	PUBLIC AutoCreateStructure AS INT
	PUBLIC ReportFolderColor AS INT
	
	
	CONSTRUCTOR()
		LOCAL cStatement AS STRING
		LOCAL dtSettings AS DataTable
	
		cStatement:="SELECT TOP 1 Setting_UNIQUEID, FolderStructureJSON, VoyageFolderName, AutoCreateStructure, ReportFolderColor  FROM FMTrueGlobalSettings"
		dtSettings := oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement)
		IF dtSettings:Rows:Count > 0
			ChangeText(dtSettings:Rows[0]["FolderStructureJSON"]:ToString(), TextType.Json)
			SettingUID := dtSettings:Rows[0]["Setting_UNIQUEID"]:ToString()
			VoyageFolderName := dtSettings:Rows[0]["VoyageFolderName"]:ToString()
			AutoCreateStructure := Convert.ToInt32(dtSettings:Rows[0]["AutoCreateStructure"]:ToString())
			ReportFolderColor := Convert.ToInt32(dtSettings:Rows[0]["ReportFolderColor"]:ToString())
		ELSE
			ChangeText("", TextType.Json)
			SettingUID := ""
		ENDIF
		
		RETURN
		
	
	CONSTRUCTOR(cText AS STRING, cTextType AS TextType, cDelimeter AS STRING)
		_Text := cText
		_TextType := cTextType
		_Delimeter := cDelimeter
		GetFolderStructure()
		RETURN
		
	PRIVATE METHOD GetFolderStructure() AS VOID
		IF string.IsNullOrEmpty(_Text)
			RETURN
		ENDIF
		TRY
			SWITCH _TextType
			CASE TextType.Json
				_FolderStructure := JsonConvert.DeserializeObject<List<Folder>>(_Text)		
			CASE TextType.PlainText
				_FolderStructure := (FROM a IN _Text:Split(_Delimeter:ToCharArray()) WHERE !string.IsNullOrEmpty(a) SELECT Folder{1, a:Trim()}):ToList()
			OTHERWISE
				THROW Exception{i"{_TextType} is not an accepted TextType"}
			END SWITCH
			IsValidStructure := TRUE
		CATCH
			IsValidStructure := FALSE
		END TRY
		
		RETURN

	PUBLIC METHOD ChangeText(cText AS STRING, cTextType AS TextType) AS VOID
		_Text := cText
		_TextType := cTextType
		_FolderStructure := List<Folder>{}
		GetFolderStructure()
		RETURN
	

	PUBLIC METHOD ToJSON() AS STRING
		LOCAL JsonFormat := JsonSerializerSettings{} AS JsonSerializerSettings
        JsonFormat:NullValueHandling := NullValueHandling.Ignore
		RETURN JsonConvert.SerializeObject(_FolderStructure, JsonFormat)
		
	PUBLIC METHOD ToFormatedJSON AS STRING
		RETURN JsonConvert.SerializeObject(_FolderStructure, Formatting.Indented)
	
	PUBLIC METHOD ToPlainText() AS STRING
		RETURN string.Join(_Delimeter, _FolderStructure:Select({o => o:Name}))
		
	PUBLIC METHOD FolderIdExistsByVoyageId(voyageId AS STRING) AS LOGIC		
		LOCAL folderExists:=FALSE AS LOGIC
		LOCAL cStatement AS STRING
		LOCAL oDTResult AS DataTable

		cStatement:="select 1 FolderExists " +;
					"from EconVoyages a " +;
					"join FOLDERS b on a.FM_FolderId=b.FOLDER_UNIQUEID " +;
					"where VOYAGE_UID=" + voyageId
		oDTResult:=oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement)
		IF oDTResult:Rows:Count > 0
			folderExists:=TRUE
		ENDIF
		RETURN folderExists
	PUBLIC STATIC METHOD FolderIdExists(folderId AS STRING) AS LOGIC
		IF Convert.ToInt32(folderId) == 0
			RETURN TRUE
		ENDIF
		
		LOCAL folderExists:=FALSE AS LOGIC
		LOCAL cStatement AS STRING
		LOCAL oDTResult AS DataTable

		cStatement:="select FolderName from FOLDERS where SystemFolder=0 and FOLDER_UNIQUEID=" + folderId
		oDTResult:=oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement)
		IF oDTResult:Rows:Count > 0
			folderExists:=TRUE
		ENDIF
	RETURN folderExists

	PUBLIC METHOD CreateVoyageFolder(vesselId AS STRING, voyageId AS STRING, routeNames AS List<STRING>) AS STRING
		
		IF FolderIdExistsByVoyageId(voyageId)
			IF QuestionBox("Voyage folder already exists. Do you want to override it?", "Voyage folder") <> System.Windows.Forms.DialogResult.Yes
				wb("Operation canceled by user!", "Cancellation")
				RETURN string.Empty
			ENDIF
		ENDIF
		
		#region Validation
		LOCAL cStatement := i"select top 1 * from [SupVessels] where [VESSEL_UNIQUEID]={vesselId}" AS STRING
		LOCAL oDTVesselDetails := oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement) AS DataTable
		
		IF oDTVesselDetails:Rows:Count:Equals(0)
			ErrorBox(i"Unable to find vessel with id '{vesselId}'!")
			RETURN ""
		ENDIF
		
		LOCAL vesselFolderId := Convert.ToInt32(oDTVesselDetails:Rows[0]["FM_FolderId"]:ToString()) AS INT
		
		IF Convert.ToInt32(vesselFolderId):Equals(0)
			ErrorBox("Vessel's Folder Id is '0'." + CRLF + "No folder for voyage created!")
			RETURN ""
		ENDIF
		
		cStatement := i"select top 1 * from [FOLDERS] where [FOLDER_UNIQUEID]={vesselFolderId}"
		LOCAL oDTFolderDetails := oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement) AS DataTable
		
		IF oDTFolderDetails:Rows:Count:Equals(0)
			ErrorBox(i"Unable to find folder with id '{vesselFolderId}'!")
			RETURN ""
		ENDIF
		#endregion
		
		LOCAL cFolderName := CreateFolderName(voyageId, VoyageFolderName, routeNames) AS STRING
		
		#region Local Variables
		LOCAL cParentFolder := oDTFolderDetails:Rows[0]["FOLDER_UNIQUEID"].ToString() AS STRING
		LOCAL cCreatorUser := oDTFolderDetails:Rows[0]["CreatorUser"].ToString() AS STRING
		LOCAL cTreeLevelInt := Convert.ToInt32(oDTFolderDetails:Rows[0]["TreeLevel"].ToString()) + 1 AS INT
		LOCAL cTreeLevel := cTreeLevelInt:ToString():PadLeft(3, '0') AS STRING
		LOCAL cUserRights := oDTFolderDetails:Rows[0]["UserRights"].ToString() AS STRING
		LOCAL cHideFolder := oDTFolderDetails:Rows[0]["HideFolder"].ToString() AS STRING
		LOCAL cFavorite := oDTFolderDetails:Rows[0]["Favorite"].ToString() AS STRING
		LOCAL cViewDays := oDTFolderDetails:Rows[0]["ViewDays"].ToString() AS STRING
		LOCAL cFolderIcon := oDTFolderDetails:Rows[0]["FolderIcon"].ToString() AS STRING
		#endregion
		
		cStatement := i"Insert into [FOLDERS]({GetFolderColumns()}) values " +;
		              i"(0, @cFolderName, @cParentFolder, @cCreatorUser, @cTreeLevel, " +;
					  i"@cUserRights, @cHideFolder, @cFavorite, @cViewDays, @cFolderIcon, 0)"		
		
		VAR dict := Dictionary<STRING, OBJECT>{}
		dict:Add("cFolderName", cFolderName)
		dict:Add("cParentFolder", cParentFolder)
		dict:Add("cCreatorUser", cCreatorUser)
		dict:Add("cTreeLevel", cTreeLevel)
		dict:Add("cUserRights", cUserRights)
		dict:Add("cHideFolder", cHideFolder)
		dict:Add("cFavorite", cFavorite)
		dict:Add("cViewDays", cViewDays)
		dict:Add("cFolderIcon", cFolderIcon)
		
		LOCAL cUID := oSoftway:Exec(oMainForm:oGFH, oMainForm:oConn, cStatement, dict, TRUE):ToString() AS STRING
		IF !oSoftway:IsValidIdentity(cUID)
			ErrorBox("Voyage's folder creation failed!", "")
			RETURN ""
		ENDIF
			
//		oSoftway:AdoCommand(oMainForm:oGFH, oMainForm:oConn, cStatement)
//		LOCAL cFolderUID := oSoftway:GetLastInsertedIdentityFromScope(oMainForm:oGFH, oMainForm:oConn, "FOLDERS", "FOLDER_UNIQUEID") AS STRING
		//update voyage.fm_folderid
		IF !string.IsNullOrEmpty(cUID)
			cStatement := i"Update [EconVoyages] set [FM_FolderId]={cUID} where [VOYAGE_UID]={voyageId}"
			oSoftway:AdoCommand(oMainForm:oGFH, oMainForm:oConn, cStatement)
		ENDIF
		
		CreateFolderSystem(vesselId, cUID, cCreatorUser, cTreeLevelInt, cUserRights, cHideFolder, cFavorite, cViewDays, cFolderIcon)
		
		RETURN cUID
	PRIVATE METHOD CreateFolderName(voyageId AS STRING, folderName AS STRING, routeNames AS List<STRING>) AS STRING
		LOCAL cStatement AS STRING
		cStatement := i"Select a.[Description], a.[VoyageNo], a.[Charterers], a.[Broker], b.[Port] PortFrom, c.[Port] PortTo" +;
					  i" from [EconVoyages] a " +;
					  i" left join VEPorts b on a.[PortFrom_UID]=b.[PORT_UID] " +;
					  i" left join VEPorts c on a.[PortTo_UID]=c.[PORT_UID] " +;
					  i" where [VOYAGE_UID]={voyageId}"
        LOCAL oDTVoyage := oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement) AS DataTable
		
		IF string.IsNullOrEmpty(VoyageFolderName)
			RETURN oDTVoyage:Rows[0]["Description"].ToString()
		ENDIF
		
		folderName := folderName:Replace("$VoyageDescription", oDTVoyage:Rows[0]["Description"].ToString())
		folderName := folderName:Replace("$VoyageNo", oDTVoyage:Rows[0]["VoyageNo"].ToString())
		folderName := folderName:Replace("$Charterers", oDTVoyage:Rows[0]["Charterers"].ToString())
		folderName := folderName:Replace("$Broker", oDTVoyage:Rows[0]["Broker"].ToString())
		folderName := folderName:Replace("$PortFrom", oDTVoyage:Rows[0]["PortFrom"].ToString())
		folderName := folderName:Replace("$PortTo", oDTVoyage:Rows[0]["PortTo"].ToString())
		
		IF routeNames == NULL_OBJECT
			routeNames := List<STRING>{}
		ENDIF
		
		VAR nList := List<STRING>{}
		nList:Add(oDTVoyage:Rows[0]["PortFrom"].ToString())
		routeNames:ForEach({i => nList:Add(i)})
		nList:Add(oDTVoyage:Rows[0]["PortTo"].ToString())
		VAR concact := string.Join(" - ", nList)
		folderName := folderName:Replace("$ConcatRoutes", concact)
		
		RETURN folderName
		
	PRIVATE METHOD GetFolderColumns() AS STRING
		LOCAL columnsList := List<STRING>{} AS List<STRING>
		columnsList:Add("[SystemFolder]")
		columnsList:Add("[FolderName]")
		columnsList:Add("[ParentFolder]")
		columnsList:Add("[CreatorUser]")
		columnsList:Add("[TreeLevel]")
		columnsList:Add("[UserRights]")
		columnsList:Add("[HideFolder]")
		columnsList:Add("[Favorite]")
		columnsList:Add("[ViewDays]")
		columnsList:Add("[FolderIcon]")
		columnsList:Add("[FolderTextColor]")
		
		LOCAL columns := string.Join(",", columnsList) AS STRING
		RETURN columns
		
	
	PUBLIC METHOD CreateFolderSystem(vesselId AS STRING, voyageFolderId AS STRING, cCreatorUser AS STRING, cParentTreeLevel AS INT, ;
	cUserRights AS STRING, cHideFolder AS STRING, cFavorite AS STRING, cViewDays AS STRING, cFolderIcon AS STRING) AS VOID
		TRY
			LOCAL cStatement, cFolderUID, cFolderName, cTreeLevel, cParentFolder AS STRING
			LOCAL cTreeLevelInt, tempId AS INT			
			
			LOCAL allfolders := _FolderStructure:SelectMany({o => o:GetMeAndMyChildren()}):ToList() AS List<Folder> //select many γιατί είναι List<List<Folder>>
			
			LOCAL maxDeepth := 1 AS INT
			LOCAL deepth := 1 AS INT
			
			IF allfolders == NULL_OBJECT
				allfolders := List<Folder>{}
			ENDIF
			IF allFolders:Count > 0
				maxDeepth := allfolders:Max({o => o:Level})
			ENDIF			
			
			cStatement := i"select distinct(isnull(NULLIF([FolderName], ''), ReportName)) ReportName from [FMReportTypesVessel] a join [FMReportTypes] b on a.REPORT_UID=b.REPORT_UID where b.ReportBaseNum > 0 and a.VESSEL_UNIQUEID={vesselId}"
			LOCAL oDTReports := oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement) AS DataTable
			FOREACH row AS DataRow IN oDTReports:Rows
				allfolders:Add(Folder{1, row["ReportName"].ToString()})
			NEXT
			
			
			WHILE deepth <= maxDeepth
				FOREACH cFolder AS Folder IN allfolders:Where({o => o:Level:Equals(deepth)})
					cFolderName := cFolder:Name
					IF string.IsNullOrEmpty(cFolder:GetParentId())
						cParentFolder := voyageFolderId
					ELSE
						cParentFolder := cFolder:GetParentId()
					ENDIF
					cTreeLevelInt := cParentTreeLevel + cFolder:Level
					cTreeLevel := cTreeLevelInt:ToString():PadLeft(3, '0')
					
//					VAR dict := Dictionary<STRING, OBJECT>{}
//					dict:Add("cFolderName", cFolderName)
//					cStatement := i"select top 1 [ReportColor] from [FMReportTypes] where isnull(NULLIF([FolderName], ''), ReportName)=@cFolderName"
//					LOCAL oDTReports := oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement) AS DataTable
					
					cStatement := i"Insert into [FOLDERS]({GetFolderColumns()}) values " +;
								  i"(0, @cFolderName, @cParentFolder, @cCreatorUser, @cTreeLevel, " +;
								  i"@cUserRights, @cHideFolder, @cFavorite, @cViewDays, @cFolderIcon, @cFolderTextColor)"		
									
					VAR dict := Dictionary<STRING, OBJECT>{}
					dict:Add("cFolderName", cFolderName)
					dict:Add("cParentFolder", cParentFolder)
					dict:Add("cCreatorUser", cCreatorUser)
					dict:Add("cTreeLevel", cTreeLevel)
					dict:Add("cUserRights", cUserRights)
					dict:Add("cHideFolder", cHideFolder)
					dict:Add("cFavorite", cFavorite)
					dict:Add("cViewDays", cViewDays)
					dict:Add("cFolderIcon", cFolderIcon)
					
					IF oDTReports:AsEnumerable():Where({i => i:FIELD<STRING>("ReportName") == cFolderName}):ToList():Count > 0
						dict:Add("cFolderTextColor", ReportFolderColor)
					ELSE
						dict:Add("cFolderTextColor", 0)
					ENDIF
					
					
					cFolderUID := oSoftway:Exec(oMainForm:oGFH, oMainForm:oConn, cStatement, dict, TRUE):ToString()
					
//					oSoftway:AdoCommand(oMainForm:oGFH, oMainForm:oConn, cStatement)
//					cFolderUID := oSoftway:GetLastInsertedIdentityFromScope(oMainForm:oGFH, oMainForm:oConn, "FOLDERS", "FOLDER_UNIQUEID")
					
					cFolder:SetMyId(cFolderUID)
					tempId++
				NEXT
				deepth++
			END
		CATCH ex AS Exception
			ErrorBox("The 'Creating Folder Structure' operation stopped!" + CRLF + ex:Message)
		END TRY
		
		RETURN
	
END CLASS



ENUM TextType AS BYTE
	MEMBER Json
	MEMBER PlainText
END ENUM