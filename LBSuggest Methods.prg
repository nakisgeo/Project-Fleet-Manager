// LBSuggest_Methods.prg
#USING System.Data
#USING System.Data.Common
#USING System.Windows.Forms
#USING System.Drawing
#USING System.Collections
#USING DevExpress.XtraEditors
#USING DevExpress.XtraEditors.Repository
#USING DevExpress.XtraBars
#USING DevExpress.XtraGrid
#USING DevExpress.XtraGrid.Views.Base
#USING DevExpress.XtraGrid.Views.Grid
#USING DevExpress.XtraGrid.Columns
#USING DevExpress.XtraGrid.Views.Grid.ViewInfo


GLOBAL oActiveGridView AS GridView

CLASS LBSuggestPort

STATIC METHOD KeyDown(e AS System.Windows.Forms.KeyEventArgs, oLBSuggest AS ListBoxControl, oGridView AS GridView) AS VOID
	DO CASE
	CASE e:KeyCode == Keys.Delete
		LBSuggestPort.Delete(oLBSuggest)

	CASE e:KeyCode == Keys.Back
		IF oMainForm:cLBSuggest_TypedChars:Length == 0
			LBSuggestPort.Escape(oLBSuggest, oGridView, FALSE)
			RETURN
		ENDIF
		// Delete last char
		oMainForm:cLBSuggest_TypedChars := oMainForm:cLBSuggest_TypedChars:Substring(0, oMainForm:cLBSuggest_TypedChars:Length - 1)
		// Locate appropriate item
		IF oLBSuggest:SelectedItem <> NULL
			LOCAL nIndex := oLBSuggest:FindString(oMainForm:cLBSuggest_TypedChars) AS INT
			IF nIndex == -1
				LBSuggestPort.Escape(oLBSuggest, oGridView, FALSE)
				RETURN
			ENDIF
			// Select the ListBoxControlItem
			oLBSuggest:SelectedIndex := nIndex
		ENDIF

	CASE e:KeyCode >= Keys.D0 .AND. e:KeyCode <= Keys.D9 ;
		.OR. e:KeyCode >= Keys.A .AND. e:KeyCode <= Keys.Z ;
		.OR. InListExact(e:KeyCode, Keys.Space, Keys.OemPeriod, Keys.Oemcomma, Keys.OemMinus, Keys.Oem7) ;
		.OR. InListExact(e:KeyData:ToString(), "D2, Shift")
		//.or. InListExact(cChar, "@", ".", "_", "-", e"\"", "<", ">")

		DO CASE
		CASE e:KeyCode == Keys.Oemcomma .AND. e:Shift
			oMainForm:cLBSuggest_TypedChars += "<"
		CASE e:KeyCode == Keys.OemPeriod .AND. e:Shift
			oMainForm:cLBSuggest_TypedChars += ">"
		CASE e:KeyCode == Keys.OemPeriod
			oMainForm:cLBSuggest_TypedChars += "."
		CASE e:KeyCode == Keys.OemMinus .AND. e:Shift
			oMainForm:cLBSuggest_TypedChars += "_"
		CASE e:KeyCode == Keys.OemMinus
			oMainForm:cLBSuggest_TypedChars += "-"
		CASE e:KeyCode == Keys.Oem7 .AND. e:Shift
			oMainForm:cLBSuggest_TypedChars += e"\""
		CASE e:KeyCode == Keys.Oem7
			oMainForm:cLBSuggest_TypedChars += "'"
		CASE e:KeyData:ToString() == "D2, Shift"
			oMainForm:cLBSuggest_TypedChars += "@"
		OTHERWISE
			oMainForm:cLBSuggest_TypedChars += IIF(Console.CapsLock .OR. e:Shift, Chr((DWORD)e:KeyValue), Chr((DWORD)e:KeyValue):ToLower())
		ENDCASE

		// Locate appropriate item
		IF oLBSuggest:SelectedItem <> NULL
			LOCAL nIndex := oLBSuggest:FindString(oMainForm:cLBSuggest_TypedChars) AS INT
			IF nIndex == -1
				//wb(oMainForm:cLBSuggest_TypedChars)
				LBSuggestPort.Escape(oLBSuggest, oGridView, FALSE)
				RETURN
			ENDIF
			// Select the ListBoxControlItem
			oLBSuggest:SelectedIndex := nIndex
		ENDIF
	ENDCASE
RETURN


