// Convertor:
// http://www.csgnetwork.com/gpscoordconv.html

// Calculate the distance between 2 geographical coordinations in nautical miles
FUNCTION HaversineFormula(cLat1 AS STRING, cLong1 AS STRING, cLat2 AS STRING, cLong2 AS STRING) AS Double
	IF cLat1 == cLat2 .and. cLong1 == cLong2
		RETURN 0
	ENDIF

	// To convert lon1,lat1 and lon2,lat2 from degrees, minutes, and seconds to radians, first convert them to decimal degrees.
	// To convert decimal degrees to radians, multiply the number of degrees by pi/180 = 0.017453293 radians/degree
	// The N, E are positive where the S, W are negative values
	LOCAL nLat1, nLong1, nLat2, nLong2, dLat, dLong, nDistance AS Double
	LOCAL nA, nC  AS Double
	// In nautical miles

	//HaversineFormula("3954.000", "02218.000", "4310.500", "01900.300")
	nLat1:=GPSCoordinate_To_DecDegrees(cLat1)
	nLong1:=GPSCoordinate_To_DecDegrees(cLong1)
	nLat2:=GPSCoordinate_To_DecDegrees(cLat2)
	nLong2:=GPSCoordinate_To_DecDegrees(cLong2)

	IF nLat1 == 0 .or. nLat2 == 0
		// No data
		RETURN 0
	ENDIF

	TRY
		nLat1:=nLat1 * nDegreeToRadiansFactor
		nLong1:=nLong1 * nDegreeToRadiansFactor
		nLat2:=nLat2 * nDegreeToRadiansFactor
		nLong2:=nLong2 * nDegreeToRadiansFactor
//LOCAL cStr AS STRING
//cStr += cLat1+CRLF+cLong1+CRLF+cLat2+CRLF+cLong2+CRLF+CRLF+nLat1:ToString()+CRLF+nLong1:ToString()+CRLF+nLat2:ToString()+CRLF+nLong2:ToString()+CRLF+CRLF
		// Haversine Formula:
		//  dlon = lon2 - lon1
		//  dlat = lat2 - lat1
		//  a = (Sin(dlat/2))^2 + Cos(lat1) * Cos(lat2) * (Sin(dlon/2))^2
		//  c = 2 * atan2( SQRT(a), SQRT(1-a) )
		//  d = R * c
		//R = earth’s radius (mean radius = 6,371km)

//double dlong = (long2 - long1) * _d2r;
//double dLat = (lat2 - lat1) * _d2r;
//double a = Math.Pow(Math.Sin(dLat / 2D), 2D) + Math.Cos(lat1 * _d2r) * Math.Cos(lat2 * _d2r) * Math.Pow(Math.Sin(dLong / 2D), 2D);
//double c = 2D * Math.Atan2(Math.Sqrt(a), Math.Sqrt(1D - a));
//double d = _eQuatorialEarthRadius * c;

		//?lat = lat2 - lat1
		dLat := nLat2 - nLat1
		//?long = long2 - long1
		dLong := nLong2 - nLong1
		//a = sin²(?lat/2) + Cos(lat1).Cos(lat2).sin²(?long/2)
		nA:=(Sin(dLat/2))^2 + Math.Cos(nLat1) * Math.Cos(nLat2) * (Math.Sin(dLong/2))^2
		//c = 2.atan2(SQRT(a), SQRT(1-a))
		nC:= 2 * Math.Atan2(Math.Sqrt(nA), Math.Sqrt(1 - nA))
		//or, nC:= 2 * asin(Min(1, SQRT(nA)))

		//d = R.c
		// Be sure to multiply the number of RADIANS by R to get distance
		nDistance:=nEarthRadius * nC
		//d1:=2 * ArcSin(Min(1, SQRT(a))) * nEarthRadius
		//wb(nDistance)
		//cStr += "dLat="+dLat:ToString()+CRLF+"dLong="+dLong:ToString()
		//memowrit(cTempDocDir+"\Hav"+Time24():Replace(":", "_")+".TXT", cStr)
		//wb(cStr)
	CATCH e AS Exception
		ErrorBox("Error calculating distance between: "+cLat1+", "+cLong1+CRLF+;
					"and: "+cLat2+", "+cLong2, "Distance calculation")
	END TRY
