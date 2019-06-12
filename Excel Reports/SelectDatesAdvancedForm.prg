#Using System.Data
#using System.Windows.Forms
#using System.IO
PUBLIC CLASS SelectDatesAdvancedForm ;
    INHERIT DevExpress.XtraEditors.XtraForm
    
    PRIVATE ButtonCancel AS DevExpress.XtraEditors.SimpleButton
    PRIVATE ButtonOK AS DevExpress.XtraEditors.SimpleButton
    PUBLIC DateTo AS DevExpress.XtraEditors.DateEdit
    PUBLIC DateFrom AS DevExpress.XtraEditors.DateEdit
    PRIVATE label2 AS System.Windows.Forms.Label
    PRIVATE label1 AS System.Windows.Forms.Label
    PRIVATE ItemsListView AS System.Windows.Forms.ListView
    PUBLIC Item AS System.Windows.Forms.ColumnHeader
    PUBLIC UID AS System.Windows.Forms.ColumnHeader
    PUBLIC cSqlUids := "" AS STRING
    PUBLIC cReportUid AS STRING
    PUBLIC cVesselUID AS STRING
    PUBLIC oItemsTable AS System.Data.DataTable
    PRIVATE lSelectionChanged AS LOGIC
    PRIVATE lLoading AS LOGIC
    PRIVATE checkBoxAll AS System.Windows.Forms.CheckBox
    PRIVATE components AS System.ComponentModel.IContainer
    CONSTRUCTOR()
      SUPER()
      SELF:InitializeComponent()
      RETURN

/// <summary>
/// Clean up any resources being used.
/// </summary>
/// <param name="disposing">true if managed resources should be disposed; otherwise, false.</param>
PROTECTED METHOD Dispose( disposing AS LOGIC ) AS VOID
      IF disposing && components != NULL
         components:Dispose()
      ENDIF
      SUPER:Dispose( disposing )
      RETURN

