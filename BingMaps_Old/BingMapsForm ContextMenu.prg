// BingMapsForm_ContextMenu.prg
#using System.Collections.Generic
#USING System.Windows
#USING System.Windows.Controls
#USING System.Windows.Input
#USING Microsoft.Maps.MapControl.WPF
//#USING DraggablePushpin
#USING WpfMapUserControl

PARTIAL CLASS BingMapForm INHERIT WpfMapUserControl.MapForm
	//PRIVATE CustomRoutedCommand AS RoutedCommand
	PRIVATE WP_Previous, WP_Next, WP_Separator1, WP_Separator2, WP_ShowAll, WP_Separator3, WP_ClearAll AS System.Windows.Controls.MenuItem

METHOD CreateContextMenu_Pushpin() AS VOID
	LOCAL contextMenuStrip_Pushpin AS System.Windows.Controls.ContextMenu

	// Previous
	WP_Previous := System.Windows.Controls.MenuItem{}
	WP_Previous:Name := "WP_Previous"
	WP_Previous:Header := "Go to the Previous Waypoint"
	WP_Previous:Click += System.Windows.RoutedEventHandler{ SELF, @WP_Previous_Click() }
	WP_Previous:InputGestureText := "F4"
	//WP_Previous:Icon := 
 
	//LOCAL CloseCmdKeyGesture := KeyGesture{Key.L, ModifierKeys.Alt} AS KeyGesture
	//LOCAL CloseKeyBinding := KeyBinding{ApplicationCommands.Close, CloseCmdKeyGesture} AS KeyBinding
	//SELF:MyMapUserControl:InputBindings:Add(CloseKeyBinding)

	// Next
	WP_Next := System.Windows.Controls.MenuItem{}
	WP_Next:Name := "WP_Next"
	WP_Next:Header := "Go to the Next Waypoint"
	WP_Next:Click += System.Windows.RoutedEventHandler{ SELF, @WP_Next_Click() }
	WP_Next:InputGestureText := "F5"

	WP_Separator1 := System.Windows.Controls.MenuItem{}
	WP_Separator1:Name := "WP_Separator1"
	WP_Separator1:Header := ""

	//// Clear all
	//WP_ClearAll := System.Windows.Controls.MenuItem{}
	//WP_ClearAll:Name := "WP_ClearAll"
	//WP_ClearAll:Header := "Clear all Waypoints"
	//WP_ClearAll:Click += System.Windows.RoutedEventHandler{ SELF, @WP_ClearAll_Click() }
	//WP_ClearAll:InputGestureText := "F9"

	//WP_Separator2 := System.Windows.Controls.MenuItem{}
	//WP_Separator2:Name := "WP_Separator2"
	//WP_Separator2:Header := ""

	//// Show all
	//WP_ShowAll := System.Windows.Controls.MenuItem{}
	//WP_ShowAll:Name := "WP_ShowAll"
	//WP_ShowAll:Header := "Show all Waypoints"
	//WP_ShowAll:Click += System.Windows.RoutedEventHandler{ SELF, @WP_ShowAll_Click() }

	//// Split Routing
	//WP_SplitRouting := System.Windows.Controls.MenuItem{}
	//WP_SplitRouting:Name := "WP_SplitRouting"
	//WP_SplitRouting:Header := "Split Voyage Routing at this waypoint"
	//WP_SplitRouting:Click += System.Windows.RoutedEventHandler{ SELF, @WP_SplitRouting_Click() }

	//WP_Separator3 := System.Windows.Controls.MenuItem{}
	//WP_Separator3:Name := "WP_Separator3"
	//WP_Separator3:Header := ""

	//// Future Pushpin
	//WP_FuturePushpin := System.Windows.Controls.MenuItem{}
	//WP_FuturePushpin:Name := "WP_FuturePushpin"
	//WP_FuturePushpin:Header := "Create new Future Waypoint"
	//WP_FuturePushpin:Click += System.Windows.RoutedEventHandler{ SELF, @WP_FuturePushpin_Click() }

	//// Clear all
	//WP_FutureClearAll := System.Windows.Controls.MenuItem{}
	//WP_FutureClearAll:Name := "WP_FutureClearAll"
	//WP_FutureClearAll:Header := "Clear all Future Waypoints"
	//WP_FutureClearAll:Click += System.Windows.RoutedEventHandler{ SELF, @WP_FutureClearAll_Click() }
	//WP_FutureClearAll:InputGestureText := "F11"


	// ContextMenu
	contextMenuStrip_Pushpin := System.Windows.Controls.ContextMenu{}
	// 
	// contextMenuStrip_Pushpin
	// 
	contextMenuStrip_Pushpin:Items:Add(WP_Previous)
	contextMenuStrip_Pushpin:Items:Add(WP_Next)
	//contextMenuStrip_Pushpin:Items:Add(WP_Separator1)

	//contextMenuStrip_Pushpin:Items:Add(WP_FuturePushpin)
	//contextMenuStrip_Pushpin:Items:Add(WP_Separator2)

	//contextMenuStrip_Pushpin:Items:Add(WP_ShowAll)
	//contextMenuStrip_Pushpin:Items:Add(WP_SplitRouting)
	//contextMenuStrip_Pushpin:Items:Add(WP_Separator3)

	//contextMenuStrip_Pushpin:Items:Add(WP_ClearAll)
	//contextMenuStrip_Pushpin:Items:Add(WP_FutureClearAll)

	contextMenuStrip_Pushpin:Name := "contextMenuStrip_Pushpin"

	SELF:MyMapUserControl:ContextMenu := contextMenuStrip_Pushpin

	SELF:MyMapUserControl:ContextMenuOpening += ContextMenuEventHandler{ SELF, @contextMenuStrip_Pushpin_ContextMenuOpening() }

	//SELF:MyMapUserControl:InputBindings:Add(KeyBinding{((MedicContext)SELF:MyMapUserControl:DataContext):SynchronizeCommand, KeyGesture{Key.F9}})
	//SELF:MyMapUserControl:InputBindings:Add(KeyBinding{SELF:CustomRoutedCommand, KeyGesture{Key.F, ModifierKeys.Control}})
