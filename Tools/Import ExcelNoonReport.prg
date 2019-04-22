// Import_ExcelNoonReport.prg
#Using System.Data
#Using System.Data.Common
#Using System.Windows.Forms
#Using System.Drawing
#Using System.Threading
#Using System.Reflection
#USING Microsoft.Office.Interop.Excel
#using System.Diagnostics

PARTIAL CLASS MainForm

METHOD ImportExcelData() AS VOID
	IF SELF:TreeListVessels:FocusedNode == NULL .or. oMainForm:LBCReports:SelectedValue == NULL
		wb("Please select a Vessel", "No Vessel selected")
		RETURN
	ENDIF

	//LOCAL cVesselUID := SELF:CheckedLBCVessels:SelectedValue:ToString() AS STRING
	LOCAL cVesselName := oMainForm:GetVesselName AS STRING
	//LOCAL cReportUID := oMainForm:LBCReports:SelectedValue:ToString() AS STRING
	//LOCAL cReportName := oMainForm:LBCReports:GetDisplayItemValue(oMainForm:LBCReports:SelectedIndex):ToString() AS STRING

	// Excel file:
	//LOCAL cFile := cTempDocDir+"\A-NEW-PMS-18AUG11.xls" AS STRING
	LOCAL oOpenFileDialog:=OpenFileDialog{} AS OpenFileDialog
	oOpenFileDialog:Filter:="Excel files|*.XLSX"
	oOpenFileDialog:Title:="Import Excel file"
	IF oOpenFileDialog:ShowDialog() <> DialogResult.OK
		RETURN
	ENDIF

	LOCAL cFile:=oOpenFileDialog:FileName AS STRING
	//wb(System.IO.Path.GetFileNameWithoutExtension(cFile):ToUpper(), "|"+cVesselName:ToUpper())
	//IF System.IO.Path.GetFileNameWithoutExtension(cFile):ToUpper() <> cVesselName:ToUpper()
	//	ErrorBox("The Excel filename must be the VesselName.XLSX: "+cVesselName+".XLSX")
	//	RETURN
	//ENDIF
	LOCAL cExt := System.IO.Path.GetExtension(cFile):ToUpper() AS STRING

	// EXCEL Automation bug Q320369: "Old format or invalid type library" error when automating Excel
	// Workaround: set the CultureInfo to "en-US" prior to calling the Excel method and restore it after
	LOCAL oldCI AS System.Globalization.CultureInfo
	oldCI:=System.Threading.Thread.CurrentThread:CurrentCulture
	System.Threading.Thread.CurrentThread:CurrentCulture:=System.Globalization.CultureInfo{"en-US"}

	LOCAL oGFHExcel AS DBProviderFactory
	LOCAL oConnExcel AS DBConnection
	//TRY
		LOCAL cConnectionString AS STRING
		// connection string to connect to the Excel Workbook
		// the first row is a header row containing the names of the columns
		DO CASE
		CASE cExt == ".XLS"
			cConnectionString:="Provider=Microsoft.Jet.OLEDB.4.0;"+;
									 "Data Source="+cFile+";"+;
									 "Extended Properties="+e"\"Excel 8.0;HDR=Yes;IMEX=1\""

		CASE cExt == ".XLSX"
			// Excel 2007:
			cConnectionString:="Provider=Microsoft.ACE.OLEDB.12.0;"+;
								 "Data Source="+cFile+";"+;
								 "Extended Properties="+e"\"Excel 12.0 Xml;HDR=YES;IMEX=1\""
		OTHERWISE
			ErrorBox("Only .XLS and .XLSX file etensions supported", "Import aborted")
			RETURN
		ENDCASE

		// Create a FactorySQL object
		oGFHExcel:=DBProviderFactories.GetFactory("System.Data.OleDb")

		// Create a SQL Connection object using OleDB
		oConnExcel:=oGFHExcel:CreateConnection()
		oConnExcel:ConnectionString:=cConnectionString
		oConnExcel:Open()
		//wb(cConnectionString, "OleDB Connection Open")

		// Create Excel DBDataAdapter
		LOCAL oDAExcel AS DBDataAdapter
		oDAExcel:=oGFHExcel:CreateDataAdapter()
		// Create Excel DBCommand
		LOCAL oCommand AS DBCommand
		oCommand:=oGFHExcel:CreateCommand()
		oCommand:CommandText:="SELECT * FROM ["+cVesselName+"$]"
		//oCommand:CommandText:="SELECT * FROM [Sheet 1$]"
		oCommand:Connection:=oConnExcel
		//oDAExcel:SelectCommand:=oSoftway:SelectCommand(SELF:oGFHExcel, SELF:oConnExcel, cStatement)
		oDAExcel:SelectCommand:=oCommand
		// Create Excel DataTable
		LOCAL oDTExcel:=System.Data.DataTable{} AS System.Data.DataTable
		oDAExcel:Fill(oDTExcel)

		LOCAL nImported AS INT
		//LOCAL lInsert := TRUE AS LOGIC
		// Check
		LOCAL cStr AS STRING
		FOREACH oRow AS DataRow IN oDTExcel:Rows
			IF SELF:ImportRow(oRow, nImported, FALSE, cStr)
				cStr += CRLF
			ELSE
				//lInsert := FALSE
				EXIT
			ENDIF
		NEXT
		LOCAL cTxt := cTempDocDir+"\ImportExcelNoonReport.TXT" AS STRING
		MemoWrit(cTxt, cStr)
		Process.Start("Notepad.exe", cTxt)

		//IF lInsert
		//	// Insert
		//	cStr := ""
		// nImported := 0
		//	FOREACH oRow AS DataRow IN oDTExcel:Rows
		//		SELF:ImportRow(oRow, nImported, TRUE, cStr)
		//	NEXT
		//	InfoBox(nImported:ToString()+" Excel lines imported")
		//ENDIF
	/*CATCH e AS Exception
		ErrorBox(e:Message)
	FINALLY
		SELF:ClearConnectionExcel(oConnExcel)
	END TRY*/

	System.Threading.Thread.CurrentThread:CurrentCulture:=oldCI
