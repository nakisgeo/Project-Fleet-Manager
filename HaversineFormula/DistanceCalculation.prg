// DistanceCalculation.prg
#Using System.Data
#Using System.Data.Common
#Using System.Windows.Forms
#Using System.Drawing
#USING Microsoft.Maps.MapControl.WPF

PARTIAL CLASS MainForm INHERIT DevExpress.XtraEditors.XtraForm

// Attention: GPS Co-ordinates here !
METHOD CalcDist_GPS(latA AS Double, lonA AS Double, latB AS Double, lonB AS Double) AS Double
	// http://stackoverflow.com/questions/7062046/how-do-i-calculate-distance-between-gps-co-ordinates-on-a-processor-with-poor-fl

	latA := DecDegrees_To_GPSCoordinate(latA)
	lonA := DecDegrees_To_GPSCoordinate(lonA)

	latB := DecDegrees_To_GPSCoordinate(latB)
	lonB := DecDegrees_To_GPSCoordinate(lonB)

	LOCAL latD := Abs(latA - latB) * 111.3 AS Double
	LOCAL lonD := Abs(lonA - lonB) * 111.3 * cos(latA * Math.PI / 180) AS Double
	//LOCAL lonD := Abs(lonA - lonB) * 111.3 * cos(latA * 3.14159265 / 180) AS Double
RETURN sqrt(latD * latD + lonD * lonD) * 1000


// Attention: MAP Co-ordinates here !
METHOD CalcDist_MAP(oLoc1 AS Location, oLoc2 AS Location) AS Double
	LOCAL latA AS Double, lonA AS Double, latB AS Double, lonB AS Double

	latA := oLoc1:Latitude
	lonA := oLoc1:Longitude

	latB := oLoc2:Latitude
	lonB := oLoc2:Longitude

	// HaversineFormula:
	LOCAL dLat, dLong, nDistance AS Double
	LOCAL nA, nC  AS Double

	IF latA == 0 .or. latB == 0
		// No data
		RETURN 0
	ENDIF

	TRY
		latA:=latA * nDegreeToRadiansFactor
		lonA:=lonA * nDegreeToRadiansFactor
		latB:=latB * nDegreeToRadiansFactor
		lonB:=lonB * nDegreeToRadiansFactor

		//?lat = lat2 - lat1
		dLat := latB - latA
		//?long = long2 - long1
		dLong := lonB - lonA
		//a = sin²(?lat/2) + Cos(lat1).Cos(lat2).sin²(?long/2)
		nA:=(Sin(dLat/2))^2 + Math.Cos(latA) * Math.Cos(latB) * (Math.Sin(dLong/2))^2
		//c = 2.atan2(SQRT(a), SQRT(1-a))
		nC:= 2 * Math.Atan2(Math.Sqrt(nA), Math.Sqrt(1 - nA))
		//or, nC:= 2 * asin(Min(1, SQRT(nA)))

		//d = R.c
		// Be sure to multiply the number of RADIANS by R to get distance
		nDistance:=nEarthRadius * nC
	CATCH e AS Exception
		ErrorBox("Error calculating distance", "Distance calculation")
	END TRY
RETURN nDistance

/*	LOCAL latD := Abs(latA - latB) * 111.3 AS Double
	LOCAL lonD := Abs(lonA - lonB) * 111.3 * cos(latA * 3.14159265 / 180) AS Double
RETURN sqrt(latD * latD + lonD * lonD) * 1000*/

END CLASS
