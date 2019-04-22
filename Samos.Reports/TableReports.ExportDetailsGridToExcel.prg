// TableReports.prg
#Using System.Data
#Using System.Data.Common
#Using System.Windows.Forms
#Using System.Diagnostics
#USING System.Threading
#Using Microsoft.Office.Interop.Excel
#Using System.Drawing
#Using System.IO
#USING System.Reflection
#Using System.Collections

PARTIAL CLASS TableReportsSelectionForm INHERIT System.Windows.Forms.Form

PRIVATE METHOD exportGridToExcelToolStripMenuItemClick() AS System.Void

			local cFile := cTempDocDir+"\FindingsResult_on_"+Datetime.Now:ToString("dd_MM_yyyy__HH_mm_ss")+".xls" as String
			IF gcDetails:Datasource<>null
				gcDetails:ExportToXls(cFile)

				LOCAL oXL AS Microsoft.Office.Interop.Excel.Application
				LOCAL oWB AS Microsoft.Office.Interop.Excel._Workbook
				LOCAL oSheet AS Microsoft.Office.Interop.Excel._WorkSheet 
				LOCAL oRange AS Microsoft.Office.Interop.Excel.Range

				oXL := Microsoft.Office.Interop.Excel.Application{}
				oXL:Visible := FALSE
				oXL:DisplayAlerts := FALSE
				oWB := oXL:Workbooks:Open(cFile, Type.Missing, Type.Missing, Type.Missing, Type.Missing, ;
										Type.Missing, Type.Missing, Type.Missing, Type.Missing, Type.Missing, ;
										Type.Missing, Type.Missing, Type.Missing, Type.Missing, Type.Missing)
				oSheet:=(_WorkSheet)oWB:Sheets[1]

				IF oSheet==NULL
					MessageBox.Show("No other sheet.")
					RETURN
				ENDIF

				oRange := oSheet:Range[oSheet:Cells[1, 1], oSheet:Cells[1, gvDetails:Columns:Count]]				
				oRange:EntireColumn:AutoFit()

				oSheet:Select(Missing.Value)
				oWB:SaveAs(cFile, Microsoft.Office.Interop.Excel.XlFileFormat.xlOpenXMLWorkbook, Missing.Value, Missing.Value, Missing.Value, Missing.Value, ;
								Microsoft.Office.Interop.Excel.XlSaveAsAccessMode.xlExclusive, Missing.Value, Missing.Value, Missing.Value, Missing.Value, Missing.Value)
		
				System.Runtime.InteropServices.Marshal.ReleaseComObject(oSheet)
				oWB:Close(Missing.Value, Missing.Value, Missing.Value)
				System.Runtime.InteropServices.Marshal.ReleaseComObject(oWB)
				oWB := NULL
				oXL:Quit()
				// Clean up
				// NOTE: When in release mode, this does the trick
				GC.WaitForPendingFinalizers()
				GC.Collect()
				GC.WaitForPendingFinalizers()
				GC.Collect()

				TRY
					LOCAL oProcessInfo:=ProcessStartInfo{cFile} AS ProcessStartInfo
					oProcessInfo:WindowStyle := ProcessWindowStyle.Maximized
					Process.Start(oProcessInfo)
				CATCH e AS Exception
					ErrorBox(e:StackTrace,e:Message)
			END TRY
			ENDIF

RETURN


END CLASS