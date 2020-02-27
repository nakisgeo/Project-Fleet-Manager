USING System
USING System.Collections.Generic
USING System.ComponentModel
USING System.Data
USING System.Drawing
USING System.Text
USING System.Windows.Forms
PUBLIC PARTIAL CLASS FSHelpForm ;
    INHERIT System.Windows.Forms.Form
    PRIVATE oParent AS System.Windows.Forms.Form
    PUBLIC CONSTRUCTOR(form AS Form) STRICT //FSHelpForm
            InitializeComponent()
            oParent := Form
            RETURN
PRIVATE METHOD FSHelpForm_Load(sender AS OBJECT, e AS System.EventArgs) AS VOID STRICT
    dataGridView1:Columns:Add("KeyWord", "KeyWord")
    dataGridView1:Columns:Add("Replace", "Replace")
    
    VAR list := List<STRING[]>{}
    list:Add(<STRING>{"$VoyageDescription", "Description"})
    list:Add(<STRING>{"$VoyageDescription", "Description"})
    list:Add(<STRING>{"$VoyageNo", "VoyageNo"})
    list:Add(<STRING>{"$Charterers", "Charterers"})
    list:Add(<STRING>{"$Broker", "Broker"})
    list:Add(<STRING>{"$PortFrom", "PortFrom"})
    list:Add(<STRING>{"$PortTo", "PortTo"})
    list:Add(<STRING>{"$ConcatRoutes", "All routes concateneted"})
    
    list:Foreach({i => dataGridView1:Rows:Add(i)})
    RETURN
PRIVATE METHOD FSHelpForm_FormClosing(sender AS OBJECT, e AS System.Windows.Forms.FormClosingEventArgs) AS VOID STRICT
    oParent:Enabled := TRUE
    RETURN
PRIVATE METHOD FSHelpForm_Shown(sender AS OBJECT, e AS System.EventArgs) AS VOID STRICT
    oParent:Enabled := FALSE
    RETURN

END CLASS 
