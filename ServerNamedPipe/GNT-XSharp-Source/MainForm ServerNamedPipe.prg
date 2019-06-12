// MainForm_NamedPipe.prg
#using System
#using System.Drawing
#using System.Collections
#using System.ComponentModel
#using System.Windows.Forms
#using System.Data

#using AppModule.InterProcessComm
#using AppModule.NamedPipes

PARTIAL CLASS MainForm INHERIT DevExpress.XtraEditors.XtraForm
    // NamedPipe:
    EXPORT TBNamedPipeUIDs AS TextBox
    STATIC EXPORT TBNamedPipeUIDsRef AS TextBox
    STATIC EXPORT cNamedPipeTag AS STRING
    STATIC EXPORT PipeManager AS IChannelManager
	EXPORT SnpBodyText := "" AS STRING
	EXPORT CrewFileAttachment := "" AS STRING

METHOD LoadServerNamedPipe() AS VOID
    MainForm.PipeManager := PipeManager{}
    MainForm.PipeManager:Initialize()

    SELF:TBNamedPipeUIDs := TextBox{}
    SELF:TBNamedPipeUIDs:Location := System.Drawing.Point{0, 0}
    SELF:TBNamedPipeUIDs:Name := "TBNamedPipeUIDs"
    SELF:TBNamedPipeUIDs:Size := System.Drawing.Size{1, 1}
    SELF:TBNamedPipeUIDs:TabIndex := 111
    SELF:TBNamedPipeUIDs:TabStop := FALSE
    SELF:TBNamedPipeUIDs:Text := ""
    //SELF:TBNamedPipeUIDs:Visible := FALSE
    SELF:Controls:Add(SELF:TBNamedPipeUIDs)
    SELF:TBNamedPipeUIDs:TextChanged += System.EventHandler{ SELF, @TBNamedPipeUIDs_TextChanged() }

    MainForm.TBNamedPipeUIDsRef := SELF:TBNamedPipeUIDs
RETURN


