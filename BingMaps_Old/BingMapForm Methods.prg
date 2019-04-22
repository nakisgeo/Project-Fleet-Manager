// BingMapForm_Methods.prg
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
//#USING DraggablePushpin
#USING WpfMapUserControl


PARTIAL CLASS BingMapForm INHERIT WpfMapUserControl.MapForm
	EXPORT cVesselUID AS STRING
	EXPORT oLBCItemVoyage AS MyLBCVoyageItem
	EXPORT oLBCItemRouting AS MyLBCVoyageItem

	EXPORT dDateFromVoyageGMT := DateTime.MinValue AS DateTime
	EXPORT dDateToVoyageGMT := DateTime.MaxValue AS DateTime
	EXPORT dDateFromRoutingGMT := DateTime.MinValue AS DateTime
	EXPORT dDateToRoutingGMT := DateTime.MaxValue AS DateTime

	EXPORT dDateFromVoyage := DateTime.MinValue AS DateTime
	EXPORT dDateToVoyage := DateTime.MaxValue AS DateTime
	EXPORT dDateFromRouting := DateTime.MinValue AS DateTime
	EXPORT dDateToRouting := DateTime.MaxValue AS DateTime

	EXPORT routeLine AS MyMapPolyline
	PRIVATE oPortFromPushpin AS Pushpin

	PRIVATE oLastLocationPushpin AS Pushpin
	PRIVATE nSpeedToGo AS Double
	PRIVATE dLastLocationDate, dFirstLocationDate AS DateTime

	PRIVATE WaypointDate AS DateTime
	PRIVATE WaypointGmtDiff AS Decimal

	PRIVATE LastRightClickPoint AS System.Windows.Point
	PRIVATE nTotalDistanceToGo AS Double

	PRIVATE WindDirection AS INT
	PRIVATE Knots AS Double

    PRIVATE timerMapRefresh AS System.Windows.Forms.Timer
	PRIVATE dUpdateLocationDate AS DateTime
	PRIVATE cFormText AS STRING

	PRIVATE polygonPointLayer AS MapLayer

	PRIVATE nTC_Equivalent, nFOPriceUSD AS Double

	PRIVATE oDTPackages AS DataTable
	PRIVATE cReportUID AS STRING

	////EXPORT STATIC MyTagProp := DependencyProperty.Register("Tag", typeof(OBJECT), typeof(MapPolyline), PropertyMetadata{NULL}) AS DependencyProperty
	////EXPORT STATIC TapEvent := EventManager.RegisterRoutedEvent("Tap", RoutingStrategy.Bubble, typeof(RoutedEventHandler), typeof(BingMapForm)) AS RoutedEvent
	//STATIC /*readonly*/ EXPORT TapEvent AS System.Windows.RoutedEvent


METHOD BingMapForm_OnLoad() AS VOID
	SELF:cReportUID := oMainForm:LBCReports:SelectedValue:ToString()

    //Set Credentials for map
    SELF:Map:CredentialsProvider := Microsoft.Maps.MapControl.WPF.ApplicationIdCredentialsProvider{BingMapsKey}

	SELF:polygonPointLayer := MapLayer{}
	SELF:Map:Children:Add(SELF:polygonPointLayer)

 //   //Add InfoboxLayer to map
	//SELF:InfoboxLayer := MapLayer{}	// Microsoft.Maps.EntityCollection{}
	////SELF:InfoboxLayer:Opacity := 1
 //   SELF:Map:Children:Add(InfoboxLayer)

	SELF:Map:SnapsToDevicePixels := TRUE

	//SELF:CustomRoutedCommand := RoutedCommand{}

	//SELF:LastRightClickPoint  := System.Windows.Point{0, 0}
	SELF:CreateContextMenu_Pushpin()

	//SELF:lAnemometerDataExists := SELF:CheckForAnemometerData()

	SELF:MyMapUserControl:MouseRightButtonDown += System.Windows.Input.MouseButtonEventHandler{SELF, @MyMapUserControl_MouseRightButtonDown()}
	SELF:MyMapUserControl:PreviewKeyDown += System.Windows.Input.KeyEventHandler{SELF, @MapUserControl_PreviewKeyDown()}

    SELF:timerMapRefresh := System.Windows.Forms.Timer{}
    SELF:timerMapRefresh:Interval := 5 * 60 * 1000			// Every 5 min
    //SELF:timerMapRefresh:Interval := 5000					// Every 5 sec
    SELF:timerMapRefresh:Tick += System.EventHandler{ SELF, @timerMapRefresh_Tick() }
	SELF:timerMapRefresh:Enabled := TRUE

	TRY
		SELF:nTC_Equivalent := Convert.ToDouble(SELF:oLBCItemRouting:oRow["TCEquivalentUSD"]:ToString())
	CATCH
		SELF:nTC_Equivalent := 0
	END TRY
	TRY
		SELF:nFOPriceUSD := Convert.ToDouble(SELF:oLBCItemRouting:oRow["FOPriceUSD"]:ToString())
	CATCH
		SELF:nFOPriceUSD := 0
	END TRY
RETURN


PRIVATE METHOD timerMapRefresh_Tick( sender AS System.Object, e AS System.EventArgs ) AS System.Void
	SELF:timerMapRefresh:Enabled := FALSE

	SELF:Text += "   -   Refreshing Map..."

	IF SELF:NewDataArrived()
		SELF:DrawRoutingLine(TRUE)
		//SELF:DrawFutureRoutingLine()
	ENDIF

	SELF:Text := SELF:cFormText

	// Hide InfoBox
	IF SELF:MyMapUserControl:MyInfobox:Visibility == Visibility.Visible
		SELF:MyMapUserControl:MyInfobox:Visibility := Visibility.Collapsed
	ENDIF

	SELF:timerMapRefresh:Enabled := TRUE
RETURN


METHOD NewDataArrived() AS LOGIC
	IF SELF:dUpdateLocationDate == DateTime.MinValue
		RETURN FALSE
	ENDIF

	LOCAL cStatement AS STRING
	cStatement:="SELECT DateTimeGMT"+;
				" FROM FMDataPackages"+oMainForm:cNoLockTerm+;
				" WHERE VESSEL_UNIQUEID="+SELF:cVesselUID+;
				" AND DateTimeGMT > '"+SELF:dUpdateLocationDate:ToString("yyyy-MM-dd HH:mm:ss")+"'"+;
				" AND DateTimeGMT <= '"+SELF:dDateToRoutingGMT:ToString("yyyy-MM-dd HH:mm:ss")+"'"+;
				" AND FMDataPackages.REPORT_UID="+SELF:cReportUID+;
				" ORDER BY DateTimeGMT DESC"
	cStatement := oSoftway:SelectTop(cStatement)
	LOCAL cNow := oSoftway:RecordExists(oMainForm:oGFH, oMainForm:oConn, cStatement, "DateTimeGMT") AS STRING
	IF cNow == ""
		RETURN FALSE
	ENDIF

	LOCAL dNow := DateTime.Parse(cNow) AS DateTime
	IF SELF:dUpdateLocationDate == dNow
		RETURN FALSE
	ENDIF
