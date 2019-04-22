#using System.IO
#Using System.Windows.Forms
CLASS Files_Form_Office INHERIT System.Windows.Forms.Form
    EXPORT cTempDir AS System.String
    EXPORT iCountDocuments AS System.Int32
    EXPORT oButton AS Button
    EXPORT oReportForm AS ReportTabForm
    EXPORT lCanEdit AS System.Boolean
    EXPORT cPackageUid AS System.String
    EXPORT iCountSize := 0 AS System.Int32
    PRIVATE toolStrip1 AS System.Windows.Forms.ToolStrip
    PRIVATE caFilesToOpen AS System.String
    PRIVATE addFiles AS System.Windows.Forms.ToolStripButton
    PRIVATE deleteFile AS System.Windows.Forms.ToolStripButton
    PRIVATE clearFiles AS System.Windows.Forms.ToolStripButton
    EXPORT FilesListView AS System.Windows.Forms.ListView
    /// <summary>
    /// Required designer variable.
    /// </summary>
    PRIVATE components AS System.ComponentModel.IContainer
    CONSTRUCTOR()
      SUPER()
      SELF:InitializeComponent()
      RETURN
    
   /// <summary>
   /// Clean up any resources being used.
   /// </summary>
   /// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
    PROTECTED METHOD Dispose( disposing AS LOGIC ) AS VOID
      IF disposing && components != NULL
         components:Dispose()
      ENDIF
      SUPER:Dispose( disposing )
      RETURN
    
   /// <summary>
   /// Required method for Designer support - do not modify
   /// the contents of this method with the code editor.
   /// </summary>
    PRIVATE METHOD InitializeComponent() AS System.Void
        SELF:toolStrip1 := System.Windows.Forms.ToolStrip{}
        SELF:addFiles := System.Windows.Forms.ToolStripButton{}
        SELF:deleteFile := System.Windows.Forms.ToolStripButton{}
        SELF:clearFiles := System.Windows.Forms.ToolStripButton{}
        SELF:FilesListView := System.Windows.Forms.ListView{}
        SELF:toolStrip1:SuspendLayout()
        SELF:SuspendLayout()
        // 
        // toolStrip1
        // 
        SELF:toolStrip1:Items:AddRange(<System.Windows.Forms.ToolStripItem>{ SELF:addFiles, SELF:deleteFile, SELF:clearFiles })
        SELF:toolStrip1:Location := System.Drawing.Point{0, 0}
        SELF:toolStrip1:Name := "toolStrip1"
        SELF:toolStrip1:Size := System.Drawing.Size{556, 25}
        SELF:toolStrip1:TabIndex := 1
        SELF:toolStrip1:Text := "toolStrip1"
        // 
        // addFiles
        // 
        SELF:addFiles:DisplayStyle := System.Windows.Forms.ToolStripItemDisplayStyle.Text
        SELF:addFiles:ImageTransparentColor := System.Drawing.Color.Magenta
        SELF:addFiles:Name := "addFiles"
        SELF:addFiles:Size := System.Drawing.Size{54, 22}
        SELF:addFiles:Text := "Add File"
        SELF:addFiles:Click += System.EventHandler{ SELF, @addFiles_Click() }
        // 
        // deleteFile
        // 
        SELF:deleteFile:DisplayStyle := System.Windows.Forms.ToolStripItemDisplayStyle.Text
        SELF:deleteFile:ImageTransparentColor := System.Drawing.Color.Magenta
        SELF:deleteFile:Name := "deleteFile"
        SELF:deleteFile:Size := System.Drawing.Size{65, 22}
        SELF:deleteFile:Text := "Delete File"
        SELF:deleteFile:Click += System.EventHandler{ SELF, @deleteFile_Click() }
        // 
        // clearFiles
        // 
        SELF:clearFiles:DisplayStyle := System.Windows.Forms.ToolStripItemDisplayStyle.Text
        SELF:clearFiles:ImageTransparentColor := System.Drawing.Color.Magenta
        SELF:clearFiles:Name := "clearFiles"
        SELF:clearFiles:Size := System.Drawing.Size{81, 22}
        SELF:clearFiles:Text := "Clear All Files"
        SELF:clearFiles:Click += System.EventHandler{ SELF, @clearFiles_Click() }
        // 
        // FilesListView
        // 
        SELF:FilesListView:Dock := System.Windows.Forms.DockStyle.Fill
        SELF:FilesListView:Location := System.Drawing.Point{0, 25}
        SELF:FilesListView:Name := "FilesListView"
        SELF:FilesListView:Size := System.Drawing.Size{556, 201}
        SELF:FilesListView:TabIndex := 2
        SELF:FilesListView:UseCompatibleStateImageBehavior := FALSE
        SELF:FilesListView:DoubleClick += System.EventHandler{ SELF, @listView1_DoubleClick() }
        // 
        // Files_Form_Office
        // 
        SELF:AutoScaleDimensions := System.Drawing.SizeF{((Single) 6), ((Single) 13)}
        SELF:AutoScaleMode := System.Windows.Forms.AutoScaleMode.Font
        SELF:ClientSize := System.Drawing.Size{556, 226}
        SELF:Controls:Add(SELF:FilesListView)
        SELF:Controls:Add(SELF:toolStrip1)
        SELF:Name := "Files_Form_Office"
        SELF:Text := "Files Form"
        SELF:FormClosing += System.Windows.Forms.FormClosingEventHandler{ SELF, @Files_Form_FormClosing() }
        SELF:Load += System.EventHandler{ SELF, @Files_Form_Load() }
        SELF:toolStrip1:ResumeLayout(FALSE)
        SELF:toolStrip1:PerformLayout()
        SELF:ResumeLayout(FALSE)
        SELF:PerformLayout()
    PRIVATE METHOD Files_Form_Load( sender AS System.Object, e AS System.EventArgs ) AS System.Void
		System.IO.Directory.CreateDirectory(SELF:cTempDir+"\Open")
		IF !lCanEdit
			SELF:addFiles:Visible := FALSE
			SELF:clearFiles:Visible := FALSE
			SELF:deleteFile:Visible := FALSE
		ENDIF
		FilesListView:View:=View.Details
		FilesListView:FullRowSelect:=TRUE

		LOCAL oColumnHeaderAttachment:=ColumnHeader{} AS ColumnHeader
		oColumnHeaderAttachment:Text:="File"
		oColumnHeaderAttachment:TextAlign:=HorizontalAlignment.Left
		oColumnHeaderAttachment:Width:=440
		FilesListView:Columns:Add(oColumnHeaderAttachment)

		LOCAL oColumnHeaderSize:=ColumnHeader{} AS ColumnHeader
		oColumnHeaderSize:Text:="Size"
		oColumnHeaderSize:Width:=80
		oColumnHeaderSize:TextAlign:=HorizontalAlignment.Right
		FilesListView:Columns:Add(oColumnHeaderSize)	
		SELF:refreshList()
		//MessageBox.Show(self:iCountSize:ToString())
