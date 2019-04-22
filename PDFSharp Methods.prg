// AppFormClass_ExportToPDF.prg
#Using System.Windows.Forms
#Using System.Drawing
#using System.Drawing.Imaging
#USING System.Diagnostics
#using PdfSharp.Pdf
#using PdfSharp.Pdf.Printing
#USING PdfSharp.Drawing



[System.Runtime.InteropServices.DllImportAttribute("GDI32.dll")];
_DLL FUNC BitBlt(hdcDest AS System.IntPtr, nXDest AS INT, nYDest AS INT, nWidth AS INT, nHeight AS INT,;
	hdcSrc AS System.IntPtr, nXSrc AS INT, nYSrc AS INT, dwRop AS System.Int32);
	AS LOGIC PASCAL:GDI32.BitBlt


PARTIAL CLASS ReportTabForm INHERIT System.Windows.Forms.Form
	PRIVATE oBitmap AS Bitmap
	PRIVATE oXGraphics AS XGraphics
	PRIVATE oPdfDocument AS PdfDocument
	PRIVATE oPdfPage AS PdfPage
	// Object to be released:
	PRIVATE oXImages AS XImage[]
	//PRIVATE oXImage AS XImage
	PRIVATE cImageFile AS STRING
	PRIVATE cPDFFile AS STRING

	EXPORT IsLandscape AS LOGIC