RETURN

 
//PRIVATE METHOD OpenCommandBinding_Executed(sender AS OBJECT, e AS ExecutedRoutedEventArgs) AS VOID
//RETURN


PRIVATE METHOD contextMenuStrip_Pushpin_ContextMenuOpening( sender AS System.Object, e AS System.Windows.Controls.ContextMenuEventArgs ) AS System.Void
	//wb(e:Source:ToString()+CRLF+e:OriginalSource:ToString(), "Menu")

	/*IF SELF:LastRightClickPoint == System.Windows.Point{0, 0} .or. SELF:oLBCItemRouting:oRow["CompletedGMT"]:ToString() <> ""
		SELF:WP_FuturePushpin:Visibility := Visibility.Hidden
	ELSE
		SELF:WP_FuturePushpin:Visibility := Visibility.Visible
	ENDIF*/

	DO CASE
	//CASE e:OriginalSource:ToString():Contains("Shapes.Path")
		//SELF:MyMapUserControl:currentPushpin := (Pushpin)sender
		//SELF:MyMapUserControl:currentPushpinLocation := SELF:MyMapUserControl:currentPushpinLocation

	//CASE e:OriginalSource:ToString():Contains("Ellipse")
	//	e:Handled := TRUE

	CASE e:OriginalSource:ToString():Contains("TextBlock")
		SELF:MyMapUserControl:CloseInfobox()
		e:Handled := TRUE

	CASE SELF:MyMapUserControl:lPushpinClosed
		e:Handled := TRUE

	//CASE ! e:OriginalSource:ToString():Contains("Ellipse") .and. ! SELF:MyMapUserControl:lPushpinClosed
	//	//LOCAL oPushpin := SELF:MyMapUserControl:currentPushpin AS Pushpin
	//	//SELF:MyMapUserControl:ClosePin(oPushpin)	//CloseInfobox_Click(e:OriginalSource, System.Windows.RoutedEventArgs.Empty)
	//	SELF:MyMapUserControl:CloseInfobox()
	//	//e:Handled := TRUE
	ENDCASE

	IF SELF:MyMapUserControl:lPushpinClosed
		SELF:MyMapUserControl:lPushpinClosed := FALSE
	ENDIF

