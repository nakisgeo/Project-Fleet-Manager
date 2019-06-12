// UsersSetupForm_Methods.prg
#Using System.Data
#Using System.Windows.Forms

PARTIAL CLASS UsersSetupForm INHERIT DevExpress.XtraEditors.XtraForm
PRIVATE lRefresh AS LOGIC

METHOD UsersSetupForm_OnLoad() AS VOID
	LOCAL aSplits := DevExpress.XtraEditors.SplitContainerControl[]{3} AS DevExpress.XtraEditors.SplitContainerControl[]
	aSplits[1] := SELF:SplitContainerControl1
	aSplits[2] := SELF:SplitContainerControl2
	aSplits[3] := SELF:SplitContainerControlSetupUsersH
	oSoftway:ReadFormSettings_DevExpress(SELF, oMainForm:alForms, oMainForm:alData, aSplits)

	//Check if [FMUsers] has the same users as [Users] table.
	//If not make the necessary changes in order to be the same.
	//All rows, same USER_UNIQUEID, same UserName
	SELF:CheckUsersTables()

	//GROUPS
	SELF:ListViewGroups:ListViewItemSorter := ListViewTextComparer{}
	SELF:ListViewNonGroups:ListViewItemSorter := ListViewTextComparer{}
RETURN

METHOD CheckUsersTables AS VOID
	//Compare the FMUsers with Users and if users are missing add them automatically to FMUsers
	LOCAL cStatement AS STRING
	cStatement:="SELECT Users.UserName, USER_UNIQUEID"+;
				" FROM Users Where InactiveUser=0"+;
				" ORDER BY USER_UNIQUEID"
	LOCAL oDTUsers := oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement) AS DataTable
	LOCAL oColPKUsers := DataColumn[]{1} AS DataColumn[]
	oColPKUsers[1] := oDTUsers:Columns["USER_UNIQUEID"]
	oDTUsers:PrimaryKey := oColPKUsers

	
	cStatement:=" SELECT Users.UserName, FMUsers.USER_UNIQUEID"+;
				" FROM FMUsers"+;
				" Inner Join Users On Users.USER_UNIQUEID = FMUsers.USER_UNIQUEID "+;
				" ORDER BY USER_UNIQUEID"
	LOCAL oDTFMUsers := oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement) AS DataTable
	LOCAL oColPKFMUsers := DataColumn[]{1} AS DataColumn[]
	oColPKFMUsers[1] := oDTFMUsers:Columns["USER_UNIQUEID"]
	oDTFMUsers:PrimaryKey := oColPKFMUsers
	
	LOCAL n AS INT
	LOCAL oFoundRow AS DataRow
	FOR n:=0 UPTO oDTUsers:Rows:Count - 1
		oFoundRow := oDTFMUsers:Rows:Find(oDTUsers:Rows[n]:Item["USER_UNIQUEID"])
		IF oFoundRow == NULL
			//WB(oDTUsers:Rows[n]:Item["USER_UNIQUEID"]:ToString()+CRLF+oDTUsers:Rows[n]:Item["UserName"]:ToString())
			cStatement:="INSERT INTO FMUsers"+;
						" (USER_UNIQUEID)"+;
						" VALUES"+;
						" ("+oDTUsers:Rows[n]:Item["USER_UNIQUEID"]:ToString()+")"
			IF oSoftway:AdoCommand(oMainForm:oGFH, oMainForm:oConn, cStatement)
				SELF:lRefresh := TRUE
			ENDIF
		ENDIF
		
	NEXT
RETURN	

METHOD FillListView_Groups(cUserUID AS STRING) AS VOID
LOCAL n, nCount AS INT
LOCAL oLVI AS ListViewItem
LOCAL cols := STRING[]{1} AS STRING[]
LOCAL cStatement AS STRING
LOCAL oDT AS DataTable

	SELF:ListViewGroups:Items:Clear()

	cStatement:="SELECT GROUP_UID, GroupName"+;
				" FROM FMUserGroups"+;
				" WHERE GROUP_UID IN"+;
				" (SELECT GROUP_UID FROM FMUserGroupLinks"+;
				" WHERE USER_UID="+cUserUID+")" 
	//WB(cStatement, "Groups") 
	oDT := oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement)

	nCount := oDT:Rows:Count - 1

	FOR n:=0 UPTO nCount
			cols[1] := oDT:Rows[n]:Item["GroupName"]:ToString():Trim()

			oLVI := ListViewItem{cols}
			oLVI:Name := oDT:Rows[n]:Item["GROUP_UID"]:ToString()
			SELF:ListViewGroups:Items:Add(oLVI)
	NEXT

	IF SELF:ListViewGroups:Items:Count >=1 
		SELF:ListViewGroups:Items[0]:Selected := TRUE
	ENDIF

RETURN