RETURN
		
PRIVATE METHOD listView1_DoubleClick( sender AS System.Object, e AS System.EventArgs ) AS System.Void
			LOCAL oListViewItem := SELF:FilesListView:FocusedItem AS 	System.Windows.Forms.ListViewItem
			TRY
				//System.Windows.Forms.MessageBox.Show(oListViewItem:tag:ToString())
				//System.IO.File.Open(oListViewItem:tag:ToString(),System.IO.FileMode.Open)
				LOCAL oProcessInfo:= System.Diagnostics.ProcessStartInfo{oListViewItem:tag:ToString()} AS System.Diagnostics.ProcessStartInfo
				System.Diagnostics.Process.Start(oProcessInfo)
			CATCH exc AS Exception
				System.Windows.Forms.MessageBox.Show("Can not open file : "+oListViewItem:Tag:ToString(),"Info")
			END
RETURN
		
    PRIVATE METHOD toolStripButton1_Click( sender AS System.Object, e AS System.EventArgs ) AS System.Void
	
RETURN
    PRIVATE METHOD Files_Form_FormClosing( sender AS System.Object, e AS System.Windows.Forms.FormClosingEventArgs ) AS System.Void
		TRY
			System.IO.Directory.Delete(SELF:cTempDir+"\Open",TRUE)
		CATCH exc AS Exception
			System.Windows.Forms.MessageBox.Show("Close All Open files first.")
			//e:Cancel := true
		END	
