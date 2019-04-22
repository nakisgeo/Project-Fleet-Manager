// ReportTabForm.prg
#Using System.IO
#Using System.Data
#Using System.Windows.Forms
#Using System.Drawing
#Using System.Collections


PARTIAL CLASS ReportTabForm INHERIT System.Windows.Forms.Form

/*PUBLIC METHOD checkForList(cToTest AS STRING) AS STRING

	LOCAL cToReturn := "" AS STRING
	LOCAL cStatement:=" SELECT List_UID FROM DMFLists"+;
					  " WHERE  Description='"+oSoftway:ConvertWildcards(cToTest, FALSE)+"'" AS STRING
	LOCAL cDuplicate:=oSoftway:RecordExists(oMainForm:oGFH, oMainForm:oConn, cStatement, "List_UID") AS STRING
	IF cDuplicate <> "" .and. cDuplicate:Trim():Length>0
			cStatement :=   " SELECT DISTINCT Description as cData From DMFListItems Where FK_List_UID="+cDuplicate+;
							" Order By Description Asc"
			LOCAL oDTLocal := oSoftway:ResultTable(oMainForm:oGFH, oMainForm:oConn, cStatement) AS DataTable

			FOREACH oRow AS DataRow IN oDTLocal:Rows
				cToReturn += oRow["cData"]:ToString() +";"
			NEXT
			IF cToReturn:Length>0
				cToTest := cToReturn
			ENDIF
	ENDIF

RETURN cToTest*/

END CLASS