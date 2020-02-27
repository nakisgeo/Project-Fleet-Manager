USING System
USING System.Collections.Generic
USING System.ComponentModel
USING System.Data
USING System.Drawing
USING System.Text
USING System.Windows.Forms
PUBLIC PARTIAL CLASS RLTItemsAddForm ;
    INHERIT System.Windows.Forms.Form
    PUBLIC CONSTRUCTOR(parent AS ItemsForm, itemUID AS STRING) STRICT //RLTItemsAddForm
        InitializeComponent()
        oParent := parent
        cItemUID := itemUID
        SELF:InitGridView()
        SELF:GetItems()
        RETURN
PRIVATE METHOD RLTItemsAddForm_Shown(sender AS OBJECT, e AS System.EventArgs) AS VOID STRICT
    IF oParent != NULL_OBJECT
        oParent:Enabled := FALSE
    ENDIF
    
    RETURN
PRIVATE METHOD RLTItemsAddForm_FormClosed(sender AS OBJECT, e AS System.Windows.Forms.FormClosedEventArgs) AS VOID STRICT
    IF oParent != NULL_OBJECT
        oParent:Enabled := TRUE
        oParent:ShowRelatedItems()
    ENDIF
    RETURN
PRIVATE METHOD barButtonItem3_ItemClick(sender AS OBJECT, e AS DevExpress.XtraBars.ItemClickEventArgs) AS VOID STRICT
	SELF:Save()
    SELF:Close()
    RETURN
PRIVATE METHOD barButtonItem1_ItemClick(sender AS OBJECT, e AS DevExpress.XtraBars.ItemClickEventArgs) AS VOID STRICT
	SELF:Save()
    SELF:GetItems()
    RETURN
PRIVATE METHOD barButtonItem2_ItemClick(sender AS OBJECT, e AS DevExpress.XtraBars.ItemClickEventArgs) AS VOID STRICT
    SELF:Close()
    RETURN

END CLASS 