RETURN TRUE


METHOD BingMapForm_OnShown() AS VOID
	// Add PushPin
	//SELF:MyMapUserControl:AddPushpin(Location{37.92, 23.70}, "Posidonos Avenue, Palaion Faliron, Greece", "37.92, 23.70")

	/*LOCAL oPushpin := Pushpin{} AS Pushpin
	oPushpin:Location := Microsoft.Maps.MapControl.WPF.Location{37.92, 23.70}
	oPushpin:ToolTip := "Posidonos Avenue, Palaion Faliron, Greece"

	LOCAL locs := List<Microsoft.Maps.MapControl.WPF.Location>{} AS List<Microsoft.Maps.MapControl.WPF.Location>
	locs:Add(oPushpin:Location)

	SELF:PinLayer:Children:Add(oPushpin)*/

	//SELF:Map:SetView(locs, Thickness{oMainForm:nThickness}, 0)

	SELF:dUpdateLocationDate := DateTime.MinValue

	SELF:ClearAll()
	SELF:DrawRoutingLine(FALSE)

	//SELF:ReadExistingDraggablePins()
RETURN


METHOD BingMapForm_OnFormClosing() AS VOID
	//IF SELF:oLBCItemRouting:oRow["CompletedGMT"]:ToString() <> ""
	//	RETURN
	//ENDIF
RETURN


PRIVATE METHOD ClearAll() AS VOID
	SELF:MyMapUserControl:PinLayer:Children:Clear()
	SELF:MyMapUserControl:RouteLineLayer:Children:Clear()

	//SELF:MyMapUserControl:FuturePinLayer:Children:Clear()
	//SELF:MyMapUserControl:FutureRouteLineLayer:Children:Clear()
RETURN


PRIVATE METHOD DrawRoutingLine(lTimerRefresh AS LOGIC) AS VOID
	SELF:MyMapUserControl:RouteLineLayer:Children:Clear()

	// Blue line
	LOCAL locs := LocationCollection{} AS LocationCollection

	SELF:FillLocations(locs)
	//LOCAL oData := SELF:FillLocations(locs) AS DataTable
	//locs:Add(Microsoft.Maps.MapControl.WPF.Location{37.92, 23.70})
	//locs:Add(Microsoft.Maps.MapControl.WPF.Location{34.00, 22.70})
	//locs:Add(Microsoft.Maps.MapControl.WPF.Location{33.92, 21.70})
	//locs:Add(Microsoft.Maps.MapControl.WPF.Location{30.92, 20.70})

	SELF:routeLine := MyMapPolyline{}
	SELF:routeLine:Locations := locs
	SELF:routeLine:Stroke := SolidColorBrush{Colors.Blue}
	SELF:routeLine:StrokeThickness := 0	//3

	//SELF:routeLine:DataContext := oData

	//LOCAL oDataSourceProvider AS DataSourceProvider
	//oDataSourceProvider:Data := oData
	//SELF:routeLine:DataContext := oDataSourceProvider
	//SELF:routeLine:StrokeThickness := 1

	/*//Set the tag property value
	SELF:routeLine:SetValue(MyTagProp, "I'm a polyline")

	//Add WPF events
	SELF:routeLine:Tapped += @ShapeTapped{}*/

	// Events:
	SELF:routeLine:MouseLeftButtonDown += System.Windows.Input.MouseButtonEventHandler{SELF, @routeLine_MouseLeftButtonDown()}
	//SELF:routeLine:PreviewReadCompleted += MouseButtonEventHandler{SELF, @routeLine_MouseLeftButtonDown()}
	SELF:routeLine:MouseEnter += System.Windows.Input.MouseEventHandler{SELF, @routeLine_MouseEnter()}
	SELF:routeLine:MouseLeave += System.Windows.Input.MouseEventHandler{SELF, @routeLine_MouseLeave()}
	//SELF:routeLine:PreviewMouseDown += System.Windows.Input.MouseButtonEventHandler{SELF, @routeLine_PreviewMouseDown()}

	//SELF:routeLine:Focusable := TRUE

	SELF:MyMapUserControl:RouteLineLayer:Children:Add(SELF:routeLine)

	SELF:ShowAllWaypoints()

	//SELF:MyMapUserControl:MapLayer:Children:Add(SELF:routeLine)
    //SELF:Map:SetView(locs, Thickness{oMainForm:nThickness}, 0)

	/*// Red line
	LOCAL locs1 := LocationCollection{} AS LocationCollection
	locs1:Add(Microsoft.Maps.MapControl.WPF.Location{34.00, 22.70})
	locs1:Add(Microsoft.Maps.MapControl.WPF.Location{33.92, 21.70})

	LOCAL routeLine1 := MapPolyline{} AS MapPolyline
	routeLine1:Locations := locs1
	routeLine1:Stroke := SolidColorBrush{Colors.Red}
	routeLine1:StrokeThickness := 5

	SELF:RouteLineLayer:Children:Add(routeLine1)*/

	IF ! lTimerRefresh
		// Zoom to line level:
		TRY
			SELF:Map:SetView(locs, Thickness{oMainForm:nThickness}, 0)
		CATCH e AS Exception
			wb(e:Message)
		END TRY
	ENDIF

	SELF:Map:Focus()
RETURN