RETURN


METHOD ClearConnectionExcel(oConn AS DBConnection) AS VOID
// Clear oConn or oConnExcel Connection
	IF oConn <> NULL
		IF oConn:State == ConnectionState.Open
			oConn:Close()
		ENDIF
	ENDIF
RETURN


METHOD ImportRow(oRow AS DataRow, nImported REF INT, lInsert AS LOGIC, cStr REF STRING) AS LOGIC
	LOCAL cLat, cLong AS STRING
	cLat := oRow["LATITUDE"]:ToString():Trim()
	IF cLat == ""
		RETURN TRUE
	ENDIF
	cLong := oRow["LONGITUDE"]:ToString():Trim()

	LOCAL cDate, cTime AS STRING
	cDate := oRow["DATE"]:ToString():Replace("12:00:00 AM", ""):Trim()
	cTime := oRow["TIME"]:ToString():Trim()
	LOCAL dDate := DateTime.Parse(cDate+" "+cTime) AS DateTime
	cDate := dDate:ToString("yyyy-MM-dd HH:mm:ss")
	//wb(cDate+" "+cTime+CRLF+dDate:ToString("yyyy-MM-dd HH:mm:ss"))
cStr += "DateTime: "+dDate:ToString("yyyy-MM-dd HH:mm:ss")+", Lat: "+cLat+", Long: "+cLong

	LOCAL cCourse, cWind, cSea, cDistance, cSpeed, cDistCovered, cTTime, cAvgSpeed, cToGo, cRPM, cSlip, cMEHandle, cMELoad, ;
			cExhGas, cScavPressure, cAELoad, cFO, cDO, cROBFO, cROBDO, cLORIB, cCO, cAELO, cEvap, cFW, cComments, cTemp AS STRING
	LOCAL n, nLen, nPos AS INT

	cCourse := oRow["COURSE"]:ToString():Trim()	
	cWind := oRow["WIND"]:ToString():Trim()	

	LOCAL cWindDir, cWindSpeed, c AS STRING
	nLen := cWind:Length - 1
	FOR n:=0 UPTO nLen
		c := cWind:Substring(n, 1)
		IF "NSWE":Contains(c)
			cWindDir += c
		ENDIF
	NEXT
	FOR n:=nLen DOWNTO 0
		c := cWind:Substring(n, 1)
		IF ! StringIsNumeric(c)
			EXIT
		ENDIF
		cWindSpeed := c + cWindSpeed
	NEXT
	//wb(cDate+CRLF+cTime+CRLF+cLat+CRLF+cLong+CRLF+cCourse+CRLF+cWindDir+CRLF+cWindSpeed)

	cSea := oRow["SEA"]:ToString():Trim()
	
	cTemp := oRow["DISTANCE"]:ToString():Trim()	
	nLen := cTemp:Length - 1
	FOR n:=0 UPTO nLen
		c := cTemp:Substring(n, 1)
		IF StringIsNumeric(c)
			cDistance += c
		ENDIF
	NEXT
