//// ISM_Form_SearchAndReplace.prg
//#USING System.Diagnostics
//#USING System.Runtime.InteropServices
//#USING System.Reflection
//#USING System.Collections
//#USING System.Collections.Generic
//#Using System.Collections.Specialized
//#USING System.Threading
//#Using System.Windows.Forms
//#USING Microsoft.Office.Interop.Word

//PARTIAL CLASS MainForm INHERIT DevExpress.XtraEditors.XtraForm

//METHOD IsmForm() AS VOID
//	LOCAL oOpenFileDialog:=OpenFileDialog{} AS OpenFileDialog
//	oOpenFileDialog:Filter:="Word documents|*.Docx|Word documents|*.Doc"
//	oOpenFileDialog:ShowDialog()
//	IF oOpenFileDialog:FileName == ""
//		RETURN
//	ENDIF

//	//Local cDocName:="C:\Users\George\Documents\Visual Studio 2008\Projects\eMaintenanceSystem\Debug\_e5.doc" as string
//	LOCAL cDocName:=oOpenFileDialog:FileName AS STRING

//	IF ! oSoftway:GetExtension(cDocName):ToUpper():Contains("DOC")
//		ErrorBox("Cannot import the file: "+cDocName)
//		RETURN
//	ENDIF
//	SELF:MSWordDocAnalyse(cDocName)
//RETURN


//METHOD MSWordDocAnalyse(cDocName AS STRING) AS VOID
//	LOCAL oWordApp AS Microsoft.Office.Interop.Word.Application
//	LOCAL oDoc AS Microsoft.Office.Interop.Word.Document
//	LOCAL documents AS documents
//	//LOCAL range AS Range
//	LOCAL missing AS OBJECT

//	missing := System.Reflection.Missing.Value

//	oWordApp := Microsoft.Office.Interop.Word.Application{}
//	documents := oWordApp:documents
//	oWordApp:Visible := TRUE	// FALSE

//	LOCAL oDocName := (OBJECT)cDocName AS OBJECT
//	LOCAL readOnly := FALSE AS OBJECT
//	LOCAL isVisible := TRUE AS OBJECT

//	oDoc := documents:Open(oDocName, missing, readOnly, missing, missing, missing, missing, missing, missing, missing, missing, ;
//											 isVisible, missing, missing, missing, missing)
//	//oDoc:=documents:Open(oDocName, missing, missing, missing, missing, missing, missing, missing, missing, missing, missing, ;
//	//										 missing, missing, missing, missing, missing)

//	oDoc:Activate()

////	LOCAL cDocCaption:=oSoftway:GetFileName(cDocName)+" - Microsoft Word" AS STRING

//	//range := oDoc:Range(@missing, @missing)
//	//range:Text := "Vulcan creates Word document. (Document will be discarded after 5 seconds)"

//	//self:ShowDocumentsCount(documents)
//	//oWBTimed:Dispose()

//	//oWordApp:Activate()
//	//oSoftway:SetForegroundWindow(NULL, cDocCaption)	//"Document1 - Microsoft Word")

//	TRY
//		SELF:ReadDocument(oWordApp, oDoc, cDocName)
//	CATCH e AS Exception
//		ErrorBox(e:Message)
//	FINALLY
//		oDoc:Close(missing, missing, missing)
//		oWordApp:Application:Quit(missing, missing, missing)
//	END TRY
//RETURN


//METHOD ReadDocument(oWordApp AS Microsoft.Office.Interop.Word.Application, oDoc AS Microsoft.Office.Interop.Word.Document, cDocName AS STRING) AS VOID
//	LOCAL cBuffer AS STRING
//	LOCAL aData := List<STRING>{} AS List<STRING>

//	FOREACH oParagraph AS Paragraph IN oDoc:Paragraphs
//		cBuffer := oParagraph:Range:Text:Trim()
//		IF cBuffer != STRING.Empty
//			aData:Add(cBuffer)
//		ENDIF
//	NEXT

//	LOCAL cStr AS STRING
//	FOREACH c AS STRING IN aData
//		cStr += c + CRLF
//	NEXT

//	// select whole data from active window document
//	oDoc:ActiveWindow:Selection:WholeStory()

//	SELF:FindAndReplace(oWordApp, "<204>", "12,45")
//	//SELF:FindAndReplace(oWordApp, "<205>", 12.45)

//	LOCAL missing AS OBJECT
//	missing := System.Reflection.Missing.Value

//	// SaveAs Document
//	LOCAL cSavedDoc := oSoftway:GetFilePath(cDocName)+"\"+oSoftway:GetFileName(cDocName)+"-1.Docx" AS OBJECT
//	oDoc:SaveAs(cSavedDoc, missing, missing, missing, missing, missing, missing, missing, missing, missing, missing, ;
//											 missing, missing, missing, missing, missing)


//	//LOCAL cFileName := oSoftway:GetFilePath(cDocName)+"\"+oSoftway:GetFileName(cDocName)+".TXT" AS STRING
//	//MemoWrit(cFileName, cStr)

//	//InfoBox(cFileName)

//	//LOCAL oProcessInfo:=ProcessStartInfo{cFileName} AS ProcessStartInfo
//	////oProcessInfo:CreateNoWindow := false
//	////oProcessInfo:UseShellExecute := true
//	//Process.Start(oProcessInfo)
//RETURN


//METHOD FindAndReplace(oWordApp AS Microsoft.Office.Interop.Word.Application, FindText AS STRING, ReplaceWith AS STRING) AS VOID
//	LOCAL matchCase := TRUE AS OBJECT
//	LOCAL matchWholeWord := TRUE AS OBJECT
//	LOCAL matchWildCards := FALSE AS OBJECT
//	LOCAL matchSoundsLike := FALSE AS OBJECT
//	LOCAL matchAllWordForms := FALSE AS OBJECT
//	LOCAL forward := TRUE AS OBJECT
//	LOCAL wrap := 1 AS OBJECT
//	LOCAL format := FALSE AS OBJECT
//	LOCAL replace := 2 AS OBJECT
//	LOCAL matchKashida := FALSE AS OBJECT
//	LOCAL matchDiacritics := FALSE AS OBJECT
//	LOCAL matchAlefHamza := FALSE AS OBJECT
//	LOCAL matchControl := FALSE AS OBJECT
//	//LOCAL read_only := FALSE AS OBJECT
//	//LOCAL visible := TRUE AS OBJECT
//	LOCAL oFindText := (OBJECT)FindText AS OBJECT
//	LOCAL oReplaceWith := (OBJECT)ReplaceWith AS OBJECT

////LOCAL oRange := oWordApp:Selection:Range AS Range
////wb(oRange:Characters:Count, "Len")

//	TRY
//		oWordApp:Selection:Find:Execute(oFindText, matchCase, matchWholeWord, matchWildCards, matchSoundsLike, matchAllWordForms, ;
//									forward, wrap, format, oReplaceWith, replace, matchKashida, matchDiacritics, matchAlefHamza, matchControl)
//	CATCH e AS Exception
//		ErrorBox(e:Message)
//	END TRY
//RETURN

//END CLASS
