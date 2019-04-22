// VoyagesForm.prg
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

PARTIAL CLASS VoyagesForm INHERIT System.Windows.Forms.Form



PRIVATE METHOD bbiMRVVoyageReportItemClick() AS System.Void

	
	LOCAL oMRVResultForm := MRVResultForm{} AS MRVResultForm
	//oMRVResultForm:oDTMyResults := oDTResults
	LOCAL cVesselUID := SELF:LookUpEditCompany_Voyages:EditValue:ToString() AS STRING
	LOCAL cVesselName := SELF:LookUpEditCompany_Voyages:Text:Trim() AS STRING
	oMRVResultForm:cMyVesselUID := cVesselUID
	oMRVResultForm:cMyVesselName := cVesselName
	oMRVResultForm:Show()

RETURN

END CLASS
