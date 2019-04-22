// AddColumnForm_Methods.prg
#Using System.IO
#Using System.Data
#Using System.Data.Common
#Using System.Windows.Forms
#Using System.Drawing
#Using System.Collections
#Using DevExpress.XtraGrid.Views.Grid
#Using DevExpress.XtraGrid.Columns
#Using DevExpress.Utils
#Using DevExpress.XtraEditors.Repository
#using DevExpress.XtraPrinting
#Using DevExpress.XtraPrintingLinks


PARTIAL CLASS AddColumnForm INHERIT DevExpress.XtraEditors.XtraForm

	Public oMyItemsForm AS ItemsForm


	METHOD AddColumn() AS VOID
	
		LOCAL cName,cPrcnt,cType,cMandatory,cShowOnMap,cIsDueDate,cShowOffice,cComboItems,cMinValue,cMaxValue,cHasLabels AS STRING
		
		cName := SELF:tbName:Text
		IF String.IsNullOrEmpty(cName)
			MessageBox.Show("You have to specify a Name.")
			RETURN
		ENDIF
		
		cPrcnt := SELF:tbPrcnt:Text
		IF String.IsNullOrEmpty(cPrcnt)
			MessageBox.Show("You have to specify a Percentage.")
			RETURN
		ENDIF
		
		
		IF SELF:cmbType:SelectedItem == NULL
			MessageBox.Show("You have to specify a Type.")
			RETURN
		ENDIF
		cType := SELF:cmbType:SelectedItem:ToString()
		IF String.IsNullOrEmpty(cType)
			MessageBox.Show("You have to specify a Type.")
			RETURN
		ENDIF
		
		//MessageBox.Show(cType)
		cMandatory := SELF:chbMandatory:Checked:ToString()
		IF cMandatory:Equals("True")
			cMandatory := "1"
		ELSE
			cMandatory := "0"
		ENDIF
		cShowOnMap := SELF:chbShowOnMap:Checked:ToString()
		IF cShowOnMap:Equals("True")
			cShowOnMap := "1"
		ELSE
			cShowOnMap := "0"
		ENDIF
		cIsDueDate := SELF:chbIsDueDate:Checked:ToString()
		IF cIsDueDate:Equals("True")
			cIsDueDate := "1"
		ELSE
			cIsDueDate := "0"
		ENDIF
		cShowOffice := SELF:chbShowOnlyOffice:Checked:ToString()
		IF cShowOffice:Equals("True")
			cShowOffice := "1"
		ELSE
			cShowOffice := "0"
		ENDIF
		//MessageBox.Show(cMandatory)
		cComboItems := SELF:tbComboitems:Text
		cMinValue := SELF:tbMinValue:Text
		cMaxValue := SELF:tbMaxValue:Text
	
		cHasLabels := SELF:chbTableHasLabels:Checked:ToString()
		IF cHasLabels:Equals("True")
			cHasLabels := "1"
		ELSE
			cHasLabels := "0"
		ENDIF
		
	
		oMyItemsForm:AddColumn(cName,cPrcnt,cType,cMandatory,cShowOnMap,cIsDueDate,cShowOffice,cComboItems,cMinValue,cMaxValue,cHasLabels)
		oMyItemsForm:Items_Refresh()
		SELF:Close()
	RETURN


END CLASS