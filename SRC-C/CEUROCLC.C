/*@**20100811********************************************/
/*@** */
/*@** Licensed Materials - Property o */
/*@** ExlService Holdings, Inc. */
/*@** */
/*@** (C) 1983-2010 ExlService Holdings, Inc.  All Rights Reserved. */
/*@** */
/*@** Contains confidential and trade secret information. */
/*@** Copyright notice is precautionary only and does not */
/*@** imply publication. */
/*@**
/*@**20100811********************************************/

#include "lpcopyrt.h"

/*************************************************************************** 
*
*  MODULE    : ceuroclc
*
*  PURPOSE   : currency translation (originally for Euro/NLS mod)
*
*  AUTHOR    : Rich Ernst
*
*
*  SR#            INIT   DATE        DESCRIPTION
*  -----------------------------------------------------------------------
*  980302-002-01  RDE    02/23/1999  Initial Release
*
***************************************************************************/

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <ctype.h>

#define COBOL_PIC_LENGTH                19                      // PIC S9(13)V9(5) SIGN LEADING SEPARATE
#define COBOL_PIC_DECIMALS              5                       // the 9(5) part of s9(13)v9(5)
#define COBOL_DIGITS                    (COBOL_PIC_LENGTH - 1)  // subtract 1 for sign
#define COBOL_RATE_PIC_LENGTH           15                      // PIC 9(15)
#define COBOL_RATE_LENGTH               6                       // use only first x significant digits in rate
                                                                // if this needs to be greater than 8, the logic in
                                                                // charMultiply & charDivide will have to be revamped
                                                                // since they take a 'long' rate, and the max.
                                                                // # of digits that can be safely stored in a 'long' is 8
#define RESULT_LENGTH                   (COBOL_DIGITS + COBOL_RATE_PIC_LENGTH + 2)
#define MIN(a,b)                        ((a)<(b)?(a):(b))

void charRound(char *value, unsigned int position);
void charDivide(char *value, long divisor, int divisorDecimals);
void charMultiply(char *value, long factor, int factorDecimals);

/*************************************************************************** 
*  CEUROCLC()
*
*  This function performs currency conversions.  It makes some strict
*  assumptions about the input parameters, although none of the parameters
*  need be null-terminated (this function assumes the strings are coming
*  from COBOL, and processes the parameters appropriately)
*
*   1) value                    - must be a string in the format "-##################"
*                                 (i.e., COBOL PIC S9(13)V9(5))
*
*   2) conversionDirection      - must be either 'C' or 'E'
*                                 'C' - divide by rate   (member-currency to Euro)
*                                 'E' - multiply by rate (Euro to member-currency)
*
*   3) rate                     - must be in the format "###############" (i.e.,
*                                 COBOL PIC 9(15)). Note that only SIX significant
*                                 digits are utilised.  There is an
*                                 implied decimal point, determined by rateDecimals
*
*   4) rateDecimals             - must be a string between "00" and "15"
*                                 implied decimal point in rate lies immediately
*                                 prior to the digit indicated by rateDecimals 
*                                 (counting from the right)
*
*   5) roundingDecimals         - must be between '0' and '5'
*                                 final answer will be rounded to this number of decimal
*                                 places
*                           
*  The result of conversion is placed back into the value parameter, using the same
*  format (COBOL PIC S9(13)V9(5)).  Values too large to fit into this format are truncated
*  (the leftmost digit(s)).
*
***************************************************************************/
#if defined (WIN32)
void __declspec(dllexport) _cdecl
        CEUROCLC(char *value,
                 char *conversionDirection,
                 char *rate,
                 char *rateDecimals,
                 char *roundingDecimals)
#elif defined (UNIX)
void
        CEUROCLC(char *value,
                 char *conversionDirection,
                 char *rate,
                 char *rateDecimals,
                 char *roundingDecimals)
#else
void _loadds _export
        CEUROCLC(char *value,
                 char *conversionDirection,
                 char *rate,
                 char *rateDecimals,
                 char *roundingDecimals)
