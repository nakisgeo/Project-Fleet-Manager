// GroupsSetupForm_Methods.prg
#Using System.Data
#Using System.Windows.Forms

PARTIAL CLASS GroupsSetupForm INHERIT DevExpress.XtraEditors.XtraForm
PRIVATE lRefresh AS LOGIC

METHOD GroupsSetupForm_OnLoad() AS VOID
	LOCAL aSplits := DevExpress.XtraEditors.SplitContainerControl[]{2} AS DevExpress.XtraEditors.SplitContainerControl[]
	aSplits[1] := SELF:SplitContainerControl1
	aSplits[2] := SELF:SplitContainerControlSetupGroupsH
	oSoftway:ReadFormSettings_DevExpress(SELF, oMainForm:alForms, oMainForm:alData, aSplits)
	
	//Check if [FMUserGroups] has the same groups as [UserGroups] table.
	//If not make the necessary changes in order to be the same.
	//All rows, same GROUP_UNIQUEID, same GroupName
	SELF:CheckGroupsTables()

	//GROUPS
	SELF:ListViewUsers:ListViewItemSorter := ListViewTextComparer{}
	SELF:ListViewNonUsers:ListViewItemSorter := ListViewTextComparer{}
RETURN

METHOD CheckGroupsTables AS VOID
	//Compare the FMUserGroups with UserGroups and if users are missing add them automatically to FMUserGroups
	LOCAL cStatement AS STRING
	cStatement:="SELECT GroupName, GROUP_UNIQUEID"+;
				" FROM UserGroups"+;
				" ORDER BY GROUP_UNIQUEID"
	LOCAL oDTUserGroups := oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement) AS DataTable
	LOCAL oColPKUserGroups := DataColumn[]{1} AS DataColumn[]
	oColPKUserGroups[1] := oDTUserGroups:Columns["GROUP_UNIQUEID"]
	oDTUserGroups:PrimaryKey := oColPKUserGroups

	
	cStatement:="SELECT GroupName, GROUP_UID"+;
				" FROM FMUserGroups"+;
				" ORDER BY GROUP_UID"
	LOCAL oDTFMUserGroups := oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement) AS DataTable
	LOCAL oColPKFMUserGroups := DataColumn[]{1} AS DataColumn[]
	oColPKFMUserGroups[1] := oDTFMUserGroups:Columns["GROUP_UID"]
	oDTFMUserGroups:PrimaryKey := oColPKFMUserGroups
	
	LOCAL n AS INT
	LOCAL oFoundRow AS DataRow
	FOR n:=0 UPTO oDTUserGroups:Rows:Count - 1
		oFoundRow := oDTFMUserGroups:Rows:Find(oDTUserGroups:Rows[n]:Item["GROUP_UNIQUEID"])
		IF oFoundRow == NULL
			//WB(oDTUserGroups:Rows[n]:Item["GROUP_UID"]:ToString()+CRLF+oDTUserGroups:Rows[n]:Item["GroupName"]:ToString())
			cStatement:="INSERT INTO FMUserGroups"+;
						" (GROUP_UID, GroupName)"+;
						" VALUES"+;
						" ("+oDTUserGroups:Rows[n]:Item["GROUP_UNIQUEID"]:ToString()+","+;
						" '"+oSoftway:ConvertWildCards(oDTUserGroups:Rows[n]:Item["GroupName"]:ToString():Trim(), FALSE)+"')"
			IF oSoftway:AdoCommand(oMainForm:oGFH, oMainForm:oConn, cStatement)
				SELF:lRefresh := TRUE
			ENDIF
		ELSE
			IF oFoundRow:Item["GroupName"]:ToString() <> oDTUserGroups:Rows[n]:Item["GroupName"]:ToString()
				cStatement:="UPDATE FMUserGroups"+;
							" SET GroupName='"+oSoftway:ConvertWildCards(oDTUserGroups:Rows[n]:Item["GroupName"]:ToString():Trim(), FALSE)+"'"+;
							" WHERE GROUP_UID="+oDTUserGroups:Rows[n]:Item["GROUP_UNIQUEID"]:ToString()
				IF oSoftway:AdoCommand(oMainForm:oGFH, oMainForm:oConn, cStatement)
					SELF:lRefresh := TRUE
				ENDIF
			ENDIF	
		ENDIF
	NEXT
RETURN	