METHOD FillLocations(locs AS LocationCollection) AS VOID
	LOCAL cStatement, cLatitude, cLongitude, cN_OR_S, cW_OR_E AS STRING

	//LOCAL cStart := "2013-09-19 13:10:00" AS STRING
	//LOCAL cEnd := "2013-10-22 19:00:00" AS STRING
	//LOCAL nRecords as INT
	//wb(oMainForm:CalcDistanceDates(Datetime.Parse(cStart), Datetime.Parse(cEnd), nRecords, FALSE):ToString()+CRLF+oMainForm:CalcDistanceDates(Datetime.Parse(cStart), Datetime.Parse(cEnd), nRecords, TRUE):ToString())

	cStatement:="SELECT DateTimeGMT, Latitude, Longitude, N_OR_S, W_OR_E, GmtDiff"+;
				" FROM FMDataPackages"+oMainForm:cNoLockTerm+;
				" WHERE DateTimeGMT BETWEEN '"+SELF:dDateFromRoutingGMT:ToString("yyyy-MM-dd HH:mm:ss")+"' AND '"+SELF:dDateToRoutingGMT:ToString("yyyy-MM-dd HH:mm:ss")+"'"+;
				" AND VESSEL_UNIQUEID="+SELF:cVesselUID+;
				" AND FMDataPackages.REPORT_UID="+SELF:cReportUID+;
				" ORDER BY DateTimeGMT"
				//" WHERE TDate BETWEEN '"+cStart+"' AND '"+cEnd+"'"+;
	SELF:oDTPackages := oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement)
	//memowrit(cTempDocDir+"\oDTPackages.txt", cStatement)
	//wb(cStatement, oDT:Rows:Count)

	LOCAL  nLatitude, nLongitude AS FLOAT
	LOCAL oLocation AS Microsoft.Maps.MapControl.WPF.Location
	LOCAL n, nRows := SELF:oDTPackages:Rows:Count - 1 AS INT

	/*IF nRows > 1
		LOCAL oPrevRow AS DataRow
		oPrevRow := SELF:oDTPackages:Rows[nRows]
		FOR n := nRows - 1 DOWNTO 0
			LOCAL oRow := SELF:oDTPackages:Rows[n] AS DataRow
			IF oRow:Item["Latitude"]:ToString() <> oPrevRow:Item["Latitude"]:ToString() .and. oRow:Item["Longitude"]:ToString() <> oPrevRow:Item["Longitude"]:ToString() //;
				//.and. oRow:Item["N_OR_S"]:ToString() <> oPrevRow:Item["N_OR_S"]:ToString() .and. oRow:Item["W_OR_E"]:ToString() <> oPrevRow:Item["W_OR_E"]:ToString()
				//wb((oRow:Item["Latitude"]:ToString() <> oPrevRow:Item["Latitude"]:ToString()):ToString()+CRLF+(oRow:Item["Longitude"]:ToString() <> oPrevRow:Item["Longitude"]:ToString()):ToString(), n:ToString())
				oPrevRow := oRow
				//wb("Prev", n:ToString())
			ELSE
				SELF:oDTPackages:Rows:Remove(oRow)
			ENDIF
		NEXT
		nRows := SELF:oDTPackages:Rows:Count - 1
	ENDIF*/

	LOCAL oRow AS DataRow
	FOR n := 0 UPTO nRows
		//IF n++ % 10 <> 0
		//	LOOP
		//ENDIF

		oRow := SELF:oDTPackages:Rows[n]

		cN_OR_S := oRow:Item["N_OR_S"]:ToString()
		cW_OR_E := oRow:Item["W_OR_E"]:ToString()
		cLatitude := oRow:Item["Latitude"]:ToString()	//:Replace(oMainForm:groupSeparator, oMainForm:decimalSeparator)
		IF cN_OR_S == "S"
			cLatitude := "-"+cLatitude
		ENDIF
		nLatitude := GPSCoordinate_To_DecDegrees(cLatitude) //* nDegreeToRadiansFactor

		cLongitude := oRow:Item["Longitude"]:ToString()	//:Replace(oMainForm:groupSeparator, oMainForm:decimalSeparator)
		IF cW_OR_E == "W"
			cLongitude := "-"+cLongitude
		ENDIF
		nLongitude := GPSCoordinate_To_DecDegrees(cLongitude) //* nDegreeToRadiansFactor

		oLocation := Microsoft.Maps.MapControl.WPF.Location{nLatitude, nLongitude}
		locs:Add(oLocation)
	NEXT

/*	IF nRows > 0
		LOCAL cFromPort, cToPort AS STRING

		// Add Start PushPin
		cFromPort := SELF:oLBCItemRouting:FromPort()
		SELF:oPortFromPushpin := SELF:AddPushPinPort(SELF:oDTPackages:Rows[0], cFromPort, "From:")

		// Add End PushPin
		cToPort := SELF:oLBCItemRouting:ToPort()
		SELF:oLastLocationPushpin := SELF:AddPushPinPort(SELF:oDTPackages:Rows[nRows], cToPort, "To:")
	ENDIF*/

	IF nRows > 0
		//IF SELF:oLBCItemRouting:dEndGMT == DateTime.MaxValue
			// Read the current (last) values
			SELF:WaypointDate := DateTime.Parse(SELF:oDTPackages:Rows[nRows]:Item["DateTimeGMT"]:ToString())
		//ELSE
			//SELF:WaypointDate := SELF:oLBCItemRouting:dEndGMT
		//ENDIF
		SELF:dLastLocationDate := SELF:WaypointDate
		SELF:dFirstLocationDate := DateTime.Parse(SELF:oDTPackages:Rows[0]:Item["DateTimeGMT"]:ToString())
	ENDIF
	//wb(SELF:WaypointDate)
	//wb(SELF:oLBCItemRouting:dStart, SELF:oLBCItemRouting:dEndGMT)

	//LOCAL nDistance := Math.Round(oMainForm:CalcWholeDistance(SELF:cVesselUID, SELF:oLBCItemRouting:dStart, SELF:oLBCItemRouting:dEndGMT), 2) AS Double
	//SELF:Text += "  Distance covered: "+nDistance:ToString()
	SELF:Text += "  ("+SELF:oDTPackages:Rows:Count:ToString()+" waypoints used)"
	SELF:cFormText := SELF:Text
//wb(nDistance, "Distance")
//RETURN oData
RETURN


PRIVATE METHOD MapUserControl_PreviewKeyDown(sender AS OBJECT, e AS System.Windows.Input.KeyEventArgs) AS VOID
	IF e:Key <> Key.F4 .and. e:Key <> Key.F5 .and. e:Key <> Key.F9 .and. e:Key <> Key.F11
		RETURN
	ENDIF

	IF SELF:MyMapUserControl:currentPushpinLocation == NULL .and. InListExact(e:Key, Key.F4, Key.F5)
		RETURN
	ENDIF

/*	LOCAL oLoc := SELF:currentPushpinLocation AS Location
	oLoc:Latitude -= 0.4
	SELF:Infobox:Visibility := Visibility.Collapsed
	MapLayer.SetPosition(SELF:InfoBox, oLoc)
	SELF:Infobox:Visibility := Visibility.Visible*/

	DO CASE
	CASE e:Key == Key.F4
		SELF:GoToPreviousPushpin()

	CASE e:Key == Key.F5
		SELF:GoToNextPushpin()

	CASE e:Key == Key.F9
		SELF:ClearAllPushpins(SELF:MyMapUserControl:PinLayer, SELF:MyMapUserControl:ListPushPin)

		SELF:Map:Focus()

	//CASE e:Key == Key.F11
	//	//IF SELF:ClearAllPushPins(SELF:MyMapUserControl:FuturePinLayer, SELF:MyMapUserControl:ListFuturePushPin)
	//	IF SELF:ClearAllDraggablePins(SELF:MyMapUserControl:FuturePinLayer, SELF:MyMapUserControl:ListFuturePushPin)
	//		SELF:MyMapUserControl:FutureRouteLineLayer:Children:Clear()
	//	ENDIF

	//	SELF:Map:Focus()
	ENDCASE
	e:Handled := TRUE
RETURN


