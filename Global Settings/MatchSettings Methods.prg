// MatchSettings_Methods.prg
#Using System.IO
#Using System.Data
#Using System.Data.Common
#Using System.Windows.Forms
#Using System.Drawing
#Using System.Collections
#Using DevExpress.XtraGrid.Views.Grid
#Using DevExpress.XtraGrid.Columns
#Using DevExpress.Utils
#Using DevExpress.XtraEditors.Repository
#using DevExpress.XtraPrinting
#Using DevExpress.XtraPrintingLinks
USING System.Collections.Generic

PARTIAL CLASS MatchSettings INHERIT System.Windows.Forms.Form
	PUBLIC PROPERTY oParent AS Form AUTO

	PRIVATE _FSHasChanged AS LOGIC

	PRIVATE oDTVessels, oDTCrewVessels AS DataTable
	PRIVATE oDTUsers AS System.Data.DataTable
    PRIVATE lSuspendNotification AS System.Boolean
	PRIVATE lGlobalSettingsExist := FALSE AS LOGIC
	PRIVATE oFStrController AS FStructureController

PRIVATE METHOD MatchSettingsLoad() AS System.Void
	SELF:loadSmtpSettings()
	//SELF:LBCUsers_SelectedIndexChanged_Method()
RETURN

 EXPORT METHOD formUsersList(inData AS system.data.datatable) AS LOGIC
		lSuspendNotification := FALSE
		SELF:oDTUsers := inData
		SELF:LBCUsers:DataSource := SELF:oDTUsers
		SELF:LBCUsers:DisplayMember := "VesselName"
		SELF:LBCUsers:ValueMember := "Vessel_UniqueID"
		lSuspendNotification := TRUE
		
		//LOCAL cReportName := oMainForm:LBCReports:GetDisplayItemValue(oMainForm:LBCReports:SelectedIndex):ToString() AS STRING
	RETURN TRUE

export METHOD checkForCrewOwnedVessels() AS VOID
	LOCAL cStatement AS STRING
	LOCAL oSupVessels AS DataTable
	LOCAL lFound := false as LOGIC

IF oSoftway:TableExists(oMainForm:oGFH,  oMainForm:oConn, "SupVessels")
	cStatement:="SELECT VESSEL_UNIQUEID, Active FROM SupVessels WHERE Active = 1"
	SELF:oDTCrewVessels:=oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement)
	Self:oDTCrewVessels:TableName:="CrewVessels"
	// Create Primary Key
	oSoftway:CreatePK(SELF:oDTCrewVessels, "VESSEL_UNIQUEID")
	
	cStatement:="SELECT VESSEL_UNIQUEID FROM FMGlobalSettings"
	oSupVessels:=oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement)
	oSupVessels:TableName:="SupVessels"
	// Create Primary Key
	oSoftway:CreatePK(oSupVessels, "VESSEL_UNIQUEID")
	local iCount := 0 as INT
	//SELF:GridVessels:DataSource := SELF:oDTVessels	
	FOREACH  rowCrew AS DataRow IN SELF:oDTCrewVessels:Rows
				lFound:= false
				FOREACH  rowSup AS DataRow IN oSupVessels:Rows
					IF rowCrew:Item["VESSEL_UNIQUEID"]:toString() == rowSup:Item["VESSEL_UNIQUEID"]:tostring()
						lFound := true
					ENDIF
				NEXT
				IF ! lFound
					cStatement:="INSERT INTO FMGlobalSettings (VESSEL_UNIQUEID)"+;
					" VALUES ("+rowCrew:Item["VESSEL_UNIQUEID"]:toString()+")"
					 IF !oSoftway:AdoCommand(oMainForm:oGFH, oMainForm:oConn, cStatement)
						LOOP
					 ENDIF
					 iCount++
				ENDIF
	NEXT
	IF iCount > 0
		MessageBox.Show("Added "+iCount:ToString()+" Vessel(s).")
	ENDIF
	//SELF:Vessels_Refresh()
ENDIF
RETURN

