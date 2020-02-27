// NewVoyageForm_Methods.prg
// Created by    : JJV-PC
// Creation Date : 1/22/2020 5:37:52 PM
// Created for   : 
// WorkStation   : DESKTOP-8HPCFRC


USING System
USING System.Collections.Generic
USING System.Text
USING System.Data
USING System.Data.Common
USING System.Windows.Forms
USING System.Data.Common
USING System.Linq

PUBLIC PARTIAL CLASS NewVoyageForm INHERIT System.Windows.Forms.Form
    
	#region Properties
    PRIVATE cVoyageUID AS STRING

    PRIVATE cVesselUID AS STRING
    PRIVATE cVesselName AS STRING
    PRIVATE cVesselFolderId AS STRING
    PRIVATE oControlList AS List<Control>
    PRIVATE cVoyageTypeId AS STRING
    PRIVATE oVoyageTypeList AS List<STRING>
    EXPORT oDTPorts AS DataTable	
	PRIVATE lIsSaved AS LOGIC
	
	PRIVATE cFromPortUID AS STRING
	PRIVATE cToPortUID AS STRING
	
	PRIVATE oParent AS Form
    #endregion
	
    #region Inits
    PRIVATE METHOD GetVesselName() AS VOID
        LOCAL cStatement := i"select [VesselName], [FM_FolderId] from VESSELS a join SupVessels b on a.[VESSEL_UNIQUEID]=b.[VESSEL_UNIQUEID] where a.[VESSEL_UNIQUEID]={cVesselUID}" AS STRING
        LOCAL oDTVesselName := oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement) AS DataTable
        cVesselName := oDTVesselName:Rows[0]["VesselName"]:ToString()
        cVesselFolderId := oDTVesselName:Rows[0]["FM_FolderId"]:ToString()
        RETURN
    
    
    PRIVATE METHOD InitControlList() AS VOID
        oControlList := List<Control>{}        
        oControlList:Add(descriptionTb)
        oControlList:Add(voyageNoTb)
        oControlList:Add(typeCb)
        
        oControlList:Add(fromPortCb)
        oControlList:Add(fromGmtTb)
        oControlList:Add(startDate)
        oControlList:Add(startGmtDate)
        
        oControlList:Add(toPortCb)
        oControlList:Add(toGmtTb)
        oControlList:Add(endDate)
        oControlList:Add(endGmtDate)
            
        endDate:CustomFormat := " "
        endGmtDate:CustomFormat := " "
		
        oControlList:Add(chartererTb)
		PortDestinationDG:Rows:Clear()
        RETURN
    PRIVATE METHOD InitDTPorts() AS VOID
        LOCAL cStatement := "Select [PORT_UID] as id, [Port] as name, [SummerGMT_DIFF] as sumGmt, [WinterGMT_DIFF] as wintGmt from [VEPorts]" AS STRING
        LOCAL oDTResult := oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement) AS DataTable
        oDTPorts := oDTResult
        RETURN
    PRIVATE METHOD InitTypeCB() AS VOID
        oVoyageTypeList := List<STRING>{}        
        oVoyageTypeList:Add("Voyage")
        oVoyageTypeList:Add("Time Charter")
        oVoyageTypeList:Add("Idle")
        
        typeCb:DataSource := oVoyageTypeList
        typeCb:SelectedIndex := 0
        cVoyageTypeId := "0"
        RETURN
    PRIVATE METHOD InitPortCBs() AS VOID
        fromPortCb:DataSource := SELF:oDTPorts:Copy()
        fromPortCb:DisplayMember := "name"
        fromPortCb:ValueMember := "id"
        SelectPortFrom("")
        
        toPortCb:DataSource := SELF:oDTPorts:Copy()
        toPortCb:DisplayMember := "name"
        toPortCb:ValueMember := "id"
        SelectPortTo("")
        RETURN
		
	PRIVATE METHOD InitDataFromDB() AS VOID
		LOCAL cStatement := "SELECT a.[Description] Description, a.[VoyageNo], a.[Type], a.PortFrom_UID fPUID, a.PortTo_UID tPUID, a.Charterers Charterers, " +;
                            "isnull(convert(varchar(25), a.StartDate, 120), '') StartDate, isnull(convert(varchar(25), a.StartDateGMT, 120), '') StartDateGMT, "+;
							"isnull(convert(varchar(25), a.EndDate, 120), '') EndDate, isnull(convert(varchar(25), a.EndDateGMT, 120), '') EndDateGMT " +;
                            "FROM [EconVoyages] a " +;
                            "left JOIN VEPorts fPort ON a.PortFrom_UID=fPort.PORT_UID " +;
                            "left JOIN VEPorts tPort ON a.PortTo_UID=tPort.PORT_UID " +;
                            i"WHERE VOYAGE_UID={cVoyageUID}" AS STRING
        LOCAL oDTResult := oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement) AS DataTable
		descriptionTb:Text := oDTResult:Rows[0]["Description"]:ToString()
		voyageNoTb:Text := oDTResult:Rows[0]["VoyageNo"]:ToString()
		SELF:SelectPortFrom(oDTResult:Rows[0]["fPUID"]:ToString())
		SELF:SelectPortTo(oDTResult:Rows[0]["tPUID"]:ToString())
		chartererTb:Text := oDTResult:Rows[0]["Charterers"]:ToString()
		cVoyageTypeId := oDTResult:Rows[0]["Type"]:ToString()
		DO CASE
        CASE cVoyageTypeId == "0"
	        typeCb:SelectedIndex := 0
			typeCb:SelectedItem := "VOYAGE"
        CASE cVoyageTypeId == "1"
	        typeCb:SelectedIndex := 1
			typeCb:SelectedItem := "TIME CHARTER"
        CASE cVoyageTypeId == "2"
	        typeCb:SelectedIndex := 2
			typeCb:SelectedItem := "IDLE"
        OTHERWISE
	        typeCb:SelectedIndex := 0
			typeCb:SelectedItem := "VOYAGE"
		ENDCASE
		
		IF !STRING.IsNullOrEmpty(oDTResult:Rows[0]["StartDate"]:ToString())
			startDate:Value := Convert.ToDateTime(oDTResult:Rows[0]["StartDate"]:ToString())
			startDate:CustomFormat := "dd/MM/yyyy HH:mm:ss"
		ELSE
			startDate:CustomFormat := " "
		ENDIF
		IF !STRING.IsNullOrEmpty(oDTResult:Rows[0]["StartDateGMT"]:ToString())
			startGmtDate:Value := Convert.ToDateTime(oDTResult:Rows[0]["StartDateGMT"]:ToString())
			startGmtDate:CustomFormat := "dd/MM/yyyy HH:mm:ss"
		ELSE
			startGmtDate:CustomFormat := " "
		ENDIF
		IF !STRING.IsNullOrEmpty(oDTResult:Rows[0]["EndDate"]:ToString())
			endDate:Value := Convert.ToDateTime(oDTResult:Rows[0]["EndDate"]:ToString())
			endDate:CustomFormat := "dd/MM/yyyy HH:mm:ss"
		ELSE
			endDate:CustomFormat := " "
		ENDIF
		IF !STRING.IsNullOrEmpty(oDTResult:Rows[0]["EndDateGMT"]:ToString())
			endGmtDate:Value := Convert.ToDateTime(oDTResult:Rows[0]["EndDateGMT"]:ToString())
			endGmtDate:CustomFormat := "dd/MM/yyyy HH:mm:ss"
		ELSE
			endGmtDate:CustomFormat := " "
		ENDIF
		RETURN
	#endregion
	
	PRIVATE METHOD SelectPortFrom(id AS STRING) AS VOID
		IF string.IsNullOrEmpty(id:Trim())
			fromPortCb:Text := ""
			fromPortCb:SelectedValue := -1
			fromPortCb:SelectedIndex := -1
			fromGmtTb:Text := "0"
			RETURN
		ENDIF
		fromPortCb:SelectedValue := id
		ValidatePorts()
		RETURN
	PRIVATE METHOD SelectPortTo(id AS STRING) AS VOID 
		IF string.IsNullOrEmpty(id:Trim())
			toPortCb:Text := ""
			toPortCb:SelectedValue := -1
			toPortCb:SelectedIndex := -1
			toGmtTb:Text := "0"
			RETURN
		ENDIF
		toPortCb:SelectedValue := id
		ValidatePorts()
		RETURN
	PRIVATE METHOD SetVoyageNo() AS VOID
        VAR cStatement := "Select isnull(Max(CAST(VoyageNo AS Decimal)), 0) MaxNo from [EconVoyages] where [VESSEL_UNIQUEID]=" + cVesselUID
        LOCAL oDTMaxVoNo := oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement) AS DataTable
        VAR oVoyageNo := Math.Round(Convert.ToDouble((oDTMaxVoNo:Rows[0]["MaxNo"]:ToString()))) + 1
		voyageNoTb:Text := oVoyageNo:ToString()
		RETURN	
    PRIVATE METHOD SetVoyageTypeId() AS VOID
        LOCAL cVoyageTypeName := typeCb:Text AS STRING
        
        IF !oVoyageTypeList:Contains(cVoyageTypeName)
            typeCb:SelectedIndex := 0
            RETURN
        ENDIF
        
        DO CASE
		CASE cVoyageTypeName:Trim():ToUpper() == "VOYAGE"
			cVoyageTypeId := "0"
		CASE cVoyageTypeName:Trim():ToUpper() == "TIME CHARTER"
			cVoyageTypeId := "1"
		CASE cVoyageTypeName:Trim():ToUpper() == "IDLE"
			cVoyageTypeId := "2"
		OTHERWISE
			cVoyageTypeId := "0"
		ENDCASE
        RETURN
    PRIVATE METHOD SetFromGmtDate() AS VOID
        TRY
        IF string.IsNullOrEmpty(fromGmtTb:Text:Trim())
            fromGmtTb:Text := "0"
        ENDIF
        LOCAL oGmt := Double.Parse(fromGmtTb:Text) AS Double
		
		LOCAL NewVoyageGMTStart := startDate:Value:AddHours(oGmt) AS DateTime
		
		IF string.IsNullOrEmpty(cVoyageUID)
			LOCAL cStatement := i"select top 1 isnull(convert(varchar(25), EndDateGMT, 120), '') EndDate from [EconVoyages] where [VESSEL_UNIQUEID]={cVesselUID} order by voyage_uid desc" AS STRING
			LOCAL oDTResult := oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement) AS DataTable
			LOCAL LastVoyageGMTEnd := Convert.ToDateTime(oDTResult:Rows[0]["EndDate"]:ToString()) AS DateTime
			LOCAL LastVoyageGMTEndSTR := oDTResult:Rows[0]["EndDate"]:ToString() AS STRING
			LOCAL result := DateTime.Compare(LastVoyageGMTEnd, NewVoyageGMTStart) AS INT
			IF result > 0
				ErrorBox(i"Last voyage's End Date (GMT) is on {LastVoyageGMTEndSTR}{Environment.NewLine}New voyage Start Date (GMT) can't be sooner than last's voyage End Date (GMT) !")
				startDate:Value := LastVoyageGMTEnd:AddMinutes(1)