METHOD ReadDates() AS LOGIC
	LOCAL cDate AS STRING

	// Voyage GMT
	cDate := SELF:oLBCItemVoyage:oRow["StartDateGMT"]:ToString()
	IF cDate == ""
		ErrorBox("No Voyage's StartDateGMT found")
		RETURN FALSE
	ENDIF
	SELF:dDateFromVoyageGMT := Datetime.Parse(cDate)

	cDate := SELF:oLBCItemVoyage:oRow["EndDateGMT"]:ToString()
	IF cDate == ""
		SELF:dDateToVoyageGMT := TimeZoneInfo.ConvertTime(Datetime.Now, TimeZoneInfo.UTC)
	ELSE
		SELF:dDateToVoyageGMT := Datetime.Parse(cDate)
	ENDIF

	// Voyage LT
	cDate := SELF:oLBCItemVoyage:oRow["StartDate"]:ToString()
	IF cDate == ""
		ErrorBox("No Voyage's StartDate found")
		RETURN FALSE
	ENDIF
	SELF:dDateFromVoyage := Datetime.Parse(cDate)

	cDate := SELF:oLBCItemVoyage:oRow["EndDate"]:ToString()
	IF cDate == ""
		SELF:dDateToVoyage := TimeZoneInfo.ConvertTime(Datetime.Now, TimeZoneInfo.UTC)
	ELSE
		SELF:dDateToVoyage := Datetime.Parse(cDate)
	ENDIF

	// Routing GMT
	cDate := SELF:oLBCItemRouting:oRow["CommencedGMT"]:ToString()
	IF cDate == ""
		ErrorBox("No Voyage Routing's CommencedGMT found")
		RETURN FALSE
	ENDIF
	SELF:dDateFromRoutingGMT := Datetime.Parse(cDate)

	cDate := SELF:oLBCItemRouting:oRow["CompletedGMT"]:ToString()
	IF cDate == ""
		SELF:dDateToRoutingGMT := TimeZoneInfo.ConvertTime(Datetime.Now, TimeZoneInfo.UTC)
	ELSE
		SELF:dDateToRoutingGMT := Datetime.Parse(cDate)
	ENDIF

	// Routing LT
	cDate := SELF:oLBCItemRouting:oRow["Commenced"]:ToString()
	IF cDate == ""
		ErrorBox("No Voyage Routing's Commenced found")
		RETURN FALSE
	ENDIF
	SELF:dDateFromRouting := Datetime.Parse(cDate)

	cDate := SELF:oLBCItemRouting:oRow["Completed"]:ToString()
	IF cDate == ""
		SELF:dDateToRouting := TimeZoneInfo.ConvertTime(Datetime.Now, TimeZoneInfo.UTC)
	ELSE
		SELF:dDateToRouting := Datetime.Parse(cDate)
	ENDIF
RETURN TRUE

#Region Events
////// Provide CLR accessors for the event 
////PUBLIC EVENT Tap AS RoutedEventHandler
//	//add { AddHandler(TapEvent, value) } 
//	//remove { RemoveHandler(TapEvent, value) }
////RETURN

//// This method raises the Tap event 
//PRIVATE METHOD RaiseTapEvent() as void
//	LOCAL newEventArgs := RoutedEventArgs{BingMapForm.TapEvent} AS RoutedEventArgs
//wb(1)
//	SELF:routeLine:RaiseEvent(newEventArgs)
////SELF:routeLine:AddHandler()
//RETURN

//// For demonstration purposes we raise the event when the MyButtonSimple is clicked 
//PROTECTED VIRTUAL METHOD OnClick() AS VOID
//wb("OnClick")
//	SELF:RaiseTapEvent()
//RETURN


//// Convert MousePoint to Map Location:
//	LOCAL oPoint := e:GetPosition(SELF:routeLine) AS System.Windows.Point
//	LOCAL oLocation AS Location
//	SELF:Map:TryViewportPointToLocation(oPoint, oLocation)
//	wb(oLocation)


METHOD routeLine_MouseEnter(sender AS System.Object, e AS System.Windows.Input.MouseEventArgs) AS VOID
	LOCAL oMapPolyLine := (MyMapPolyline)sender AS MyMapPolyline
	oMapPolyLine:Cursor := System.Windows.Input.Cursors.Hand
RETURN


METHOD routeLine_MouseLeave(sender AS System.Object, e AS System.Windows.Input.MouseEventArgs) AS VOID
	LOCAL oMapPolyLine := (MyMapPolyline)sender AS MyMapPolyline
	oMapPolyLine:Cursor := System.Windows.Input.Cursors.Arrow
RETURN


METHOD MyMapUserControl_MouseRightButtonDown(sender AS System.Object, e AS System.Windows.Input.MouseButtonEventArgs) AS VOID
	SELF:LastRightClickPoint := System.Windows.Point{0, 0}
	IF ! e:OriginalSource:ToString():EndsWith("Border")
		RETURN
	ENDIF
	SELF:LastRightClickPoint := e:GetPosition(SELF:routeLine)

	/*//LOCAL oMapPolyLine := (MyMapPolyline)sender AS MyMapPolyline
	//LOCAL oPoint := e:GetPosition(oMapPolyLine) AS System.Windows.Point

	LOCAL oPoint := e:GetPosition(SELF:routeLine) AS System.Windows.Point
	LOCAL oLocClicked AS Location
	SELF:Map:TryViewportPointToLocation(oPoint, oLocClicked)

	//LOCAL oLocation := Microsoft.Maps.MapControl.WPF.Location{oLocClicked:Latitude, oLocClicked:Longitude} AS Microsoft.Maps.MapControl.WPF.Location

	// Create a new FuturePushpin
	SELF:CreateFuturePushpin(oLocClicked)*/
RETURN


METHOD routeLine_MouseLeftButtonDown(sender AS System.Object, e AS System.Windows.Input.MouseButtonEventArgs) AS VOID
	//wb(e:GetPosition(SELF:routeLine), e:Source)
	//wb(SELF:routeLine)
	//LOCAL oPoint := e:GetPosition(SELF:Map) AS System.Windows.Point
	LOCAL oMapPolyLine := (MyMapPolyline)sender AS MyMapPolyline
	LOCAL oPoint := e:GetPosition(oMapPolyLine) AS System.Windows.Point

	//IF oMapPolyLine:SnapsToDevicePixels
	//	wb("SnapsToDevicePixels")
	//ENDIF

	LOCAL oLocClicked AS Location
	SELF:Map:TryViewportPointToLocation(oPoint, oLocClicked)