PRIVATE METHOD TBNamedPipeUIDs_TextChanged( sender AS System.Object, e AS System.EventArgs ) AS System.Void
    //Application.DoEvents()
    IF oMainForm:TBNamedPipeUIDs:Text == ""
        RETURN
    ENDIF

    //SELF:TBNamedPipeUIDs:TextChanged -= System.EventHandler{ SELF, @TBNamedPipeUIDs_TextChanged() }

    // MainForm.cNamedPipeUIDs: comma-separated MSG_UNIQUEID string

    LOCAL cStatement AS STRING

	DO CASE
	CASE MainForm.cNamedPipeTag:Contains(">Paid") .or. MainForm.cNamedPipeTag:Contains("Paid")
		IF oDMFForm == NULL
			TRY
				oDMFForm := DMFForm{}
				oDMFForm:oMainForm := oMainForm
				oDMFForm:Show()
			CATCH ex AS Exception
				ErrorBox(ex:Message)
				RETURN
			END TRY
		ENDIF
		LOCAL cArgs := SELF:TBNamedPipeUIDs:Text AS STRING
		SELF:AdvanceCaseToNextState(cArgs)
		RETURN

	CASE MainForm.cNamedPipeTag:Contains(">DMFCase") .or. MainForm.cNamedPipeTag:Contains("DMFCase")
		IF oDMFForm == NULL
			TRY
				oDMFForm := DMFForm{}
				oDMFForm:oMainForm := oMainForm
				oDMFForm:Show()
			CATCH ex AS Exception
				ErrorBox(ex:Message)
				RETURN
				//wb("The Folder(s) used into the Document Management Framework are not yet loaded by the Communicator"+CRLF+CRLF+;
				//	"Please retry")
			END TRY
		ENDIF

		LOCAL cCaseNo := SELF:TBNamedPipeUIDs:Text AS STRING
		LOCAL cWhere := " WHERE DocNo='"+cCaseNo+"'" AS STRING

		oDMFForm:Activate()
		oDMFForm:FindCase(cWhere)
		oDMFForm:Focus()
		oDMFForm:BringToFront()
		RETURN

	CASE MainForm.cNamedPipeTag:Contains(">SoftwayMessages")
		// MainForm.cNamedPipeTag: "<[0]XmlStart:data.xml:XmlEnd>SoftwayMessages"
		LOCAL xmlFile := oSoftway:GetTextBetween(MainForm.cNamedPipeTag, "XmlStart:", ":XmlEnd") AS STRING
		SoftwayMessages_FileXML := xmlFile
		//wb(SoftwayMessages_FileXML)
		SELF:SoftwayMessages_OpenEditor()
		RETURN

	CASE MainForm.cNamedPipeTag:Contains(">AttachFile")
		LOCAL aUsualFiles := oSoftway:SemicolonListToArray(SELF:TBNamedPipeUIDs:Text, ",") AS ARRAY
		LOCAL n1, nLen := ALen(aUsualFiles) AS DWORD
		LOCAL aFiles := STRING[]{(INT)nLen} AS STRING[]
		FOR n1:=1 UPTO nLen
			aFiles[(INT)n1] := AsString(aUsualFiles[n1])
		NEXT
		LOCAL oHTMLEditor := oMainForm:OpenEmptyEditor() AS HTMLEditor
		oHTMLEditor:AttachFiles_FromCode(aFiles)
		RETURN

	CASE MainForm.cNamedPipeTag:Contains(">CCL")
		// "<["+cCallerObjectUID+"]"+cAddTagInfo+">" + cTag + "|" + "0"
		LOCAL cTag := MainForm.cNamedPipeTag AS STRING
		LOCAL cAddTagInfo := "", cCallerObjectUID := "" AS STRING
		LOCAL nPos := At(">", cTag) AS DWORD
		IF nPos > 0
			// AddTagInfo:
			cAddTagInfo := Left(cTag, nPos)
			cAddTagInfo := cAddTagInfo:Replace("<", "")
			cAddTagInfo := cAddTagInfo:Replace(">", "")		// [Editor]
			cTag := SubStr(cTag, nPos + 1)					// BodyText

			// cCallerObjectUID: 
			LOCAL nPosUID := At("]", cAddTagInfo) AS DWORD
			IF nPosUID > 0
				cCallerObjectUID := Left(cAddTagInfo, nPosUID)
				cCallerObjectUID := cCallerObjectUID:Replace("[", "")
				cCallerObjectUID := cCallerObjectUID:Replace("]", "")			// Editor
				cAddTagInfo := SubStr(cAddTagInfo, nPosUID + 1)
				//wb(cCallerObjectUID, "cCallerObjectUID")

				cStatement:="SELECT COMPANY_UNIQUEID, Full_Style"+;
				              " FROM Companies"+SELF:cNoLockTerm+;
				              " WHERE COMPANY_UNIQUEID="+cCallerObjectUID
				LOCAL oDT := oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement) AS DataTable
				IF oDT:Rows:Count == 0
				    wb("No Company found")
				    RETURN
				ENDIF
				LOCAL cCompanyUID, cCompanyName AS STRING
				cCompanyUID := oDT:Rows[0]:Item["COMPANY_UNIQUEID"]:ToString()
				cCompanyName := oDT:Rows[0]:Item["Full_Style"]:ToString()

				SELF:Cursor:=Cursors.AppStarting

				LOCAL oCompanies:=Companies{} AS Companies
				oCompanies:cCompanyUID:=cCompanyUID
				oCompanies:cCompanyName:=cCompanyName
				oCompanies:Show()
				//oCompanies:Show(Self)

				SELF:Cursor:=Cursors.Default
				
			ENDIF
		ENDIF
		RETURN

	// EmlViewer - Editor
	CASE MainForm.cNamedPipeTag:Contains(">EmlViewer")
		LOCAL cTag := MainForm.cNamedPipeTag AS STRING
		LOCAL cAddTagInfo := "", cCallerObjectUID := "" AS STRING
		LOCAL nPos := At(">", cTag) AS DWORD
		IF nPos > 0
			// AddTagInfo:
			cAddTagInfo := Left(cTag, nPos)
			cAddTagInfo := cAddTagInfo:Replace("<", "")
			cAddTagInfo := cAddTagInfo:Replace(">", "")		// [Editor]
			cTag := SubStr(cTag, nPos + 1)					// BodyText

			// cCallerObjectUID: 
			LOCAL nPosUID := At("]", cAddTagInfo) AS DWORD
			IF nPosUID > 0
				cCallerObjectUID := Left(cAddTagInfo, nPosUID)
				cCallerObjectUID := cCallerObjectUID:Replace("[", "")
				cCallerObjectUID := cCallerObjectUID:Replace("]", "")			// Editor
				cAddTagInfo := SubStr(cAddTagInfo, nPosUID + 1)
				//wb(cTag+CRLF+"cCallerObjectUID="+cCallerObjectUID+CRLF+"cAddTagInfo="+cAddTagInfo)
				IF cCallerObjectUID == "Editor"
					VAR oHTMLEditor := SELF:OpenEditorSNP(cAddTagInfo)
				ENDIF
			ENDIF
		ENDIF
		RETURN
	ENDCASE


	// Editor or Grid:

	// SNP - Editor
	IF MainForm.cNamedPipeTag:ToUpper():Contains(">SNP") .or. MainForm.cNamedPipeTag:ToUpper():Contains(">EXADAS")
		LOCAL cTag := MainForm.cNamedPipeTag AS STRING
		LOCAL cAddTagInfo := "", cCallerObjectUID := "" AS STRING
		LOCAL nPos := At(">", cTag) AS DWORD
		IF nPos > 0
			// AddTagInfo:
			cAddTagInfo := Left(cTag, nPos)
			cAddTagInfo := cAddTagInfo:Replace("<", "")
			cAddTagInfo := cAddTagInfo:Replace(">", "")		// [Editor]
			cTag := SubStr(cTag, nPos + 1)					// BodyText

			// cCallerObjectUID: 
			LOCAL nPosUID := At("]", cAddTagInfo) AS DWORD
			IF nPosUID > 0
				cCallerObjectUID := Left(cAddTagInfo, nPosUID)
				cCallerObjectUID := cCallerObjectUID:Replace("[", "")
				cCallerObjectUID := cCallerObjectUID:Replace("]", "")			// Editor
				cAddTagInfo := SubStr(cAddTagInfo, nPosUID + 1)
				//wb(cTag+CRLF+"cCallerObjectUID="+cCallerObjectUID+CRLF+"cAddTagInfo="+cAddTagInfo)
				IF cCallerObjectUID == "Editor"
					//wb("cAddTagInfo="+cAddTagInfo)
					SELF:OpenEditorSNP(cAddTagInfo)
