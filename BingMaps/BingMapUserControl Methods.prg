// BingMapUserControl_Methods.prg
#USING System
#USING System.ComponentModel
#USING System.Windows.Forms
#USING System.Drawing
#USING System.Data
#USING System.Collections.Generic
#USING System.Text
#USING System.IO
#USING System.Net
#USING System.Runtime.Serialization

#USING Microsoft.Maps.MapControl.WPF
#USING System.Windows
#USING System.Windows.Controls
#USING System.Windows.Media
#USING System.Windows.Data
#USING System.Windows.Input
#USING System.Windows.Shapes
#USING System.Windows.Threading
#USING WpfMapUserControl
#using DevExpress.XtraTreeList.Nodes


PARTIAL CLASS BingMapUserControl INHERIT WpfMapUserControl.MapFormUserControl
	PRIVATE polygonPointLayer AS MapLayer

METHOD BingMapUserControl_OnLoad() AS VOID
    //Set Credentials for map
    SELF:Map:CredentialsProvider := Microsoft.Maps.MapControl.WPF.ApplicationIdCredentialsProvider{BingMapsKey}

	SELF:polygonPointLayer := MapLayer{}
	SELF:Map:Children:Add(SELF:polygonPointLayer)

	SELF:Map:SnapsToDevicePixels := TRUE
	//System.Windows.Forms.MessageBox.Show("You are in the UserControl.Load event 1.")

	//SELF:Click += System.EventHandler{ SELF, @BingMapUserControl_Click() }
	//SELF:PreviewKeyDown += System.Windows.Forms.PreviewKeyDownEventHandler{ SELF, @BingMapUserControl_PreviewKeyDown() }

//	SELF:CreateContextMenu_Pushpin()

	SELF:MyMapUserControl:MouseRightButtonDown += System.Windows.Input.MouseButtonEventHandler{SELF, @MyMapUserControl_MouseRightButtonDown()}
	//SELF:MyMapUserControl:PreviewKeyDown += System.Windows.Input.KeyEventHandler{SELF, @MapUserControl_PreviewKeyDown()}

	//SELF:DrawRoutingLine(FALSE)
	
	//SELF:Map:Mode := AerialMode{TRUE}
	SELF:Map:Mode := RoadMode{}
	////SELF:Map:Mode := MercatorMode{}

	SELF:MyMapUserControl:MyCoordinates:Foreground := System.Windows.Media.Brushes.Black
RETURN


METHOD MyMapUserControl_MouseRightButtonDown(sender AS System.Object, e AS System.Windows.Input.MouseButtonEventArgs) AS VOID
	IF e:OriginalSource:ToString():Contains("TextBlock")
		SELF:MyMapUserControl:CloseInfobox()
		e:Handled := TRUE
	ENDIF
RETURN


//METHOD BingMapUserControl_OnShown() AS VOID
//	//SELF:dUpdateLocationDate := DateTime.MinValue

//	//SELF:ClearAll()
//	//SELF:DrawRoutingLine(FALSE)

//	//SELF:ReadExistingDraggablePins()
//RETURN


//PRIVATE METHOD BingMapUserControl_Click(sender AS System.Object, e AS System.EventArgs) AS VOID
//	SELF:Map:Focus()
//RETURN

//PRIVATE METHOD BingMapUserControl_PreviewKeyDown( sender AS System.Object, e AS System.Windows.Forms.PreviewKeyDownEventArgs ) AS System.Void
//	wb(e:KeyCode)
//RETURN

METHOD ShowSelectedVesselsOnMap() AS VOID
	//IF oMainForm:LBCReports:SelectedIndex == -1
		//wb("No Report selected")
		//SELF:Map:Focus()
		//RETURN
	//ENDIF
	SELF:ClearAll()
	SELF:ClearReportPins()

	LOCAL nChecked AS INT
	LOCAL locs := LocationCollection{} AS LocationCollection

	// Show all selected Vessels on Map
	FOREACH oNode AS TreeListNode IN oMainForm:TreeListVessels:Nodes
		IF oNode:Tag:ToString():StartsWith("Fleet")
			SELF:ShowSelectedVesselsOnMap_Recursive(oNode, locs, nChecked)
			LOOP
		ENDIF
	
		IF ! oNode:Checked
			LOOP
		ENDIF

		IF SELF:ShowVesselOnMap(oNode, locs, false, null)
			nChecked++
		ENDIF
	NEXT

	IF nChecked == 0
		SELF:Map:Focus()
		RETURN
	ENDIF

	// Zoom to Locations level:
	TRY
		SELF:Map:SetView(locs, Thickness{oMainForm:nThickness}, 0)
		IF locs:Count == 1
			SELF:Map:ZoomLevel := 4
		ENDIF
	CATCH e AS Exception
		wb(e:Message)
	END TRY

	SELF:Map:Focus()
