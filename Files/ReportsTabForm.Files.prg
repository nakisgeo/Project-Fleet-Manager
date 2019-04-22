// ReportTabForm_Methods.prg
#Using System.IO
#Using System.Data
#Using System.Windows.Forms
#Using System.Drawing
#Using System.Collections


PARTIAL CLASS ReportTabForm INHERIT System.Windows.Forms.Form


PRIVATE iCountSize := 0 AS INT	

PRIVATE METHOD File_Button_Clicked( sender AS System.Object, e AS System.EventArgs ) AS System.Void
	TRY
		LOCAL oButton := (Button)sender as Button
		IF oButton:Text:Contains("File")
			//MessageBox.Show("File")
			/////////////////////////////////////////////////////////////////////////////////////////////////////////////05.01.17
			IF (oMainForm:oConnBlob == NULL .OR. oMainForm:oConnBlob:State == ConnectionState.Closed)
				oMainForm:oConnBlob:Open()	
			ENDIF
			LOCAL cButtonName := oButton:Name AS STRING //:= "FileUploader" + cItemUID
			cButtonName := cButtonName:Replace("FileUploader","")
			LOCAL oFilesTempDT, oFileTempDT AS DataTable
			LOCAL cStatement:=" SELECT ITEM_UID,FileName FROM FMBlobData "+oMainForm:cNoLockTerm+;
							  " WHERE PACKAGE_UID="+self:cMyPackageUID+" AND ITEM_UID="+cButtonName AS STRING
			oFilesTempDT := oSoftway:ResultTable(oMainForm:oGFHBlob, oMainForm:oConnBlob, cStatement)
		
			IF oFilesTempDT != null .and. oFilesTempDT:Rows:Count > 0
				local iCountRows := oFilesTempDT:Rows:Count, i as INT
				FOR i := 0 UPTO iCountRows-1 STEP 1
					cStatement:=" SELECT  BlobData FROM FMBlobData "+oMainForm:cNoLockTerm+;
								" WHERE PACKAGE_UID="+self:cMyPackageUID+" AND Item_UID="+cButtonName+;
								" AND  FileName='"+oFilesTempDT:Rows[i]:Item["FileName"]:ToString()+"'"
					oFileTempDT := oSoftway:ResultTable(oMainForm:oGFHBlob, oMainForm:oConnBlob, cStatement) 
					local oData := (BYTE[]) oFileTempDT:Rows[0]:Item["BlobData"]  as  BYTE[]
					IF oData <> NULL .and. oData:Length>0 
						local cFileName := oFilesTempDT:Rows[i]:Item["FileName"]:ToString() as String
						local cButtonId := oFilesTempDT:Rows[i]:Item["ITEM_UID"]:ToString() as String
						LOCAL oFS AS FileStream
						LOCAL oBinaryWriter as BinaryWriter
						TRY
							IF File.Exists(SELF:cTempDocsDir+"\"+cFileName)
								File.Delete(SELF:cTempDocsDir+"\"+cFileName)
							ENDIF
							oFS  :=FileStream{SELF:cTempDocsDir+"\"+cFileName, FileMode.CreateNew}
						CATCH exc AS Exception
							MessageBox.Show("An issue presented while extracting the file :"+cFileName+". Press ok to continue.")
						END
						//oFS:Write(oBinary, 0, oBinary:Length)
						oBinaryWriter:=BinaryWriter{oFS}
						oBinaryWriter:Write(oData)
						//oFS:Write(oData, 0, oData:Length)
						oBinaryWriter:Close()
						oFS:Close()
						oData := null
					ENDIF	
					oFileTempDT:Clear()
					oFileTempDT:=null	
				NEXT
				oFilesTempDT:Clear()
				oFilesTempDT:=null
			ENDIF
			oMainForm:oConnBlob:Close() 
			///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
			LOCAL oFiles_Form := Files_Form_Office{} AS Files_Form_Office
			oFiles_Form:cTempDir := cTempDocsDir
			oFiles_Form:iCountDocuments := int32.Parse(oButton:Text:Substring(0,oButton:Text:LastIndexOf(" ")))
			oFiles_Form:oButton := oButton
			oFiles_Form:oReportForm := SELF
			LOCAL oRowLocal := oMainForm:returnUserSetting(oUser:USER_UNIQUEID) AS DataRow
			IF (oRowLocal == NULL || oRowLocal["CanEditReportData"]:ToString() == "False") 
				IF (oMainForm:checkIFUserIsCreatorOfThePachage(self:cMyPackageUID) && oMainForm:LBCReportsOffice:Visible == TRUE)
					oFiles_Form:lCanEdit := TRUE
				else
					oFiles_Form:lCanEdit := FALSE
				endif
			ELSE
				oFiles_Form:lCanEdit := true
			ENDIF
		
			IF !SELF:lisInEditMode 
				oFiles_Form:lCanEdit := FALSE
			ENDIF
		
			oFiles_Form:Show()
			RETURN
		ELSE
			IF !SELF:lisInEditMode 
				RETURN
			ENDIF
			//MessageBox.Show("Else")
			LOCAL iCountFiles := 0 AS INT
			LOCAL cItemUID := SELF:GetFileUID(oButton:name) as String
	
			LOCAL oOpenFileDialog:=  System.Windows.Forms.OpenFileDialog{} AS System.Windows.Forms.OpenFileDialog
			oOpenFileDialog:Filter:="All Files|*.*"
			oOpenFileDialog:Multiselect := TRUE
			LOCAL dr := oOpenFileDialog:ShowDialog() AS System.Windows.Forms.DialogResult
			IF oOpenFileDialog:FileName == ""
				RETURN
			ENDIF
			SELF:iCountSize := 0
			IF dr == System.Windows.Forms.DialogResult.OK
				FOREACH file AS STRING IN oOpenFileDialog:FileNames
				TRY
					LOCAL iCountSizeLocal :=0 AS INT
					iCountSizeLocal := Convert.ToInt32(System.IO.FileInfo{file}:Length) 
					IF iCountSizeLocal + SELF:iCountSize > 10000000
						MessageBox.Show("Maximum size of 10 Mbytes reached. No other file can be inserted.")
						EXIT
					ENDIF
					SELF:iCountSize += iCountSizeLocal
					System.Io.File.Copy(file,System.IO.Directory.GetCurrentDirectory()+"\TempDocs\"+ file:Substring(file:LastIndexOf('\\'))+"."+ cItemUID)
					oMainForm:addFileToDatabase(file,cItemUID,self:cMyPackageUID)	
					iCountFiles++
				CATCH ex AS Exception
					// Could not load the image - probably related to Windows file system permissions.
					MessageBox.Show("Cannot open the file: " + file:Substring(file:LastIndexOf('\\')) +;
					". You may not have permission to read the file, or " +;
					"it may be corrupt.\r\nReported error: " + ex:Message)
					Application.DoEvents()
					LOOP
				END	
				NEXT
				IF iCountFiles==1
					oButton:Text := "1 File"
				ELSE
					oButton:Text := iCountFiles:ToString()+ " Files"
				ENDIF
			ENDIF
		ENDIF
	CATCH exc AS Exception
			MessageBox.Show(exc:ToString(),"Error")	
	END					
RETURN

END CLASS