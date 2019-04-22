//
// FleetManager.prg
//

#using System
#using System.Windows.Forms
#Using System.IO
#Using License

/// <summary>
/// The main entry point for the application.
/// </summary>
[STAThread] ;
FUNCTION Start(asCmdLine AS STRING[]) AS INT
   LOCAL exitCode AS INT
    
	DevExpress.Skins.SkinManager.EnableFormSkins()
	Application.EnableVisualStyles()
	Application.SetCompatibleTextRenderingDefault( false )

	// Skin registration.
	DevExpress.UserSkins.BonusSkins.Register()
	//DevExpress.UserSkins.OfficeSkins.Register()
	//DevExpress.Skins.SkinManager.Default:RegisterAssembly(GetType(DevExpress.UserSkins.Office2007Bonus):Assembly)
    DevExpress.Skins.SkinManager.EnableFormSkinsIfNotVista()

	// Create an instance of Softway Class (Namespace Softway.Common)
	oSoftway:=Softway{}

	IF oSoftway:AlreadyRunning()
		wb("The "+Application.ProductName+" program is already running")
		Application.Exit()
		RETURN -1
	ENDIF

   LOCAL cHardwareID AS STRING
   LOCAL oStreamWriter AS StreamWriter
   LOCAL cProvidedUserName := NULL, cProvidedPassword := NULL AS STRING
	IF asCmdLine:Length > 0
		DO CASE
		CASE asCmdLine[1]:Trim():StartsWith("/Logon")
			oSoftway:UserLogonInfoProvided := TRUE
			IF asCmdLine:Length == 3
				cProvidedUserName := asCmdLine[2]:Substring(1)
				cProvidedPassword := asCmdLine[3]:Substring(1)
			ENDIF
			//MessageBox.Show(cProvidedUserName+"..."+cProvidedPassword)
            //ENDIF
		CASE asCmdLine[1] == "1"
			oStreamWriter:=StreamWriter{cStartupPath+"\HardwareID.TXT"}
			// Get the Hardware generation ID parameter
			cHardwareID:=License.Status.HardwareID
			oStreamWriter:Write(cHardwareID)
			oStreamWriter:Close()
			oStreamWriter:Dispose()
			wb("License information"+CRLF+CRLF+;
			"HardwareID="+cHardwareID+CRLF+CRLF+;
			"Written to: "+cStartupPath+"\HardwareID.TXT", "HardwareID")
			//oSoftway:GetHardwareID("")
			Application.Exit()
			RETURN -1
		ENDcase
	ENDIF
	//wb(cStartupPath+"\"+Application.ProductName+".license")


	LOCAL lCheckLocalLicense := System.IO.File.Exists(cStartupPath+"\"+Application.ProductName+".license") AS LOGIC
	//wb(cStartupPath+"\"+Application.ProductName+".license", lCheckLocalLicense:ToString())
	IF ! oSoftway:CheckLicense(lCheckLocalLicense, cStartupPath+"\"+Application.ProductName+".license", Application.ProductName)
      oStreamWriter:=StreamWriter{cStartupPath+"\HardwareID.TXT"}
      // Get the Hardware generation ID parameter
      cHardwareID:=License.Status.HardwareID
      oStreamWriter:Write(cHardwareID)
      oStreamWriter:Close()
      oStreamWriter:Dispose()
      wb("License information"+CRLF+CRLF+;
         "HardwareID="+cHardwareID+CRLF+CRLF+;
         "Written to: "+cStartupPath+"\HardwareID.TXT", "HardwareID")
      //oSoftway:GetHardwareID("")
      Application.Exit()
	   RETURN -1
   ENDIF

	// Specify the path for Crystal Report RPT files: Application.StartupPath for final EXE
	//cReportFolder:=cStartupPath+"\Reports"
	//MessageBox.Show(oSoftway:UserLogonInfoProvided:ToString())
    symServer:=ReadIniFile(cStartupPath+"\SOFTWAY.INI", oSoftway:UserLogonInfoProvided,cProvidedUserName, cProvidedPassword)
	IF symServer == NULL_SYMBOL
		Application.Exit()
		RETURN -1
	ENDIF

	//#ifndef __DEBUG__
		// Comment in order to Debug
		//SplashScreen.ShowSplashScreen()
	//#ENDIF

   oSoftway:CreateSQLDefaults()

   cAppName:=cStartupPath+"\"+Application.ProductName
	//wb(cAppName, cTempDocDir)

	// Create TempDoc, Logs directories (if not exist)
	oSoftway:CreateDirectory(cTempDocDir)
	//oSoftway:CreateDirectory(cLogDir)
	cFleetManagerVesselPath := Application.StartupPath + "\FleetManagerVessel"
	oSoftway:CreateDirectory(cFleetManagerVesselPath)

	IF ! lCheckLocalLicense
		IF lRemoteObjectService .and. symServer <> #SqlCe .and. symServer <> #SQLite
			// Create RemoteObject to RemoteObjectServer Service to checl the .license file
			LOCAL oRemoteObjectClient := RemoteObjectClient{oSoftway, ms_frmSplash, lSplashScreenClosed} AS RemoteObjectClient   
			IF ! oRemoteObjectClient:Main()
				Application.Exit()
				RETURN -1
			ENDIF
		ENDIF
	ENDIF

//cLicensedCompany := "Larus S.A."
//cLicensedCompany := "Softway Ltd"

	TRY
		Application.Run( MainForm{} )
	CATCH e AS Exception
		ErrorBox(e:Message, "Application.Run")
	END TRY
   RETURN exitCode