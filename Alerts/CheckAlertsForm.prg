USING System
USING System.Collections
USING System.Collections.Generic
USING System.ComponentModel
USING System.Data
USING system.Data.Common
USING system.Linq
USING System.Drawing
USING System.Text
USING System.Windows.Forms
PUBLIC PARTIAL CLASS CheckAlertsForm ;
    INHERIT System.Windows.Forms.Form
    PUBLIC CONSTRUCTOR() STRICT //CheckAlertsForm
            InitializeComponent()
            RETURN
PRIVATE METHOD button1_Click(sender AS OBJECT, e AS System.EventArgs) AS VOID STRICT
    IF string.IsNullOrEmpty(tb_PUID:Text)
		RETURN
	ENDIF
	
	VAR tmp := CheckAlerts(tb_PUID:Text)
	
	MessageBox.Show("AlertsUids: " + string.Join(", ", tmp))
	
	VAR stop := "stop"
	
	RETURN
	
	PUBLIC METHOD CheckAlerts(packageUid AS STRING) AS List<STRING>
		LOCAL lResult := List<STRING>{} AS List<STRING>
		LOCAL cStatement AS STRING
		LOCAL oDTPackageData, oDTAlertsConditions AS DataTable
		LOCAL lPackageData AS List<PckData>
		LOCAL lAlertsConditions, lAlertsConditionsFiltered AS List<AltConditions>
	
		cStatement := "SELECT a.PACKAGE_UID, a.VESSEL_UNIQUEID, a.REPORT_UID, b.ITEM_UID, b.Data "+;
						"FROM FMDataPackages a "+;
						"JOIN FMData b ON a.PACKAGE_UID=b.PACKAGE_UID "+;
						"WHERE a.Visible > 0 and a.PACKAGE_UID=" + packageUid
		oDTPackageData := oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement)
		lPackageData := (FROM a IN oDTPackageData:AsEnumerable() ;
						SELECT PckData{a["PACKAGE_UID"]:ToString(), a["VESSEL_UNIQUEID"]:ToString(), a["REPORT_UID"]:ToString(), a["ITEM_UID"]:ToString(), a["Data"]:ToString()}):ToList()

		cStatement := "SELECT a.AlertUid,a.AlertReportUID,c.FK_VesselUid,a.AlertApplyAllConditions,b.ConditionItemUid, b.ConditionOperator, b.ConditionValue "+;
						"FROM FMAlerts a "+;
						"JOIN FMAlertsConditions b ON a.AlertUid=b.ConditionAlertUid "+;
						"JOIN FMAlertsVessels c ON a.AlertUid=c.FK_AlertUid "+;
						"where c.FK_VesselUid=" + oDTPackageData:Rows[0]["VESSEL_UNIQUEID"]:ToString() + " and AlertReportUID=" + oDTPackageData:Rows[0]["REPORT_UID"]:ToString()
		oDTAlertsConditions := oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement)
		lAlertsConditions := (FROM a IN oDTAlertsConditions:AsEnumerable() ;
							 SELECT AltConditions{a["AlertUid"]:ToString(), a["AlertReportUID"]:ToString(), a["FK_VesselUid"]:ToString(), a["AlertApplyAllConditions"]:ToString(), a["ConditionItemUid"]:ToString(), a["ConditionOperator"]:ToString(), a["ConditionValue"]:ToString()}):ToList()
	
		FOREACH alertUid AS STRING IN lAlertsConditions:Select({i => i:AlertUid}):Distinct()
			lAlertsConditionsFiltered := lAlertsConditions:Where({i => i:AlertUid:Equals(alertUid)}):ToList()
		
			cStatement := string.Join(IIF(lAlertsConditionsFiltered:First():AlertApplyAllConditions:Equals("True"), " AND ", " OR "), ;
			lAlertsConditionsFiltered:Select({i => " (ITEM_UID=" + i:ConditionItemUid + " AND Data" + i:ConditionOperator + i:ConditionValue +")" }))
		
			LOCAL oListPck := (FROM a IN oDTPackageData:Select(cStatement):AsEnumerable() ;
						SELECT PckData{a["PACKAGE_UID"]:ToString(), a["VESSEL_UNIQUEID"]:ToString(), a["REPORT_UID"]:ToString(), a["ITEM_UID"]:ToString(), a["Data"]:ToString()}):ToList() AS List<PckData>
			IF oListPck:Count() > 0
				lResult:Add(alertUid)
			ENDIF
			
		NEXT
		RETURN lResult
		
	
END CLASS 

PUBLIC CLASS PckData
PROPERTY PACKAGE_UID AS STRING AUTO
PROPERTY VESSEL_UNIQUEID AS STRING AUTO
PROPERTY REPORT_UID AS STRING AUTO
PROPERTY ITEM_UID AS STRING AUTO
PROPERTY Data AS STRING AUTO
	
PUBLIC CONSTRUCTOR(pUid AS STRING, vUid AS STRING, rUid AS STRING, iUid AS STRING, _data AS STRING)
	PACKAGE_UID		:= pUid
	VESSEL_UNIQUEID	:= vUid
	REPORT_UID		:= rUid
	ITEM_UID		:= iUid
	Data			:= _data
	RETURN
	


END CLASS

PUBLIC CLASS AltConditions
PROPERTY AlertUid AS STRING AUTO
PROPERTY AlertReportUID AS STRING AUTO
PROPERTY FK_VesselUid AS STRING AUTO
PROPERTY AlertApplyAllConditions AS STRING AUTO
PROPERTY ConditionItemUid AS STRING AUTO
PROPERTY ConditionOperator AS STRING AUTO
PROPERTY ConditionValue AS STRING AUTO
	
PUBLIC CONSTRUCTOR(aUid AS STRING, rUid AS STRING, vUid AS STRING, applyAll AS STRING, iUid AS STRING, OPERATOR AS STRING, _value AS STRING)
	AlertUid				:= aUid
	AlertReportUID			:= rUid
	FK_VesselUid			:= vUid
	AlertApplyAllConditions	:= applyAll
	ConditionItemUid		:= iUid
	ConditionOperator		:= OPERATOR
	ConditionValue			:= _value
	RETURN
	


END CLASS