Export METHOD Form_ExportToPDF(lPrintPDF := false AS LOGIC) AS VOID
	//Graphics g1 = SELF:CreateGraphics()
	//Image MyImage = new Bitmap(SELF:tabControl_Report:TabPages[0]:Size.Width, SELF:tabControl_Report:TabPages[0]:Size.Height, g1)
	LOCAL oScreen := System.Windows.Forms.Screen.PrimaryScreen AS System.Windows.Forms.Screen
	LOCAL iScreenHeight := oScreen:Bounds:Height as INT
	LOCAL A4prefHeight := iScreenHeight-56 AS INT
	LOCAL cPdfName := SELF:Text:Replace("/",".") AS STRING
	cPdfName := cPdfName:Replace(":","_")
	
	SELF:cPDFFile := oMainForm:cTempDocDir+"\"+cPdfName+".PDF"

	// Create a new PDF document
	oPdfDocument := PdfDocument{}
	oPdfDocument:Info:Title := "Created by Softway Fleet Manager"

	//LOCAL oImage AS System.Drawing.Image

	IF SELF:tabControl_Report == NULL
		// PMSForm without TabControl
		//IF SELF:IPanel == NULL
			// No TabControl - No Panel
		//	RETURN
		//ENDIF

		SELF:oXImages := XImage[]{1}

		// Hide the ButtonAddNew for E13
		/*LOCAL oControl := SELF:FindField("BUTTONADDNEW", SELF:IPanel:Controls) AS Control
		IF oControl <> NULL
			oControl:Visible := FALSE
		ENDIF*/

		// Use Form's Panel:
		//MessageBox.Show(SELF:tabControl_Report:Height:ToString())
		oBitmap := Bitmap{SELF:tabControl_Report:Width, SELF:tabControl_Report:Height}
		SELF:tabControl_Report:DrawToBitmap(oBitmap, Rectangle{0, 0, oBitmap:Width, oBitmap:Height})

		// Show the ButtonAddNew for E13
		//IF oControl <> NULL
		//	oControl:Visible := TRUE
		//ENDIF

		SELF:cImageFile := oMainForm:cTempDocDir+"\"+SELF:Name+" Page 1.PNG"
		oBitmap:Save(SELF:cImageFile, ImageFormat.Png)

		// Create an empty page
		oPdfPage := oPdfDocument:AddPage()
		//wb(oPdfDocument:PageCount)

		// A4: 778 x 1100: ratio: 0,707

		// Set Page size to A4
		oPdfPage:Size := PdfSharp.PageSize.A4

		IF SELF:IsLandscape
			// Set Orientation
			oPdfPage:Orientation := PdfSharp.PageOrientation.Landscape
		ENDIF

		// Get an XGraphics object for drawing
		oXGraphics := XGraphics.FromPdfPage(oPdfPage)

		//// Create a font
		//XFont font = new XFont("Verdana", 20, XFontStyle.BoldItalic)
		//// Draw the text
		//oXGraphics.DrawString("Hello World", font, XBrushes.Black,
		//  new XRect(0, 0, oPdfPage.Width, oPdfPage.Height),
		//  XStringFormats.Center)

		SELF:DrawImage(SELF:cImageFile, oXGraphics, oPdfPage, 1)
		// Save the document...
		TRY
			oPdfDocument:Save(SELF:cPDFFile)
			SELF:CreatePDFProcess(lPrintPDF)
		CATCH oe AS Exception
			MessageBox.Show(oe:Message, "Error creating PDF", MessageBoxButtons.OK, MessageBoxIcon.Error)
		END TRY
		RETURN
	ENDIF
	//Count The pages needed
	LOCAL nCountPagesNeeded := 0 AS INT
	FOREACH oTabPage AS System.Windows.Forms.TabPage IN SELF:tabControl_Report:TabPages
		
		IF oTabPage:PreferredSize:Height > A4prefHeight
			LOCAL dDouble := (Decimal)oTabPage:PreferredSize:Height/(Decimal)A4prefHeight AS Decimal
			nCountPagesNeeded := nCountPagesNeeded + (int)Math.Ceiling(dDouble)
		ELSE
			nCountPagesNeeded := nCountPagesNeeded + 1
		ENDIF
	NEXT
	//
	SELF:oXImages := XImage[]{nCountPagesNeeded}
	//MessageBox.Show(nCountPagesNeeded:ToString())
	
	LOCAL n := 0, /*nPages := nCountPagesNeeded - 1,*/ iPage := 0, iCounter AS INT
	FOREACH oTabPage AS System.Windows.Forms.TabPage IN SELF:tabControl_Report:TabPages
		SELF:tabControl_Report:SelectedIndex := n
		Application.DoEvents()

		// Use TabPage
		//oBitmap := Bitmap{SELF:tabControl_Report:TabPages[n]:Width, SELF:tabControl_Report:TabPages[n]:Height}
		//SELF:tabControl_Report:TabPages[n]:DrawToBitmap(oBitmap, Rectangle{0, 0, oBitmap:Width, oBitmap:Height})

		// Use TabControl + TabPage
		//MessageBox.Show(oTabPage:PreferredSize:Width:ToString()+"/"+oTabPage:PreferredSize:Height:ToString())
		SELF:Width := oTabPage:PreferredSize:Width+100
		SELF:Height:= oTabPage:PreferredSize:Height+100
		//SELF:Height := 1024
		
		IF oTabPage:PreferredSize:Height < A4prefHeight
			oBitmap := Bitmap{oTabPage:PreferredSize:Width, oTabPage:PreferredSize:Height}
			oTabPage:DrawToBitmap(oBitmap, Rectangle{0, 0, oBitmap:Width, oBitmap:Height})
			SELF:cImageFile := oMainForm:cTempDocDir+"\"+SELF:Name+" Page "+(iPage+1):ToString()+".PNG"
			oBitmap:Save(SELF:cImageFile, ImageFormat.Png)
			oPdfPage := oPdfDocument:AddPage()
			oPdfPage:Size := PdfSharp.PageSize.A4
			IF SELF:IsLandscape
				// Set Orientation
				oPdfPage:Orientation := PdfSharp.PageOrientation.Landscape
			ENDIF
			oXGraphics := XGraphics.FromPdfPage(oPdfPage)
			SELF:DrawImage(SELF:cImageFile, oXGraphics, oPdfPage, iPage + 1)
			iPage := iPage+1
		ELSE
			LOCAL dDouble := (Decimal)oTabPage:PreferredSize:Height/(Decimal)A4prefHeight AS Decimal
			/*LOCAL iHeight as INT*/
			LOCAL nLocalCountPagesNeeded :=  (INT)Math.Ceiling(dDouble) AS INT
				FOR iCounter:=0 UPTO nLocalCountPagesNeeded-1
					//IF iCounter < nLocalCountPagesNeeded-1
						oBitmap := Bitmap{oTabPage:PreferredSize:Width, A4prefHeight}
						LOCAL oPoint := Point{0,iCounter*A4prefHeight} AS Point
						oTabPage:AutoScrollPosition := oPoint 
						Application.DoEvents()
						oTabPage:DrawToBitmap(oBitmap, Rectangle{0, 0, oBitmap:Width, oBitmap:Height})
						SELF:cImageFile := oMainForm:cTempDocDir+"\"+SELF:Name+" Page "+(iPage+1):ToString()+".PNG"
						oBitmap:Save(SELF:cImageFile, ImageFormat.Png)
						oPdfPage := oPdfDocument:AddPage()
						oPdfPage:Size := PdfSharp.PageSize.A4
						//LOCAL a4w := oPdfPage:Size AS PdfSharp.PageSize
						IF SELF:IsLandscape
							// Set Orientation
							oPdfPage:Orientation := PdfSharp.PageOrientation.Landscape
						ENDIF
						oXGraphics := XGraphics.FromPdfPage(oPdfPage)
						SELF:DrawImage(SELF:cImageFile, oXGraphics, oPdfPage, iPage + 1)
						iPage := iPage+1
					/*ELSE
						LOCAL iRemain := oTabPage:PreferredSize:Height%A4prefHeight as INT
						oBitmap := Bitmap{oTabPage:PreferredSize:Width, A4prefHeight}
						LOCAL oPoint := Point{0,iCounter*A4prefHeight} AS Point
						oTabPage:AutoScrollPosition := oPoint 
						Application.DoEvents()
						LOCAL iStartFromHeight := A4prefHeight-iRemain AS INT
						LOCAL oRect := Rectangle{0,iStartFromHeight,oBitmap:Width,iRemain} AS Rectangle
						oRect:Y := iStartFromHeight
						oTabPage:DrawToBitmap(oBitmap, oRect)
						SELF:cImageFile := oMainForm:cTempDocDir+"\"+SELF:Name+" Page "+(iPage+1):ToString()+".PNG"
						oBitmap:Save(SELF:cImageFile, ImageFormat.Png)
						oPdfPage := oPdfDocument:AddPage()
						oPdfPage:Size := PdfSharp.PageSize.A4
						LOCAL a4w := oPdfPage:Size AS PdfSharp.PageSize
						IF SELF:IsLandscape
							// Set Orientation
							oPdfPage:Orientation := PdfSharp.PageOrientation.Landscape
						ENDIF
						oXGraphics := XGraphics.FromPdfPage(oPdfPage)
						SELF:DrawImage(SELF:cImageFile, oXGraphics, oPdfPage, iPage + 1)
						iPage := iPage+1
					ENDIF*/
				next
		ENDIF
		//oImage := System.Drawing.Image.FromHbitmap(SELF:tabControl_Report:Handle)
		//SELF:DrawImage(oImage, oXGraphics, oPdfPage)
		//oImage:Dispose()
		n := n+1 
	NEXT

	// Save the document...
	TRY
		oPdfDocument:Save(SELF:cPDFFile)
		SELF:CreatePDFProcess(lPrintPDF)
	CATCH oe AS Exception
		MessageBox.Show(oe:Message, "Error creating PDF", MessageBoxButtons.OK, MessageBoxIcon.Error)
	END TRY