RETURN

METHOD ShowSelectedVesselReportOnMap(cDataPackageUID as String) AS LOGIC
	TRY
		IF !(SELF:ShowSelectedVesselReportOnMap(cDataPackageUID))
			RETURN false	
		ENDIF
	CATCH exc AS Exception
		wb(exc:StackTrace)
		RETURN false
	END
RETURN TRUE	

METHOD ShowSelectedVesselsOnMap_Recursive(oParent AS TreeListNode, locs AS LocationCollection, nChecked REF INT) AS VOID
	FOREACH oNode AS TreeListNode IN oParent:Nodes
		IF oNode:Tag:ToString():StartsWith("Fleet")
			SELF:ShowSelectedVesselsOnMap_Recursive(oNode, locs, nChecked)
			LOOP
		ENDIF
	
		IF ! oNode:Checked
			LOOP
		ENDIF

		IF SELF:ShowVesselOnMap(oNode, locs, false, null)
			nChecked++
		ENDIF
	NEXT
RETURN

// Antonis 28.11.14 In order to show report location on map //

METHOD ShowVesselOnMap(oNode AS TreeListNode, locs AS LocationCollection, isReport as LOGIC, cPackageUID as String) AS LOGIC
	LOCAL cStatement AS STRING
	LOCAL cUID := oNode:Tag:ToString() AS STRING
	LOCAL cReportUID,cReportName as String
	IF oMainForm:LBCReports:SelectedIndex == -1 .or. (isReport == true .and. cPackageUID==null)
		cReportUID := "-1"
		cReportName := "MODE"
	ELSE
		cReportUID := oMainForm:LBCReports:SelectedValue:ToString()
		cReportName := oMainForm:LBCReports:GetDisplayItemValue(oMainForm:LBCReports:SelectedIndex):ToString() 
	ENDIF
	LOCAL cForReportSQL := "" AS STRING
	IF isReport .AND. cPackageUID <> null
		cForReportSQL := " AND FMDataPackages.PACKAGE_UID = "+cPackageUID+" "
	ENDIF

	IF cReportName:ToUpper():StartsWith("MODE")
		cStatement:="SELECT FMDataPackages.*, FMReportTypes.ReportName, FMReportTypes.ReportColor FROM FMDataPackages"+oMainForm:cNoLockTerm+;
					" INNER JOIN FMReportTypes ON FMReportTypes.REPORT_UID=FMDataPackages.REPORT_UID"+;
					" WHERE FMDataPackages.Visible=1 AND FMDataPackages.VESSEL_UNIQUEID="+cUID+cForReportSQL+; 
					" AND RTRIM(FMDataPackages.Latitude) <> '' AND FMDataPackages.Latitude IS NOT NULL"+;
					" ORDER BY FMDataPackages.DateTimeGMT DESC"
	ELSE
		cStatement:="SELECT FMDataPackages.*, FMReportTypes.ReportName, FMReportTypes.ReportColor FROM FMDataPackages"+oMainForm:cNoLockTerm+;
					" INNER JOIN FMReportTypes ON FMReportTypes.REPORT_UID=FMDataPackages.REPORT_UID"+;
					" WHERE FMDataPackages.Visible=1 AND FMDataPackages.VESSEL_UNIQUEID="+cUID+cForReportSQL+;
					" AND FMDataPackages.REPORT_UID="+cReportUID+;
					" AND RTRIM(FMDataPackages.Latitude) <> '' AND FMDataPackages.Latitude IS NOT NULL"+;
					" ORDER BY FMDataPackages.DateTimeGMT DESC"
	ENDIF
	// Select the most recent Report
	cStatement := oSoftway:SelectTop(cStatement, 1)

	LOCAL oDT := oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement) AS DataTable
	IF oDT:Rows:Count == 0
		IF isReport == TRUE .and. cPackageUID==NULL
			SELF:ShowSelectedVesselsOnMap()
		ENDIF
		RETURN FALSE
	ENDIF

	// Show Vessel on Map
	LOCAL  nLatitude, nLongitude AS FLOAT
	LOCAL cN_OR_S := oDT:Rows[0]:Item["N_OR_S"]:ToString() AS STRING
	LOCAL cW_OR_E := oDT:Rows[0]:Item["W_OR_E"]:ToString() AS STRING
	LOCAL cLatitude, cLongitude AS STRING
	cLatitude := oDT:Rows[0]:Item["Latitude"]:ToString()	//:Replace(oMainForm:groupSeparator, oMainForm:decimalSeparator)
	IF cN_OR_S == "S"
		cLatitude := "-"+cLatitude
	ENDIF
	nLatitude := GPSCoordinate_To_DecDegrees(cLatitude) //* nDegreeToRadiansFactor

	cLongitude := oDT:Rows[0]:Item["Longitude"]:ToString()	//:Replace(oMainForm:groupSeparator, oMainForm:decimalSeparator)
	IF cW_OR_E == "W"
		cLongitude := "-"+cLongitude
	ENDIF
	nLongitude := GPSCoordinate_To_DecDegrees(cLongitude) //* nDegreeToRadiansFactor
	//wb(cLatitude+CRLF+nLatitude:ToString()+CRLF+CRLF+cLongitude+CRLF+nLongitude:ToString())

	//System.Windows.MessageBox.Show(nLongitude:ToString()+"/"+cN_OR_S,nLatitude:ToString()+"/"+cW_OR_E)

	LOCAL oLocation := Microsoft.Maps.MapControl.WPF.Location{nLatitude, nLongitude} AS Microsoft.Maps.MapControl.WPF.Location
	locs:Add(oLocation)

	LOCAL cVesselName := oNode:GetValue(0):ToString() AS STRING
	LOCAL cTitle AS STRING
	cTitle := cVesselName+" - "+oDT:Rows[0]:Item["ReportName"]:ToString()

	LOCAL cInfo := "" AS STRING
	LOCAL dLocal, dGMT as DateTime
	dGMT := DateTime.Parse(oDT:Rows[0]:Item["DateTimeGMT"]:ToString())

	LOCAL nGmtDiff := Convert.ToDouble(oDT:Rows[0]:Item["GmtDiff"]:ToString()) AS Double
	LOCAL nHours := (INT)nGmtDiff AS INT
	dLocal := dGMT:AddHours(nHours)

	LOCAL nMinutes := nGmtDiff - (Double)nHours AS Double
	IF nMinutes <> (Double)0
		nMinutes := (INT)(((Double)nMinutes * (Double)60) / (Double)3600)
		dLocal := dLocal:AddMinutes(nMinutes)
	ENDIF
	cInfo += dGMT:ToString("dd/MM/yyyy HH:mm")+" (GMT)"+", "+dLocal:ToString("dd/MM/yyyy HH:mm")+" (LT)"+CRLF
	cInfo += DecDegrees_To_DegreesMinutesSeconds(Math.Abs(oLocation:Latitude):ToString())+" ("+cN_OR_S+")"+", "+;
			DecDegrees_To_DegreesMinutesSeconds(Math.Abs(oLocation:Longitude):ToString())+" ("+cW_OR_E+")"+CRLF

	LOCAL oPushpin AS Pushpin

	cStatement:="SELECT FMReportItems.ItemName, FMData.Data"+;
				" FROM FMData"+oMainForm:cNoLockTerm+;
				" INNER JOIN FMDataPackages ON FMDataPackages.PACKAGE_UID=FMData.PACKAGE_UID"+;
				"	AND FMDataPackages.VESSEL_UNIQUEID="+cUID+" AND FMDataPackages.Visible=1 "+;
				" INNER JOIN FMReportItems ON FMReportItems.ITEM_UID=FMData.ITEM_UID"+;
				"	AND FMReportItems.ShowOnMap=1"+; //"	AND FMReportItems.ItemType='N'"+;
				" WHERE DateTimeGMT='"+dGMT:ToString("yyyy-MM-dd HH:mm:ss")+"'"+;
				" ORDER BY FMReportItems.ItemNo"
	LOCAL oDTData := oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement) AS DataTable
	//LOCAL oBrush AS System.Windows.Media.Brush
	//oBrush := System.Windows.Media.Brushes.Red
	//oBrush := System.Windows.Media.Brush{}