cStr += ", Course: "+cCourse+", WindDir: "+cWindDir+", BF: "+cWindSpeed+", Sea: "+cSea+", Distance to go: "+cDistance

	//cTemp := oRow["Run. Hrs"]:ToString():Trim():ToUpper()
	cTemp := oRow[8]:ToString():Trim():ToUpper()				// Field contains '.' --> Zero-based number of field
	LOCAL cHours, cMinStr := "", cMin := "" AS STRING
	nPos := cTemp:IndexOf("HRS")
	IF nPos == -1
		nPos := cTemp:IndexOf("H")
		IF nPos == -1
			ErrorBox("Invalid Run. Hrs: "+cTemp)
			RETURN FALSE
		ENDIF
		cHours := cTemp:Substring(0, nPos):Trim()
		cMinStr := cTemp:Substring(nPos + "H":Length):Trim()
	ELSE
		cHours := cTemp:Substring(0, nPos):Trim()
		cMinStr := cTemp:Substring(nPos + "HRS":Length):Trim()
	ENDIF
	nLen := cMinStr:Length - 1
	FOR n:=0 UPTO nLen
		c := cMinStr:Substring(n, 1)
		IF ! StringIsNumeric(c)
			EXIT
		ENDIF
		cMin += c
	NEXT
	IF cMin <> ""
		cHours += "." + (Convert.ToInt32(cMin) * 100 / 60):ToString()
	ENDIF
cStr += ", Run.Hours: "+cHours

	cTemp := oRow["SPEED"]:ToString():Trim()
	nLen := cTemp:Length - 1
	FOR n:=0 UPTO nLen
		c := cTemp:Substring(n, 1)
		IF ! StringIsNumeric(c)
			EXIT
		ENDIF
		cSpeed += c
	NEXT
cStr += ", Speed: "+cSpeed

	//cTemp := oRow["Dist.cov."]:ToString():Trim()
	cTemp := oRow[11]:ToString():Trim()						// Field contains '.' --> Zero-based number of field
	nLen := cTemp:Length - 1
	FOR n:=0 UPTO nLen
		c := cTemp:Substring(n, 1)
		IF ! StringIsNumeric(c)
			EXIT
		ENDIF
		cDistCovered += c
	NEXT
cStr += ", Distance Covered: "+cDistCovered

	//cTemp := oRow["T.Time"]:ToString():Trim()
	cTemp := oRow[12]:ToString():Trim()						// Field contains '.' --> Zero-based number of field
	nLen := cTemp:Length - 1
	FOR n:=0 UPTO nLen
		c := cTemp:Substring(n, 1)
		IF ! StringIsNumeric(c)
			EXIT
		ENDIF
		cTTime += c
	NEXT
cStr += ", T.Time: "+cTTime

	//cTemp := oRow["Av.speed"]:ToString():Trim()
	cTemp := oRow[13]:ToString():Trim()						// Field contains '.' --> Zero-based number of field
	nLen := cTemp:Length - 1
	FOR n:=0 UPTO nLen
		c := cTemp:Substring(n, 1)
		IF ! StringIsNumeric(c)
			EXIT
		ENDIF
		cAvgSpeed += c
	NEXT
cStr += ", Avg.Speed: "+cAvgSpeed

	cTemp := oRow["TO GO"]:ToString():Trim()
	nLen := cTemp:Length - 1
	FOR n:=0 UPTO nLen
		c := cTemp:Substring(n, 1)
		IF ! StringIsNumeric(c)
			EXIT
		ENDIF
		cToGo += c
	NEXT