RETURN


/// Draws an image in original size using a disk file
METHOD DrawImage(cImageFile AS STRING, oXGraphics AS XGraphics, oPdfPage AS PdfPage, nPage AS INT) AS VOID
	//BeginBox(oXGraphics, number, "DrawImage (original)")
	//LOCAL oXImageLocal := SELF:oXImages[nPage] AS XImage
	//oXImageLocal := XImage.FromFile(cImageFile)
	SELF:oXImages[nPage] := XImage.FromFile(cImageFile)
	//SELF:oXImage := XImage.FromFile(cImageFile)

	//LOCAL image := XImage.FromFile(cImageFile) AS XImage

	// Left position in point
	//double x = (250 - image.PixelWidth * 72 / image.HorizontalResolution) / 2
	//oXGraphics.DrawImage(image, x, 0)

	//double nPageRatio = oPdfPage.Width / oPdfPage.Height
	//double nIgameRation = image.PixelWidth / image.PixelHeight

	LOCAL nRatioWidth := (Double)oPdfPage:Width / (Double)SELF:oXImages[nPage]:PixelWidth AS Double
	LOCAL nRatioHeight := (Double)oPdfPage:Height / (Double)SELF:oXImages[nPage]:PixelHeight AS Double
	LOCAL nRationMin := Iif(nRatioWidth < nRatioHeight, nRatioWidth, nRatioHeight) AS Double
	//oXGraphics.DrawImage(image, 0, 0, oPdfPage.Width, oPdfPage.Height)
	oXGraphics:DrawImage(SELF:oXImages[nPage], 0, 0, nRationMin * SELF:oXImages[nPage]:PixelWidth, nRationMin * SELF:oXImages[nPage]:PixelHeight)
	//EndBox(oXGraphics)