METHOD FillListView_NonGroups(cUserUID AS STRING) AS VOID
LOCAL n, nCount AS INT
LOCAL oLVI AS ListViewItem
LOCAL cols := STRING[]{1} AS STRING[]
LOCAL cStatement AS STRING
LOCAL oDT AS DataTable

	SELF:ListViewNonGroups:Items:Clear()

	cStatement:="SELECT GROUP_UID, GroupName"+;
				" FROM FMUserGroups"+;
				" WHERE GROUP_UID NOT IN"+;
				" (SELECT GROUP_UID FROM FMUserGroupLinks"+;
				" WHERE USER_UID="+cUserUID+")"
	//WB(cStatement, "Non") 
	oDT := oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement)

	IF oDT:Rows:Count == 0
		cStatement:="SELECT FMUserGroups.GROUP_UID, FMUserGroups.GroupName FROM FMUserGroups"
		oDT := oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement)
	ENDIF

	nCount := oDT:Rows:Count - 1

	FOR n:=0 UPTO nCount
			cols[1] := oDT:Rows[n]:Item["GroupName"]:ToString():Trim()

			oLVI := ListViewItem{cols}
			oLVI:Name := oDT:Rows[n]:Item["GROUP_UID"]:ToString()
			SELF:ListViewNonGroups:Items:Add(oLVI)
	NEXT

	IF SELF:ListViewNonGroups:Items:Count >= 1 
		SELF:ListViewNonGroups:Items[0]:Selected := TRUE
	ENDIF

RETURN


METHOD SaveGroups() AS VOID
	LOCAL cStatement, cGroupUID, cUserUID, cExistedValue AS STRING
	LOCAL n, nCount AS INT

	IF SELF:LBCUsers:SelectedValue == NULL
		ErrorBox("No User is selected", "Aborted")
		RETURN	
	ENDIF
	 
	cUserUID := SELF:LBCUsers:SelectedValue:ToString()//oRow:Item["USER_UID"]:ToString()

	//INSERT
	nCount := SELF:ListViewGroups:Items:Count - 1

	// Save FMUserGroupLinks
	FOR n:=0 UPTO nCount
		cGroupUID := SELF:ListViewGroups:Items[n]:Name
		cStatement:="SELECT GROUP_UID FROM FMUserGroupLinks"+;
					" WHERE GROUP_UID="+cGroupUID+;
					" AND USER_UID="+cUserUID
		cExistedValue := oSoftway:RecordExists(oMainForm:oGFH, oMainForm:oConn, cStatement, "GROUP_UID")
		IF cExistedValue == ""
			cStatement:="INSERT INTO FMUserGroupLinks (GROUP_UID, USER_UID) VALUES"+;
						" ("+cGroupUID+", "+cUserUID+")"
			oSoftway:AdoCommand(oMainForm:oGFH, oMainForm:oConn, cStatement)
		ENDIF
	NEXT

	//DELETE
	nCount := SELF:ListViewNonGroups:Items:Count - 1

	// Delete From FMUserGroupLinks
	FOR n:=0 UPTO nCount
		cGroupUID := SELF:ListViewNonGroups:Items[n]:Name
		cStatement:="DELETE FROM FMUserGroupLinks"+;
					" WHERE GROUP_UID="+cGroupUID+;
					" AND USER_UID="+cUserUID
		oSoftway:AdoCommand(oMainForm:oGFH, oMainForm:oConn, cStatement)
	NEXT
RETURN

PRIVATE METHOD cbInformUserForGMApprovalCheckedChanged() AS System.Void

	IF lSuspendNotification
			TRY
				IF SELF:cbInformUserForGMApproval:Checked
					oMainForm:updateUserSetting("InformUserForGMApproval","1", SELF:LBCUsers:SelectedValue:ToString():Trim(),0) 
				ELSE
					oMainForm:updateUserSetting("InformUserForGMApproval","0", SELF:LBCUsers:SelectedValue:ToString():Trim(),0) 
				ENDIF
			CATCH
				
			END
			RETURN
	ENDIF

RETURN

PRIVATE METHOD bttnEmailToSendOnGMApprovalsClick() AS System.Void

	LOCAL cEmailText := SELF:txtbttnEmailToSendOnGMApprovals:Text:Trim() AS STRING

	IF cEmailText:Length > 0
		LOCAL cStatement, cUserUID AS STRING
		LOCAL n AS INT

		IF SELF:LBCUsers:SelectedValue == NULL
			ErrorBox("No User is selected", "Aborted")
			RETURN	
		ENDIF
	 
		cUserUID := SELF:LBCUsers:SelectedValue:ToString()

		
		oMainForm:updateUserSetting("InformUserForGMApprovalEmail",oSoftway:ConvertWildcards(cEmailText, FALSE), cUserUID,1) 

	ELSE
		MessageBox.Show("Please Fill the text box on the right.")
	ENDIF
RETURN


END CLASS