// BingMapForm_AllWaypoints.prg
#USING System.Windows
#USING System.Windows.Controls
#USING System.Windows.Media
#USING System.Windows.Data
#USING System.Windows.Input
#USING System.Windows.Shapes
#USING Microsoft.Maps.MapControl.WPF
#USING System.Collections.Generic
#USING System.Data
//#USING Microsoft.Maps.SpatialToolbox.Bing.Clustering

PARTIAL CLASS BingMapForm INHERIT WpfMapUserControl.MapForm

PRIVATE METHOD ShowAllWaypoints() AS VOID
	//SELF:polygonPointLayer:Children:Clear()

	LOCAL locs := SELF:routeLine:Locations AS LocationCollection

	/*// Define a Rectangle:
	LOCAL r AS System.Windows.Shapes.Rectangle
	FOREACH oLoc AS Location IN locs
//		SELF:MyMapUserControl:AddPushpin(SELF:MyMapUserControl:PinLayer, oLoc, "", "", FALSE)
		// A visual representation of a polygon point.
		r := System.Windows.Shapes.Rectangle{}
		//r:Fill := SolidColorBrush{Colors.Red}
		//r:Stroke := SolidColorBrush{Colors.Yellow}
		r:Fill := SolidColorBrush{Colors.Yellow}
		r:StrokeThickness := 0
		r:Width := 2
		r:Height := 2
		r:MouseLeftButtonDown += System.Windows.Input.MouseButtonEventHandler{SELF, @Rectangle_MouseLeftButtonDown()}
		r:MouseEnter += System.Windows.Input.MouseEventHandler{SELF, @Rectangle_MouseEnter()}
		r:MouseLeave += System.Windows.Input.MouseEventHandler{SELF, @Rectangle_MouseLeave()}
        // Adds a small square where the user clicked, to mark the polygon point.
        SELF:polygonPointLayer:AddChild(r, oLoc)
		//SELF:MyMapUserControl:RouteLineLayer:AddChild(r, oLoc)
	NEXT*/

	LOCAL p AS Pushpin
	LOCAL nRow AS INT
	LOCAL cTitle, cInfo AS STRING
	LOCAL oLoc AS Location
	//LOCAL oPreviousLoc AS Location
	LOCAL dDate, dLocal AS DateTime
	LOCAL nHours AS INT
	LOCAL nMinutes, nGmtDiff AS Double
	FOREACH oRow AS DataRow IN SELF:oDTPackages:Rows
		oLoc := locs:Item[nRow]
		nRow++
		//IF oPreviousLoc <> NULL .and. oPreviousLoc:Latitude == oLoc:Latitude .and. oPreviousLoc:Longitude == oLoc:Longitude
		//	LOOP
		//ENDIF

		dDate := DateTime.Parse(oRow["DateTimeGMT"]:ToString())

		nGmtDiff := Convert.ToDouble(oRow["GmtDiff"]:ToString())
		nHours := (INT)nGmtDiff
		dLocal := dDate:AddHours(nHours)

		nMinutes := nGmtDiff - (Double)nHours
		IF nMinutes <> (Double)0
			nMinutes := (INT)(((Double)nMinutes * (Double)60) / (Double)3600)
			dLocal := dLocal:AddMinutes(nMinutes)
		ENDIF

		cTitle := dDate:ToString("dd/MM/yyyy HH:mm")+" (GMT), "+dLocal:ToString("dd/MM/yyyy HH:mm")+" (LT)"
		cInfo := SELF:LocationInfo(oLoc, dDate, Convert.ToDecimal(oRow["GmtDiff"]:ToString()))

		p := SELF:MyMapUserControl:AddPushpin(SELF:MyMapUserControl:PinLayer, oLoc, cTitle, cInfo, FALSE)
		//oPreviousLoc := oLoc
		// MouseRightButtonDown -> PinClose
		p:MouseRightButtonDown += System.Windows.Input.MouseButtonEventHandler{SELF, @Pushpin_MouseRightButtonDown()}
	NEXT
	//wb("End")

	/*LOCAL boundingBox := LocationRect{locs} AS LocationRect
	SELF:Map:SetView(boundingBox)
	IF true
		RETURN
	ENDIF*/
