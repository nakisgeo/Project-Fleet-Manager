//GLOBAL PI := 3.14159265358979323846 AS USUAL     // Pi

//// TrigonometricalFunctions.prg
//FUNCTION acos(nX AS FLOAT) AS FLOAT STRICT

//// Berechnet einen Winkel (Arcus Cosinus) in Bogenma? zwischen -PI und PI,
//// dessen Cosinus gleich nX ist.
//// Eine weitere Moglichkeit: RETURN atan2(SQRT(1.0 - nX * nX),nX)

//// Arcus Cosinus berechnen.
//RETURN -ATan(nX / SQRT(-nX * nX + 1.0)) + (PI / 2.0)



//FUNCTION acosh(nX AS FLOAT) AS FLOAT STRICT

//// Berechnet den Arcus Cosinus Hyperbolicus von X Fur Werte X >= 1.0.

//// Arcus Cosinus Hyperbolicus berechnen.
//RETURN LOG(nX + SQRT(nX * nX - 1.0))



//FUNCTION acoth(nX AS FLOAT) AS FLOAT STRICT

//// Berechnet den Arcus Cotangens Hyperbolicus von X Fur Werte X >= 1.0 und X <= -1.0.

//// Arcus Cotangens Hyperbolicus berechnen.
//RETURN LOG((nX + 1.0) / (nX - 1.0)) / 2.0
//FUNCTION ArcSin( nValue ) AS FLOAT
//// ArcSin = asin
//LOCAL nReturn AS FLOAT

//IF IsNumeric( nValue )
//	nReturn := ATan( nValue / SQRT( ( ( -1 * nValue ) * nValue ) + 1 ) )
//ENDIF

//RETURN nReturn
//FUNCTION asin(nX AS FLOAT) AS FLOAT STRICT
//// ArcSin = asin

//// Berechnet einen Winkel (Arcus Sinus) in Bogenma? zwischen -PI und PI,
//// dessen Sinus gleich nX ist.
//// Eine weitere Moglichkeit: RETURN atan2(nX,SQRT(1.0 - nX * nX))

//// Arcus Sinus berechnen.
//RETURN ATan(nX / SQRT(-nX * nX + 1.0))



//FUNCTION asinh(nX AS FLOAT) AS FLOAT STRICT

//// Berechnet den Arcus Sinus Hyperbolicus von X Fur Werte X >= 1.0.

//// Arcus Sinus Hyperbolicus berechnen.
//RETURN LOG(nX + SQRT(nX * nX + 1.0))



//FUNCTION atan2(nY AS FLOAT, nX AS FLOAT) AS FLOAT STRICT

//// Berechnet den Arcus Tangens der Kreisbogenkoordinten nY und nX als Wert, der zwischen
//// -Phi und Phi liegen kann. Im Gegensatz zu der Funktion atan() wird kein "divide by zero"-
//// Fehler generiert und die Berechnung erfolgt uber alle vier Quadranten.

//// Variablen
//LOCAL nNegX,nNegY AS LOGIC
//LOCAL nErg AS FLOAT

//// Variablen vorbelegen.
//nNegX := FALSE
//nNEGY := FALSE

//// Vorzeichen kontrollieren.
//IF nX <= 0.0
//nNegX := TRUE
//nX := nX * -1
//IF nY <= 0.0
//nNegY := TRUE
//ENDIF
//ENDIF

//// Division durch Null abfangen.
//IF nX == 0.0
//IF nY == 0.0 .or. .not. nNegY
//RETURN PI / 2.0
//ELSEIF nNegY
//RETURN -PI / 2.0
//ENDIF
//ENDIF

//// Arcus Tangens berechnen.
//nErg := ATan(nY / nX)

//// Ergebnis anhand der Vorzeichen dem richtigen Quadranten zuordnen.
//IF nNegX
//IF nNegY
//nErg := -PI - nErg
//ELSE
//nErg := PI - nErg
//ENDIF
//ENDIF
//RETURN nErg



//FUNCTION atanh(nX AS FLOAT) AS FLOAT STRICT

//// Berechnet den Arcus Tangens Hyperbolicus von X im Bereich von -1.0 >= X <= 1.0.

//// Arcus Tangens Hyperbolicus berechnen.
//RETURN LOG((1.0 + nX) / (1.0 - nX)) / 2.0



//FUNCTION cosh(nX AS FLOAT) AS FLOAT STRICT

//// Berechnet den Cosinus Hyperbolicus von X.

//// Cosinus Hyperbolicus berechnen.
//RETURN (EXP(nX) + EXP(-nX)) / 2.0



//FUNCTION coth(nX AS FLOAT) AS FLOAT STRICT

//// Berechnet den Cotangens Hyperbolicus von X fur Werte X != 0.0.

//// Cotangens Hyperbolicus berechnen.
//RETURN EXP(-nX) / (EXP(nX) - EXP(-nX)) * 2.0 + 1.0



//FUNCTION sinh(nX AS FLOAT) AS FLOAT STRICT

//// Berechnet den Sinus Hyperbolicus von X.

//// Sinus Hyperbolicus berechnen.
//RETURN (EXP(nX) - EXP(-nX)) / 2.0



//FUNCTION tanh(nX AS FLOAT) AS FLOAT STRICT

//// Berechnet den Tangens Hyperbolicus von X fur Werte X != 0.0.

//// Tangens Hyperbolicus berechnen.
//RETURN -EXP(-nX) / (EXP(nX) + EXP(-nX)) * 2.0 + 1.0



//FUNCTION integ(nNum AS USUAL) AS USUAL STRICT

//// Ersetzt die fehlerhafte CAVO-Funktion integer(). Gibt den ganzzahligen
//// Anteil einer Zahl zuruck

//// Ganzzahligen Anteil berechnen.
//RETURN iif(nNum >= 0.0,Floor(nNum),Ceil(nNum))