/// <summary>
/// Required method for Designer support - do not modify
/// the contents of this method with the code editor.
/// </summary>
PRIVATE METHOD InitializeComponent() AS VOID STRICT
    SELF:ButtonCancel := DevExpress.XtraEditors.SimpleButton{}
    SELF:ButtonOK := DevExpress.XtraEditors.SimpleButton{}
    SELF:DateTo := DevExpress.XtraEditors.DateEdit{}
    SELF:DateFrom := DevExpress.XtraEditors.DateEdit{}
    SELF:label2 := System.Windows.Forms.Label{}
    SELF:label1 := System.Windows.Forms.Label{}
    SELF:ItemsListView := System.Windows.Forms.ListView{}
    SELF:Item := System.Windows.Forms.ColumnHeader{}
    SELF:UID := System.Windows.Forms.ColumnHeader{}
    SELF:checkBoxAll := System.Windows.Forms.CheckBox{}
    ((System.ComponentModel.ISupportInitialize)(SELF:DateTo:Properties:CalendarTimeProperties)):BeginInit()
    ((System.ComponentModel.ISupportInitialize)(SELF:DateTo:Properties)):BeginInit()
    ((System.ComponentModel.ISupportInitialize)(SELF:DateFrom:Properties:CalendarTimeProperties)):BeginInit()
    ((System.ComponentModel.ISupportInitialize)(SELF:DateFrom:Properties)):BeginInit()
    SELF:SuspendLayout()
    // 
    // ButtonCancel
    // 
    SELF:ButtonCancel:Anchor := ((System.Windows.Forms.AnchorStyles)(((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Left)  ;
                | System.Windows.Forms.AnchorStyles.Right)))
    SELF:ButtonCancel:DialogResult := System.Windows.Forms.DialogResult.Cancel
    SELF:ButtonCancel:Location := System.Drawing.Point{483, 646}
    SELF:ButtonCancel:Name := "ButtonCancel"
    SELF:ButtonCancel:Size := System.Drawing.Size{60, 23}
    SELF:ButtonCancel:TabIndex := 29
    SELF:ButtonCancel:Text := "Cancel"
    // 
    // ButtonOK
    // 
    SELF:ButtonOK:Anchor := ((System.Windows.Forms.AnchorStyles)((System.Windows.Forms.AnchorStyles.Bottom | System.Windows.Forms.AnchorStyles.Left)))
    SELF:ButtonOK:Location := System.Drawing.Point{371, 646}
    SELF:ButtonOK:Name := "ButtonOK"
    SELF:ButtonOK:Size := System.Drawing.Size{60, 23}
    SELF:ButtonOK:TabIndex := 28
    SELF:ButtonOK:Text := "OK"
    SELF:ButtonOK:Click += System.EventHandler{ SELF, @ButtonOK_Click() }
    // 
    // DateTo
    // 
    SELF:DateTo:EditValue := NULL
    SELF:DateTo:Location := System.Drawing.Point{69, 35}
    SELF:DateTo:Name := "DateTo"
    SELF:DateTo:Properties:AllowNullInput := DevExpress.Utils.DefaultBoolean.False
    SELF:DateTo:Properties:Buttons:AddRange(<DevExpress.XtraEditors.Controls.EditorButton>{ DevExpress.XtraEditors.Controls.EditorButton{DevExpress.XtraEditors.Controls.ButtonPredefines.Combo} })
    SELF:DateTo:Properties:CalendarTimeProperties:Buttons:AddRange(<DevExpress.XtraEditors.Controls.EditorButton>{ DevExpress.XtraEditors.Controls.EditorButton{} })
    SELF:DateTo:Properties:DisplayFormat:FormatString := "dd/MM/yy  HH:mm:ss"
    SELF:DateTo:Properties:DisplayFormat:FormatType := DevExpress.Utils.FormatType.@@DateTime
    SELF:DateTo:Properties:EditFormat:FormatString := "dd/MM/yy  HH:mm:ss"
    SELF:DateTo:Properties:EditFormat:FormatType := DevExpress.Utils.FormatType.@@DateTime
    SELF:DateTo:Properties:Mask:EditMask := "dd/MM/yy  HH:mm:ss"
    SELF:DateTo:Properties:Mask:MaskType := DevExpress.XtraEditors.Mask.MaskType.DateTimeAdvancingCaret
    SELF:DateTo:Properties:ShowWeekNumbers := TRUE
    SELF:DateTo:Size := System.Drawing.Size{115, 20}
    SELF:DateTo:TabIndex := 27
    // 
    // DateFrom
    // 
    SELF:DateFrom:EditValue := NULL
    SELF:DateFrom:Location := System.Drawing.Point{69, 10}
    SELF:DateFrom:Name := "DateFrom"
    SELF:DateFrom:Properties:AllowNullInput := DevExpress.Utils.DefaultBoolean.False
    SELF:DateFrom:Properties:Buttons:AddRange(<DevExpress.XtraEditors.Controls.EditorButton>{ DevExpress.XtraEditors.Controls.EditorButton{DevExpress.XtraEditors.Controls.ButtonPredefines.Combo} })
    SELF:DateFrom:Properties:CalendarTimeProperties:Buttons:AddRange(<DevExpress.XtraEditors.Controls.EditorButton>{ DevExpress.XtraEditors.Controls.EditorButton{} })
    SELF:DateFrom:Properties:DisplayFormat:FormatString := "dd/MM/yy  HH:mm:ss"
    SELF:DateFrom:Properties:DisplayFormat:FormatType := DevExpress.Utils.FormatType.@@DateTime
    SELF:DateFrom:Properties:EditFormat:FormatString := "dd/MM/yy  HH:mm:ss"
    SELF:DateFrom:Properties:EditFormat:FormatType := DevExpress.Utils.FormatType.@@DateTime
    SELF:DateFrom:Properties:Mask:EditMask := "dd/MM/yy  HH:mm:ss"
    SELF:DateFrom:Properties:Mask:MaskType := DevExpress.XtraEditors.Mask.MaskType.DateTimeAdvancingCaret
    SELF:DateFrom:Properties:ShowWeekNumbers := TRUE
    SELF:DateFrom:Size := System.Drawing.Size{115, 20}
    SELF:DateFrom:TabIndex := 26
    // 
    // label2
    // 
    SELF:label2:AutoSize := TRUE
    SELF:label2:Location := System.Drawing.Point{9, 38}
    SELF:label2:Name := "label2"
    SELF:label2:Size := System.Drawing.Size{62, 13}
    SELF:label2:TabIndex := 25
    SELF:label2:Text := "Up to date:"
    // 
    // label1
    // 
    SELF:label1:AutoSize := TRUE
    SELF:label1:Location := System.Drawing.Point{9, 13}
    SELF:label1:Name := "label1"
    SELF:label1:Size := System.Drawing.Size{60, 13}
    SELF:label1:TabIndex := 24
    SELF:label1:Text := "From date:"
    // 
    // ItemsListView
    // 
    SELF:ItemsListView:Anchor := ((System.Windows.Forms.AnchorStyles)((((System.Windows.Forms.AnchorStyles.Top | System.Windows.Forms.AnchorStyles.Bottom)  ;
                | System.Windows.Forms.AnchorStyles.Left)  ;
                | System.Windows.Forms.AnchorStyles.Right)))
    SELF:ItemsListView:CheckBoxes := TRUE
    SELF:ItemsListView:Columns:AddRange(<System.Windows.Forms.ColumnHeader>{ SELF:Item, SELF:UID })
    SELF:ItemsListView:FullRowSelect := TRUE
    SELF:ItemsListView:GridLines := TRUE
    SELF:ItemsListView:Location := System.Drawing.Point{12, 96}
    SELF:ItemsListView:Name := "ItemsListView"
    SELF:ItemsListView:Size := System.Drawing.Size{907, 524}
    SELF:ItemsListView:TabIndex := 30
    SELF:ItemsListView:UseCompatibleStateImageBehavior := FALSE
    SELF:ItemsListView:View := System.Windows.Forms.View.Details
    SELF:ItemsListView:ItemChecked += System.Windows.Forms.ItemCheckedEventHandler{ SELF, @ItemsListView_ItemChecked() }
    // 
    // Item
    // 
    SELF:Item:Tag := "1"
    SELF:Item:Text := "Item Name"
    SELF:Item:Width := 903
    // 
    // UID
    // 
    SELF:UID:Tag := "2"
    SELF:UID:Width := 0
    // 
    // checkBoxAll
    // 
    SELF:checkBoxAll:AutoSize := TRUE
    SELF:checkBoxAll:Location := System.Drawing.Point{12, 73}
    SELF:checkBoxAll:Name := "checkBoxAll"
    SELF:checkBoxAll:Size := System.Drawing.Size{108, 17}
    SELF:checkBoxAll:TabIndex := 31
    SELF:checkBoxAll:Text := "Check/Uncked All"
    SELF:checkBoxAll:UseVisualStyleBackColor := TRUE
    SELF:checkBoxAll:CheckedChanged += System.EventHandler{ SELF, @checkBoxAll_CheckedChanged() }
    // 
    // SelectDatesAdvancedForm
    // 
    SELF:AcceptButton := SELF:ButtonOK
    SELF:AutoScaleDimensions := System.Drawing.SizeF{6, 13}
    SELF:AutoScaleMode := System.Windows.Forms.AutoScaleMode.Font
    SELF:CancelButton := SELF:ButtonCancel
    SELF:ClientSize := System.Drawing.Size{931, 681}
    SELF:Controls:Add(SELF:checkBoxAll)
    SELF:Controls:Add(SELF:ItemsListView)
    SELF:Controls:Add(SELF:ButtonCancel)
    SELF:Controls:Add(SELF:ButtonOK)
    SELF:Controls:Add(SELF:DateTo)
    SELF:Controls:Add(SELF:DateFrom)
    SELF:Controls:Add(SELF:label2)
    SELF:Controls:Add(SELF:label1)
    SELF:MaximizeBox := FALSE
    SELF:MinimizeBox := FALSE
    SELF:Name := "SelectDatesAdvancedForm"
    SELF:ShowIcon := FALSE
    SELF:StartPosition := System.Windows.Forms.FormStartPosition.CenterScreen
    SELF:Text := "Select items and period"
    SELF:Load += System.EventHandler{ SELF, @SelectDatesAdvancedForm_Load() }
    ((System.ComponentModel.ISupportInitialize)(SELF:DateTo:Properties:CalendarTimeProperties)):EndInit()
    ((System.ComponentModel.ISupportInitialize)(SELF:DateTo:Properties)):EndInit()
    ((System.ComponentModel.ISupportInitialize)(SELF:DateFrom:Properties:CalendarTimeProperties)):EndInit()
    ((System.ComponentModel.ISupportInitialize)(SELF:DateFrom:Properties)):EndInit()
    SELF:ResumeLayout(FALSE)
    SELF:PerformLayout()