RETURN


//PRIVATE METHOD ShowAllWaypoints() AS VOID
//	SELF:polygonPointLayer:Children:Clear()

//	LOCAL locs := SELF:routeLine:Locations AS LocationCollection

//	// Define a Rectangle:
//	LOCAL r AS System.Windows.Shapes.Rectangle

//	FOREACH oLoc AS Location IN locs
////		SELF:MyMapUserControl:AddPushpin(SELF:MyMapUserControl:PinLayer, oLoc, "", "", FALSE)
//		// A visual representation of a polygon point.
//		r := System.Windows.Shapes.Rectangle{}
//		//r:Fill := SolidColorBrush{Colors.Red}
//		//r:Stroke := SolidColorBrush{Colors.Yellow}
//		r:Fill := SolidColorBrush{Colors.Yellow}
//		r:StrokeThickness := 0
//		r:Width := 2
//		r:Height := 2
//		r:MouseLeftButtonDown += System.Windows.Input.MouseButtonEventHandler{SELF, @Rectangle_MouseLeftButtonDown()}
//		r:MouseEnter += System.Windows.Input.MouseEventHandler{SELF, @Rectangle_MouseEnter()}
//		r:MouseLeave += System.Windows.Input.MouseEventHandler{SELF, @Rectangle_MouseLeave()}
//        // Adds a small square where the user clicked, to mark the polygon point.
//        SELF:polygonPointLayer:AddChild(r, oLoc)
//		//SELF:MyMapUserControl:RouteLineLayer:AddChild(r, oLoc)
//	NEXT

//	/*LOCAL boundingBox := LocationRect{locs} AS LocationRect
//	SELF:Map:SetView(boundingBox)
//	IF true
//		RETURN
//	ENDIF*/
//RETURN


//PRIVATE METHOD Rectangle_MouseEnter(sender AS System.Object, e AS System.Windows.Input.MouseEventArgs) AS VOID
//	LOCAL oRectangle := (System.Windows.Shapes.Rectangle)sender AS System.Windows.Shapes.Rectangle
//	oRectangle:Cursor := System.Windows.Input.Cursors.Hand
//RETURN


//PRIVATE METHOD Rectangle_MouseLeave(sender AS System.Object, e AS System.Windows.Input.MouseEventArgs) AS VOID
//	LOCAL oRectangle := (System.Windows.Shapes.Rectangle)sender AS System.Windows.Shapes.Rectangle
//	oRectangle:Cursor := System.Windows.Input.Cursors.Arrow
//RETURN


//PRIVATE METHOD Rectangle_MouseLeftButtonDown(sender AS System.Object, e AS System.Windows.Input.MouseButtonEventArgs) AS VOID
//	//wb(e:GetPosition(SELF:routeLine), e:Source)
//	//wb(SELF:routeLine)
//	//LOCAL oPoint := e:GetPosition(SELF:Map) AS System.Windows.Point
//	LOCAL oMapPolyLine := SELF:routeLine AS MyMapPolyline
//	LOCAL oPoint := e:GetPosition(oMapPolyLine) AS System.Windows.Point

//	LOCAL oLocClicked AS Location
//	SELF:Map:TryViewportPointToLocation(oPoint, oLocClicked)

//	LOCAL cError, cErrorTitle AS STRING
//	LOCAL lFound AS LOGIC
//	LOCAL nTries := 0 AS Double
//	LOCAL nNear := 0.1 AS Double

//	LOCAL oLocations := List<Microsoft.Maps.MapControl.WPF.Location>{} AS List<Microsoft.Maps.MapControl.WPF.Location>
//	oLocations:AddRange(oMapPolyLine:Locations)
//	oLocations:TrimExcess()
//	oLocations:Sort(CompareLocations)

