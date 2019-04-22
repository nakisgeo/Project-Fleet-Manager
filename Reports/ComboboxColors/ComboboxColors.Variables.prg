// ComboboxColors.prg
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
#Using DevExpress.XtraEditors.Controls 
#using DevExpress.XtraPrinting
#Using DevExpress.XtraPrintingLinks

partial CLASS ComboboxColors INHERIT System.Windows.Forms.Form

	PRIVATE oDTReports as DataTable
	PRIVATE oEditColumn AS GridColumn
	PRIVATE oEditRow AS DataRowView
	PRIVATE cItemTypeValue as STRING
	PRIVATE oChangedReportColor AS Color
	PRIVATE lPendingDuplicate AS LOGIC
	PRIVATE cUIDtoDuplicate AS STRING
	PRIVATE oMatchIds as DataTable 

END CLASS