STATIC METHOD KeyPress(e AS System.Windows.Forms.KeyPressEventArgs, oLBSuggest AS ListBoxControl, oGridView AS GridView) AS System.Void
	DO CASE
	CASE e:KeyChar == Keys.Enter
		LBSuggestPort.CommonMethod(oLBSuggest, oGridView)

	CASE e:KeyChar == Keys.Escape
		IF oMainForm:cLBSuggest_TypedChars:Length  == 1 .AND. InListExact(oMainForm:cLBSuggest_TypedChars, "@", ".", "_", "-", e"\"", "<", ">")
			oMainForm:cLBSuggest_TypedChars := ""
		ENDIF
		LBSuggestPort.Escape(oLBSuggest, oGridView, TRUE)
	ENDCASE
RETURN


STATIC METHOD KeyUp(e AS System.Windows.Forms.KeyEventArgs, oLBSuggest AS ListBoxControl, oGridView AS GridView) AS VOID
	/*IF e:KeyCode == Keys.Back
		IF oMainForm:cLBSuggest_TypedChars:Length <= 1
			oMainForm:cLBSuggest_TypedChars := ""
		ENDIF
	ENDIF*/

	IF e:KeyCode == Keys.Back .and. oMainForm:cLBSuggest_TypedChars == ""
		oLBSuggest:Visible := FALSE
		oGridView:GridControl:Enabled := TRUE
		oGridView:ShowEditor()
	ENDIF
RETURN


STATIC METHOD Fill(oLBSuggest AS ListBoxControl, oGridView AS GridView, c AS STRING) AS LOGIC
	// Check if LBSuggest is already filled by the items starting with 'c'
	IF oLBSuggest:Items:Count > 0 .AND. oLBSuggest:Items[0]:ToString():StartsWith(c)
		//	LBSuggest remembers the previously highlited characters - go to the first item
//		oLBSuggest:SelectedIndex := 0
		RETURN TRUE
	ENDIF

    oLBSuggest:Parent:Cursor := System.Windows.Forms.Cursors.WaitCursor

	// Clear list
	oLBSuggest:Items:Clear()

	LOCAL oDTPort AS DataTable
	LOCAL cStatement, cItem AS STRING
	cStatement:="SELECT Port"+;
				" FROM VEPorts"+;
				" WHERE Port LIKE '"+oSoftway:ConvertWildcards(c, FALSE)+"%'"+;
				" ORDER BY Port"
	oDTPort := oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement)
	IF oDTPort:Rows:Count == 0 .AND. ! oLBSuggest:Visible
	    oLBSuggest:Parent:Cursor := System.Windows.Forms.Cursors.Default
		RETURN TRUE
	ENDIF
	//wb(cStatement+CRLF+"c="+c, oDTPort:Rows:Count)
	LOCAL n, nCount := oDTPort:Rows:Count - 1 AS INT
	FOR n:=0 UPTO nCount
		cItem := oDTPort:Rows[n]:Item["Port"]:ToString()
		oLBSuggest:Items:Add(cItem)
	NEXT

    oLBSuggest:Parent:Cursor := System.Windows.Forms.Cursors.Default

	IF oMainForm:cLBSuggest_TypedChars:Length > 0
		LOCAL nC, nLen := oMainForm:cLBSuggest_TypedChars:Length - 1 AS INT
		// Perform incremental search
		FOR nC:=0 UPTO nLen
			//SendKeys.Send(oMainForm:decimalSeparator)
			SendMessage(oLBSuggest:Handle, WinConstants.WM_CHAR, (INT)Asc(oMainForm:cLBSuggest_TypedChars:Substring(nC, 1)), 0)	// WM_CHAR=0x0102
		NEXT
	ENDIF

	IF oLBSuggest:Visible
		RETURN TRUE
	ENDIF

	// Adjust the ListBoxControl to the Bottom of the current control
	//Local nTopBootBarSize := Self:barDockControlTop:Size:Height + 2 as int
	//Local nLeftBootBarSize := Self:barDockControlLeft:Size:Width as int
	//oLBSuggest:Location:=System.Drawing.Point{Self:Parent:Location:X + nLeftBootBarSize, ;
	//											Self:Parent:Location:Y + Self:Parent:Height + nTopBootBarSize}
	//oLBSuggest:Size:=System.Drawing.Size{Self:Parent:Size:Width, 210}

	LBSuggestPort.LBSuggestEnsureVisible(oLBSuggest, oGridView)
	oLBSuggest:Focus()
	oGridView:GridControl:Enabled := FALSE

	// Assign the active GridView
	oActiveGridView := oGridView