RETURN


/*/// Draws an image in original size using a System.Drawing.Image
METHOD DrawImage(oImage AS System.Drawing.Image, oXGraphics AS XGraphics, oPdfPage AS PdfPage) AS VOID
	//BeginBox(oXGraphics, number, "DrawImage (original)")
	LOCAL image := XImage.FromGdiPlusImage(oImage) AS XImage

	// Left position in point
	//double x = (250 - image.PixelWidth * 72 / image.HorizontalResolution) / 2
	//oXGraphics.DrawImage(image, x, 0)

	//double nPageRatio = oPdfPage.Width / oPdfPage.Height
	//double nIgameRation = image.PixelWidth / image.PixelHeight

	LOCAL nRatioWidth := (Double)oPdfPage:Width / (Double)image:PixelWidth AS Double
	LOCAL nRatioHeight := (Double)oPdfPage:Height / (Double)image:PixelHeight AS Double
	LOCAL nRationMin := Iif(nRatioWidth < nRatioHeight, nRatioWidth, nRatioHeight) AS Double
	//oXGraphics.DrawImage(image, 0, 0, oPdfPage.Width, oPdfPage.Height)
	oXGraphics:DrawImage(image, 0, 0, nRationMin * image:PixelWidth, nRationMin * image:PixelHeight)
	//EndBox(oXGraphics)
RETURN*/


METHOD CreatePDFProcess(lPrintPDF := false AS LOGIC) AS VOID
	//Process.Start(SELF:cPDFFile)

	LOCAL oPdfProcess := Process{} AS Process

/*	AcroRd32.exe <filename>
	 The following switches are available:
	 /n - Launch a new instance of Reader even if one is already open
	 /s - Don't show the splash screen
	 /o - Don't show the open file dialog
	 /h - Open as a minimized window
	 /p <filename> - Open and go straight to the print dialog
	 /t <filename> <printername> <drivername> <portname> - Print the file the specified printer.*/

	/*IF lPrintPDF
		//FOR STARBULK OR ACROBAT PROFESSIONAL
		//oPdfProcess:StartInfo:FileName := "Acrobat.exe"
		//oPdfProcess:StartInfo:FileName := "AcroRd32.exe"
		oPdfProcess:StartInfo:FileName := SELF:GetAcrobatExe()
		//oPdfProcess:StartInfo:FileName := "C:\Program Files (x86)\Adobe\Reader 9.0\Reader\AcroRD32.EXE"
		IF oPdfProcess:StartInfo:FileName == ""
			MessageBox.Show("No Adobe Acrobat/Adobe Reader found in Registry", "Adobe not installed", MessageBoxButtons.OK, MessageBoxIcon.Error)
			RETURN
		//ELSE
			//MessageBox.Show(oPdfProcess:StartInfo:FileName, "Adobe", MessageBoxButtons.OK, MessageBoxIcon.Information)
		ENDIF

		LOCAL oPrinter := SELF:GetDefaultPrinterObject() AS System.Management.ManagementObject
		IF oPrinter == NULL
			wb("No default Printer found")
			RETURN
		ENDIF
		LOCAL cPrinterName := oPrinter:Properties["DeviceID"]:Value:ToString() AS STRING
		LOCAL cDriverName := oPrinter:Properties["DriverName"]:Value:ToString() AS STRING
		LOCAL cPortName := oPrinter:Properties["PortName"]:Value:ToString() AS STRING
		oPdfProcess:StartInfo:Arguments := " /t " + e"\"" + SELF:cPDFFile + e"\"" +;
											" "+e"\""+cPrinterName+e"\"" + " "+e"\""+cDriverName+e"\"" + " "+e"\""+cPortName+e"\""
		//oPdfProcess:StartInfo:Arguments := " /p " + e"\"" + SELF:cPDFFile + e"\""
		//wb(oPdfProcess:StartInfo:FileName+" "+oPdfProcess:StartInfo:Arguments)
	ELSE*/
		oPdfProcess:StartInfo:FileName := SELF:cPDFFile
	//ENDIF

	oPdfProcess:StartInfo:WindowStyle := ProcessWindowStyle.Maximized

	//IF lPrintPDF
	//	oPdfProcess:EnableRaisingEvents := TRUE
	//	oPdfProcess:Exited += EventHandler{SELF, @oPdfProcess_Exited()}
	//ENDIF

	IF oPdfProcess:Start()
		// Async mode:
		//oPdfProcess:WaitForInputIdle()
		//oPdfProcess:Exited += EventHandler{SELF, @oPdfProcess_Exited()}

		IF lPrintPDF
			//LOCAL oPrinter := SELF:GetDefaultPrinterObject() AS System.Management.ManagementObject
			//IF oPrinter == NULL
			//	wb("No default Printer found")
			//	RETURN
			//ENDIF
			//LOCAL cPrinterName := oPrinter:Properties["DeviceID"]:Value:ToString() AS STRING

			//LOCAL oPdfFilePrinter := PdfFilePrinter{SELF:cPDFFile, cPrinterName} AS PdfFilePrinter
			//oPdfFilePrinter:Print(3000)
			//Application.DoEvents()

			//oPdfProcess:Close()
			//oPdfProcess:CloseMainWindow()
			//WHILE ! oPdfProcess:HasExited
			//	Application.DoEvents()
			//ENDDO
			//WHILE ! oPdfProcess:CloseMainWindow()
			//	Application.DoEvents()
			//ENDDO
			//oPdfProcess:Close()
			System.Threading.Thread.Sleep(7000)
			Application.DoEvents()
			oPdfProcess:Kill()