//Rectangle myRgbRectangle = new Rectangle();
//myRgbRectangle.Width = 50;
//myRgbRectangle.Height = 50;
//SolidColorBrush mySolidColorBrush = new SolidColorBrush();

//// Describes the brush's color using RGB values.  
//// Each value has a range of 0-255.
//mySolidColorBrush.Color = Color.FromArgb(255, 0, 0, 255);
//myRgbRectangle.Fill = mySolidColorBrush;

	IF oDTData:Rows:Count > 0
		//LOCAL nData AS Double
		LOCAL cItemName AS STRING
		FOREACH oRow AS DataRow IN oDTData:Rows
			cItemName := oRow["ItemName"]:ToString()
			//nData := Convert.ToDouble(oRow["Data"]:ToString())
			cInfo += cItemName+": "+oRow["Data"]:ToString()+CRLF
		NEXT
		cInfo := cInfo:Substring(0, cInfo:Length - 2)
//		oPushpin := SELF:MyMapUserControl:AddPushpin(SELF:MyMapUserControl:PinLayer, oLocation, cTitle, cInfo, TRUE)
		//IF StringIsNumeric(Left(cVesselName, 2))
		//	//oPushpin:Content := Convert.ToInt32(Left(cVesselName, 2):Trim())
		//	oPushpin:Content := cVesselName
		//	oPushpin:ToolTip := cVesselName:Trim()
		//ENDIF
		IF isReport .AND. cPackageUID <> null
			oPushpin := SELF:MyMapUserControl:AddVesselPushpin(SELF:MyMapUserControl:ReportLayer, oLocation, cVesselName:Trim(), cTitle, cInfo, TRUE ,1)
			SELF:Map:SetView(oLocation,4)
		ELSEIF isReport .AND. cPackageUID == NULL
			SELF:Map:SetView(oLocation,5)
		ELSE
			oPushpin := SELF:MyMapUserControl:AddVesselPushpin(SELF:MyMapUserControl:PinLayer, oLocation, cVesselName:Trim(), cTitle, cInfo, TRUE ,0)
		ENDIF
		//wb(cVesselName)
	ELSE
		//oPushpin := SELF:MyMapUserControl:AddPushpin(SELF:MyMapUserControl:PinLayer, oLocation, cTitle, cInfo, TRUE)
		//IF StringIsNumeric(Left(cVesselName, 2))
		//	oPushpin:Content := Convert.ToInt32(Left(cVesselName, 2):Trim())
		//	oPushpin:ToolTip := cVesselName:Trim()
		//ENDIF
		IF isReport .AND. cPackageUID <> null
			oPushpin := SELF:MyMapUserControl:AddVesselPushpin(SELF:MyMapUserControl:ReportLayer, oLocation, cVesselName:Trim(), cTitle, cInfo, TRUE, 1)
			SELF:Map:SetView(oLocation,4)
		ELSEIF isReport .AND. cPackageUID == NULL
			SELF:Map:SetView(oLocation,5)
		
		ELSE
			oPushpin := SELF:MyMapUserControl:AddVesselPushpin(SELF:MyMapUserControl:PinLayer, oLocation, cVesselName:Trim(), cTitle, cInfo, TRUE ,0)
		ENDIF
		//wb(cVesselName, "Last")
	ENDIF

	IF oPushpin == NULL
		RETURN FALSE
	ENDIF

	// Set Background Text Color
	LOCAL cReportColor := oDT:Rows[0]:Item["ReportColor"]:ToString() AS STRING
	IF cReportColor <> "0"
		// Create System.Drawing.Color
		LOCAL nRed, nGreen, nBlue AS LONG
		oMainForm:SplitColorToRGB(cReportColor, nRed, nGreen, nBlue)
		LOCAL oColor := System.Drawing.Color.FromArgb((BYTE)nRed, (BYTE)nGreen, (BYTE)nBlue) AS System.Drawing.Color
		//LOCAL oColor := System.Drawing.Color.FromArgb(Convert.ToInt32(cReportColor)) AS System.Drawing.Color

		// Create System.Windows.Media.Color
		LOCAL oWpfColor := System.Windows.Media.Color.FromArgb(oColor:A, oColor:R, oColor:G, oColor:B) AS System.Windows.Media.Color
		oPushpin:Background := SolidColorBrush{oWpfColor}
	ENDIF

	// Set Foreground Text Color
	IF IsInstanceOf(SELF:Map:Mode, #AerialMode)
		oPushpin:Foreground := System.Windows.Media.Brushes.Red
	ELSE
		oPushpin:Foreground := System.Windows.Media.Brushes.Black
	ENDIF
RETURN TRUE


PRIVATE METHOD ClearAll() AS VOID
	SELF:MyMapUserControl:CloseInfobox()
	SELF:MyMapUserControl:PinLayer:Children:Clear()
RETURN

PUBLIC METHOD ClearReportPins() AS VOID
	SELF:MyMapUserControl:CloseInfobox()
	SELF:MyMapUserControl:ReportLayer:Children:Clear()
RETURN
	

END CLASS