RETURN TRUE


STATIC METHOD LBSuggestEnsureVisible(oLBSuggest AS ListBoxControl, oGridView AS GridView) AS VOID
	LOCAL oRect := LBSuggestPort.GetCellRect(oGridView) AS Rectangle
	LOCAL nHeight := 210, nY AS INT

	// Check LBSuggest's height:
	IF oGridView:GridControl:ClientRectangle:Height < nHeight
		nHeight := oGridView:GridControl:ClientRectangle:Height
		nY := oGridView:GridControl:ClientRectangle:Top
	ELSE
		DO CASE
		// Check Cell's position:
		CASE oRect:Location:Y < (INT)(oGridView:GridControl:ClientRectangle:Height / 2)
			// The Cell is near the Grid's Top
			IF oGridView:GridControl:ClientRectangle:Bottom - oRect:Top < nHeight
				nHeight := oGridView:GridControl:ClientRectangle:Bottom - oRect:Top
			ENDIF
			nY := oRect:Location:Y

		OTHERWISE
			// The Cell is near the Grid's Bottom
			IF oRect:Location:Y + oRect:Height < nHeight
				nHeight := oRect:Location:Y + oRect:Height
			ENDIF
			nY := oRect:Location:Y + oRect:Height - nHeight
		ENDCASE
	ENDIF

	IF oGridView:Name == "GridViewVoyages" .or. oGridView:Name == "GridViewRoutings"
		// Add the size of standaloneBarDockControl
		nY += 26	//SELF:standaloneBarDockControl_Voyages:Size:Height
	ENDIF

	oLBSuggest:Location:=System.Drawing.Point{oRect:Location:X, nY}
	oLBSuggest:Size := Size{oRect:Width + 20, nHeight}
	oLBSuggest:Visible := TRUE
RETURN


STATIC METHOD GetCellRect(oGridView AS GridView) AS Rectangle
	// the GetGridViewInfo function can be found in article #2624
	// GridViewInfo info = GetGridViewInfo(view);
	LOCAL info := (GridViewInfo)oGridView:GetViewInfo() AS GridViewInfo
	LOCAL cell := info:GetGridCellInfo(oGridView:FocusedRowHandle, oGridView:FocusedColumn) AS GridCellInfo
	IF cell != NULL
		RETURN cell:Bounds
	ENDIF
RETURN Rectangle.Empty


STATIC METHOD Delete(oLBSuggest AS ListBoxControl) AS VOID
	IF oLBSuggest:SelectedItem == NULL
		RETURN
	ENDIF

/*	if ! oUser:lMasterUser
		wb("This operation is not supported for Non-Master Users."+CRLF+;
			"Please ask your system administrator (or a Master User) to perform this task")
		Return
	endif*/

	LOCAL cPort := oLBSuggest:SelectedItem:ToString():Trim() AS STRING
	LOCAL cStatement, cExists AS STRING

	// Check before delete
	cStatement:="SELECT Count(*) AS nFound FROM VEDistances"+;
				" WHERE PortFrom IN"+;
				" (SELECT PORT_UID FROM VEPorts WHERE Port='"+oSoftway:ConvertWildcards(cPort, FALSE)+"')"+;
				" OR PortTo IN"+;
				" (SELECT PORT_UID FROM VEPorts WHERE Port='"+oSoftway:ConvertWildcards(cPort, FALSE)+"')"
	cExists := oSoftway:RecordExists(oMainForm:oGFH, oMainForm:oConn, cStatement, "nFound")
	IF cExists <> "0"
		ErrorBox("The Port: "+cPort+CRLF+;
					"has "+cExists+" links into the Distance Table", "Deletion aborted")
		RETURN
	ENDIF

	IF QuestionBox("Do you want to Delete the Port:"+CRLF+CRLF+;
					cPort+" ?", ;
					"Delete") == System.Windows.Forms.DialogResult.No
		//e:Cancel:=True
		RETURN
	ENDIF

	// Delete Port
	cStatement:="DELETE FROM VEPorts"+;
				" WHERE Port='"+oSoftway:ConvertWildcards(cPort, FALSE)+"'"
	IF oSoftway:AdoCommand(oMainForm:oGFH, oMainForm:oConn, cStatement)
		//Self:ReadACList()
		oLBSuggest:Items:Remove(oLBSuggest:SelectedItem)
	ENDIF