PRIVATE METHOD LBCUsers_SelectedIndexChanged_Method() AS System.Void
	TRY
		IF SELF:LBCUsers:SelectedValue <> NULL .AND.  self:lSuspendNotification
			LOCAL cUserName := SELF:LBCUsers:GetDisplayItemValue(SELF:LBCUsers:SelectedIndex):ToString() AS STRING
			LOCAL cUserUID := SELF:LBCUsers:SelectedValue:ToString() AS STRING
			SELF:userLabel:Text := cUserName + " / " + cUserUID
			//SELF:LBCUsers:SetSelected(0,TRUE)
			LOCAL oRow  AS system.data.datarow 
			oRow := oMainForm:returnGlobalSetting(cUserUID:Trim()) 
			IF oRow == NULL
				MessageBox.Show("No row retreived.")
				RETURN
			ENDIF
			self:tbArRepUID:Text :=  oRow["Arrival_REPORT_UID"]:ToString():Trim() 
			self:tbDepRepUID:Text :=  oRow["Departure_REPORT_UID"]:ToString():Trim() 
			SELF:tbDepNextPortUID:Text :=  oRow["DepartureNextPort_ITEM_UID"]:ToString():Trim() 
			//Arrival
			self:tbArHFOUID:Text :=  oRow["Arrival_HFOROB_Item_UID"]:ToString():Trim() 
			self:tbArLFOUID:Text :=  oRow["Arrival_LFOROB_Item_UID"]:ToString():Trim() 
			SELF:tbArMGOUID:Text :=  oRow["Arrival_MGOROB_Item_UID"]:ToString():Trim() 
			SELF:tbArrivalPortUID:Text :=  oRow["ArrivalPort_Item_UID"]:ToString():Trim() 
			//Departure
			self:tbDepHFOUID:Text :=  oRow["Departure_HFOROB_Item_UID"]:ToString():Trim() 
			self:tbDepLFOUID:Text :=  oRow["Departure_LFOROB_Item_UID"]:ToString():Trim() 
			SELF:tbDepMGOUID:Text :=  oRow["Departure_MGOROB_Item_UID"]:ToString():Trim() 
			SElf:tbDeparturePortUID:Text := oRow["DeparturePort_Item_UID"]:ToString():Trim() 
			//Bunkering
			self:tbBunkeredHFO:Text :=  oRow["DepartureBunkeredHFO_Item_UID"]:ToString():Trim() 
			self:tbBunkeredLFO:Text :=  oRow["DepartureBunkeredLFO_Item_UID"]:ToString():Trim() 
			SELF:tbBunkeredMDO:Text :=  oRow["DepartureBunkeredMDO_Item_UID"]:ToString():Trim() 

		ENDIF
	CATCH exc AS Exception
		WB(exc:StackTrace)
	END	
		
RETURN

EXPORT Method applyToSelected() AS VOID
				TRY
					LOCAL cStatement AS STRING
						cStatement:="Update FMGlobalSettings set Arrival_REPORT_UID = '"+SELF:tbArRepUID:Text:Trim()+;
						"', DepartureNextPort_ITEM_UID = '"+SELF:tbDepNextPortUID:Text:Trim()+;
						"', Departure_REPORT_UID = '"+SELF:tbDepRepUID:Text:Trim()+;
						"', Arrival_HFOROB_Item_UID = '"+SELF:tbArHFOUID:Text:Trim()+;
						"', Arrival_LFOROB_Item_UID = '"+SELF:tbArLFOUID:Text:Trim()+;
						"', Arrival_MGOROB_Item_UID = '"+SELF:tbArMGOUID:Text:Trim()+;
						"', ArrivalPort_Item_UID = '"+SELF:tbArrivalPortUID:Text:Trim()+;
						"', Departure_HFOROB_Item_UID = '"+SELF:tbDepHFOUID:Text:Trim()+;
						"', Departure_LFOROB_Item_UID = '"+SELF:tbDepLFOUID:Text:Trim()+;
						"', Departure_MGOROB_Item_UID = '"+SELF:tbDepMGOUID:Text:Trim()+;
						"', DeparturePort_Item_UID = '"+SELF:tbDeparturePortUID:Text:Trim()+;
						"', DepartureBunkeredHFO_Item_UID = '"+SELF:tbBunkeredHFO:Text:Trim()+;
						"', DepartureBunkeredLFO_Item_UID = '"+SELF:tbBunkeredLFO:Text:Trim()+;
						"', DepartureBunkeredMDO_Item_UID = '"+SELF:tbBunkeredMDO:Text:Trim()+;
						"' Where Vessel_Uniqueid="+SELF:LBCUsers:SelectedValue:ToString()
						oSoftway:AdoCommand(oMainForm:oGFH, oMainForm:oConn, cStatement)
						//WB("User Created."+cstatement)
					
				CATCH
					wb("Vessel Not Updated.")
				END		