RETURN nDistance

         
FUNCTION GPSCoordinate_To_DecDegrees(cCoor AS STRING) AS Double
	IF Empty(cCoor)
		RETURN 0
	ENDIF

	LOCAL nGPSCoor := Convert.ToDouble(cCoor:Replace(oMainForm:groupSeparator, oMainForm:decimalSeparator):Trim()) AS Double
	LOCAL nDecDegrees AS Double

	//GPSCoordinate to Decimal Degrees:
	// dd = DegreesMinutes.m / 100
	// Degrees (INT)
	// Degrees + .m * 100 / 60

	// 5409.2084
	// dd = 54.092084
	// 54
	// 54 + 0.092084 * 100 / 60 = 0,1534733333333333

	LOCAL dd := nGPSCoor / 100 AS Double
	LOCAL Degrees := (INT)dd AS INT
	LOCAL mm := dd - Degrees AS Double
	nDecDegrees := (Double)Degrees + (mm * 100 / 60)
RETURN nDecDegrees


FUNCTION DecDegrees_To_GPSCoordinate(nDecCoor AS Double) AS Double
	LOCAL nGPSCoor AS Double

	// 11.1892 -> 1111.351999999999975
	// nDegrees = 11
	// nM = 0.1892 * 60 = 11.352
	// nD = 11 * 100 + 11.352 -> 1111.352

	//Degrees Minutes.m to Decimal Degrees:
	//.d = M.m / 60
	// Decimal Degrees = Degrees + .d

	LOCAL nDegrees := (INT)(nDecCoor) AS INT
	LOCAL nM := nDecCoor - nDegrees AS Double
	LOCAL nD := nM * 60 AS Double	
	nGPSCoor := (Double)nDegrees * 100 + nD
RETURN nGPSCoor


FUNCTION DecDegrees_To_DegreesMinutesSeconds(cCoor AS STRING) AS STRING
	IF Empty(cCoor)
		RETURN ""
	ENDIF								

	LOCAL cRet := "" AS STRING

	cCoor := cCoor:Replace(oMainForm:groupSeparator, oMainForm:decimalSeparator):Trim()

	LOCAL nDecCoor := Convert.ToDouble(cCoor:Replace(oMainForm:groupSeparator, oMainForm:decimalSeparator):Trim()) AS Double
	LOCAL nGPSCoor := DecDegrees_To_GPSCoordinate(nDecCoor) AS Double

	cRet := GPSCoordinate_To_DegreesMinutesSeconds(nGPSCoor:ToString())
RETURN cRet


FUNCTION GPSCoordinate_To_DegreesMinutesSeconds(cCoor AS STRING) AS STRING
	IF Empty(cCoor)
		RETURN ""
	ENDIF								

	LOCAL cRet := "" AS STRING

	cCoor := cCoor:Replace(oMainForm:groupSeparator, oMainForm:decimalSeparator):Trim()

	LOCAL nGPSCoor := Convert.ToDouble(cCoor) AS Double

// 5409.2084
// 54.092084

// 6955.5508
// 6955,5508
// dd:=69,555508
// Degrees:=69
// mm:=69,555508 - 69 * 100 = 55,5508
// nMin:=55
// nSec:=(55,5508 - 55) * 60 = 33,048
// 69 
	LOCAL dd := nGPSCoor / 100 AS Double
// 54
	LOCAL Degrees := (INT)dd AS INT
// 54.092084 - 54 = 0.092084
// 0.092084 * 100 = 9.2084
	LOCAL mm := (dd - (Double)Degrees) * 100 AS Double
// 9.2084 - 9 = 0.2084
	LOCAL nMin := (INT)mm AS INT
// 0.2084 * 60 = 12.504
	LOCAL nSec := Math.Round((mm - nMin) * 60, 2) AS Double

	IF nSec >= 60
		nMin++
		nSec -= 60
	ENDIF
	IF nMin >= 60
		Degrees++
		nMin -=60
	ENDIF

	cRet := Degrees:ToString() + "° " + nMin:ToString() + "' " + nSec:ToString() + "''"
	cRet := cRet:Replace(",", ".")
RETURN cRet
//	LOCAL nPos AS DWORD
//	LOCAL cRet := "" AS STRING

//	IF Empty(cCoor)
//		RETURN ""
//	ENDIF

//	cCoor := cCoor:Replace(oMainForm:groupSeparator, oMainForm:decimalSeparator):Trim()

//	// 15 59 14.80
//	//Degrees: 15
//	//Minutes: 59
//	//Seconds: 0.2467 * 60 -> 14.80	-> Round(0): 15
//	TRY
//		// Sec
//		LOCAL nSec AS Double
//		nPos:=At(".", cCoor)
//		IF nPos > 0
//			nSec := Val("0."+SubStr(cCoor, nPos + 1))
//			nSec := Math.Round(nSec * 60, 2)
//			cCoor:=Left(cCoor, nPos - 1)
//		ELSE
//			nSec:=0
//		ENDIF