//	SELF:LocateGPSDataRow(oLocClicked)
	LOCAL cError, cErrorTitle AS STRING
	LOCAL lFound AS LOGIC
	LOCAL nTries := 0 AS Double
	LOCAL nNear := 0.1 AS Double

	LOCAL oLocations := List<Microsoft.Maps.MapControl.WPF.Location>{} AS List<Microsoft.Maps.MapControl.WPF.Location>
	oLocations:AddRange(oMapPolyLine:Locations)
	oLocations:TrimExcess()
	//	LOCAL n AS INT
	//	LOCAL cStr AS STRING
	//	FOR n := 0 UPTO oLocations:Count - 1
	//		cStr += "Map: "+oLocations[n]:Latitude:ToString()+" - "+oLocations[n]:Longitude:ToString()+;
	//				" GPS: "+DecDegrees_To_GPSCoordinate(oLocations[n]:Latitude):ToString()+" - "+DecDegrees_To_GPSCoordinate(oLocations[n]:Longitude):ToString()+CRLF
	//	NEXT
	//	memowrit(cTempDocDir+"\before.txt", cStr)
	oLocations:Sort(CompareLocations)
		//cStr := ""
		//FOR n := 0 UPTO oLocations:Count - 1
		//	cStr += "Map: "+oLocations[n]:Latitude:ToString()+" - "+oLocations[n]:Longitude:ToString()+;
		//			" GPS: "+DecDegrees_To_GPSCoordinate(oLocations[n]:Latitude):ToString()+" - "+DecDegrees_To_GPSCoordinate(oLocations[n]:Longitude):ToString()+CRLF
		//NEXT
		//memowrit(cTempDocDir+"\after.txt", cStr)

	SELF:MyMapUserControl:currentPushpinLocation := NULL
	WHILE ! lFound .and. nTries < 5
		// Near: from 0.1 up to 0.4
		nTries++
		lFound := SELF:LocateShortestDistance(oLocations, oLocClicked, nNear * nTries, cError, cErrorTitle, SELF:MyMapUserControl:currentPushpinLocation, SELF:WaypointDate, SELF:WaypointGmtDiff)
	ENDDO
	IF ! lFound
		wb(cError, cErrorTitle)
		//System.Windows.MessageBox.Show(cError, cErrorTitle)
		SELF:Map:Focus()
		RETURN
	ENDIF

	// Add Pushpin:
	SELF:CreatePushpin()

	//LOCAL oInfobox := Microsoft.Maps.Infobox{SELF:MyMapUserControl:currentPushpinLocation}	//, { visible: FALSE, offset: new Microsoft.Maps.Point(0, 20) })
	//SELF:InfoboxLayer:AddChild(oInfobox)

	//LOCAL oPushpin := Pushpin{} AS Pushpin
	/*oPushpin:Location := SELF:MyMapUserControl:currentPushpinLocation
	LOCAL mData := WpfMapUserControl.Metadata{} AS WpfMapUserControl.Metadata
	mData:Title := "Location info"
	mData:Description := cInfo
	oPushpin:Tag := mData
	//oPushpin:Content := SELF:WaypointDate
	oPushpin:ToolTip := "Location info"
	// Adds the pushpin to the map
	SELF:PinLayer:Children:Add(oPushpin)*/
	////SELF:Map:Children:Add(oPushpin)

	//oPushpin:MouseLeftButtonDown += System.Windows.Input.MouseButtonEventHandler{SELF, @Pushpin_MouseLeftButtonDown()}
	//oPushpin:MouseLeftButtonDown += System.Windows.Input.MouseButtonEventHandler{@MyMapUserControl, @PinClicked()}
	//SELF:MyMapUserControl:currentPushpin:MouseRightButtonDown += System.Windows.Input.MouseButtonEventHandler{SELF, @Pushpin_MouseRightButtonDown()}

	//LOCAL n := oMapPolyLine:Locations:Count - 1 AS INT
	//wb(oMapPolyLine:Locations[n]:Latitude:ToString()+CRLF+oMapPolyLine:Locations[n]:Longitude:ToString())

	//LOCAL oProjectedPoints := oMapPolyLine:ProjectedPointsCollection AS PointCollection
	//wb(oLocClicked, oProjectedPoints:Count:ToString())
	//LOCAL oPolyLine := (System.Windows.Shapes.Polyline)oMapPolyLine:InputHitTest(oPoint) AS System.Windows.Shapes.Polyline

	//LOCAL oTranslatedPoint := oMapPolyLine:TranslatePoint(oPoint, oMapPolyLine) AS Point
	//wb(oTranslatedPoint:ToString())

	//wb(oMapPolyLine:MyLogicalChildren)
RETURN


PUBLIC METHOD Pushpin_MouseRightButtonDown(sender AS OBJECT, e AS System.Windows.Input.MouseButtonEventArgs) AS VOID
	LOCAL p := (Pushpin)sender AS Pushpin

	IF SELF:MyMapUserControl:PinLayer:Children:Contains(p)
		SELF:MyMapUserControl:ClosePin(SELF:MyMapUserControl:PinLayer, p)
	//ELSE
	//	SELF:MyMapUserControl:ClosePin(SELF:MyMapUserControl:FuturePinLayer, p)
	//	SELF:DrawFutureRoutingLine()
	ENDIF

	e:Handled := TRUE
RETURN


//PUBLIC METHOD DraggablePin_MouseRightButtonDown(sender AS OBJECT, e AS System.Windows.Input.MouseButtonEventArgs) AS VOID
//	LOCAL p := (DraggablePin)sender AS DraggablePin

//	//IF SELF:MyMapUserControl:PinLayer:Children:Contains(p)
//		//SELF:MyMapUserControl:ClosePin(SELF:MyMapUserControl:PinLayer, p)
//	//ELSE
//		//SELF:MyMapUserControl:ClosePin(SELF:MyMapUserControl:FuturePinLayer, p)
//		SELF:MyMapUserControl:CloseDraggablePin(SELF:MyMapUserControl:FuturePinLayer, p)
//		SELF:DrawFutureRoutingLine()
//	//ENDIF

//	e:Handled := TRUE
//RETURN

#EndRegion Events


METHOD CreatePushpin() AS VOID
 	LOCAL cInfo AS STRING

	cInfo := SELF:LocationInfo(SELF:MyMapUserControl:currentPushpinLocation, SELF:WaypointDate, SELF:WaypointGmtDiff)
	// Remove last CRLF
	cInfo := cInfo:Substring(0, cInfo:Length - 2)

	LOCAL dLocal as DateTime
	LOCAL nHours := (INT)SELF:WaypointGmtDiff AS INT
	dLocal := SELF:WaypointDate:AddHours(nHours)

	LOCAL nMinutes := (Double)SELF:WaypointGmtDiff - (Double)nHours AS Double
	IF nMinutes <> (Double)0
		nMinutes := (INT)(((Double)nMinutes * (Double)60) / (Double)3600)
		dLocal := dLocal:AddMinutes(nMinutes)
	ENDIF
	//wb(dLocal, SELF:WaypointDate)
	LOCAL cTitle := SELF:WaypointDate:ToString("dd/MM/yyyy HH:mm")+" (GMT), "+dLocal:ToString("dd/MM/yyyy HH:mm")+" (LT)" AS STRING

	//wb(SELF:MyMapUserControl:currentPushpinLocation:Latitude:ToString())
	LOCAL p := SELF:MyMapUserControl:AddPushpin(SELF:MyMapUserControl:PinLayer, SELF:MyMapUserControl:currentPushpinLocation, cTitle, cInfo, FALSE) AS Pushpin
	// MouseRightButtonDown -> PinClose
	p:MouseRightButtonDown += System.Windows.Input.MouseButtonEventHandler{SELF, @Pushpin_MouseRightButtonDown()}