//					SELF:SnpBodyText := cAddTagInfo
//					SELF:oMainUserControl:TVFolders:Focus()
////					SendKeys.Send("{F14}")
//					Application.DoEvents()
//					SendKeys.Send("{F14}")
					RETURN
				ENDIF
			ENDIF
		ENDIF
	ENDIF

	// CrewFile - InterOffice
	IF MainForm.cNamedPipeTag:ToUpper():Contains(">CREWFILE") .or. MainForm.cNamedPipeTag:ToUpper():Contains(">EXADAS")
		LOCAL cTag := MainForm.cNamedPipeTag AS STRING
		LOCAL cAddTagInfo := "", cCallerObjectUID := "" AS STRING
		LOCAL nPos := At(">", cTag) AS DWORD
		IF nPos > 0
			// AddTagInfo:
			cAddTagInfo := Left(cTag, nPos)
			cAddTagInfo := cAddTagInfo:Replace("<", "")
			cAddTagInfo := cAddTagInfo:Replace(">", "")		// [InterOffice]
			cTag := SubStr(cTag, nPos + 1)					// Attachment
			//wb(cTag, "cTag")

			// cCallerObjectUID: 
			LOCAL nPosUID := At("]", cAddTagInfo) AS DWORD
			IF nPosUID > 0
				cCallerObjectUID := Left(cAddTagInfo, nPosUID)
				cCallerObjectUID := cCallerObjectUID:Replace("[", "")
				cCallerObjectUID := cCallerObjectUID:Replace("]", "")			// Editor
				cAddTagInfo := SubStr(cAddTagInfo, nPosUID + 1)
				//wb(cCallerObjectUID, "cCallerObjectUID")
				IF cCallerObjectUID == "InterOffice"
					//wb("cAddTagInfo="+cAddTagInfo)
					SELF:OpenEditorAttachmentCrewFile(cAddTagInfo)