cStr += ", Miles to go: "+cToGo

	cTemp := oRow["RPM"]:ToString():Trim()
	nLen := cTemp:Length - 1
	FOR n:=0 UPTO nLen
		c := cTemp:Substring(n, 1)
		IF ! StringIsNumeric(c)
			EXIT
		ENDIF
		cRPM += c
	NEXT
cStr += ", RPM: "+cRPM

	cTemp := oRow["Slip"]:ToString():Trim()
	cTemp := cTemp:Replace("+", "")
	cTemp := cTemp:Replace("-", "")
	cTemp := cTemp:Replace("%", "")
	nLen := cTemp:Length - 1
	FOR n:=0 UPTO nLen
		c := cTemp:Substring(n, 1)
		IF ! StringIsNumeric(c, ".")
			EXIT
		ENDIF
		cSlip += c
	NEXT
cStr += ", Slip: "+cSlip

	cMEHandle := oRow["M/E HANDLE"]:ToString():Trim()

	cMELoad := oRow["M/E LOAD"]:ToString():Trim()
cStr += ", M/: "+cMEHandle+", M/E LOAD: "+cMELoad

	cExhGas := oRow["EXH GAS"]:ToString():Trim()
	LOCAL aExhGas := cExhGas:Split('/') AS STRING[]
	IF aExhGas:Length <> 6
		ErrorBox("Exh Gas error: "+cExhGas+CRLF+"6 values expected"+CRLF+;
				"for DateTime: "+cDate+CRLF+;
				"Please correct and retry")
		RETURN FALSE
	ENDIF
	// aExhGas[6]
	LOCAL cExhGas233, cExhGas234, cExhGas235, cExhGas236, cExhGas237, cExhGas238 AS STRING
	cExhGas233 := aExhGas[1]
	cExhGas234 := aExhGas[2]
	cExhGas235 := aExhGas[3]
	cExhGas236 := aExhGas[4]
	cExhGas237 := aExhGas[5]
	cExhGas238 := aExhGas[6]
cStr += ", Exh.Gas: "+cExhGas233+"/"+cExhGas234+"/"+cExhGas235+"/"+cExhGas236+"/"+cExhGas237+"/"+cExhGas238

	//cScavPressure := oRow["M.E SCAVENING PRESSURE"]:ToString():Trim()
	cScavPressure := oRow[20]:ToString():Trim()						// Field contains '.' --> Zero-based number of field
	LOCAL aScavPressure := cScavPressure:Split('/') AS STRING[]
	// aScavPressure[1] or aScavPressure[2]
	LOCAL cScavPressure1, cScavPressure2 := "NULL" AS STRING
	cScavPressure1 := aScavPressure[1]
	IF aScavPressure:Length == 2
		cScavPressure2 := aScavPressure[2]
	ENDIF
cStr += ", ScavPressure: "+cScavPressure1+", ScavPressure2: "+cScavPressure2

	cAELoad := oRow["A/E&KW"]:ToString():Trim():ToUpper()
	LOCAL cAELoad1 := "NULL", cAELoad2 := "NULL", cAELoad3 := "NULL" AS STRING
	// NO.1&3/360(4HRS)NO.3 280KW(24HRS)
	// NO.3 290KW(24HRS)
	// NO.2/280
	// NO.1 165KW,NO.2 165KW
	// NO.2 280KW
	// NO.1 280KW/NO.3 280KW
	IF cAELoad:Contains("&")
		ErrorBox("Invalid A/E&KW: "+cAELoad+CRLF+;
				"for DateTime: "+cDate+CRLF+;
				"Please correct and retry")
		RETURN FALSE
	ENDIF
	nPos := cAELoad:IndexOf("NO.3")
	IF nPos <> -1
		cTemp := cAELoad:Substring(nPos + "NO.3":Length):Trim()
		nLen := cTemp:Length - 1
		cAELoad3 := ""
		FOR n:=0 UPTO nLen
			c := cTemp:Substring(n, 1)
			IF ! StringIsNumeric(c)
				EXIT
			ENDIF
			cAELoad3 += c
		NEXT
	ENDIF

	nPos := cAELoad:IndexOf("NO.2")
	IF nPos <> -1
		cTemp := cAELoad:Substring(nPos + "NO.2":Length):Trim()
		nLen := cTemp:Length - 1
		cAELoad2 := ""
		FOR n:=0 UPTO nLen
			c := cTemp:Substring(n, 1)
			IF ! StringIsNumeric(c)
				EXIT
			ENDIF
			cAELoad2 += c
		NEXT
	ENDIF

	nPos := cAELoad:IndexOf("NO.1")
	IF nPos <> -1
		cTemp := cAELoad:Substring(nPos + "NO.1":Length):Trim()
		nLen := cTemp:Length - 1
		cAELoad1 := ""
		FOR n:=0 UPTO nLen
			c := cTemp:Substring(n, 1)
			IF ! StringIsNumeric(c)
				EXIT
			ENDIF
			cAELoad1 += c
		NEXT
	ENDIF
	//wb("cAELoad1="+cAELoad1+CRLF+"cAELoad2="+cAELoad2+CRLF+"cAELoad3="+cAELoad3+CRLF)
