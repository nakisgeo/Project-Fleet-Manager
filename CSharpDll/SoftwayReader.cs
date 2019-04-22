using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace CSharpDll
{
    public class SoftwayReader
    {
        public string cGetMyElement(object[,] oMyArray, int iX, int iY)
        {
            string cToReturn = "";
            try {
                object oMyElement = oMyArray[iX, iY];
                cToReturn = oMyElement.ToString().Trim();
            }
            catch(Exception exc)
            {
                cToReturn = exc.Message;
            }
            return cToReturn;

        }

    }
}