//					SELF:CrewFileAttachment := cAddTagInfo
//					SELF:oMainUserControl:TVFolders:Focus()
////					SendKeys.Send("{F15}")
//					Application.DoEvents()
//					SendKeys.Send("{F15}")
					RETURN
				ENDIF
			ENDIF
		ENDIF
	ENDIF


	// Locate messages:
	// Check if TAB is already open for the given ToolTip:
	LOCAL n, nCount := SELF:xtraTabControl:TabPages:Count - 1 AS INT
	LOCAL oMainUserControl as MainUserControl
	LOCAL lFound := FALSE AS LOGIC
	FOR n:=0 UPTO nCount
		oMainUserControl := (MainUserControl)SELF:xtraTabControl:TabPages[n]:Controls[0]
		//wb(MainForm.cNamedPipeTag, oMainUserControl:AddTagInfo)
		IF oMainUserControl:AddTagInfo <> "" .and. MainForm.cNamedPipeTag:Contains(oMainUserControl:AddTagInfo)
			SELF:xtraTabControl:SelectedTabPage := SELF:xtraTabControl:TabPages[n]
			lFound := TRUE
			EXIT
		ENDIF
	NEXT

	IF ! lFound
		//oMainForm:CreateNewConnectionAuto(cFolder, MainForm.cNamedPipeTag)
		oMainForm:CreateNewConnectionAuto(SELF:oMainUserControl, MainForm.cNamedPipeTag)
	ENDIF

	cStatement:="SELECT DISTINCT "+oMainForm:cGridFields+" FROM MSG32"+oMainForm:cNoLockTerm+;
				" LEFT OUTER JOIN "+oMainForm:cCurrentDatabasePrefix+"StateFlags AS StateFlags ON MSG32.STATEFLAG_UID=StateFlags.STATEFLAG_UID"+;
                " WHERE MSG32.MSG_UNIQUEID IN ("+SELF:TBNamedPipeUIDs:Text+")"+;
		        " ORDER BY "+oMainForm:oMainUserControl:SortColumnFields()
    //wb(cStatement)
	TRY
		oMainForm:oMainUserControl:oDTMsg32 := oSoftway:ResultTable(oMainForm:oMainUserControl:oGFH, oMainForm:oMainUserControl:oHistConn, cStatement)
	CATCH oe AS Exception
		ErrorBox(oe:Message)
		SELF:xtraTabControl:TabPages:Remove(SELF:xtraTabControl:SelectedTabPage)
		RETURN
	END TRY

	oMainForm:oMainUserControl:cActiveStatement := cStatement

	oSoftway:CreatePK(oMainForm:oMainUserControl:oDTMsg32, "MSG_UNIQUEID")

	SELF:oMainUserControl:aSearchPatern := NULL
	SELF:oMainUserControl:searchPaternMarked := FALSE

	oMainForm:oGridMessages:DataSource:=oMainForm:oMainUserControl:oDTMsg32

	//oMainForm:oMainUserControl:barStaticItem_Count:Caption := oMainForm:oGridViewMessages:DataRowCount:ToString("N0")+" Msgs"
	oMainForm:oMainUserControl:barStaticItem_Count:Caption := SELF:oMainUserControl:TotalMessages()

	// Reset the flag
	oMainForm:oMainUserControl:lBarItemDateChanged:=FALSE

	IF ! oMainForm:oGridMessages:Focused
		oMainForm:oGridMessages:Focus()
	ENDIF

	//// If Minimized then Restore it:
	//if Self:WindowState == FormWindowState.Minimized
	//	//Self:Activate()
	//	SELF:WindowState := FormWindowState.Maximized
	//	//Application.DoEvents()
	//	//System.Threading.Thread.Sleep(40)
	//	//WinApi.PostMessage(self:Handle, )
	//	//SELF:Activate()
 //       WinApi.SetForegroundWindow(SELF:Handle)
	//	//SingleInstance.ShowFirstInstance()
	//ENDIF

    //oMainForm:TBNamedPipeUIDs:Text := ""
RETURN

END CLASS