//				startDate:CustomFormat := " "
				startGmtDate:Value := startDate:Value:AddHours(oGmt)
//				startGmtDate:CustomFormat := " "
				RETURN
			ENDIF
		ENDIF
		
        
		startGmtDate:Value := NewVoyageGMTStart
		CATCH ex AS EXCEPTION
			
        END TRY
        
        RETURN
    PRIVATE METHOD SetToGmtDate() AS VOID
        TRY
        IF string.IsNullOrEmpty(toGmtTb:Text:Trim())
            toGmtTb:Text := "0"
        ENDIF
        LOCAL oGmt := Double.Parse(toGmtTb:Text) AS Double
        endGmtDate:Value := endDate:Value:AddHours(oGmt)
        CATCH ex AS EXCEPTION
        END TRY
        
        RETURN
	PRIVATE METHOD SetCharterers() AS VOID
		LOCAL oSelect_Company := Select_Company{} AS Select_Company
		LOCAL oResult := oSelect_Company:ShowDialog() AS DialogResult
		IF oResult == DialogResult.OK
			chartererTb:Text := oSelect_Company:cReturnName
		ENDIF
		RETURN
    PRIVATE METHOD ClearData() AS VOID
        FOREACH ctrl AS Control IN oControlList 
            ctrl:Text := NULL
		NEXT
		InitTypeCB()
		endDate:CustomFormat := " "
        endGmtDate:CustomFormat := " "
		PortDestinationDG:Rows:Clear()
        RETURN

    
    
    PRIVATE METHOD SetGmts() AS VOID
        TRY
            LOCAL cStatement AS STRING
            VAR oPortSearch := List<DataRow>{}
            
            IF !string.IsNullOrEmpty(fromPortCb:Text)
                oPortSearch := oDTPorts:AsEnumerable():Where({i => i:FIELD<STRING>("name") == fromPortCb:Text}):ToList()
                IF oPortSearch:Count > 0
                    fromGmtTb:Text := IIF(oSoftway:IsSummerTimeGMT(startDate:Value), oPortSearch:First():FIELD<Decimal>("sumGmt"):ToString(), oPortSearch:First():FIELD<Decimal>("wintGmt"):ToString())
                ENDIF
			ENDIF
			
			IF !string.IsNullOrEmpty(toPortCb:Text)
                oPortSearch := oDTPorts:AsEnumerable():Where({i => i:FIELD<STRING>("name") == toPortCb:Text}):ToList()
                IF oPortSearch:Count > 0
                    toGmtTb:Text := IIF(oSoftway:IsSummerTimeGMT(startDate:Value), oPortSearch:First():FIELD<Decimal>("sumGmt"):ToString(), oPortSearch:First():FIELD<Decimal>("wintGmt"):ToString())
                ENDIF
			ENDIF
			
            SetFromGmtDate()
            SetToGmtDate()
        CATCH ex AS Exception
            
        END TRY
        RETURN
        
        
    PRIVATE METHOD SaveData() AS VOID
        TRY
            ValidateBeforeSave()
            
            LOCAL cStatement AS STRING
			
			IF fromPortCb:SelectedIndex >= 0
				cFromPortUID := fromPortCb:SelectedValue:ToString()
			ENDIF
            LOCAL oPortFrom_UID := Convert.ToInt32(cFromPortUID) AS INT