//	IF SELF:MyMapUserControl:currentPushpinLocation == NULL
//		SELF:WP_Previous:Visibility := System.Windows.Visibility.Hidden
//		SELF:WP_Next:Visibility := System.Windows.Visibility.Hidden
//	ENDIF

//	IF SELF:MyMapUserControl:ListPushPin:Count == 0
//		SELF:WP_ClearAll:Visibility := System.Windows.Visibility.Hidden
////		e:Handled := TRUE
//	ENDIF
RETURN


PRIVATE METHOD WP_Previous_Click( sender AS System.Object, e AS System.Windows.RoutedEventArgs ) AS System.Void
	//LOCAL o := (MenuItem)e:Source AS System.Windows.Controls.MenuItem
	//wb(o:ActualWidth)
	SELF:GoToPreviousPushpin()
RETURN


PRIVATE METHOD GoToPreviousPushpin() AS VOID
	IF SELF:MyMapUserControl:currentPushpinLocation == NULL
		RETURN
	ENDIF

	LOCAL nIndex := SELF:routeLine:Locations:IndexOf(SELF:MyMapUserControl:currentPushpinLocation) AS INT
	//wb("nIndex="+nIndex:ToString()+CRLF+"Locations="+SELF:routeLine:Locations:Count:ToString(), "Locations")
	IF nIndex < 1
		RETURN
	ENDIF

	LOCAL oPrevLoc := SELF:MyMapUserControl:currentPushpinLocation AS Location

	nIndex--
	//wb(SELF:MyMapUserControl:currentPushpinLocation:Latitude:ToString()+CRLF+SELF:MyMapUserControl:currentPushpinLocation:Longitude:ToString(), "Prev")
	SELF:MyMapUserControl:currentPushpinLocation := SELF:routeLine:Locations[nIndex]
	IF SELF:LocateFMDataRecord("Previous", oPrevLoc)
		SELF:CreatePushpin()
	ENDIF
	//wb(SELF:MyMapUserControl:currentPushpinLocation:Latitude:ToString()+CRLF+SELF:MyMapUserControl:currentPushpinLocation:Longitude:ToString(), "Next")
RETURN


PRIVATE METHOD WP_Next_Click( sender AS System.Object, e AS System.Windows.RoutedEventArgs ) AS System.Void
	SELF:GoToNextPushpin()
RETURN


PRIVATE METHOD GoToNextPushpin() AS VOID
	IF SELF:MyMapUserControl:currentPushpinLocation == NULL
		RETURN
	ENDIF

	LOCAL nIndex := SELF:routeLine:Locations:IndexOf(SELF:MyMapUserControl:currentPushpinLocation) AS INT
	IF nIndex == -1 .or. nIndex >= SELF:routeLine:Locations:Count - 1
		RETURN
	ENDIF

	LOCAL oPrevLoc := SELF:MyMapUserControl:currentPushpinLocation AS Location

	nIndex++
//wb(SELF:MyMapUserControl:currentPushpinLocation:Latitude:ToString()+CRLF+SELF:MyMapUserControl:currentPushpinLocation:Longitude:ToString(), "Prev")
	SELF:MyMapUserControl:currentPushpinLocation := SELF:routeLine:Locations[nIndex]
	IF SELF:LocateFMDataRecord("Next", oPrevLoc)
		SELF:CreatePushpin()
	ENDIF
RETURN


PRIVATE METHOD WP_ShowAll_Click( sender AS System.Object, e AS System.Windows.RoutedEventArgs ) AS System.Void
	SELF:ShowAllWaypoints()
	SELF:Map:Focus()
RETURN


