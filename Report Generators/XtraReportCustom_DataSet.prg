// XtraReportCustom_DataSet.prg
#Using System
#Using System.Data
#Using System.Data.Common

// Remove the next line for EXE dustribution:
//#Define Designer

PUBLIC CLASS XtraReportCustom_DataSet INHERIT DataSet
	PRIVATE oConn AS System.Data.SqlClient.SqlConnection
	PRIVATE oDA AS System.Data.SqlClient.SqlDataAdapter

CONSTRUCTOR()
	SUPER()

	#IFNDEF Designer
		// Customer's site code
		LOCAL oDT AS DataTable

		oDT := DataTable{"FMReportPresentation"}
		oDT:Columns:Add("FORMULA_UID", System.Type.GetType("System.Int32"))
		SELF:Tables:Add(oDT)
		/*// Create Primary Key
		LOCAL oColPK1:=DataColumn[]{1} AS DataColumn[]
		oColPK1[1] := SELF:Tables["TrialC"]:Columns["VOUCHER_UID"]
		SELF:Tables["TrialC"]:PrimaryKey := oColPK1*/
	#ELSE
		// Called from XtraReport Designer
		TRY
			// This code will succed only for VS Designer - it will faill on Customer's site because of the oConn:ConnectionString
			SELF:oConn := System.Data.SqlClient.SqlConnection{}

			oConn:ConnectionString := "server=george-laptop;database=softway;Integrated Security=SSPI"
			//oConn:ConnectionString := "server=kiriakos-Laptop;database=starbulk;Integrated Security=SSPI"

			oConn:Open()

			SELF:oDA := System.Data.SqlClient.SqlDataAdapter{}
			LOCAL cStatement AS STRING

			cStatement:="SELECT FMReportFormulas.*, FMReportPresentation.Amount, FMReportPresentation.TextField,"+;
						" FMReportItems.Unit AS ItemUnit, FMCustomItems.Unit AS CustomItemUnit"+;
						" FROM FMReportPresentation"+;
						" INNER JOIN FMReportFormulas ON FMReportFormulas.FORMULA_UID=FMReportPresentation.FORMULA_UID"+;
						" LEFT OUTER JOIN FMReportItems ON FMReportItems.ItemNo=FMReportFormulas.ID"+;
						" LEFT OUTER JOIN FMCustomItems ON FMCustomItems.ID=FMReportFormulas.ID"+;
						" AND HideLine=0"+;
						" ORDER BY LineNum"
						//" WHERE REPORT_UID=2"+;
			LOCAL oDBCommandPMTrans := System.Data.SqlClient.SqlCommand{} AS System.Data.SqlClient.SqlCommand
			oDBCommandPMTrans:CommandType:=CommandType.Text
			oDBCommandPMTrans:Connection := SELF:oConn
			oDBCommandPMTrans:CommandText:=cStatement
			SELF:oDA:SelectCommand := oDBCommandPMTrans
			SELF:oDA:Fill(SELF, "FMReportPresentation")


		CATCH oe AS Exception
			ErrorBox("The code contains: #Define Designer"+CRLF+CRLF+;
						oe:Message, "DataSet error")
		END TRY
	#ENDIF
RETURN


CONSTRUCTOR(_oDT AS DataTable)
	// Called from source code: MainForm:ButtonDataReport_Click()
	SUPER()
	//LOCAL oDT := _oDT:Copy() AS DataTable
	//oDT:TableName := "FMReportPresentation"
	SELF:Tables:Add(_oDT)
RETURN

END CLASS