cStr += ", A/E&KW: "+cAELoad1+"/"+cAELoad2+"/"+cAELoad3

	//cTemp := oRow["F.O."]:ToString():Trim()
	cTemp := oRow[22]:ToString():Trim()						// Field contains '.' --> Zero-based number of field
	nLen := cTemp:Length - 1
	FOR n:=0 UPTO nLen
		c := cTemp:Substring(n, 1)
		IF ! StringIsNumeric(c, ".")
			EXIT
		ENDIF
		cFO += c
	NEXT

	//cTemp := oRow["D.O."]:ToString():Trim()
	cTemp := oRow[23]:ToString():Trim()						// Field contains '.' --> Zero-based number of field
	nLen := cTemp:Length - 1
	FOR n:=0 UPTO nLen
		c := cTemp:Substring(n, 1)
		IF ! StringIsNumeric(c, ".")
			EXIT
		ENDIF
		cDO += c
	NEXT

	//cTemp := oRow["(ROB)F.O."]:ToString():Trim()
	cTemp := oRow[24]:ToString():Trim()						// Field contains '.' --> Zero-based number of field
	nLen := cTemp:Length - 1
	FOR n:=0 UPTO nLen
		c := cTemp:Substring(n, 1)
		IF ! StringIsNumeric(c, ".")
			EXIT
		ENDIF
		cROBFO += c
	NEXT

	//cTemp := oRow["(ROB)D.O."]:ToString():Trim()
	cTemp := oRow[25]:ToString():Trim()						// Field contains '.' --> Zero-based number of field
	nLen := cTemp:Length - 1
	FOR n:=0 UPTO nLen
		c := cTemp:Substring(n, 1)
		IF ! StringIsNumeric(c, ".")
			EXIT
		ENDIF
		cROBDO += c
	NEXT
cStr += ", FO: "+cFO+", DO: "+cDO+", ROB FO: "+cROBFO+", ROB DO: "+cROBDO

	cLORIB := oRow["Lub Oil RIB/Sump tank"]:ToString():Trim()
	LOCAL aRIB := cLORIB:Split('/') AS STRING[]
	// aRIB[1] or aRIB[2]
	LOCAL cLORIB1, cLORIB2 := "NULL" AS STRING
	cLORIB1 := aRIB[1]
	IF aScavPressure:Length == 2
		cTemp := aRIB[2]
		nLen := cTemp:Length - 1
		cLORIB2 := ""
		FOR n:=0 UPTO nLen
			c := cTemp:Substring(n, 1)
			IF ! StringIsNumeric(c)
				EXIT
			ENDIF
			cLORIB2 += c
		NEXT
	ENDIF