//            LOCAL oPortFrom_UID := Convert.ToInt32(fromPortCb:SelectedValue:ToString()) AS INT
			
			LOCAL oPortTo_UID AS INT
			IF toPortCb:SelectedIndex >= 0
				cToPortUID := toPortCb:SelectedValue:ToString()
			ENDIF
			oPortTo_UID := Convert.ToInt32(cToPortUID)
//			IF toPortCb:SelectedValue != NULL_OBJECT
//                oPortTo_UID := Convert.ToInt32(toPortCb:SelectedValue:ToString())
//			ELSE
//				oPortTo_UID := 0
//			ENDIF
            
//            LOCAL oVoyageNo AS Double
//            cStatement := "Select isnull(Max(CAST(VoyageNo AS Decimal)), 0) MaxNo from [EconVoyages] where [VESSEL_UNIQUEID]=" + cVesselUID
//            LOCAL oDTMaxVoNo := oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement) AS DataTable
//            oVoyageNo := Math.Round(Convert.ToDouble((oDTMaxVoNo:Rows[0]["MaxNo"]:ToString()))) + 1
            
            LOCAL sDate := startDate:Value:ToString("yyyy-MM-dd HH:mm:ss") AS STRING
            LOCAL sGmtDate := startGmtDate:Value:ToString("yyyy-MM-dd HH:mm:ss") AS STRING
            LOCAL eDate := endDate:Value:ToString("yyyy-MM-dd HH:mm:ss") AS STRING
            LOCAL eGmtDate := endGmtDate:Value:ToString("yyyy-MM-dd HH:mm:ss") AS STRING
            LOCAL description := descriptionTb:Text AS STRING
            LOCAL userId := oUser:USER_UNIQUEID AS STRING
			LOCAL cCharteres := SubStr(chartererTb:Text, 0, 128) AS STRING
			
			LOCAL createFolders := FALSE AS LOGIC
			
			VAR dict := Dictionary<STRING, OBJECT>{}			
			
			IF string.IsNullOrEmpty(cVoyageUID)
				dict:Add("cVesselUID", cVesselUID)
				dict:Add("oVoyageNo", voyageNoTb:Text)
				dict:Add("cCharteres", cCharteres)				
				dict:Add("description", description)
				dict:Add("oPortFrom_UID", oPortFrom_UID)
				dict:Add("oPortTo_UID", oPortTo_UID)
				dict:Add("sDate", sDate)
				dict:Add("sGmtDate", sGmtDate)
				
		        cStatement := i"Insert into [EconVoyages] ({GetVoyageColumns()}) VALUES " +;
                              i"(@cVesselUID, @oVoyageNo, @cCharteres, @description, @oPortFrom_UID, @oPortTo_UID, " +;
                              i"@sDate, @sGmtDate, "			
			    IF !string.IsNullOrEmpty(endDate:CustomFormat:Trim())
			        cStatement := cStatement + i" @eDate, @eGmtDate, "
					dict:Add("eDate", eDate)
					dict:Add("eGmtDate", eGmtDate)
				ENDIF							
			    cStatement := cStatement + i"@cVoyageTypeId, @userId)"
				dict:Add("cVoyageTypeId", cVoyageTypeId)
				dict:Add("userId", userId)
				
				cVoyageUID := oSoftway:Exec(oMainForm:oGFH, oMainForm:oConn, cStatement, dict, TRUE):ToString()
				createFolders := TRUE
			ELSE
				dict:Add("cVesselUID", cVesselUID)
				dict:Add("description", description)
				dict:Add("cCharteres", cCharteres)
				dict:Add("oPortFrom_UID", oPortFrom_UID)
				dict:Add("oPortTo_UID", oPortTo_UID)
				dict:Add("sDate", sDate)
				dict:Add("sGmtDate", sGmtDate)
				cStatement := "Update [EconVoyages] set " +;
				            i"[VESSEL_UNIQUEID]= @cVesselUID " +;
		                    i",[Description]= @description " +;
		                    i",[Charterers]= @cCharteres " +;
		                    i",[PortFrom_UID]= @oPortFrom_UID " +;
		                    i",[PortTo_UID]= @oPortTo_UID " +;
		                    i",[StartDate]=@sDate " +;
		                    i",[StartDateGMT]=@sGmtDate "
		        IF !string.IsNullOrEmpty(endDate:CustomFormat:Trim())
		            cStatement := cStatement + i",[EndDate]=@eDate "
		            cStatement := cStatement + i",[EndDateGMT]=@eGmtDate "
					dict:Add("eDate", eDate)
					dict:Add("eGmtDate", eGmtDate)
				ENDIF
				dict:Add("cVoyageUID", cVoyageUID)
				cStatement := cStatement + i"where VOYAGE_UID=@cVoyageUID"
				
				LOCAL cUID := oSoftway:Exec(oMainForm:oGFH, oMainForm:oConn, cStatement, dict, FALSE):ToSTring() AS STRING
				IF ! oSoftway:IsValidIdentity(cUID)
					MemoWrit(cTempDocDir+"\Comp.txt", cStatement)
				ENDIF
				
				createFolders := FALSE
			ENDIF			
            