METHOD FillListView_Users(cGroupUID AS STRING) AS VOID
LOCAL n, nCount AS INT
LOCAL oLVI AS ListViewItem
LOCAL cols := STRING[]{1} AS STRING[]
LOCAL cStatement AS STRING
LOCAL oDT AS DataTable

	SELF:ListViewUsers:Items:Clear()

	cStatement:=" SELECT FMUsers.USER_UNIQUEID, RTRIM(Users.UserName) AS UserName"+;
				" FROM FMUsers"+;
				" INNER JOIN Users ON Users.USER_UNIQUEID=FMUsers.USER_UNIQUEID "+;
				" WHERE FMUsers.USER_UNIQUEID IN"+;
				" (SELECT USER_UID FROM FMUserGroupLinks"+;
				" WHERE GROUP_UID="+cGroupUID+")" 
	oDT:=oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement)

	nCount:=oDT:Rows:Count - 1

	FOR n:=0 UPTO nCount
			cols[1]:=oDT:Rows[n]:Item["UserName"]:ToString():Trim()

			oLVI:=ListViewItem{cols}
			oLVI:Name:=oDT:Rows[n]:Item["USER_UNIQUEID"]:ToString()
			SELF:ListViewUsers:Items:Add(oLVI)
	NEXT

	IF SELF:ListViewUsers:Items:Count >=1 
		SELF:ListViewUsers:Items[0]:Selected := TRUE
	ENDIF

RETURN


METHOD FillListView_NonUsers(cGroupUID AS STRING) AS VOID
LOCAL n, nCount AS INT
LOCAL oLVI AS ListViewItem
LOCAL cols := STRING[]{1} AS STRING[]
LOCAL cStatement AS STRING
LOCAL oDT AS DataTable

	SELF:ListViewNonUsers:Items:Clear()

	cStatement:="SELECT FMUsers.USER_UNIQUEID, RTRIM(Users.UserName) AS UserName"+;
				" FROM FMUsers"+;
				" INNER JOIN Users ON Users.USER_UNIQUEID=FMUsers.USER_UNIQUEID "+;
				" WHERE FMUsers.USER_UNIQUEID NOT IN"+;
				" (SELECT USER_UID FROM FMUserGroupLinks"+;
				" WHERE GROUP_UID="+cGroupUID+")"
	//MemoWrit("C:\NonUsers.TXT", cStatement) 
	oDT:=oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement)

	IF oDT:Rows:Count == 0
		cStatement:="SELECT FMUsers.USER_UNIQUEID, RTRIM(Users.UserName) FROM FMUsers"+;
		" INNER JOIN Users ON Users.USER_UNIQUEID=FMUsers.USER_UNIQUEID "
		oDT:=oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement)
	ENDIF

	nCount:=oDT:Rows:Count - 1

	FOR n:=0 UPTO nCount
			cols[1]:=oDT:Rows[n]:Item["UserName"]:ToString():Trim()

			oLVI:=ListViewItem{cols}
			oLVI:Name:=oDT:Rows[n]:Item["USER_UNIQUEID"]:ToString()
			SELF:ListViewNonUsers:Items:Add(oLVI)
	NEXT

	IF SELF:ListViewNonUsers:Items:Count >=1 
		SELF:ListViewNonUsers:Items[0]:Selected := TRUE
	ENDIF

RETURN


METHOD SaveUsers() AS VOID
	LOCAL cStatement, cGroupUID, cUserUID, cExistedValue AS STRING
	LOCAL n, nCount AS INT
	
	IF SELF:LBCGroups:SelectedValue == NULL
		ErrorBox("No Group is selected", "Aborted")
		RETURN	
	ENDIF

	cGroupUID := SELF:LBCGroups:SelectedValue:ToString()

	//INSERT
	nCount := SELF:ListViewUsers:Items:Count - 1

	// Save FMUserGroupLinks
	FOR n:=0 UPTO nCount
		cUserUID := SELF:ListViewUsers:Items[n]:Name
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
	nCount := SELF:ListViewNonUsers:Items:Count - 1

	// Delete From FMUserGroupLinks
	FOR n:=0 UPTO nCount
		cUserUID := SELF:ListViewNonUsers:Items[n]:Name
		cStatement:="DELETE FROM FMUserGroupLinks"+;
					" WHERE GROUP_UID="+cGroupUID+;
					" AND USER_UID="+cUserUID
		oSoftway:AdoCommand(oMainForm:oGFH, oMainForm:oConn, cStatement)
	NEXT
RETURN

END CLASS