PRIVATE METHOD ButtonOK_Click( sender AS System.Object, e AS System.EventArgs ) AS System.Void
        IF SELF:DateFrom:DateTime > SELF:DateTo:DateTime
            wb("Invalid dates")
            SELF:DateTo:Focus()
            RETURN
        ENDIF
        IF lSelectionChanged
            LOCAL cNewSqlUids := "(" AS STRING
            FOREACH oListVI AS ListViewItem IN SELF:ItemsListView:Items
                IF oListVI:Checked
                    IF cNewSqlUids == "(" // einai to prwto mhn valeis ,
                        cNewSqlUids += oListVI:SubItems[1]:Text
                    ELSE
                        cNewSqlUids += ","+oListVI:SubItems[1]:Text
                    ENDIF
                ENDIF
            NEXT
            cNewSqlUids += ")"
            cSqlUids := cNewSqlUids
            LOCAL cTempString := cTempDocDir+"/ExcelReports/"+SELF:cVesselUID+"/"+SELF:cReportUid+".txt" AS STRING
            IF !Directory.Exists(cTempDocDir+"/ExcelReports/"+SELF:cVesselUID)
                Directory.CreateDirectory(cTempDocDir+"/ExcelReports/"+SELF:cVesselUID)
            ENDIF
            LOCAL oWritter := StreamWriter{cTempString,FALSE} AS StreamWriter
            oWritter:Write(cNewSqlUids)
            oWritter:Dispose()
        ENDIF
        
        SELF:DialogResult := System.Windows.Forms.DialogResult.OK
        RETURN