//            oSoftway:AdoCommand(oMainForm:oGFH, oMainForm:oConn, cStatement)
//			IF string.IsNullOrEmpty(cVoyageUID)
//		        cVoyageUID := oSoftway:GetLastInsertedIdentityFromScope(oMainForm:oGFH, oMainForm:oConn, "EconVoyages", "VOYAGE_UID")
//			ENDIF

			LOCAL fsController := FStructureController{} AS FStructureController
			IF fsController:AutoCreateStructure > 0 && createFolders
				CreateFolderStructure(fsController)
			ENDIF
			lIsSaved := TRUE
			
            SELF:Close()
        CATCH ex AS EXCEPTION
            ErrorBox(ex:Message)
            RETURN
		END TRY
        RETURN
		
	PRIVATE METHOD GetVoyageColumns() AS STRING
		LOCAL columnsList := List<STRING>{} AS List<STRING>
		columnsList:Add("[VESSEL_UNIQUEID]")
		columnsList:Add("[VoyageNo]")
		columnsList:Add("[Charterers]")
		columnsList:Add("[Description]")
		columnsList:Add("[PortFrom_UID]")
		columnsList:Add("[PortTo_UID]")
		columnsList:Add("[StartDate]")
		columnsList:Add("[StartDateGMT]")
		
		IF !string.IsNullOrEmpty(endDate:CustomFormat:Trim())
		    columnsList:Add("[EndDate]")
		    columnsList:Add("[EndDateGMT]")
		ENDIF
		
		columnsList:Add("[Type]")
		columnsList:Add("[USER_UNIQUEID]")
		
		LOCAL columns := string.Join(",", columnsList) AS STRING
		RETURN columns
		
	PRIVATE METHOD ValidatePorts() AS VOID
        VAR oPortSearch := List<DataRow>{}
		LOCAL cFromPortName := fromPortCb:Text AS STRING
		LOCAL cToPortName := toPortCb:Text AS STRING
		LOCAL cStatement AS STRING
		
		oPortSearch := oDTPorts:AsEnumerable():Where({i => i:FIELD<STRING>("name") == cFromPortName}):ToList()		
        IF oPortSearch:Count.Equals(0) && !string.IsNullOrEmpty(cFromPortName:Trim())
		    IF QuestionBox(i"Port '{cFromPortName}' not exist in data.{Environment.NewLine}Do you want to add it?", "New Port") == System.Windows.Forms.DialogResult.Yes
				
				VAR dict := Dictionary<STRING, OBJECT>{}
				dict:Add("PortName", cFromPortName)
				
		        cStatement := i"Insert into [VEPorts] ([Port]) values (@PortName)"
