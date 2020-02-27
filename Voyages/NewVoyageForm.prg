USING System
USING System.Collections.Generic
USING System.ComponentModel
USING System.Data
USING System.Data.Common
USING System.Drawing
USING System.Text
USING System.Windows.Forms
PUBLIC PARTIAL CLASS NewVoyageForm ;
    INHERIT System.Windows.Forms.Form
    PUBLIC CONSTRUCTOR(parent AS Form, vesselUID AS STRING, cVoyageUID AS STRING) STRICT //NewVoyageForm         
        InitializeComponent()
        
        oParent := parent
        
        SELF:cVesselUID := vesselUID
        SELF:cVoyageUID := cVoyageUID
            
        SELF:GetVesselName()
        SELF:VesselNameLbl:Text := i"Vessel: {cVesselName}"
        SELF:InitControlList()
        SELF:InitTypeCB()
        SELF:InitDTPorts()
        SELF:InitPortCBs()
        SELF:SetVoyageNo()
        
        SELF:SelectPortFrom("")
        SELF:SelectPortTo("")
        
        IF !string.IsNullOrEmpty(cVoyageUID)
            SELF:InitDataFromDB()
        ENDIF
        
        RETURN
        
        
        
        
        
        #region PRIVATE Methods
PRIVATE METHOD RefreshFormBtn_ItemClick(sender AS OBJECT, e AS DevExpress.XtraBars.ItemClickEventArgs) AS VOID STRICT
    ClearData()
    RETURN
PRIVATE METHOD CloseFormBtn_ItemClick(sender AS OBJECT, e AS DevExpress.XtraBars.ItemClickEventArgs) AS VOID STRICT
    SELF:Close()
    RETURN
PRIVATE METHOD SaveBtn_ItemClick(sender AS OBJECT, e AS DevExpress.XtraBars.ItemClickEventArgs) AS VOID STRICT
    SELF:SaveData()    
    RETURN
PRIVATE METHOD FromGC_Paint(sender AS OBJECT, e AS System.Windows.Forms.PaintEventArgs) AS VOID STRICT
    RETURN
PRIVATE METHOD typeCb_Leave(sender AS OBJECT, e AS System.EventArgs) AS VOID STRICT
    SetVoyageTypeId()
    RETURN
PRIVATE METHOD fromPortCb_Leave(sender AS OBJECT, e AS System.EventArgs) AS VOID STRICT
    ValidatePorts()
    RETURN
PRIVATE METHOD toPortCb_Leave(sender AS OBJECT, e AS System.EventArgs) AS VOID STRICT
    ValidatePorts()
    RETURN
PRIVATE METHOD startDate_ValueChanged(sender AS OBJECT, e AS System.EventArgs) AS VOID STRICT
    startDate:CustomFormat := "dd/MM/yyyy HH:mm:ss"
    startGmtDate:CustomFormat := "dd/MM/yyyy HH:mm:ss"
    SetFromGmtDate()
    RETURN
PRIVATE METHOD endDate_ValueChanged(sender AS OBJECT, e AS System.EventArgs) AS VOID STRICT
    endDate:CustomFormat := "dd/MM/yyyy HH:mm:ss"
    endGmtDate:CustomFormat := "dd/MM/yyyy HH:mm:ss"
    SetToGmtDate()
    RETURN
PRIVATE METHOD chartererTb_Click(sender AS OBJECT, e AS System.EventArgs) AS VOID STRICT
    SetCharterers()
    RETURN
PRIVATE METHOD chartererTb_KeyDown(sender AS OBJECT, e AS System.Windows.Forms.KeyEventArgs) AS VOID STRICT
    SetCharterers()
    RETURN
PRIVATE METHOD NewVoyageForm_FormClosing(sender AS OBJECT, e AS System.Windows.Forms.FormClosingEventArgs) AS VOID STRICT
    IF SELF:lIsSaved
        oMainForm:Fill_TreeList_Reports()
    ENDIF
    oParent:Enabled := TRUE
    RETURN
PRIVATE METHOD fromPortCb_SelectedValueChanged(sender AS OBJECT, e AS System.EventArgs) AS VOID STRICT
//    ValidatePorts()
    RETURN
PRIVATE METHOD NewVoyageForm_Shown(sender AS OBJECT, e AS System.EventArgs) AS VOID STRICT
    oParent:Enabled := FALSE
    IF string.IsNullOrEmpty(cVoyageUID)
        SELF:CheckLastVoyage()
    ENDIF    
    RETURN
PRIVATE METHOD AddPortToBtn_Click(sender AS OBJECT, e AS System.EventArgs) AS VOID STRICT
    SELF:AddPortDestination()
    RETURN
PRIVATE METHOD descriptionTb_TextChanged(sender AS OBJECT, e AS System.EventArgs) AS VOID STRICT
    RETURN
PRIVATE METHOD voyageNoTb_KeyPress(sender AS OBJECT, e AS System.Windows.Forms.KeyPressEventArgs) AS VOID STRICT
    //only number
    IF !char.IsDigit(e:KeyChar)
        e:Handled := TRUE
    ENDIF
    
    RETURN
PRIVATE METHOD NewVoyageForm_FormClosed(sender AS OBJECT, e AS System.Windows.Forms.FormClosedEventArgs) AS VOID STRICT
    oParent:Enabled := TRUE
    RETURN
PRIVATE METHOD bbiCreateFolders_ItemClick(sender AS OBJECT, e AS DevExpress.XtraBars.ItemClickEventArgs) AS VOID STRICT
    LOCAL fsController := FStructureController{} AS FStructureController
    SELF:CreateFolderStructure(fsController)
    RETURN
    #endregion

END CLASS 