#endif
{
    unsigned int iRoundingDecimals, firstSignif;
    int iRateDecimals;
    long iRate;
    char szWork[40], szValue[RESULT_LENGTH + 1], szRateString[COBOL_RATE_LENGTH + 1];

/*
    if(getenv("EURODEBUG")!=NULL)
    {
        char msgbuf[1024];
        sprintf(msgbuf, "value=%.19s \ndirection=%.1s \nrate=%.15s \nrate Decimals=%.2s \nrounding Decimals=%.1s",
                        value, conversionDirection, rate, rateDecimals, roundingDecimals);
        MessageBox(NULL, msgbuf, "Input Values", MB_OK|MB_ICONINFORMATION);
    }
*/

// convert incoming strings into numeric values
// must assume that the strings will not be null-terminated,
// since they might be coming from COBOL

    // the translation amount
    memset(szValue, '0', sizeof(szValue));
    memcpy(szValue, value+1, COBOL_DIGITS);  // skip over the sign
    szValue[RESULT_LENGTH]='\0';


    for(firstSignif=0; firstSignif<(COBOL_RATE_PIC_LENGTH-COBOL_RATE_LENGTH) && *(rate+firstSignif)=='0'; firstSignif++);
    memcpy(szRateString, rate+firstSignif, COBOL_RATE_LENGTH);
    szRateString[COBOL_RATE_LENGTH]='\0';
    iRate=atol(szRateString);
    if(iRate==0 && conversionDirection[0]=='C')
    {
        strcpy(value, "*BAD RATE (=0)     ");
        return;
    }

    // the decimal position in the rate
    memcpy(szWork, rateDecimals, 2);
    szWork[2]='\0';
    iRateDecimals = atoi(szWork);
    if(iRateDecimals > COBOL_RATE_PIC_LENGTH || iRateDecimals < 0)
    {
        strcpy(value, "*BAD RATE DECIMALS ");
        return;
    }
    iRateDecimals -= (COBOL_RATE_PIC_LENGTH - (firstSignif + COBOL_RATE_LENGTH));
    if(iRateDecimals > COBOL_RATE_PIC_LENGTH)
    {
        strcpy(value, "*BAD RATE DECIMALS ");
        return;
    }

    // number of decimals to round the final answer to
    szWork[0]=roundingDecimals[0];
    szWork[1]='\0';
    iRoundingDecimals = atoi(szWork);
    if(iRoundingDecimals > COBOL_PIC_DECIMALS)
    {
        strcpy(value, "*BAD ROUND DECIMALS");
        return;
    }

// do the translation
    if(conversionDirection[0]=='C')
        charDivide(szValue, iRate, iRateDecimals);
    else
        charMultiply(szValue, iRate, iRateDecimals);

    charRound(szValue, COBOL_DIGITS - COBOL_PIC_DECIMALS + iRoundingDecimals);
    memset(value+1, '0', COBOL_DIGITS);
    memcpy(value+1, szValue, MIN(strlen(szValue), COBOL_DIGITS));
/*
    if(getenv("EURODEBUG")!=NULL)
    {
        char msgbuf[1024];
        sprintf(msgbuf, "\n\noutput value=%s", value);
        MessageBox(NULL, msgbuf, "Output Value", MB_OK|MB_ICONINFORMATION);
    }
*/
}