//wb(oPdfProcess:HasExited:ToString(), "HasExited")
		//ELSE
			// Sync mode:
			//oPdfProcess:WaitForExit()
		ENDIF
			LOCAL n, nPos := SELF:cImageFile:LastIndexOf(" ") + 1 AS INT
			LOCAL cDeleteFile AS STRING
			FOR n:=1 UPTO SELF:oXImages:Length
				SELF:oXImages[n]:Dispose()

				//IF SELF:lDeletePageImageFile
					// Delete cImageFile
					cDeleteFile := SELF:cImageFile:Substring(0, nPos) + n:ToString() + ".PNG"
					System.IO.File.Delete(cDeleteFile)
				//ENDIF
			NEXT
			//IF SELF:lDeletePageImageFile
				// Delete cPDFFile
			//	System.IO.File.Delete(SELF:cPDFFile)
			//ENDIF
		//ENDIF

		//wb("oPdfProcess:Id="+oPdfProcess:Id:ToString(), "ExitCode="+oPdfProcess:ExitCode:ToString())
		// Release SELF:oXImage
		//SELF:oXImage:Dispose()
	ENDIF
RETURN


//METHOD oPdfProcess_Exited(sender AS OBJECT, e AS System.EventArgs) AS VOID
//LOCAL nExitCode := ((Process)sender):ExitCode AS INT
////LOCAL nId := ((Process)sender):Id AS INT

//	wb("nExitCode="+nExitCode:ToString())

//	// The AcrobatReader return nExitCode=1
//	IF nExitCode == 1
//		LOCAL n, nPos := SELF:cImageFile:LastIndexOf(" ") + 1 AS INT
//		LOCAL cDeleteFile AS STRING
//		FOR n:=1 UPTO SELF:oXImages:Length
//			SELF:oXImages[n]:Dispose()

//			IF SELF:lDeletePageImageFile
//				// Delete cImageFile
//				cDeleteFile := SELF:cImageFile:Substring(0, nPos) + n:ToString() + ".PNG"
//				System.IO.File.Delete(cDeleteFile)
//			ENDIF
//		NEXT
//		IF SELF:lDeletePageImageFile
//			// Delete cPDFFile
//			System.IO.File.Delete(SELF:cPDFFile)
//		ENDIF
//	ENDIF
//RETURN

END CLASS