RETURN


METHOD LocateFMDataRecord(cOper AS STRING, oPrevLoc AS Location) AS LOGIC
	LOCAL cStatement AS STRING

	DO CASE
	CASE cOper == "Previous"
		cStatement:="SELECT DateTimeGMT, Latitude, Longitude, N_OR_S, W_OR_E, GmtDiff"+;
					" FROM FMDataPackages"+oMainForm:cNoLockTerm+;
					" WHERE VESSEL_UNIQUEID="+SELF:cVesselUID+;
					" AND DateTimeGMT >= '"+dFirstLocationDate:ToString("yyyy-MM-dd HH:mm:ss")+"'"+;
					" AND DateTimeGMT < '"+SELF:WaypointDate:ToString("yyyy-MM-dd HH:mm:ss")+"'"+;
					" AND FMDataPackages.REPORT_UID="+SELF:cReportUID+;
					" ORDER BY DateTimeGMT DESC"
		cStatement := oSoftway:SelectTop(cStatement)

	CASE cOper == "Next"
		cStatement:="SELECT DateTimeGMT, Latitude, Longitude, N_OR_S, W_OR_E, GmtDiff"+;
					" FROM FMDataPackages"+oMainForm:cNoLockTerm+;
					" WHERE VESSEL_UNIQUEID="+SELF:cVesselUID+;
					" AND DateTimeGMT > '"+SELF:WaypointDate:ToString("yyyy-MM-dd HH:mm:ss")+"'"+;
					" AND DateTimeGMT <= '"+dLastLocationDate:ToString("yyyy-MM-dd HH:mm:ss")+"'"+;
					" AND FMDataPackages.REPORT_UID="+SELF:cReportUID+;
					" ORDER BY DateTimeGMT"
		cStatement := oSoftway:SelectTop(cStatement)

	//OTHERWISE
	//	cStatement:="SELECT DateTimeGMT"+;
	//				" FROM FMDataPackages"+oMainForm:cNoLockTerm+;
	//				" WHERE VESSEL_UNIQUEID="+SELF:cVesselUID+;
	//				" AND DateTimeGMT = '"+cOper+"'"
	//	wb(cStatement, "OTHERWISE")
	ENDCASE
	//wb(cStatement)
	//memowrit(cTempDocDir+"\st.txt", cStatement)
	LOCAL oData := oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement) AS DataTable
	IF oData:Rows:Count == 0
		RETURN FALSE
	ENDIF

	LOCAL oRow AS DataRow
	oRow := oData:Rows[0]

	LOCAL cLatitude, cLongitude, cN_OR_S, cW_OR_E AS STRING
	LOCAL nLatitude, nLongitude AS Double

	cN_OR_S := oRow:Item["N_OR_S"]:ToString()
	cW_OR_E := oRow:Item["W_OR_E"]:ToString()
	cLatitude := oRow:Item["Latitude"]:ToString()	//:Replace(oMainForm:groupSeparator, oMainForm:decimalSeparator)
	IF cN_OR_S == "S"
		cLatitude := "-"+cLatitude
	ENDIF
	nLatitude := GPSCoordinate_To_DecDegrees(cLatitude) //* nDegreeToRadiansFactor

	cLongitude := oRow:Item["Longitude"]:ToString()	//:Replace(oMainForm:groupSeparator, oMainForm:decimalSeparator)
	IF cW_OR_E == "W"
		cLongitude := "-"+cLongitude
	ENDIF
	nLongitude := GPSCoordinate_To_DecDegrees(cLongitude) //* nDegreeToRadiansFactor

	//wb(oPrevLoc:Latitude, nLatitude)
	IF oPrevLoc:Latitude == nLatitude .and. oPrevLoc:Longitude == nLongitude
		RETURN FALSE
	ENDIF

	SELF:WaypointDate := DateTime.Parse(oRow:Item["DateTimeGMT"]:ToString())
	SELF:WaypointGmtDiff := Convert.ToDecimal(oData:Rows[0]:Item["GmtDiff"]:ToString())
RETURN TRUE


METHOD LocationInfo(oPosition AS Location, dDate AS DateTime, nGmtDiff AS Decimal) AS STRING
	LOCAL cInfo, cN_OR_S, cW_OR_E AS STRING

	IF oPosition:Latitude < 0
		cN_OR_S := "S"
	ELSE
		cN_OR_S := "N"
	ENDIF
	IF oPosition:Longitude < 0
		cW_OR_E := "W"
	ELSE
		cW_OR_E := "E"
	ENDIF
	//cInfo += "Latitude: "+DecDegrees_To_DegreesMinutesSeconds(oPosition:Latitude:ToString())+" ("+cN_OR_S+")"+", "+;
	//		"Longitude: "+DecDegrees_To_DegreesMinutesSeconds(oPosition:Longitude:ToString())+" ("+cW_OR_E+")"+CRLF
	cInfo += DecDegrees_To_DegreesMinutesSeconds(Math.Abs(oPosition:Latitude):ToString())+" ("+cN_OR_S+")"+", "+;
			DecDegrees_To_DegreesMinutesSeconds(Math.Abs(oPosition:Longitude):ToString())+" ("+cW_OR_E+")"+CRLF

	LOCAL cStatement AS STRING
	cStatement:="SELECT FMReportItems.ItemName, FMData.Data"+;
				" FROM FMData"+oMainForm:cNoLockTerm+;
				" INNER JOIN FMDataPackages ON FMDataPackages.PACKAGE_UID=FMData.PACKAGE_UID"+;
				"	AND FMDataPackages.VESSEL_UNIQUEID="+SELF:cVesselUID+;
				" INNER JOIN FMReportItems ON FMReportItems.ITEM_UID=FMData.ITEM_UID"+;
				"	AND FMReportItems.ShowOnMap=1"+;
				"	AND FMReportItems.ItemType='N'"+;
				" WHERE DateTimeGMT='"+dDate:ToString("yyyy-MM-dd HH:mm:ss")+"'"+;
				" AND FMDataPackages.REPORT_UID="+SELF:cReportUID+;
				" ORDER BY FMReportItems.ItemNo"
	LOCAL oDT := oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement) AS DataTable
	IF oDT:Rows:Count == 0
		RETURN cInfo
	ENDIF

	//LOCAL nData AS Double
	LOCAL cItemName AS STRING
	FOREACH oRow AS DataRow IN oDT:Rows
		cItemName := oRow["ItemName"]:ToString()
		//nData := Convert.ToDouble(oRow["Data"]:ToString())
		cInfo += cItemName+": "+oRow["Data"]:ToString()+CRLF
	NEXT
	cInfo := cInfo:Substring(0, cInfo:Length - 2)