/**************************************************
 * charDivide():                                  *
 *                                                *
 * Purpose:                                       *
 *   handles divisions in which the operands, the *
 *   result, or the precision required, are       *
 *   greater than that allowed or provided by C   *
 *   floating point routines                      *
 *                                                *
 * How it works:                                  *
 *   Remember grade-school?  This routine does    *
 *   long division "by hand" in order to get the  *
 *   required precision, and to allow input and   *
 *   output values having more than 15 signifi-   *
 *   cant digits                                  *
 *                                                *
 * Parameters:                                    *
 *   char *value -  a string representation of    *
 *                  the number to be divided by   *
 *                  the "divisor";                *
 *                  The input value must be       *
 *                  padded with zeros on the left *
 *                  and right side as required to *
 *                  ensure the value contains     *
 *                  exactly the number of digits  *
 *                  specified by COBOL_DIGITS,    *
 *                  with implied decimal point as *
 *                  specified by COBOL_DIGITS less*
 *                  COBOL_PIC_DECIMALS (counting  *
 *                  from the LEFT.) This value    *
 *                  will be replaced with the     *
 *                  result, which will contain    *
 *                  an implied decimal point in   *
 *                  the same position, although   *
 *                  it may have additional digits *
 *                  trailing (providing extra     *
 *                  precision necessary for accu- *
 *                  rounding in a subsequent step)*
 *                  Note: if a math operation     *
 *                  produces an answer too large, *
 *                  the most significant digits   *
 *                  are truncated (i.e., the      *
 *                  overflow is discarded)        *
 *                                                *
 *   long divisor - the divisor; this includes an *
 *                  implied decimal, in the       *
 *                  position indicated by         *
 *                  divisorDecimals               *
 *                                                *
 *   int divisorDecimals -                        *
 *                  number of digits after the    *
 *                  implied decimal point in the  *
 *                  divisor paramter              *
 *                                                *
 **************************************************
 * EXAMPLE:                                       *
 *                                                *
 *   to divide 345678901234.6789 by 1234.56       *
 *   when COBOL_DIGITS=18 & COBOL_PIC_DECIMALS=5, *
 *   pass in value of "034567890123467890"        *
 *   a divisor of 123456, and a divisorDecimals   *
 *   of 2                                         *
 *   upon function return, value will be set to   *
 *   "000028000170201098" (280001702.01098)       *
 *                                                *
 **************************************************/
void charDivide(char *value, long divisor, int divisorDecimals)
{
    char answer[RESULT_LENGTH + 1];
    int currDigit;
    long remainder;
    short shift;

    remainder=0;
    for(currDigit=0; currDigit<RESULT_LENGTH; currDigit++)
    {
        remainder*=10;
        remainder+=value[currDigit]-'0';
        answer[currDigit]=(remainder/divisor)+'0';
        remainder%=divisor;
    }
    answer[sizeof(answer)-1]='\0';
    shift=-divisorDecimals;
    memset(value, '0', RESULT_LENGTH);
    if(shift > 0)
    {
        strncpy(value+shift, answer, RESULT_LENGTH-shift);
    }
    else
        strcpy(value, answer-shift);
}

/**************************************************
 * charMultiply():                                *
 *                                                *
 * Purpose:                                       *
 *   handles multiplication in which the operands,*
 *   the result, or the precision required, are   *
 *   greater than that allowed or provided by C   *
 *   floating point routines                      *
 *                                                *
 * How it works:                                  *
 *   Breaks the input value into small segments,  *
 *   each of which can be processed by the built- *
 *   in math operations, then multiplies each     *
 *   segment by the desired factor, then adds the *
 *   individual results together for a final      *
 *   answer.                                      *
 *                                                *
 * Parameters:                                    *
 *   char *value -  a string representation of    *
 *                  the number to be multiplied   *
 *                  by "factor";                  *
 *                  (see additional information   *
 *                  describing the value para-    *
 *                  meter in the charDivide()     *
 *                  function)                     *
 *                                                *
 *   long factor  - the factor; this includes an  *
 *                  implied decimal, in the       *
 *                  position indicated by         *
 *                  factorDecimals                *
 *                                                *
 *   int factorDecimals -                         *
 *                  number of digits after the    *
 *                  implied decimal point in the  *
 *                  factor paramter               *
 *                                                *
 **************************************************
 * EXAMPLE:                                       *
 *                                                *
 *   to multiply 45678901234.6789 by 1234.56      *
 *   when COBOL_DIGITS=18 & COBOL_PIC_DECIMALS=5, *
 *   pass in value of "004567890123467890"        *
 *   a factor of 123456, and a factorDecimals     *
 *   of 2                                         *
 *   upon function return, value will be set to   *
 *   "639334430828518278" (56393344308285.18278   *
 *   with leading 5 truncated)                    *
 *                                                *
 **************************************************/