//			    oSoftway:AdoCommand(oMainForm:oGFH, oMainForm:oConn, cStatement)
			    cFromPortUID :=  oSoftway:Exec(oMainForm:oGFH, oMainForm:oConn, cStatement, dict, TRUE):ToString()
			    SELF:InitDTPorts()
		    ELSE
                SELF:SelectPortFrom("")
		    ENDIF
		ENDIF
		
		oPortSearch := oDTPorts:AsEnumerable():Where({i => i:FIELD<STRING>("name") == cToPortName}):ToList()
        IF oPortSearch:Count.Equals(0) && !string.IsNullOrEmpty(cToPortName:Trim())
            IF QuestionBox(i"Port '{cToPortName}' not exist in data.{Environment.NewLine}Do you want to add it?", "New Port") == System.Windows.Forms.DialogResult.Yes
				
				VAR dict := Dictionary<STRING, OBJECT>{}
				dict:Add("PortName", cToPortName)
				
		        cStatement := i"Insert into VEPorts (Port) values (@PortName)"
				
//				oSoftway:AdoCommand(oMainForm:oGFH, oMainForm:oConn, cStatement)
				cToPortUID := oSoftway:Exec(oMainForm:oGFH, oMainForm:oConn, cStatement, dict, TRUE):ToString()
				SELF:InitDTPorts()
			ELSE
                SELF:SelectPortTo("")
			ENDIF
		ENDIF
		
        SetGmts()
		RETURN
	PRIVATE METHOD ValidateBeforeSave() AS VOID
		LOCAL oMessages := List<STRING>{} AS List<STRING>
		IF string.IsNullOrEmpty(descriptionTb:Text)
            oMessages:Add("Field 'Description' can't be emtpy.")
        ENDIF            
        IF string.IsNullOrEmpty(typeCb:Text)
            oMessages:Add("Field 'Type' can't be emtpy.")
        ENDIF            
        ValidatePorts()
        IF fromPortCb:SelectedIndex < 0 && string.IsNullOrEmpty(cFromPortUID)
            oMessages:Add("Field 'Port' in section 'From' can't be emtpy.")
        ENDIF