PRIVATE METHOD SelectDatesAdvancedForm_Load( sender AS System.Object, e AS System.EventArgs ) AS System.Void
            LOCAL oListViewItem AS ListViewItem
            LOCAL cTempUids := "" AS STRING
            
            TRY 
                LOCAL cTempString := cTempDocDir+"/ExcelReports/"+SELF:cVesselUID+"/"+SELF:cReportUid+".txt" AS STRING
                IF System.IO.File.Exists(cTempString)
                    LOCAL oReader := StreamReader{cTempString} AS StreamReader
                    SELF:cSqlUids := oReader:ReadToEnd():Trim()
                    oReader:Close()
                ENDIF
            CATCH
                SELF:cSqlUids := ""
            END    
            IF SELF:cSqlUids != ""
                cTempUids := SELF:cSqlUids
                cTempUids := cTempUids:Replace("(",",")
                cTempUids := cTempUids:Replace(")",",")            
            ENDIF
            //IF SELF:oItemsTable:Rows:Count() >0
            lLoading := TRUE
            SELF:ItemsListView:Items:Clear()
            FOREACH iRow AS DataRow IN SELF:oItemsTable:Rows
                    oListViewItem := ListViewItem{iRow["ItemName"]:ToString()}
                    oListViewItem:SubItems:Add(iRow["ITEM_UID"]:ToString())
                    IF cTempUids:Contains(","+iRow["ITEM_UID"]:ToString()+",") || cSqlUids == ""
                        oListViewItem:Checked := TRUE
                    ENDIF
                    SELF:ItemsListView:Items:Add(oListViewItem)
            NEXT
            lLoading := FALSE
            //ENDIF
            
            
        RETURN

PRIVATE METHOD ItemsListView_ItemChecked( sender AS System.Object, e AS System.Windows.Forms.ItemCheckedEventArgs ) AS System.Void
            IF !lLoading
                lSelectionChanged := TRUE
            ENDIF
        RETURN

PRIVATE METHOD checkBoxAll_CheckedChanged(sender AS OBJECT, e AS System.EventArgs) AS VOID

		LOCAL lChecked := SELF:checkBoxAll:Checked AS LOGIC
			FOREACH item AS ListViewItem IN SELF:ItemsListView:Items
				item:Checked := lChecked
			NEXT
	RETURN

END CLASS