RETURN

EXPORT Method applyToAllVessels() AS VOID
	TRY
		IF QuestionBox("Are you sure you want to update the all Vessels ?", ;
							"Update All") <> System.Windows.Forms.DialogResult.Yes
				RETURN 
		ENDIF
		
				LOCAL cStatement AS STRING
						cStatement:="Update FMGlobalSettings set Arrival_REPORT_UID = '"+SELF:tbArRepUID:Text:Trim()+;
						"', DepartureNextPort_ITEM_UID = '"+SELF:tbDepNextPortUID:Text:Trim()+;
						"', Departure_REPORT_UID = '"+SELF:tbDepRepUID:Text:Trim()+;
						"', Arrival_HFOROB_Item_UID = '"+SELF:tbArHFOUID:Text:Trim()+;
						"', Arrival_LFOROB_Item_UID = '"+SELF:tbArLFOUID:Text:Trim()+;
						"', Arrival_MGOROB_Item_UID = '"+SELF:tbArMGOUID:Text:Trim()+;
						"', ArrivalPort_Item_UID = '"+SELF:tbArrivalPortUID:Text:Trim()+;
						"', Departure_HFOROB_Item_UID = '"+SELF:tbDepHFOUID:Text:Trim()+;
						"', Departure_LFOROB_Item_UID = '"+SELF:tbDepLFOUID:Text:Trim()+;
						"', Departure_MGOROB_Item_UID = '"+SELF:tbDepMGOUID:Text:Trim()+;
						"', DeparturePort_Item_UID = '"+SELF:tbDeparturePortUID:Text:Trim()+;
						"', DepartureBunkeredHFO_Item_UID = '"+SELF:tbBunkeredHFO:Text:Trim()+;
						"', DepartureBunkeredLFO_Item_UID = '"+SELF:tbBunkeredLFO:Text:Trim()+;
						"', DepartureBunkeredMDO_Item_UID = '"+SELF:tbBunkeredMDO:Text:Trim()+;
						"'"
						oSoftway:AdoCommand(oMainForm:oGFH, oMainForm:oConn, cStatement)
						//WB("User Created."+cstatement)
				CATCH
					wb("Vessel Not Updated.")
				END		
RETURN

PRIVATE METHOD bttnTestSMTPClick() AS System.Void
	LOCAL oEmail AS SocketTools.InternetMail
	oEmail := SocketTools.InternetMail{}
	oEmail:Initialize(SocketToolsLicenseKey)

	TRY
		oEmail:@@TO := self:txtSender:Text
		oEmail:@@Date := DateTime.Now:ToString("dd/MM/yyyy HH:mm:ss")
		oEmail:Encoding := "8bit"
		oEmail:From := self:txtSender:Text
		oEmail:MessageText := "This is a message from Fleet Manager to test the SMTP realy settings."
		oEmail:Subject := "Test Successful." 
		oEmail:ThrowError := TRUE

		LOCAL cServer := "", cPort:="", cUserNameLocal := "", cPassLocal := "" AS STRING
		cServer := self:txtSMTPServer:Text
		cPort := self:txtPort:Text
		cUserNameLocal := self:txtUser:Text
		cPassLocal := self:txtPass:Text

		IF cServer <> "" && cPort <> "" && cUserNameLocal <> "" && cPassLocal <> "" 
			IF !oEmail:SendMessage(cServer,Convert.ToInt32(cPort),cUserNameLocal,cPassLocal)
				MessageBox.Show("Wrong Settings")
			ELSE
				MessageBox.Show("Message Sent")
			ENDIF
		ELSE
			MessageBox.Show("The settings are not correct. Something is missing.")
		ENDIF
		//oEmail:SendMessage()
	CATCH exc AS Exception
		MessageBox.Show(oEmail:LastError:ToString(), exc:Message)
	END TRY
RETURN