RETURN


STATIC METHOD CommonMethod(oLBSuggest AS ListBoxControl, oGridView as GridView) AS VOID
	//wb("oLBSuggest:SelectedIndex="+oLBSuggest:SelectedIndex:ToString()+CRLF+oMainForm:cLBSuggest_TypedChars+CRLF+oGridView:Name)
//TRY
	IF oLBSuggest:SelectedIndex <> -1
		//oLBSuggest:Visible := FALSE
		oGridView:GridControl:Enabled := TRUE
		oGridView:Focus()

		oGridView:ShowEditor()
		oGridView:ActiveEditor:EditValue := oLBSuggest:SelectedItem:ToString():Trim()
		//Application.DoEvents()
		oGridView:ActiveEditor:Focus()
		//Application.DoEvents()
		SendKeys.Send("{Enter}")
		oMainForm:cLBSuggest_TypedChars := ""
		//Self:SetEditModeOff_Common(SELF:GridViewVoyages, Self:oEditColumn_Routing, Self:oEditRow_Routing)
		//SELF:GridViewVoyages:ShowEditor()
	ENDIF
//CATCH e AS exception
//	ErrorBox(e:Message)
//FINALLY
	//wb(oMainForm:cLBSuggest_TypedChars+CRLF+oGridView:Name)
//END TRY
RETURN


STATIC METHOD Escape(oLBSuggest AS ListBoxControl, oGridView as GridView, lEscapePressed AS LOGIC) AS VOID
	IF ! oLBSuggest:Visible
		RETURN
	ENDIF
	oLBSuggest:Visible:=False
	oGridView:GridControl:Enabled := TRUE
	oGridView:OptionsSelection:EnableAppearanceFocusedCell := TRUE
	oGridView:Focus()

	//IF ! lEscapePressed
		//oGridView:ActiveEditor:EditValue := ""
		oGridView:ShowEditor()
		//wb(oMainForm:cLBSuggest_TypedChars+CRLF+oGridView:Name)
		IF oGridView:ActiveEditor <> NULL
			oGridView:ActiveEditor:EditValue := oMainForm:cLBSuggest_TypedChars
			oGridView:ActiveEditor:Focus()
	//		oMainForm:cLBSuggest_TypedChars := ""
			SendKeys.Send("{End}")
		ENDIF
		//Application.DoEvents()
	//ENDIF
RETURN

END CLASS


PARTIAL CLASS VoyagesForm INHERIT System.Windows.Forms.Form
//Private aACValues := {} as array

#Region RepositoryItemTextEdit_Port

METHOD CreateRepositoryItemTextEdit_Port() AS RepositoryItemTextEdit
	LOCAL RepositoryItemTextEdit_Port AS RepositoryItemTextEdit
	RepositoryItemTextEdit_Port := RepositoryItemTextEdit{}
	RepositoryItemTextEdit_Port:KeyUp += System.Windows.Forms.KeyEventHandler{ SELF, @RepositoryItemTextEdit_Port_KeyUp() }
	RepositoryItemTextEdit_Port:KeyPress += System.Windows.Forms.KeyPressEventHandler{ SELF, @RepositoryItemTextEdit_Port_KeyPress() }
RETURN RepositoryItemTextEdit_Port


METHOD RepositoryItemTextEdit_Port_KeyPress(sender AS System.OBJECT, e AS System.Windows.Forms.KeyPressEventArgs) AS VOID
	
RETURN


METHOD RepositoryItemTextEdit_Port_KeyUp(sender AS System.OBJECT, e AS System.Windows.Forms.KeyEventArgs) AS VOID
	//Local oCol := Self:GridViewAnticipated:Columns["Port"] as GridColumn
	IF oMainForm:cLBSuggest_TypedChars == ""
		RETURN
	ENDIF

	IF (e:KeyCode >= Keys.D0 .AND. e:KeyCode <= Keys.D9 ;
		.OR. e:KeyCode >= Keys.A .AND. e:KeyCode <= Keys.Z) ;
		.OR. InList(e:KeyCode, Keys.Delete, Keys.Back)

		//e:Handled := True
		//Local cFirstChar as string
		//cFirstChar := Iif(Console.CapsLock .or. e:Shift, Chr((dword)e:KeyValue), Chr((dword)e:KeyValue):ToLower())

		//SELF:LBCSuggestPort:cLBSuggest_TypedChars := SELF:cLBSuggest_TypedChars

		//SELF:LBCSuggestPort:Fill_LBSuggest(SELF:cLBSuggest_TypedChars)
		//SELF:Fill_LBSuggest(SELF:cLBSuggest_TypedChars)

		LOCAL oView:=(GridView)SELF:GridVoyages:FocusedView AS GridView
		IF oView == NULL
			RETURN
		ENDIF
		LBSuggestPort.Fill(SELF:LBSuggest, oView, oMainForm:cLBSuggest_TypedChars)
	ENDIF