void charMultiply(char *value, long factor, int factorDecimals)
{
    // SEG... = segment; approach below is to break the
    //          input value into pieces small enough that
    //          we can do math operations against them
    // sp     = segment product: the results of multiplying
    //          each segment by "factor"
    // answer = final product: essentially the sum of the
    //          sp (segment products)
    //

#define SEG_CNT            3            // set to the minimum value that is an
                                        // integer factor of COBOL_DIGITS such that
                                        // SEG_PADDED_SIZE <= 15  (the max. # of
                                        // significant digits that a double can store)
#define SEG_SIZE           (COBOL_DIGITS / SEG_CNT)
#define SEG_PADDED_SIZE    (SEG_SIZE + COBOL_RATE_LENGTH)

    short currColumn, carry, currSeg, shift;
    char sp[SEG_CNT][RESULT_LENGTH + 1];
    char answer[RESULT_LENGTH + 1];

    memset(sp, '0', sizeof(sp));

    for(currSeg=0; currSeg<SEG_CNT; currSeg++)
    {
        char szProduct[SEG_PADDED_SIZE + 1];
        short offset;
        char component[SEG_SIZE + 1];
        memset(component, 0x00, sizeof(component));
        memcpy(component, value+(currSeg * SEG_SIZE), SEG_SIZE);
        sprintf(szProduct, "%0*.0f", SEG_PADDED_SIZE, atof(component) * factor);
        offset=currSeg * SEG_SIZE;
        memcpy(sp[currSeg] + offset, szProduct, SEG_PADDED_SIZE);
    }

    carry=0;
    for(currColumn=RESULT_LENGTH-1; currColumn>=0; currColumn--)
    {
        int columnTotal=0;
        for(currSeg=0; currSeg<SEG_CNT; currSeg++)
            if(sp[currSeg][currColumn]>'0')
                columnTotal+=sp[currSeg][currColumn] - '0';
        columnTotal+=carry;
        carry=columnTotal/10;
        columnTotal%=10;
        answer[currColumn]=columnTotal+'0';
    }
    answer[sizeof(answer)-1]='\0';
    shift = factorDecimals - COBOL_RATE_LENGTH;
    memset(value, '0', RESULT_LENGTH);
    if(shift > 0)
    {
        strncpy(value+shift, answer, RESULT_LENGTH-shift);
    }
    else
        strcpy(value, answer-shift);
}

/**************************************************
 * charRound();                                   *
 *                                                *
 * Purpose:                                       *
 *   handles rounding where the precision         *
 *   required may be greater than that provided   *
 *   by C floating point routines                 *
 *                                                *
 * How it works:                                  *
 *   rounds manually by inspecting each digit in  *
 *   a character string of digits, modifying them *
 *   as required                                  *
 *                                                *
 * Parameters:                                    *
 *   char *value -  a string representation of    *
 *                  the number to be rounded      *
 *                                                *
 *   int position - counting from the left, the   *
 *                  digit where rounding will be  *
 *                  applied                       *
 *                                                *
 **************************************************
 * EXAMPLE:                                       *
 *                                                *
 *   to round 123456.8990123 to the 3rd decimal   *
 *   place, pass in value of "1234568990123", and *
 *   a position of 9.                             *
 *                                                *
 *   upon function return, value will be set to   *
 *   "1234569000000"                              *
 *                                                *
 **************************************************/
void charRound(char *value, unsigned int position)
{
    unsigned int savePosition;
    unsigned int len = strlen(value);

    if(position > COBOL_DIGITS)
        position = COBOL_DIGITS;
    if(position > len)
        return;
    savePosition = position;

    if(*(value+position)>'4')
    {
        while(--position >= 0)
        {
            if(++(*(value+position)) <= '9')
                break;
            *(value+position)='0';
        }
    }
    memset(value+savePosition, '0', len - savePosition);
}