PRIVATE METHOD buttonSaveSMTPSettingsClick() AS System.Void
	LOCAL cStatement AS STRING
	LOCAL cSecure:="0" AS STRING
	IF SELF:checkBoxSMTPSecure:Checked
		cSecure := "1"
	ENDIF
	
	IF lGlobalSettingsExist
		TRY
				cStatement:="Update FMTrueGlobalSettings set "+;
				"  SMTP_Server = '"+oSoftway:ConvertWildcards(SELF:txtSMTPServer:Text:Trim(), FALSE)+"'"+;
				" ,SMTP_Sender = '"+oSoftway:ConvertWildcards(SELF:txtSender:Text:Trim(), FALSE)+"'"+;
				" ,SMTP_Port = '"+oSoftway:ConvertWildcards(SELF:txtPort:Text:Trim(), FALSE)+"'"+;
				" ,SMTP_UserName = '"+oSoftway:ConvertWildcards(SELF:txtUser:Text:Trim(), FALSE)+"'"+;
				" ,SMTP_Pass = '"+oSoftway:ConvertWildcards(SELF:txtPass:Text:Trim(), FALSE)+"'"+;
				", SMTP_Secure = "+cSecure
				oSoftway:AdoCommand(oMainForm:oGFH, oMainForm:oConn, cStatement)

		CATCH exc AS Exception
			MessageBox.Show(exc:Message)
		END			

	ELSE
		TRY
			cStatement:="INSERT INTO FMTrueGlobalSettings (SMTP_Server, SMTP_Port, SMTP_UserName, SMTP_Pass, SMTP_Sender, SMTP_Secure)"+;
			" VALUES ('"+oSoftway:ConvertWildcards(SELF:txtSMTPServer:Text:Trim(), FALSE)+"'"+;
			" ,'"+oSoftway:ConvertWildcards(SELF:txtPort:Text:Trim(), FALSE)+"'"+;
			" ,'"+oSoftway:ConvertWildcards(SELF:txtUser:Text:Trim(), FALSE)+"'"+;
			" ,'"+oSoftway:ConvertWildcards(SELF:txtPass:Text:Trim(), FALSE)+"'"+;
			" ,'"+oSoftway:ConvertWildcards(SELF:txtSender:Text:Trim(), FALSE)+"'"+;
			" ,"+cSecure+")"
		oSoftway:AdoCommand(oMainForm:oGFH, oMainForm:oConn, cStatement)
		SELF:lGlobalSettingsExist := true
		CATCH exc AS Exception
			MessageBox.Show(exc:Message)
		END			

	ENDIF

	oMainForm:returnSMTPSetting()
RETURN

PRIVATE METHOD loadSmtpSettings() AS System.Void
	LOCAL cStatement AS STRING
	LOCAL dtSettings AS DataTable

	IF oSoftway:TableExists(oMainForm:oGFH,  oMainForm:oConn, "FMTrueGlobalSettings")
		cStatement:="SELECT TOP 1 * FROM FMTrueGlobalSettings"
		dtSettings := oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement)
	
		FOREACH  drSetting AS DataRow IN dtSettings:Rows
			SELF:lGlobalSettingsExist := TRUE
			SELF:txtSMTPServer:Text := drSetting:Item["SMTP_Server"]:toString()
			SELF:txtPort:Text := drSetting:Item["SMTP_Port"]:toString()
			SELF:txtUser:Text := drSetting:Item["SMTP_UserName"]:toString()
			SELF:txtPass:Text := drSetting:Item["SMTP_Pass"]:toString()
			SELF:txtSender:Text := drSetting:Item["SMTP_Sender"]:toString()
			LOCAL cSecureString := drSetting:Item["SMTP_Secure"]:toString() AS STRING
			IF cSecureString:ToUpper()=="TRUE"
				SELF:checkBoxSMTPSecure:Checked := TRUE
			ENDIF			
		NEXT

	ENDIF
RETURN


//Folder Structure

PRIVATE METHOD LoadFStructureData() AS VOID
	oFStrController := FStructureController{}
	
	readOnlyChk:Checked := FALSE
	
	fStrJSONRtb:Text := oFStrController:ToFormatedJSON()
	fStrTextRtb:Text := oFStrController:ToPlainText()
	
	readOnlyChk:Checked := TRUE
	
	voyageFlrNmTb:Text := oFStrController:VoyageFolderName
	
	LOCAL nRed, nGreen, nBlue AS INT
	oMainForm:SplitColorToRGB(oFStrController:ReportFolderColor:ToString(), nRed, nGreen, nBlue)
	
	folderColorPE:Color := Color.FromArgb(nRed, nGreen, nBlue)
	
	IF oFStrController:AutoCreateStructure > 0
		autoCreateStructureChk:Checked := TRUE
	ENDIF
	_FSHasChanged := FALSE
RETURN
PRIVATE METHOD ChangePlainText() AS VOID
	IF !readOnlyChk:Checked
		RETURN
	END IF
	oFStrController:ChangeText(fStrTextRtb:Text, TextType.PlainText)
	fStrJSONRtb:Text := oFStrController:ToFormatedJSON()