RETURN cInfo


/*METHOD Pushpin_MouseLeftButtonDown(sender AS System.Object, e AS System.Windows.Input.MouseButtonEventArgs) AS VOID
	//LOCAL oPushpin := (Pushpin)sender AS Pushpin
	////LOCAL m := (Metadata)oPushpin:Tag AS Metadata
	////wb(m:Title, m:Description)
	//SELF:MyMapUserControl:PinClicked(oPushpin, e)

	LOCAL oPushpin := (Pushpin)sender AS Pushpin
	LOCAL m := (Metadata)oPushpin:Tag AS Metadata

	//IF (! (STRING.IsNullOrEmpty(m:Title) .and. STRING.IsNullOrEmpty(m:Description)))
	//	SELF:MyMapUserControl:InfoboxTitle:Text := m:Title
	//	SELF:MyMapUserControl:InfoboxDescription:Text := m:Description
	//ENDIF
RETURN*/


//METHOD Pushpin_MouseRightButtonDown(sender AS System.Object, e AS System.Windows.Input.MouseButtonEventArgs) AS VOID
////wb(sender, "Mouse")
//	//LOCAL infobox := (Grid)SELF:Map:FindName("Infobox") AS Grid
//	//wb(Infobox:ToString())
//	//LOCAL oPushpin := (Pushpin)sender AS Pushpin
//	//SELF:PinLayer:Children:Remove(oPushpin)
//	//e:Handled := TRUE

//	IF sender:ToString():Contains("Pushpin")
//		SELF:MyMapUserControl:currentPushpin := (Pushpin)sender
//		SELF:MyMapUserControl:currentPushpinLocation := SELF:MyMapUserControl:currentPushpinLocation
//		//e:Handled := TRUE
//	ENDIF
//RETURN


METHOD LocateShortestDistance(oLocations AS List<Microsoft.Maps.MapControl.WPF.Location>, oLocClicked AS Location, nNear AS Double, ;
								cError REF STRING, cTitle REF STRING, oPosition REF Microsoft.Maps.MapControl.WPF.Location, dDate REF DateTime, nGmtDiff REF Decimal) AS LOGIC
	LOCAL cStatement := "" AS STRING
	TRY
		LOCAL n AS INT
		//LOCAL cStr AS STRING
		//FOR n := 0 UPTO oLocations:Count - 1
		//	cStr += "Map: "+oLocations[n]:Latitude:ToString()+" - "+oLocations[n]:Longitude:ToString()+;
		//			" GPS: "+DecDegrees_To_GPSCoordinate(oLocations[n]:Latitude):ToString()+" - "+DecDegrees_To_GPSCoordinate(oLocations[n]:Longitude):ToString()+CRLF
		//NEXT
		//memowrit(cTempDocDir+"\locs1.txt", cStr)

		LOCAL nLen := oLocations:Count - 1, nStart := -1 AS INT
		FOR n := 0 UPTO nLen
			IF oLocations[n]:Latitude >= oLocClicked:Latitude - nNear
				nStart := n
				EXIT
			ENDIF
		NEXT

		IF nStart == -1
			cError := "No Location found near the User's click"
			cTitle := "Geo search (+/- 0.1)"
			RETURN FALSE
		ENDIF

		//LOCAL c AS STRING
		//c := "Start="+nStart:ToString()+CRLF+"Len="+nLen:ToString()+CRLF+"Clicked="+oLocClicked:Latitude:ToString()+CRLF+CRLF
		//memowrit(cTempDocDir+"\n.txt", c)
		LOCAL oLocSelected := List<Microsoft.Maps.MapControl.WPF.Location>{} AS List<Microsoft.Maps.MapControl.WPF.Location>
		FOR n := nStart UPTO nLen
			IF oLocations[n]:Latitude >= oLocClicked:Latitude + nNear
				EXIT
			ENDIF
			oLocSelected:Add(oLocations[n])
			//c += "n="+n:ToString()+": "+oLocations[n]:Latitude:ToString()+CRLF
			//memowrit(cTempDocDir+"\n.txt", c)
		NEXT
		oLocSelected:TrimExcess()
		IF oLocSelected:Count == 0
			cError := "No Location found near the User's click"
			cTitle := NULL
			RETURN FALSE
		ENDIF
		//c += "Capacity="+oLocSelected:Count:ToString()+CRLF
		//memowrit(cTempDocDir+"\n.txt", c)

		//LOCAL cStr AS STRING
		LOCAL nLenSel := oLocSelected:Count - 1 AS INT
		LOCAL nDistance, nMin := 1000000 AS Double
		//cStr := ""
		LOCAL nSelected := -1 AS INT
		FOR n := 0 UPTO nLenSel
			nDistance := oMainForm:CalcDist_MAP(oLocClicked, oLocSelected[n])
			IF nDistance < nMin
				nSelected := n
			ENDIF
			nMin := Min(nMin, nDistance)
			//cStr += "Distance: "+Math.Round(nDistance, 2):ToString()+" Map: "+oLocSelected[n]:Latitude:ToString()+" - "+oLocSelected[n]:Longitude:ToString()+;
			//		" GPS: "+DecDegrees_To_GPSCoordinate(oLocSelected[n]:Latitude):ToString()+" - "+DecDegrees_To_GPSCoordinate(oLocSelected[n]:Longitude):ToString()+CRLF
			//memowrit(cTempDocDir+"\nStr.txt", cStr)
		NEXT

		IF nSelected == -1
			cError := "No Location found near the User's click"
			cTitle := NULL
			RETURN FALSE
		ENDIF

		//LOCAL cv := "nSelected="+nSelected:ToString()+CRLF AS STRING
		//memowrit(cTempDocDir+"\nSel.txt", cv)
		//cv += oLocSelected[nSelected]:Latitude:ToString()+" - "+oLocSelected[nSelected]:Longitude:ToString()+CRLF
		//memowrit(cTempDocDir+"\nSel.txt", cv)
		//cv += DecDegrees_To_GPSCoordinate(oLocSelected[nSelected]:Latitude):ToString()+" - "+DecDegrees_To_GPSCoordinate(oLocSelected[nSelected]:Longitude):ToString()
		//memowrit(cTempDocDir+"\nSel.txt", cv)

		oPosition := oLocSelected[nSelected]

		LOCAL nLatSelected := Math.Round(DecDegrees_To_GPSCoordinate(oPosition:Latitude), 4) AS Double
		LOCAL nLonSelected := Math.Round(DecDegrees_To_GPSCoordinate(oPosition:Longitude), 4) AS Double
		LOCAL cLatitude, cLongitude, cN_OR_S, cW_OR_E AS STRING

		IF nLatSelected < 0
			cLatitude := (-nLatSelected):ToString():Replace(",", ".")
			cN_OR_S := "S"
		ELSE
			cLatitude := nLatSelected:ToString():Replace(",", ".")
			cN_OR_S := "N"
		ENDIF

		IF nLonSelected < 0
			cLongitude := (-nLonSelected):ToString():Replace(",", ".")
			cW_OR_E := "W"
		ELSE
			cLongitude := nLonSelected:ToString():Replace(",", ".")
			cW_OR_E := "E"
		ENDIF

		cStatement:="SELECT DateTimeGMT, GmtDiff"+;
					" FROM FMDataPackages"+oMainForm:cNoLockTerm+;
					" WHERE VESSEL_UNIQUEID="+SELF:cVesselUID+;
					" AND FMDataPackages.REPORT_UID="+SELF:cReportUID+;
					" AND DateTimeGMT BETWEEN '"+SELF:dDateFromRoutingGMT:ToString("yyyy-MM-dd HH:mm:ss")+"' AND '"+SELF:dDateToRoutingGMT:ToString("yyyy-MM-dd HH:mm:ss")+"'"+;
					" AND Latitude LIKE '%"+cLatitude+"%' AND N_OR_S='"+cN_OR_S+"'"+;
					" AND Longitude LIKE '%"+cLongitude+"%' AND W_OR_E='"+cW_OR_E+"'"
		//memowrit(cTempDocDir+"\st.txt", cStatement)
		LOCAL oData := oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement) AS DataTable
		IF oData:Rows:Count == 0
			memowrit(cTempDocDir+"\st.txt", cStatement)
			cError := "Record not found for the clicked Location"
			cTitle := NULL
			RETURN FALSE
		ENDIF

		dDate := DateTime.Parse(oData:Rows[0]:Item["DateTimeGMT"]:ToString())
		nGmtDiff := Convert.ToDecimal(oData:Rows[0]:Item["GmtDiff"]:ToString())
		//cCourse := "0"	//oData:Rows[0]:Item["Course"]:ToString()

		//memowrit(cTempDocDir+"\locs.txt", cStr+CRLF+CRLF+"Min="+nMin:ToString()+CRLF+;
		//	"User Lat: "+oLocClicked:Latitude:ToString()+CRLF+"User Lon: "+oLocClicked:Longitude:ToString()+CRLF+"Selected="+oLocSelected[nSelected]:Latitude:ToString()+" - "+oLocSelected[nSelected]:Longitude:ToString())

		//memowrit(cTempDocDir+"\locs.txt", cStr+CRLF+CRLF+;
		//	"Position selected: "+oLocSelected:Count:ToString()+CRLF+;
		//	"Min="+nMin:ToString()+CRLF+;
		//	"User: "+oLocClicked:Latitude:ToString()+" - "+oLocClicked:Longitude:ToString()+CRLF+"Selected MAP: "+oLocSelected[nSelected]:Latitude:ToString()+" - "+oLocSelected[nSelected]:Longitude:ToString()+CRLF+;
		//	"Selected GPS: "+nLatSelected:ToString()+" - "+nLonSelected:ToString()+CRLF+;
		//	"Found at: "+DateTime.Parse(oData:Rows[0]:Item["TDate"]:ToString()):ToString("yyyy-MM-dd HH:mm:ss")+CRLF)
		//wb("Min="+nMin:ToString()+CRLF)

		//oLocations:Exists(x => x:PartId == 1444))
		//LOCAL f := oListFind{SELF, @ListFind(oLocations[0])} AS oListFind
		//oLocations:Find(oListFind{SELF, @ListFind(oLocations[0])})
		//LOCAL a := Location[]{1} AS Location[]
		//Array.Find(a, ListFind(oLocations[0]))
	CATCH e AS Exception
		memowrit(cTempDocDir+"\st.txt", cStatement)
		cError := e:Message+CRLF+CRLF+cStatement
		cTitle := "Exception error"
	END TRY