//		// Min
//		cRet := Right(cCoor, 2)
//		//nMin:=Val(Right(cCoor, 2))
//		cCoor := Left(cCoor, SLen(cCoor) - 2)

//		cRet := cCoor + " " + cRet + " " + nSec:ToString("N2"):Replace(oMainForm:groupSeparator, ""):Replace(oMainForm:decimalSeparator, ".")
//		IF cRet:EndsWith("00")
//			// Remove ',00'
//			cRet := cRet:Substring(0, cRet:Length - 3)
//		ENDIF
//	CATCH e AS Exception
//		ErrorBox(e:Message, "GPSCoordinate_To_DegreesMinutesSeconds")
//	END TRY
//RETURN cRet


//FUNCTION GPSCoordinate_To_DecDegrees(cCoor AS STRING) AS Double
//	LOCAL nPos AS DWORD
//	LOCAL nDecDegrees, nMin, nSec AS Double
//	LOCAL cDecDegrees AS STRING

//	IF Empty(cCoor)
//		RETURN 0
//	ENDIF

//	cCoor:=AllTrim(cCoor)
//	//LOCAL cCoorKeep := cCoor AS STRING

////cCoor:="1559.2467"
//	// 1559.2467 -> 15.987445
//	// DecDegrees: 15
//	// DecMinutes: INT(59 * 100 / 60): 98 (Remaining: 0,33333333333)
//	// DegSeconds: INT(0.2467 * 100 / 60) + 0,33333333333	-> Round(4): 0,7445

////cCoor:="5410.9185"
//	// 5410.9185 -> 54.181975
//	// DecDegrees: 54
//	// DecMinutes: INT(10 * 100 / 60): 16 (Remaining: 0,66666666666667)
//	// DegSeconds: INT(0.9185 * 100 / 60) + 0,66666666666667	-> Round(4): 2,1975

//	TRY
//		// Sec
//		// The GPS entry is using '.' as Decimal value here
//		nPos:=At(".", cCoor)
//		IF nPos > 0
//			nSec:=Val("0."+SubStr(cCoor, nPos + 1))
//			cCoor:=Left(cCoor, nPos - 1)
//		ELSE
//			nSec:=0
//		ENDIF

//		// Min
//		nMin:=Val(Right(cCoor, 2))
//		cCoor:=Left(cCoor, SLen(cCoor) - 2)

//		// Degrees
//		LOCAL nDecMin := nMin * 100 / 60 AS Double
//		LOCAL nRemSec := nDecMin - (INT)nDecMin AS Double
//		LOCAL nDecSec := nRemSec + (nSec * 100 / 60) AS Double

//		LOCAL cDegSeconds := nDecSec:ToString() AS STRING
//		// The ToString("N4") entry is using ',' (oMainForm:decimalSeparator) as Decimal value here
//		LOCAL cDS1 := "0", cDecSec AS STRING
//		LOCAL nPosSep := cDegSeconds:IndexOf(oMainForm:decimalSeparator) AS INT
//		IF nPosSep <> -1
//			cDS1 := cDegSeconds:Substring(0, nPosSep)
//			cDecSec := cDegSeconds:Substring(nPosSep + 1)	// Remove '0,'
//		ELSE
//			cDecSec := cDegSeconds
//		ENDIF
//		//wb("cDS1="+cDS1+CRLF+"cDegSeconds="+cDegSeconds)
//		//wb("cDecSec="+cDecSec+CRLF+"(INT)nDecMin + Convert.ToInt32(cDS1)="+((INT)nDecMin + Convert.ToInt32(cDS1)):ToSTring())
//		cDecDegrees := cCoor + oMainForm:decimalSeparator + StrZero((INT)nDecMin + Convert.ToInt32(cDS1), 2) + cDecSec
//		//wb("cDecDegrees="+cDecDegrees)
//		//nDecDegrees := Convert.ToDouble(cCoor) + ((INT)nDecMin) + nDecSec
//		nDecDegrees := Math.Round(Convert.ToDouble(cDecDegrees), 4)
//		//wb("nDecDegrees="+nDecDegrees:ToString())
//	CATCH e AS Exception
//		ErrorBox(e:Message, cCoor)	//Keep)
//	END TRY
//RETURN nDecDegrees
