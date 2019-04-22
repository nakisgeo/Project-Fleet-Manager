// MainForm_NamedPipe.prg
#using System
#using System.Drawing
#using System.Collections
#using System.ComponentModel
#using System.Windows.Forms
#using System.Data

#using AppModule.InterProcessComm
#using AppModule.NamedPipes

#using DevExpress.XtraTreeList
#using DevExpress.XtraTreeList.Nodes

PARTIAL CLASS MainForm INHERIT DevExpress.XtraEditors.XtraForm
    // NamedPipe:
    EXPORT TBNamedPipeUIDs AS TextBox
    STATIC EXPORT TBNamedPipeUIDsRef AS TextBox
    STATIC EXPORT cNamedPipeTag AS STRING
    STATIC EXPORT PipeManager AS IChannelManager

METHOD LoadServerNamedPipe() AS VOID
    //LOCAL oServerForm := ServerForm{} AS ServerForm
    //oServerForm:Show(SELF)

   //wb("LoadServerNamedPipe")

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
	// MainForm.cNamedPipeTag=<[1]LocateReport>Communicator
	// SELF:TBNamedPipeUIDs:Text=FleetManagerData-2 2014_10_08__05_54_58.ZIP

    //Application.DoEvents()
    IF oMainForm:TBNamedPipeUIDs:Text == ""
        RETURN
    ENDIF

	LOCAL cVesselUID, cReportUID AS STRING
	LOCAL nPos1, nPos2 AS INT
	//wb("MainForm.cNamedPipeTag="+MainForm.cNamedPipeTag+CRLF+"SELF:TBNamedPipeUIDs:Text="+SELF:TBNamedPipeUIDs:Text+CRLF)
	IF MainForm.cNamedPipeTag:Contains("Communicator")
			// VesselUID
			nPos1 := MainForm.cNamedPipeTag:IndexOf("[")
			IF nPos1 == -1
				RETURN
			ENDIF
			nPos2 := MainForm.cNamedPipeTag:IndexOf("]", nPos1)
			IF nPos2 == -1
				RETURN
			ENDIF
			cVesselUID := MainForm.cNamedPipeTag:Substring(nPos1 + 1, nPos2 - nPos1 - 1)

			// ReportUID
			nPos1 := SELF:TBNamedPipeUIDs:Text:IndexOf("-")
			IF nPos1 == -1
				RETURN
			ENDIF
			nPos2 := SELF:TBNamedPipeUIDs:Text:IndexOf(" ", nPos1)
			IF nPos2 == -1
				RETURN
			ENDIF
			cReportUID := SELF:TBNamedPipeUIDs:Text:Substring(nPos1 + 1, nPos2 - nPos1 - 1)

			LOCAL cRest := SELF:TBNamedPipeUIDs:Text:Substring(nPos2 + 1):ToUpper():Replace(".ZIP", "") AS STRING
			cRest := cRest:Substring(0, 4)+"-"+cRest:Substring(5, 2)+"-"+cRest:Substring(8, 2)+" "+cRest:Substring(12, 2)+":"+cRest:Substring(15, 2)+":"+cRest:Substring(18, 2)

			IF oMainForm:LBCReports:SelectedValue <> NULL .and. oMainForm:LBCReports:SelectedValue:ToString() <> cReportUID
				oMainForm:LBCReports:SelectedValue := cReportUID
			ENDIF


			//wb(cVesselUID)
			self:getNodeForVessel(cVesselUID)
	
			/*IF SELF:GetVesselUID <> cVesselUID
				oMainForm:TreeListVessels:FocusedNode:Tag := Convert.ToInt32(cVesselUID)
			ENDIF*/

			LOCAL dDate := DateTime.Parse(cRest) AS DateTime
			//LOCAL cText := dDate:ToString("dd/MM/yyyy HH:mm")+" "+oMainForm:LBCReports:Text AS STRING
			LOCAL cText := dDate:ToString("dd/MM/yyyy HH") AS STRING	// The attachment DateTime is different than the FMDataPackages.DateTimeGMT
	
			SELF:getNodeForReport(cText)
			/*LOCAL nIndex := SELF:LBCReports:FindString(cText) AS INT
			IF nIndex <> -1
				SELF:LBCReports:SelectedIndex := nIndex
			ENDIF*/
	

			/*IF MainForm.cNamedPipeTag:Contains("DMFCase")
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
				RETURN
			ENDIF

			// Check if TAB is already open for the given ToolTip:
			LOCAL n, nCount := SELF:xtraTabControl:TabPages:Count - 1 AS INT
			LOCAL oMainUserControl as MainUserControl
			LOCAL lFound AS LOGIC
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

			LOCAL cStatement AS STRING
			cStatement:="SELECT DISTINCT "+oMainForm:cGridFields+" FROM MSG32"+oMainForm:cNoLockTerm+;
						" LEFT OUTER JOIN "+oMainForm:cCurrentDatabasePrefix+"StateFlags AS StateFlags ON MSG32.STATEFLAG_UID=StateFlags.STATEFLAG_UID"+;
						" WHERE MSG32.MSG_UNIQUEID IN ("+self:TBNamedPipeUIDs:Text+")"+;
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

			oMainForm:oGridMessages:DataSource:=oMainForm:oMainUserControl:oDTMsg32

			oMainForm:oMainUserControl:barStaticItem_Count:Caption:=oMainForm:oGridViewMessages:DataRowCount:ToString("N0")+" Msgs"

			// Reset the flag
			oMainForm:oMainUserControl:lBarItemDateChanged:=FALSE

			IF ! oMainForm:oGridMessages:Focused
				oMainForm:oGridMessages:Focus()
			ENDIF*/

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
	ELSEif MainForm.cNamedPipeTag:Contains("ApprovalsForm")
			SELF:locateReport(SELF:TBNamedPipeUIDs:Text)
	ENDIF