RETURN

#EndRegion RepositoryItemTextEdit_Port

/*PRIVATE METHOD LBCSuggestPort_KeyDown( sender AS System.Object, e AS System.Windows.Forms.KeyEventArgs ) AS System.Void
	SELF:LBCSuggestPort:OnKeyDown(sender, e)
RETURN

PRIVATE METHOD LBCSuggestPort_KeyPress( sender AS System.Object, e AS System.Windows.Forms.KeyPressEventArgs ) AS System.Void
	SELF:LBCSuggestPort:OnKeyPress(sender, e)
RETURN

PRIVATE METHOD LBCSuggestPort_KeyUp( sender AS System.Object, e AS System.Windows.Forms.KeyEventArgs ) AS System.Void
	SELF:LBCSuggestPort:OnKeyUp(sender, e)
RETURN

PRIVATE METHOD LBCSuggestPort_Leave( sender AS System.Object, e AS System.EventArgs ) AS System.Void
	SELF:LBCSuggestPort:OnLeave(sender, e)
RETURN

PRIVATE METHOD LBCSuggestPort_MouseDoubleClick( sender AS System.Object, e AS System.Windows.Forms.MouseEventArgs ) AS System.Void
	SELF:LBCSuggestPort:OnMouseDoubleClick(sender, e)
RETURN*/

END CLASS


/*PARTIAL CLASS VoyageForm INHERIT DevExpress.XtraEditors.XtraForm
	PRIVATE LBSuggestOwner := "" AS STRING	//DevExpress.XtraEditors.SplitContainerControl

#Region RepositoryItemTextEdit_Port

METHOD CreateRepositoryItemTextEdit_Port() AS RepositoryItemTextEdit
	LOCAL RepositoryItemTextEdit_Port AS RepositoryItemTextEdit
	RepositoryItemTextEdit_Port := RepositoryItemTextEdit{}
	RepositoryItemTextEdit_Port:KeyUp += System.Windows.Forms.KeyEventHandler{ SELF, @RepositoryItemTextEdit_Port_KeyUp() }
	RepositoryItemTextEdit_Port:KeyPress += System.Windows.Forms.KeyPressEventHandler{ SELF, @RepositoryItemTextEdit_Port_KeyPress() }
RETURN RepositoryItemTextEdit_Port


METHOD RepositoryItemTextEdit_Port_KeyPress(sender AS System.OBJECT, e AS System.Windows.Forms.KeyPressEventArgs) AS VOID
	
RETURN


METHOD RepositoryItemTextEdit_Port_KeyUp(sender AS System.OBJECT, e AS System.Windows.Forms.KeyEventArgs) AS VOID
	//Local oCol := Self:GridViewAnticipated:Columns["Port"] as GridColumn
	IF oMainForm:cLBSuggest_TypedChars == ""
		RETURN
	ENDIF

	IF (e:KeyCode >= Keys.D0 .AND. e:KeyCode <= Keys.D9 ;
		.OR. e:KeyCode >= Keys.A .AND. e:KeyCode <= Keys.Z) ;
		.OR. InList(e:KeyCode, Keys.Delete, Keys.Back)

		//e:Handled := True
		//Local cFirstChar as string
		//cFirstChar := Iif(Console.CapsLock .or. e:Shift, Chr((dword)e:KeyValue), Chr((dword)e:KeyValue):ToLower())
		//SELF:Fill_LBSuggest(SELF:cLBSuggest_TypedChars)

		LOCAL oRepositoryItemTextEdit := (TextEdit)sender AS TextEdit
		LOCAL oGrid := (GridControl)oRepositoryItemTextEdit:Parent AS GridControl
		LOCAL oView := (GridView)oGrid:FocusedView AS GridView

		SELF:LBSuggestOwner := oView:Name

		LBSuggestPort.Fill(SELF:LBSuggest, oView, oMainForm:cLBSuggest_TypedChars)
	ENDIF
RETURN

#EndRegion RepositoryItemTextEdit_Port

END CLASS*/