//PRIVATE METHOD WP_SplitRouting_Click( sender AS System.Object, e AS System.Windows.RoutedEventArgs ) AS System.Void
//	IF SELF:MyMapUserControl:currentPushpinLocation == NULL
//		wb("No waypoint selected")
//		RETURN
//	ENDIF

//	LOCAL nIndex := SELF:routeLine:Locations:IndexOf(SELF:MyMapUserControl:currentPushpinLocation) AS INT
//	IF nIndex == -1 .or. nIndex >= SELF:routeLine:Locations:Count - 1
//		wb("No waypoint selected")
//		RETURN
//	ENDIF

//	SELF:SplitVoyageRouting()
//	//SELF:Map:Focus()
//RETURN


PRIVATE METHOD WP_ClearAll_Click( sender AS System.Object, e AS System.Windows.RoutedEventArgs ) AS System.Void
	SELF:ClearAllPushpins(SELF:MyMapUserControl:PinLayer, SELF:MyMapUserControl:ListPushPin)

	SELF:polygonPointLayer:Children:Clear()

	SELF:Map:Focus()
RETURN


//PRIVATE METHOD WP_FutureClearAll_Click( sender AS System.Object, e AS System.Windows.RoutedEventArgs ) AS System.Void
//	IF SELF:ClearAllDraggablePins(SELF:MyMapUserControl:FuturePinLayer, SELF:MyMapUserControl:ListFuturePushPin)
//	//IF SELF:ClearAllPushpins(SELF:MyMapUserControl:FuturePinLayer, SELF:MyMapUserControl:ListFuturePushPin)
//		SELF:MyMapUserControl:FutureRouteLineLayer:Children:Clear()
//	ENDIF

//	SELF:Map:Focus()
//RETURN


PRIVATE METHOD ClearAllPushpins(oPinLayer AS MapLayer, oListPushPin AS List<Pushpin>) AS LOGIC
	LOCAL cStr := " " AS STRING

	//IF oPinLayer:Name == "FuturePinLayer"
	//	SELF:nTotalDistanceToGo := (Double)0
	//	cStr := " Future"
	//ENDIF
	IF QuestionBox("Do you want to remove all the"+cStr+" Waypoints ?", "Clear all"+cStr+" Waypoints") <> System.Windows.Forms.DialogResult.Yes
		RETURN FALSE
	ENDIF

	LOCAL n, nLen := oListPushPin:Count - 1 AS INT

	FOR n:=nLen DOWNTO 0
		SELF:MyMapUserControl:ClosePin(oPinLayer, oListPushPin[n])
	NEXT
RETURN TRUE


//PRIVATE METHOD ClearAllDraggablePins(oPinLayer AS MapLayer, oListPushPin AS List<DraggablePin>) AS LOGIC
//	LOCAL cStr := " " AS STRING

//	IF oPinLayer:Name == "FuturePinLayer"
//		SELF:nTotalDistanceToGo := (Double)0
//		cStr := " Future"
//	ENDIF
//	IF QuestionBox("Do you want to remove all the"+cStr+" Waypoints ?", "Clear all"+cStr+" Waypoints") <> System.Windows.Forms.DialogResult.Yes
//		RETURN FALSE
//	ENDIF

//	LOCAL n, nLen := oListPushPin:Count - 1 AS INT

//	FOR n:=nLen DOWNTO 0
//		//SELF:MyMapUserControl:ClosePin(oPinLayer, oListPushPin[n])
//		SELF:MyMapUserControl:CloseDraggablePin(oPinLayer, oListPushPin[n])
//	NEXT
//RETURN TRUE


//PRIVATE METHOD WP_FuturePushpin_Click( sender AS System.Object, e AS System.Windows.RoutedEventArgs ) AS System.Void
//	LOCAL oLocClicked AS Location
//	SELF:Map:TryViewportPointToLocation(SELF:LastRightClickPoint, oLocClicked)

//	SELF:CreateFuturePushpin(oLocClicked)
//RETURN

END CLASS