//        IF toPortCb:SelectedIndex < 0 
//            oMessages:Add("Field 'Port' in section 'To' can't be emtpy.")
//        ENDIF
        SetGmts()
        IF !string.IsNullOrEmpty(endDate:CustomFormat:Trim())
		    IF endDate:Value < startDate:Value
                oMessages:Add("The StartDate must be earlier than the EndDate.")
			ENDIF
        ENDIF
        IF oMessages:Count > 0
			THROW Exception{string.Join(e"\n", oMessages)}
		ENDIF
		RETURN
		
		
		
		
	
	
	
	
	PRIVATE METHOD CheckLastVoyage() AS VOID
		TRY
			LOCAL cStatement := i"select top 1 isnull(convert(varchar(25), EndDateGMT, 120), '') EndDate from [EconVoyages] where [VESSEL_UNIQUEID]={cVesselUID} order by voyage_uid desc" AS STRING
			LOCAL oDTResult := oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement) AS DataTable
			IF string.IsNullOrEmpty(oDTResult:Rows[0]["EndDate"]:ToString())			
				ErrorBox(i"Last voyage has not value on 'End Date' field.{Environment.NewLine}You can not create new voyage before last voyage ends.", "")
				SELF:Close()
			ENDIF
		CATCH ex AS exception
		END TRY
		RETURN
		
	PRIVATE METHOD AddPortDestination() AS VOID
		IF PortDestinationDG:ColumnCount < 1
			PortDestinationDG:Columns:Add("Id", "Id")			
			PortDestinationDG:Columns:Add("Port", "Port")
		ENDIF
		
		VAR values := OBJECT[]{2}
		values[1] := toPortCb:SelectedValue
		values[2] := toPortCb:Text
		
		PortDestinationDG:Rows:Add(values)
		PortDestinationDG:Columns["Id"]:Visible := FALSE 
		SelectPortTo("")
		RETURN
		
	PRIVATE METHOD CreateFolderStructure(fsController AS FStructureController) AS VOID
		VAR routes := List<STRING>{}
		
		IF PortDestinationDG:ColumnCount > 0
			FOREACH row AS DataGridViewRow IN PortDestinationDG:Rows
				routes:Add(row:Cells[1]:Value:ToString())
			NEXT
		ENDIF
				
		LOCAL folderId := fsController:CreateVoyageFolder(cVesselUID, cVoyageUID, routes) AS STRING
		
		IF string.IsNullOrEmpty(folderId)
			RETURN
		ENDIF
		
		IF Convert.ToInt32(folderId) > 0
			MessageBox.Show("Folder structure created for voyage!")
		ENDIF
	RETURN
	
		
		
END CLASS 