RETURN
PRIVATE METHOD ChangeJSON() AS VOID
	IF readOnlyChk:Checked
		RETURN
	END IF
	
	oFStrController:ChangeText(fStrJSONRtb:Text, TextType.Json)
	fStrTextRtb:Text := oFStrController:ToPlainText()
RETURN
PRIVATE METHOD SetReadOnly() AS VOID
	IF readOnlyChk:Checked
        fStrJSONRtb:Enabled := FALSE
        fStrTextRtb:Enabled := TRUE
    ELSE
        fStrJSONRtb:Enabled := TRUE
        fStrTextRtb:Enabled := FALSE
    ENDIF
	RETURN
	
PRIVATE METHOD SaveFolderStructure() AS VOID
	TRY
		IF !oFStrController:IsValidStructure
			THROW Exception{"Invalid Folder Structure"}
		ENDIF
		
		LOCAL cStatement AS STRING
		LOCAL cJson AS STRING
		LOCAL cSettingUID := oFStrController:SettingUID AS STRING
		LOCAL cVoyageFolderName := voyageFlrNmTb:Text AS STRING
		LOCAL cAutoCreateFolder AS INT
		IF autoCreateStructureChk:Checked
			cAutoCreateFolder := 1
		ENDIF
		
		cJson := oFStrController:ToJSON()
		
		VAR dict := Dictionary<STRING, OBJECT>{}
		dict:Add("cJson", cJson)
		dict:Add("cVoyageFolderName", cVoyageFolderName)
		dict:Add("cAutoCreateFolder", cAutoCreateFolder)
		dict:Add("cReportFolderColor", RGB(folderColorPE:Color:R, folderColorPE:Color:G, folderColorPE:Color:B))
		
		IF string.IsNullOrEmpty(cSettingUID)
			cStatement := i"insert into [FMTrueGlobalSettings]([FolderStructureJSON], [VoyageFolderName], [AutoCreateStructure], [ReportFolderColor]) " +;
						  i" values (@cJson, @cVoyageFolderName, @cAutoCreateFolder, @cReportFolderColor)"
			LOCAL cUID := oSoftway:Exec(oMainForm:oGFH, oMainForm:oConn, cStatement, dict, TRUE):ToString() AS STRING
			IF !oSoftway:IsValidIdentity(cUID)
				ErrorBox("Insert failed!", "")
				bbiFSRefresh:PerformClick()
				RETURN
			ENDIF
		ELSE
			cStatement := i"update [FMTrueGlobalSettings] set " +;
						  i"[FolderStructureJSON]=@cJson, " +;
						  i"[VoyageFolderName]=@cVoyageFolderName, " +;
						  i"[AutoCreateStructure]=@cAutoCreateFolder, " +;
						  i"[ReportFolderColor]=@cReportFolderColor " +;
						  i"where [Setting_UNIQUEID]={cSettingUID}"
			IF oSoftway:Exec(oMainForm:oGFH, oMainForm:oConn, cStatement, dict, FALSE) < 1
				errorbox("Update failed!", "")
				bbiFSRefresh:PerformClick()
				RETURN
			ENDIF			
		ENDIF
		
		/*oSoftway:Exec(oMainForm:oGFH, oMainForm:oConn, cStatement, dict, TRUE)*/
//		oSoftway:AdoCommand(oMainForm:oGFH, oMainForm:oConn, cStatement)
		wb("Folder structure saved")
		bbiFSRefresh:PerformClick()
	CATCH ex AS Exception
		ErrorBox(ex:Message)
	END TRY
	
	RETURN
	
PRIVATE METHOD ShowHelpForFolderStructure() AS VOID
//	LOCAL msg AS STRING
//	msg += "$VoyageDescription : Description" + Environment.NewLine
//	msg += "$VoyageNo : VoyageNo" + Environment.NewLine
//	msg += "$Charterers : Charterers" + Environment.NewLine
//	msg += "$Broker : Broker" + Environment.NewLine
//	msg += "$PortFrom : PortFrom" + Environment.NewLine
//	msg += "$PortTo : PortTo" + Environment.NewLine
//	System.Windows.Forms.MessageBox.Show(msg)
	VAR form := FSHelpForm{SELF}
	form:Show()
	RETURN
	

//---------------------------------------

END CLASS
