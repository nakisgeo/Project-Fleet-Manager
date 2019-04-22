// HaversineFormula.prg

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


FUNCTION GPSCoordinate_To_DegreesMinutesSeconds(cCoor AS STRING) AS STRING
	IF Empty(cCoor)
		RETURN ""
	ENDIF								

	LOCAL cRet := "" AS STRING

	cCoor := cCoor:Replace(oMainForm:groupSeparator, oMainForm:decimalSeparator):Trim()

	LOCAL nGPSCoor := Convert.ToDouble(cCoor) AS Double
	//wb(cCoor, nGPSCoor)

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
	//wb(Degrees, "Degrees")
	LOCAL mm := (dd - (Double)Degrees) * 100 AS Double
// 9.2084 - 9 = 0.2084
	LOCAL nMin := (INT)mm AS INT
// 0.2084 * 60 = 12.504
	LOCAL nSec := Math.Round((mm - nMin) * 60, 2) AS Double
	//wb(nMin, "nMin")
	//wb(nSec, "nSec")

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
	//wb(cRet, "cRet")
RETURN cRet


// 12 17 00