cStr += ", Lub Oil RIB/Sump tank: "+cLORIB1+"/"+cLORIB2

	//cTemp := oRow["C.O."]:ToString():Trim()
	cTemp := oRow[27]:ToString():Trim()						// Field contains '.' --> Zero-based number of field
	nLen := cTemp:Length - 1
	FOR n:=0 UPTO nLen
		c := cTemp:Substring(n, 1)
		IF ! StringIsNumeric(c)
			EXIT
		ENDIF
		cCO += c
	NEXT

	//cTemp := oRow["L.O(A/E)"]:ToString():Trim()
	cTemp := oRow[28]:ToString():Trim()						// Field contains '.' --> Zero-based number of field
	nLen := cTemp:Length - 1
	FOR n:=0 UPTO nLen
		c := cTemp:Substring(n, 1)
		IF ! StringIsNumeric(c)
			EXIT
		ENDIF
		cAELO += c
	NEXT

	//cTemp := oRow["EVAP."]:ToString():Trim()
	cTemp := oRow[29]:ToString():Trim()						// Field contains '.' --> Zero-based number of field
	nLen := cTemp:Length - 1
	FOR n:=0 UPTO nLen
		c := cTemp:Substring(n, 1)
		IF ! StringIsNumeric(c)
			EXIT
		ENDIF
		cEvap += c
	NEXT

	//cTemp := oRow["F. W."]:ToString():Trim()
	cTemp := oRow[30]:ToString():Trim()						// Field contains '.' --> Zero-based number of field
	nLen := cTemp:Length - 1
	FOR n:=0 UPTO nLen
		c := cTemp:Substring(n, 1)
		IF ! StringIsNumeric(c)
			EXIT
		ENDIF
		cFW += c
	NEXT
cStr += ", C.O.: "+cCO+", L.O(A/E): "+cAELO+", EVAP.: "+cEvap+", F. W.: "+cFW

	LOCAL cNextPort, cETA := "" AS STRING
	cTemp := oRow["ETA"]:ToString():Trim()
	nPos := cTemp:IndexOf("ETA ")
	IF nPos == -1
		cNextPort := cTemp:Trim()
	ELSE
		cNextPort := cTemp:Substring(nPos + 4):Trim()
	ENDIF
	
	LOCAL lEtaDateTimeFound AS LOGIC
	nLen := cNextPort:Length - 1
	FOR n:=0 UPTO nLen
		c := cNextPort:Substring(n, 1)
		IF StringIsNumeric(c, "/")
			lEtaDateTimeFound := TRUE
			cETA += c
		ELSE
			EXIT
		ENDIF
	NEXT
	
	IF cETA!=""
		cETA := cETA:Trim()
		cETA := right(cETA,4) +"."+ cETA:Substring(3,2)+"."+ cETA:Substring(0,2)
	ENDIF
	
	IF cETA!=""
		cStr += ", NextPort: "+cNextPort:Replace(cETA, ""):Trim()
	ELSE
		cStr += ", NextPort: "+cNextPort:Trim()
	ENDIF
	
	LOCAL cEtaDate := "" AS STRING
	LOCAL dEtaDate := DateTime.MinValue AS DateTime
	IF lEtaDateTimeFound
		cTemp := cNextPort:Replace(cETA, ""):Trim()
		// Locate the end of ETA Date
		nPos := cNextPort:IndexOf(" ")
		IF nPos == -1 .and. cETA == ""
			ErrorBox("Invalid ETA: "+cNextPort+CRLF+;
					"for DateTime: "+cDate+CRLF+;
					"Please correct and retry")
			RETURN FALSE
		ENDIF
		IF cETA==""
			cEtaDate := cNextPort
		ELSE
			cEtaDate := cETA			
		ENDIF
		TRY
			dEtaDate := DateTime.Parse(cEtaDate)
		CATCH
			//MessageBox.Show("'"+cEtaDate+"'")
			ErrorBox("Invalid ETA: "+"'"+cEtaDate+"'"+CRLF+;
					"for DateTime: "+cDate+CRLF+;
					"Please correct and retry")
			RETURN FALSE
		END TRY

		// Locate the end of ETA Time
		/*cTemp := cNextPort:Substring(nPos):Trim()
		nLen := cTemp:Length - 1
		FOR n:=0 UPTO nLen
			c := cTemp:Substring(n, 1)
			IF ! StringIsNumeric(c)
				EXIT
			ENDIF
			cEtaTime += c
		NEXT*/
	ENDIF
cStr += ", EtaDate: "+Iif(dEtaDate == DateTime.MinValue, "not found", cEtaDate)	//+", EtaTime: "+Iif(cEtaTime == "", "not found", cEtaTime)

	cComments:= oRow["Comments"]:ToString():Trim()
cStr += ", Comments: "+cComments
	//IF ! lInsert
	//	RETURN TRUE
	//ENDIF
RETURN TRUE

END CLASS