//	SELF:MyMapUserControl:currentPushpinLocation := NULL
//	WHILE ! lFound .and. nTries < 5
//		// Near: from 0.1 up to 0.4
//		nTries++
//		lFound := SELF:LocateShortestDistance(oLocations, oLocClicked, nNear * nTries, cError, cErrorTitle, SELF:MyMapUserControl:currentPushpinLocation, SELF:WaypointDate, SELF:WaypointSpeed, SELF:WaypointCourse)
//	ENDDO
//	IF ! lFound
//		wb(cError, cErrorTitle)
//		//System.Windows.MessageBox.Show(cError, cErrorTitle)
//		SELF:Map:Focus()
//		RETURN
//	ENDIF

//	// Add Pushpin:
//	SELF:CreatePushpin()
//RETURN


//private method ClusterData(locs as LocationCollection) as Void
////Create an instance of the clustering layer
//    LOCAL layer := ClusteringLayer{} AS ClusteringLayer
//    layer:ClusterType := ClusteringType.Point

//    //Add event handlers to create the pushpins
//    layer.CreateItemPushpin += CreateItemPushpin
//    layer.CreateClusteredItemPushpin += CreateClusteredItemPushpin

//    //Add data to layer, where _mockdata is a ItemLocationCollection
//    layer:Items:AddRange(locs)
//    SELF:Map:Children:Add(layer)
//RETURN


//METHOD SplitVoyageRouting() AS VOID
//	LOCAL cTitle := SELF:MyMapUserControl:MyInfoboxTitle:Text AS STRING
//	cTitle := cTitle:Replace(" (GMT)", "")

//	//TRY
//		LOCAL dDate := DateTime.Parse(cTitle) AS DateTime
//		LOCAL cCurrentDate := dDate:ToString("yyyy-MM-dd HH:mm:ss") AS STRING

//		// Read Voyage Routing
//		LOCAL cStatement AS STRING
//		cStatement:="SELECT ROUTING_UID, RoutingROB_FO, FOPriceUSD, CommencedGMT, Distance, Deviation, Condition, TCEquivalentUSD,"+;
//					" VEPortsFrom.Port_UID AS PortFromUID, VEPortsTo.Port_UID AS PortToUID, RTrim(VEPortsFrom.Port) AS PortFrom, RTrim(VEPortsTo.Port) AS PortTo,"+;
//					" VEPortsFrom.SummerGMT_Diff AS PortFromSummerGMT_Diff, VEPortsFrom.WinterGMT_Diff AS PortFromWinterGMT_Diff,"+;
//					" VEPortsTo.SummerGMT_Diff AS PortToSummerGMT_Diff, VEPortsTO.WinterGMT_Diff AS PortToWinterGMT_Diff"+;
//					" FROM EconRoutings"+oMainForm:cNoLockTerm+;
//					" LEFT OUTER JOIN VEPorts AS VEPortsFrom ON EconRoutings.PortFrom_UID=VEPortsFrom.PORT_UID"+;
//					" LEFT OUTER JOIN VEPorts AS VEPortsTo ON EconRoutings.PortTo_UID=VEPortsTo.PORT_UID"+;
//					" WHERE VOYAGE_UID="+SELF:oLBCItemVoyage:oRow["VOYAGE_UID"]:ToString()+;
//					" AND (CompletedGMT IS NULL OR CommencedGMT='"+cCurrentDate+"')"
//		LOCAL oDT := oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement) AS DataTable
//		IF oDT:Rows:Count <> 1
//			wb("Cannot find GPS data record for Date: "+cTitle)
//			RETURN
//		ENDIF

//		// Split Routing
//		IF QuestionBox("Do you want to Split Voyage Routing at the selected Waypoint ?", "Split Voyage Routing") <> System.Windows.Forms.DialogResult.Yes
//			RETURN
//		ENDIF

//		oMainForm:SplitVoyageRouting(SELF:oLBCItemRouting, cTitle)

//	//CATCH
//	//	wb("You must select a waypoint apart the Start/End waypoints")
//	//END TRY
//RETURN

END CLASS