RETURN
 
    PRIVATE METHOD refreshList() AS System.Void
		SELF:FilesListView:Items:Clear()		
	
		LOCAL cFileName AS STRING
		LOCAL oListViewItem AS 	System.Windows.Forms.ListViewItem
		TRY
			LOCAL caFiles := System.IO.Directory.GetFiles(SELF:cTempDir) AS STRING[]
			LOCAL iCountSizeLocal as INT
			FOREACH file AS STRING IN caFiles
				IF !SELF:IfEndsWithNumberDelete(file)
					LOOP
				ENDIF
				//MessageBox.Show(SELF:GetItemUID(SELF:oButton:Name)+"//"+SELF:GetItemUID(file))
				IF !SELF:GetItemUID(SELF:oButton:Name):Equals(SELF:GetItemUID(file))
					LOOP
				ENDIF
				iCountSizeLocal := Convert.ToInt32(System.IO.FileInfo{file}:Length)
				self:iCountSize += iCountSizeLocal 
				cFileName := file:Substring(file:LastIndexOf('\\')+1)
				cFileName := cFileName:Substring(0,cFileName:LastIndexOf("."))
				//MessageBox.Show(file)
				System.IO.File.Copy(file,SELF:cTempDir+"\Open\"+cFileName,TRUE)

				
				/*oListViewItem := ListViewItem{cFileName}
				oListViewItem:SubItems:Add(SizeSuffix(INT64.Parse(iCountSizeLocal:ToString())))
				oListViewItem:Tag := SELF:cTempDir+"\Open\"+cFileName
				SELF:FilesListView:Items:Add(oListViewItem)*/

				oListViewItem:=ListViewItem{}
				oListViewItem:Name:= cFileName
				oListViewItem:Text:= cFileName
				oListViewItem:SubItems:Add(SizeSuffix(INT64.Parse(iCountSizeLocal:ToString())))
				oListViewItem:Tag := SELF:cTempDir+"\Open\"+cFileName
				// Add ListViewItem
				SELF:FilesListView:Items:Add(oListViewItem)

			NEXT
		CATCH exc AS Exception
			System.Windows.Forms.MessageBox.Show(exc:Message+CRLF+CRLF+exc:Source)
		END		
RETURN
    PUBLIC METHOD  SizeSuffix( value as Int64,  decimalPlaces := 2 as INT) as String

LOCAL SizeSuffixes := STRING[]{4} AS STRING[]
SizeSuffixes[1]:= "bytes"
SizeSuffixes[2]:= "KB"
SizeSuffixes[3]:= "MB"
SizeSuffixes[4]:= "GB"

    IF (value < 0) 
		 RETURN "-" + SizeSuffix(-value)
	ENDIF 

    IF (value == 0)  
		RETURN "0.0 bytes"
	ENDIF
    // mag is 0 for bytes, 1 for KB, 2, for MB, etc.
    local mag := (int)Math.Log(value, 1024) as INT

    // 1L << (mag * 10) == 2 ^ (10 * mag) 
    // [i.e. the number of bytes in the unit corresponding to mag]
    local adjustedSize := (decimal)value / (1 << (mag * 10)) as decimal

    // make adjustment when the value is large enough that
    // it would round up to 1000 or more
    if (Math.Round(adjustedSize, decimalPlaces) >= 1000)
        mag += 1
        adjustedSize := adjustedSize / 1024
    ENDIF

RETURN STRING.Format("{0:n" + decimalPlaces:ToString() + "} {1}", adjustedSize, SizeSuffixes[mag+1])
    PRIVATE METHOD deleteFile_Click( sender AS System.Object, e AS System.EventArgs ) AS System.Void
	TRY
		IF QuestionBox("Are you sure you want to delete :'"+SELF:FilesListView:FocusedItem:text+"' ?","Confirm") <> System.Windows.Forms.DialogResult.Yes
			RETURN 
		ENDIF
		LOCAL oListViewItem := SELF:FilesListView:FocusedItem AS System.Windows.Forms.ListViewItem
		LOCAL caMyFiles := System.IO.Directory.GetFiles(SELF:cTempDir) AS STRING[]
		FOREACH cFile AS STRING IN caMyFiles
			//System.Windows.Forms.MessageBox(cFile,)
			IF cFile:StartsWith(SELF:cTempDir+"\"+oListViewItem:text+".")
				File.Delete(cFile)
				SELF:deleteBlobFromDB(system.IO.Path.GetFileName(cFile),SELF:GetItemUID(SELF:oButton:Name),oReportForm:cMyPackageUID)
				File.Delete(oListViewItem:Tag:ToString())
				iCountDocuments--
				Application.DoEvents()
				SELF:refreshList()
				SELF:refreshButtonText()
				RETURN
			ENDIF
		NEXT
	CATCH exc AS Exception
		system.Windows.Forms.MessageBox.Show("Error on deleting file.")
	END
RETURN
	
    PRIVATE METHOD deleteBlobFromDB(file AS STRING, cItem_Uid as string, cPackage_Uid as string) as Void
	TRY
		oMainForm:deleteBlobFromDB(file,cItem_Uid,cPackage_Uid)
	CATCH exc AS Exception
		MessageBox.Show(exc:ToString())
	END
RETURN 	
	
    export method deleteAllFiles(cItemUid AS STRING) AS VOID
	oMainForm:deleteBlobFromDB(cItemUid,oReportForm:cMyPackageUID)
return
		
    PRIVATE METHOD addFiles_Click( sender AS System.Object, e AS System.EventArgs ) AS System.Void
	TRY
		LOCAL oOpenFileDialog:=  System.Windows.Forms.OpenFileDialog{} AS System.Windows.Forms.OpenFileDialog
		oOpenFileDialog:Filter:="All Files|*.*"
		oOpenFileDialog:Multiselect := TRUE
		LOCAL dr := oOpenFileDialog:ShowDialog() AS DialogResult
		IF oOpenFileDialog:FileName == ""
			RETURN
		ENDIF
		IF dr == System.Windows.Forms.DialogResult.OK
			// Read the files 
			FOREACH file AS STRING IN oOpenFileDialog:FileNames
			// 
			TRY
				LOCAL iCountSizeLocal :=0 AS INT
				iCountSizeLocal := Convert.ToInt32(System.IO.FileInfo{file}:Length) 
				IF iCountSizeLocal + SELF:iCountSize > 10000000
					MessageBox.Show("Maximum size of 10 Mbytes reached. No other file can be inserted.")
					EXIT
				ENDIF
				SELF:iCountSize += iCountSizeLocal
				LOCAL cItemUID := oReportForm:GetItemUID(oButton:name) as STRING
				System.Io.File.Copy(file,System.IO.Directory.GetCurrentDirectory()+"\TempDocs\"+ file:Substring(file:LastIndexOf('\\'))+"."+ cItemUID)
				System.Io.File.Copy(file,System.IO.Directory.GetCurrentDirectory()+"\TempDocs\Open\"+ file:Substring(file:LastIndexOf('\\')))
				SELF:addFileToDatabase(file,cItemUID,oReportForm:cMyPackageUID)
				iCountDocuments++
				Application.DoEvents()
			CATCH ex AS Exception
				// Could not load the image - probably related to Windows file system permissions.
				MessageBox.Show("Cannot open the file: " + file:Substring(file:LastIndexOf('\\')) +;
				". You may not have permission to read the file, or " +;
				"it may be corrupt. Reported error: " + ex:Message)
			END	
			NEXT
			SELF:refreshButtonText()
			SELF:refreshList()
		ENDIF
	CATCH exc AS Exception
			System.Windows.Forms.MessageBox.Show(exc:StackTrace,"Error")	
	END      
RETURN
		
    PRIVATE METHOD refreshButtonText AS VOID
	IF iCountDocuments==1
				oButton:Text := "1 File"
	ELSEIF iCountDocuments == 0
				oButton:Text := "Upload"
	ELSE 
				oButton:Text := iCountDocuments:ToString()+ " Files"
	ENDIF
RETURN
		
    PRIVATE METHOD clearFiles_Click( sender AS System.Object, e AS System.EventArgs ) AS System.Void
	TRY
		IF QuestionBox("Are you sure you want to delete all files ?","Confirm") <> System.Windows.Forms.DialogResult.Yes
			RETURN 
		ENDIF
		LOCAL caMyFiles := System.IO.Directory.GetFiles(SELF:cTempDir) AS STRING[]
		SELF:deleteAllFiles(SELF:GetItemUID(SELF:oButton:Name))
		FOREACH cFile AS STRING IN caMyFiles
				//System.Windows.Forms.MessageBox(cFile,)
				IF !SELF:GetItemUID(SELF:oButton:Name):Equals(SELF:GetItemUID(cFile))
					LOOP
				ENDIF
				File.Delete(cFile)
		NEXT
		caMyFiles := System.IO.Directory.GetFiles(SELF:cTempDir+"\Open")
		FOREACH cFile AS STRING IN caMyFiles
				//System.Windows.Forms.MessageBox(cFile,)
				File.Delete(cFile)
		NEXT
		SELF:FilesListView:Items:Clear()
		SELF:iCountDocuments := 0
		SELF:refreshButtonText()
	CATCH exc AS Exception
		system.Windows.Forms.MessageBox.Show("Error on deleting file.")
	END
RETURN
    PRIVATE METHOD GetItemUID(cName AS STRING) AS STRING
	LOCAL cIteUID := "", c AS STRING
TRY		
	LOCAL n, nLen := cName:Length - 1 AS INT
	LOCAL iTestForInt AS INT
	// Get IteUID from the right part of Control:Name
	FOR n:=nLen DOWNTO 0
		c := cName:Substring(n, 1)
		IF !int32.TryParse(c,iTestForInt)
			EXIT
		ENDIF
		cIteUID := c + cIteUID
	NEXT
CATCH
	MessageBox.show("Error while getting UID from file.")
	RETURN ""
END
RETURN cIteUID
    EXPORT METHOD IfEndsWithNumberDelete(cToTestString AS STRING) AS LOGIC
TRY		
		LOCAL chMyChar := cToTestString:Chars[cToTestString:Length-1] AS Char
				LOCAL iTestForInt AS INT
				IF !int32.TryParse(chMyChar:ToString(),iTestForInt)
					system.IO.File.Delete(cToTestString)
					RETURN FALSE
				END	
CATCH
	RETURN FALSE
END
RETURN TRUE	
    EXPORT METHOD addFileToDatabase(cFile AS STRING,cItemUid AS STRING,cPackageUIDLocal as String) AS VOID
	oMainForm:addFileToDatabase(cFile,cItemUid,cPackageUIDLocal)		
RETURN

END CLASS