RETURN


METHOD getNodeForVessel(cVesselUID AS STRING) AS VOID
	LOCAL oRootNodesLocal,oChildNodesLocal AS TreeListNodes
	oRootNodesLocal := oMainForm:TreeListVessels:Nodes
	IF oRootNodesLocal:Count >0
	FOREACH oEachRootNode AS TreeListNode IN oRootNodesLocal // Pare ola ta fleets
		oChildNodesLocal := oEachRootNode:Nodes
		IF oChildNodesLocal:Count >0
		FOREACH oEachChildNode AS TreeListNode IN oChildNodesLocal // Pare ola ta fleets
			IF oEachChildNode:Tag:ToString() == cVesselUID
				oMainForm:TreeListVessels:FocusedNode := oEachChildNode
				return
			ENDIF
		NEXT
		ELSE
			IF oEachRootNode:Tag:ToString() == cVesselUID
				oMainForm:TreeListVessels:FocusedNode := oEachRootNode
				return
			ENDIF
		ENDIF
	NEXT 
	ENDIF
RETURN
	
METHOD getNodeForReport(cDateTime AS STRING, cReport_UID := "0" as String) AS VOID
	LOCAL oRootNodesLocal,oChildNodesLocal AS TreeListNodes
	oRootNodesLocal := oMainForm:TreeListVesselsReports:Nodes
	IF oRootNodesLocal:Count >0
	FOREACH oEachRootNode AS TreeListNode IN oRootNodesLocal // 
		oChildNodesLocal := oEachRootNode:Nodes
		IF oChildNodesLocal:Count >0
		FOREACH oEachChildNode AS TreeListNode IN oChildNodesLocal // 
			//wb(oEachChildNode:ToString())
			IF cReport_UID == "0"
				IF oEachChildNode:GetValue(0):ToString():StartsWith(cDateTime)
					oMainForm:TreeListVesselsReports:FocusedNode := oEachChildNode
					RETURN
				ENDIF
			ELSE
				IF oEachChildNode:Tag:ToString() == cReport_UID
					oMainForm:TreeListVesselsReports:FocusedNode := oEachChildNode
					RETURN
				ENDIF
			ENDIF
		NEXT
		ELSE
			IF cReport_UID == "0"
				IF oEachRootNode:GetValue(0):ToString():StartsWith(cDateTime)
					oMainForm:TreeListVesselsReports:FocusedNode := oEachRootNode
					return
				ENDIF
			ELSE
				IF oEachRootNode:Tag:ToString() == cReport_UID
					oMainForm:TreeListVesselsReports:FocusedNode := oEachRootNode
					RETURN
				ENDIF
			ENDIF
		ENDIF
	NEXT 
	ENDIF
RETURN	
		

END CLASS