RETURN TRUE


//STATIC METHOD ListFind(oLoc AS Location) AS logic
//RETURN TRUE

//PRIVATE METHOD GetNextWaypoint() AS VOID
//	wb("Next")
//RETURN


METHOD CompareLocations(x AS Location, y AS Location) AS INT
	IF x == NULL
		IF y == NULL
			RETURN 0
		ENDIF
		RETURN -1
	ENDIF
	
	IF y == NULL
		RETURN 1
	ENDIF

	DO CASE
	CASE x:Latitude < y:Latitude
		RETURN -1

	//CASE x:Latitude == y:Latitude
	//	IF x:Longitude <= y:Longitude
	//		RETURN -1
	//	ELSE
	//		RETURN 1
	//	ENDIF
	ENDCASE
RETURN 1


//PUBLIC STATIC METHOD DoEvents() AS VOID
//    Application.Current.Dispatcher.Invoke(DispatcherPriority.Background, Action{DELEGATE{}})
//RETURN


//METHOD routeLine_PreviewMouseDown(sender AS System.Object, e AS System.Windows.Input.MouseButtonEventArgs ) AS VOID
//	IF e:OriginalSource:ToString():Contains("Ellipse")
//		wb(e:OriginalSource:ToString(), "Down")
//	ENDIF
//	//LOCAL oMapPolyLine := (MyMapPolyline)sender AS MyMapPolyline
//	//oMapPolyLine:Locations(e:
//RETURN


//PUBLIC STATIC METHOD GetClosestPointOnRoute(line AS System.Data.Spatial.DbGeography, point AS System.Data.Spatial.DbGeography) AS System.Data.Spatial.DbGeography
//	LOCAL sqlLine := SqlGeography:Parse(line:AsText()):MakeValid() AS SqlGeography //the linestring
//	LOCAL sqlPoint := SqlGeography:Parse(point:AsText()):MakeValid() AS SqlGeography //the point i want on the line

//	LOCAL shortestLine := sqlPoint.ShortestLineTo(sqlLine) AS SqlGeography //find the shortest line from the linestring to point

//	//lines have a start, and an end
//	LOCAL start := shortestLine:STStartPoint() AS SqlGeography
//	LOCAL oEnd := shortestLine:STEndPoint() AS SqlGeography

//	LOCAL newGeography := DbGeography.FromText(oEnd:ToString(), 4326) AS DbGeography

//	LOCAL distance := newGeography.Distance(line)
//RETURN newGeography

END CLASS


CLASS MyMapPolyline INHERIT MapPolyline
	PROPERTY ProjectedPointsCollection AS PointCollection
		GET
			RETURN SELF:ProjectedPoints
		END GET

		SET
			SELF:ProjectedPoints := Value
		END SET
	END	PROPERTY

	//PROPERTY MyLogicalChildren AS LogicalChildren
	//	GET
	//		RETURN SELF:LogicalChildren
	//	END GET

	//	SET
	//		SELF:LogicalChildren := Value
	//	END SET
	//END	PROPERTY
END CLASS
