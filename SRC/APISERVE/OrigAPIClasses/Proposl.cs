/*@*****************************************************
/*@** 
/*@** Licensed Materials - Property of
/*@** ExlService Holdings, Inc.
/*@**  
/*@** (C) 1983-2013 ExlService Holdings, Inc.  All Rights Reserved.
/*@** 
/*@** Contains confidential and trade secret information.  
/*@** Copyright notice is precautionary only and does not
/*@** imply publication.
/*@** 
/*@*****************************************************

/*
*  SR#              INIT   DATE        DESCRIPTION
*  -----------------------------------------------------------------------
*  20060713-004-01   DAR   07/19/06    14.0 Base changes/additions
*  20070730-003-01   DAR   09/08/08    Reprojection enhancements
*  20090604-004-01   DAR   07/05/09    Updates to Illustration API
*  20090310-001-01   WAR   10/05/09    Reprojection enhancements
*  20091014-001-01   WAR   11/17/09    Add Cash Flows output fields
*  20100107-002-01   WAR   01/18/10    Modify table rated fields for riders
*  20120308-005-01   DAR   03/09/12    Add AIR Primary Insured Flag
*  20120503-005-01   DAR   07/05/12    Add Warning Codes/Messages
*  20120524-005-01   DAR   12/03/12    Add output values related to Guideline 
*                                      Premium tracking.    
*  20120816-002-01   TAP   05/22/13    Allow Assumed / Starting rate as an input override
*  20130520-005-01   DAR   09/04/13    Add Special Class Loan Rate
*  20131015-001-01   DAR   10/28/13    Support WCF and Web Services
*  20130508-004-01   AKR   01/07/15    Chgd TrPaidUpAdds&TrCurrDb to double
*  20160526-007-01   SAP   10/14/16    Added properties for Mortgage Special Premiums
*/


using System;
using LPNETAPI ;
using System.ServiceModel;
using System.ServiceModel.Description;  


namespace PDMA.LifePro
{
    /// <summary>
    /// The Proposal LifePRO API produces full illustrations given coverage and insured information (not an actual policy), 
    /// or produces a reprojection given a specific policy and override information.  
    /// 
    /// </summary>

    public class Proposl : IProposl
    {
        OPROPOSL apiProp ;

        public static OAPPLICA apiApp ;
        public string UserType ;

        public BaseResponse Init(string userType)
        {
            UserType = userType ;
            apiProp = new OPROPOSL(apiApp, UserType);

            BaseResponse outProps = new BaseResponse() ;
            outProps.ReturnCode = apiProp.getReturnCode() ;
            outProps.ErrorMessage = apiProp.getErrorMessage() ;
            return outProps;   

        }

        public void Dispose()
        {
            apiProp.Dispose();
            apiProp = null ;
        }

        public ProposalResponse RunProposal (ProposalRequest inProps )
        {

            SetProposalRequest(inProps);

            apiProp.RunProposal() ;

            ProposalResponse outProps = new ProposalResponse() ;
            outProps.ReturnCode = apiProp.getReturnCode();
            outProps.ErrorMessage = apiProp.getErrorMessage();

            int warningCount = apiProp.getWarningCount();
            outProps.ProcessWarningCode = new int[warningCount];
            outProps.ProcessWarningMessage = new string[warningCount];

            int i = 0;
            for (i = 0; i < warningCount; i++)
            {
                outProps.ProcessWarningCode[i] = apiProp.getProcessWarningCode(i+1);  
                outProps.ProcessWarningMessage[i] = apiProp.getProcessWarningMessage(i + 1);   
            }

            outProps.CurrLastEntry = apiProp.getCurrLastEntry();
            outProps.GuarLastEntry = apiProp.getGuarLastEntry();
            outProps.MidPointLastEntry = apiProp.getMidPointLastEntry();
            outProps.MaturityDate = apiProp.getMaturityDate();
            outProps.CurrMinPremPerd = apiProp.getCurrMinPremPerd();
            outProps.GuarMinPremPerd = apiProp.getGuarMinPremPerd();
            outProps.MidptMinPremPerd = apiProp.getMidptMinPremPerd();
            outProps.MinimumPrem = apiProp.getMinimumPrem();
            outProps.TargetPrem = apiProp.getTargetPrem();
            outProps.GuidelineLevelPrem = apiProp.getGuidelineLevelPrem();
            outProps.GuidelineSinglePrem = apiProp.getGuidelineSinglePrem();
            outProps.Tamra7PayPrem = apiProp.getTamra7PayPrem();
            outProps.TamraMecDate = apiProp.getTamraMecDate();
            outProps.PvMaxIndex = apiProp.getPvMaxIndex();
            outProps.NetpCurr10 = apiProp.getNetpCurr10();
            outProps.NetpCurr20 = apiProp.getNetpCurr20();
            outProps.NetpGuar10 = apiProp.getNetpGuar10();
            outProps.NetpGuar20 = apiProp.getNetpGuar20();
            outProps.SurrCurr10 = apiProp.getSurrCurr10();
            outProps.SurrCurr20 = apiProp.getSurrCurr20();
            outProps.SurrGuar10 = apiProp.getSurrGuar10();
            outProps.SurrGuar20 = apiProp.getSurrGuar20();
            outProps.Elad10 = apiProp.getElad10();
            outProps.Elad20 = apiProp.getElad20();
            outProps.NetpCurr10Lp = apiProp.getNetpCurr10Lp();
            outProps.NetpCurr20Lp = apiProp.getNetpCurr20Lp();
            outProps.NetpGuar10Lp = apiProp.getNetpGuar10Lp();
            outProps.NetpGuar20Lp = apiProp.getNetpGuar20Lp();
            outProps.CurrIntRate = apiProp.getCurrIntRate();
            outProps.GuarIntRate = apiProp.getGuarIntRate();
            outProps.Proj1IntRate = apiProp.getProj1IntRate();
            outProps.Proj2IntRate = apiProp.getProj2IntRate();
            outProps.Proj3IntRate = apiProp.getProj3IntRate();
            outProps.Proj4IntRate = apiProp.getProj4IntRate();
            outProps.LoanIntRate = apiProp.getLoanIntRate();
            outProps.SpecialClassLoanRate = apiProp.getSpecialClassLoanRate(); 
            outProps.ImpairedRule = apiProp.getImpairedRule();
            outProps.ImpairedIntRate = apiProp.getImpairedIntRate();
            outProps.PrfrImpRule = apiProp.getPrfrImpRule();
            outProps.PrfrImpIntRate = apiProp.getPrfrImpIntRate();
            outProps.VarIllusFlag = apiProp.getVarIllusFlag();
            outProps.PctExpenseChg = apiProp.getPctExpenseChg();
            outProps.ExpenseCharge = apiProp.getExpenseCharge();
            outProps.AdminChg1st = apiProp.getAdminChg1st();
            outProps.AdminChgAfter = apiProp.getAdminChgAfter();
            outProps.GtdYield10 = apiProp.getGtdYield10();
            outProps.GtdYieldMat = apiProp.getGtdYieldMat();
            outProps.CurrYield10 = apiProp.getCurrYield10();
            outProps.CurrYieldMat = apiProp.getCurrYieldMat();
            outProps.AnnualPolicyFee = apiProp.getAnnualPolicyFee();
            outProps.CurrModalSemiAnnual = apiProp.getCurrModalSemiAnnual();
            outProps.CurrModalQuarterly = apiProp.getCurrModalQuarterly();
            outProps.CurrModalMonthly = apiProp.getCurrModalMonthly();
            outProps.CurrModalMonthlyPac = apiProp.getCurrModalMonthlyPac();
            outProps.GuarModalSemiAnnual = apiProp.getGuarModalSemiAnnual();
            outProps.GuarModalQuarterly = apiProp.getGuarModalQuarterly();
            outProps.GuarModalMonthly = apiProp.getGuarModalMonthly();
            outProps.GuarModalMonthlyPac = apiProp.getGuarModalMonthlyPac();
            outProps.CurrModalBase = apiProp.getCurrModalBase();
            outProps.CurrModalRiders = apiProp.getCurrModalRiders();
            outProps.GuarModalBase = apiProp.getGuarModalBase();
            outProps.GuarModalRiders = apiProp.getGuarModalRiders();
            outProps.LevelDbOptionCode = apiProp.getLevelDbOptionCode();
            outProps.IncrsDbOptionCode = apiProp.getIncrsDbOptionCode();
            outProps.LoanTiming = apiProp.getLoanTiming();
            outProps.QualCode = apiProp.getQualCode();
            outProps.TrLoanTiming = apiProp.getLoanTiming();
            outProps.TrLoanIntRate = apiProp.getTrLoanIntRate();
            outProps.AccumIntRate = apiProp.getAccumIntRate();
            outProps.ProcMsgFlag = apiProp.getProcMsgFlag();
            outProps.ProcessingMessage = apiProp.getProcessingMessage();
            outProps.ErrorField = apiProp.getErrorField();
            outProps.TotalPremiums = apiProp.getTotalPremiums();

            outProps.IssueDate = apiProp.getIssueDateOut();
            outProps.CurrEndingDate = apiProp.getCurrEndingDate();  
            outProps.MidEndingDate = apiProp.getMidEndingDate();
            outProps.GuarEndingDate = apiProp.getGuarEndingDate();
            outProps.CurrEndIndicator = apiProp.getCurrEndIndicator();
            outProps.MidEndIndicator = apiProp.getMidEndIndicator();
            outProps.GuarEndIndicator = apiProp.getGuarEndIndicator();   

            int count = 200 ;
            int count2 = 30;

            outProps.PolicyYear = new int [count];
            outProps.AttainedAge = new int [count];
            outProps.AnnualPrem = new double[count];
            outProps.SpecifiedAmt = new int [count];
               outProps.Withdrawal = new double[count];
            outProps.LoanActivity = new double[count];
            outProps.LoanBalance = new double[count];
            outProps.LoanIntPaid = new double[count];
            outProps.GuidlnSngPrm = new double[count];
            outProps.GuidlnLvlPrm = new double[count];
            outProps.GuidlnLimit = new double[count];
            outProps.GuidlnViolationDate = new int[count];
            outProps.PlannedPremium = new double[count];
            outProps.RejectedPremium = new double[count];
            outProps.PremiumBasis = new double[count];
            outProps.CumulativePremium = new double[count];  
            outProps.CurrCoiRate = new double[count];
            outProps.AsmdIntRate = new double[count];
            outProps.GtdIntRate = new double[count];
            outProps.SurrChgRate = new double[count];
            outProps.TrAnnualDividend = new double[count];
            outProps.TrCurrCashValue = new double[count];
            outProps.TrLoanAct = new double[count];
            outProps.TrLoanBal = new double[count];
            outProps.TrLoanIntPd = new double[count];
            outProps.TrMidPtPremium = new double[count];
            outProps.TrMidPtSurrVal = new double[count];
            outProps.TrMidPtDeathBen = new int[count];
            outProps.TrmMidPtPremium = new double[count];
            outProps.TrmLpGtdPrem = new double[count];
            outProps.TrmLpGtdDb = new int[count];
            outProps.TrmLbGtdPrem = new double[count];
            outProps.TrmLbGtdDb = new int[count];
            outProps.TrmLpCurrPrem = new double[count];
            outProps.TrmLpCurrDb = new int[count];
            outProps.TrmLbCurrPrem = new double[count];
            outProps.TrmLbCurrDb = new int[count];
            outProps.CurrCashVal = new double[count];
            outProps.CurrSurrVal = new double[count];
            outProps.CurrDeathBen = new double[count];
            outProps.GuarCoiRate = new double[count];
            outProps.GuarCashVal = new double[count];
            outProps.GuarSurrVal = new double[count];
            outProps.GuarDeathBen = new double[count];
            outProps.MidptCoiRate = new double[count];
            outProps.MidptCashVal = new double[count];
            outProps.MidptSurrVal = new double[count];
            outProps.MidptDeathBen = new double[count];
            outProps.CurrMinimumPremium = new double[count];
            outProps.CurrTamraPremium = new double[count];
            outProps.CurrTargetPremium = new double[count];
            outProps.TrCurrAnnualPrem = new double[count];
            outProps.TrGuarAnnualPrem = new double[count];
            outProps.TrDeathBenefit = new double[count];
            outProps.TrGtdCashValue = new double[count];
            outProps.TrCashDividend = new double[count];
            outProps.TrTrmlDividend = new double[count];
            outProps.TrDivReducePrem = new double[count];
            outProps.TrPaidUpAdds = new double[count];
            outProps.TrPaidUpAddsCv  = new double[count];
            outProps.TrDividendAccums = new double[count];
            outProps.TrOytAdds = new int[count];
            outProps.TrOytAddsCv = new double[count];
            outProps.TrCurrCashValue = new double[count];
            outProps.TrCurrDb = new double[count];

            //outProps.ProjCoiRate = new double [count,5];
            //outProps.ProjCashVal = new double[count,5];
            //outProps.ProjSurrVal = new double[count,5];
            //outProps.ProjDeathBen = new double[count, 5];
            //outProps.ProjMiAtD12 = new double[2, 5];
            //outProps.ProjMiAtMat = new double[2, 5];

            outProps.ProjCoiRate = new double[count][];
            outProps.ProjCashVal = new double[count][];
            outProps.ProjSurrVal = new double[count][];
            outProps.ProjDeathBen = new double[count][];
            outProps.ProjMiAtD12 = new double[2][];
            outProps.ProjMiAtMat = new double[2][];

            outProps.TrInitCurrAnnual = new double[count2];
            outProps.TrInitCurrSemi = new double[count2];
            outProps.TrInitCurrQtrly = new double[count2];
            outProps.TrInitCurrMnthly = new double[count2];
            outProps.TrInitCurrPac = new double[count2];
            outProps.TrInitGuarAnnual = new double[count2];
            outProps.TrInitGuarSemi = new double[count2];
            outProps.TrInitGuarQtrly = new double[count2];
            outProps.TrInitGuarMnthly = new double[count2];
            outProps.TrInitGuarPac = new double[count2];
            outProps.CurrMiAge = new double[5];
            outProps.GuarMiAge = new double[5];
            outProps.PdfAccountBal = new double[count];
            outProps.DivWd = new double[count];
            outProps.PpWd = new double[count];
            outProps.PdfWd = new double[count];
            outProps.PpGtdSingleAmt = new double[count];
            outProps.PpGtdSingleCv = new double[count];
            outProps.PpGtdRecurAmt = new double[count];
            outProps.PpGtdRecurCv = new double[count];
            outProps.PpCurrSingleAmt = new double[count];
            outProps.PpCurrSingleCv = new double[count];
            outProps.PpCurrRecurAmt = new double[count];
            outProps.PpCurrRecurCv = new double[count];
            outProps.RecurringPpDiv = new double[count];
            outProps.DumpinPpDiv = new double[count];
            outProps.DivToPua = new double[count];
            outProps.DivToAccum = new double[count];
            outProps.WithDeathBenefit = new double[count];
            outProps.GtdReducePaidUp = new double[count];
            outProps.CurReducePaidUp = new double[count];

            for (i=1;i<=count;i++)
            {
                outProps.PolicyYear[i-1] = apiProp.getPolicyYear(i);
                outProps.AttainedAge[i-1] = apiProp.getAttainedAge(i);
                outProps.AnnualPrem[i-1] = apiProp.getAnnualPrem(i);
                outProps.SpecifiedAmt[i-1] = apiProp.getSpecifiedAmt(i);
                outProps.Withdrawal[i-1] = apiProp.getWithdrawal(i);
                outProps.LoanActivity[i-1] = apiProp.getLoanActivity(i);
                outProps.LoanBalance [i-1] = apiProp.getLoanBalance(i);
                outProps.LoanIntPaid[i-1] = apiProp.getLoanIntPaid(i);
                outProps.GuidlnSngPrm[i-1] = apiProp.getGuidlnSngPrm(i);
                outProps.GuidlnLvlPrm[i-1] = apiProp.getGuidlnLvlPrm(i);
                outProps.GuidlnLimit[i - 1] = apiProp.getGuidlnLimit(i);
                outProps.GuidlnViolationDate[i - 1] = apiProp.getGuidlnViolationDate(i);
                outProps.PlannedPremium[i - 1] = apiProp.getPlannedPremium(i);
                outProps.RejectedPremium[i - 1] = apiProp.getRejectedPremium(i);
                outProps.PremiumBasis[i - 1] = apiProp.getPremiumBasis(i);
                outProps.CumulativePremium[i - 1] = apiProp.getCumulativePremium(i); 
                outProps.CurrCoiRate[i-1] = apiProp.getCurrCoiRate(i);
                outProps.AsmdIntRate[i-1] = apiProp.getAsmdIntRate(i);
                outProps.GtdIntRate[i-1] = apiProp.getGtdIntRate(i);
                outProps.SurrChgRate[i-1] = apiProp.getSurrChgRate(i);
                outProps.TrAnnualDividend[i-1] = apiProp.getTrAnnualDividend(i);
                outProps.TrCurrCashValue[i-1] = apiProp.getTrCurrCashValue(i);
                outProps.TrMidPtPremium[i-1] = apiProp.getTrMidPtPremium(i);
                outProps.TrMidPtSurrVal[i-1] = apiProp.getTrMidPtSurrVal(i);
                outProps.TrMidPtDeathBen[i-1] = apiProp.getTrMidPtDeathBen(i);
                outProps.TrmMidPtPremium[i-1] = apiProp.getTrmMidPtPremium(i);
                outProps.TrmLpGtdPrem[i-1] = apiProp.getTrmLpGtdPrem(i);
                outProps.TrmLpGtdDb[i-1] = apiProp.getTrmLpGtdDb(i);
                outProps.TrmLbGtdPrem[i-1] = apiProp.getTrmLbGtdPrem(i);
                outProps.TrmLbGtdDb[i-1] = apiProp.getTrmLbGtdDb(i);
                outProps.TrmLpCurrPrem[i-1] = apiProp.getTrmLpCurrPrem(i);
                outProps.TrmLpCurrDb[i-1] = apiProp.getTrmLpCurrDb(i);
                outProps.TrmLbCurrPrem[i-1] = apiProp.getTrmLbCurrPrem(i);
                outProps.TrmLbCurrDb[i-1] = apiProp.getTrmLbCurrDb(i);
                outProps.CurrCashVal[i-1] = apiProp.getCurrCashVal(i);
                outProps.CurrSurrVal[i-1] = apiProp.getCurrSurrVal(i);
                outProps.CurrDeathBen[i-1] = apiProp.getCurrDeathBen(i);
                outProps.GuarCoiRate[i-1] = apiProp.getGuarCoiRate(i);
                outProps.GuarCashVal[i-1] = apiProp.getGuarCashVal(i);
                outProps.GuarSurrVal[i-1] = apiProp.getGuarSurrVal(i);
                outProps.GuarDeathBen[i-1] = apiProp.getGuarDeathBen(i);
                outProps.MidptCoiRate[i-1] = apiProp.getMidptCoiRate(i);
                outProps.MidptCashVal[i-1] = apiProp.getMidptCashVal(i);
                outProps.MidptSurrVal[i-1] = apiProp.getMidptSurrVal(i);
                outProps.MidptDeathBen[i-1] = apiProp.getMidptDeathBen(i);
                outProps.CurrTargetPremium[i - 1] = apiProp.getCurrTargetPremium(i);
                outProps.CurrMinimumPremium[i - 1] = apiProp.getCurrMinimumPremium(i);
                outProps.CurrTamraPremium[i - 1] = apiProp.getCurrTamraPremium(i);
                outProps.TrCurrAnnualPrem[i-1] = apiProp.getTrCurrAnnualPrem(i);
                outProps.TrGuarAnnualPrem[i-1] = apiProp.getTrGuarAnnualPrem(i);
                outProps.TrDeathBenefit[i-1] = apiProp.getTrDeathBenefit(i);
                outProps.TrGtdCashValue[i-1] = apiProp.getTrGtdCashValue(i);
                outProps.TrCashDividend[i-1] = apiProp.getTrCashDividend(i);
                outProps.TrTrmlDividend[i-1] = apiProp.getTrTrmlDividend(i);
                outProps.TrDivReducePrem[i-1] = apiProp.getTrDivReducePrem(i);
                outProps.TrPaidUpAdds[i-1] = apiProp.getTrPaidUpAdds(i);
                outProps.TrPaidUpAddsCv[i-1] = apiProp.getTrPaidUpAddsCv(i);
                outProps.TrDividendAccums[i-1] = apiProp.getTrDividendAccums(i);
                outProps.TrOytAdds[i-1] = apiProp.getTrOytAdds(i);
                outProps.TrOytAddsCv[i-1] = apiProp.getTrOytAddsCv(i);
                outProps.TrCurrCashValue[i-1] = apiProp.getTrCurrCashValue(i);
                outProps.TrCurrDb[i-1] = apiProp.getTrCurrDb(i);
                outProps.TrLoanAct[i - 1] = apiProp.getTrLoanAct(i);
                outProps.TrLoanBal[i - 1] = apiProp.getTrLoanBal(i);
                outProps.TrLoanIntPd[i - 1] = apiProp.getTrLoanIntPd(i);
                outProps.PdfAccountBal[i - 1] = apiProp.getPdfAccountBal(i);
                outProps.DivWd[i - 1] = apiProp.getDivWd(i);
                outProps.PpWd[i - 1] = apiProp.getPpWd(i);
                outProps.PdfWd[i - 1] = apiProp.getPdfWd(i);
                outProps.PpGtdSingleAmt[i - 1] = apiProp.getPpGtdSingleAmt(i);
                outProps.PpGtdSingleCv[i - 1] = apiProp.getPpGtdSingleCv(i);
                outProps.PpGtdRecurAmt[i - 1] = apiProp.getPpGtdRecurAmt(i);
                outProps.PpGtdRecurCv[i - 1] = apiProp.getPpGtdRecurCv(i);
                outProps.PpCurrSingleAmt[i - 1] = apiProp.getPpCurrSingleAmt(i);
                outProps.PpCurrSingleCv[i - 1] = apiProp.getPpCurrSingleCv(i);
                outProps.PpCurrRecurAmt[i - 1] = apiProp.getPpCurrRecurAmt(i);
                outProps.PpCurrRecurCv[i - 1] = apiProp.getPpCurrRecurCv(i);
                outProps.RecurringPpDiv[i - 1] = apiProp.getRecurringPpDiv(i);
                outProps.DumpinPpDiv[i - 1] = apiProp.getDumpInPpDiv(i);
                outProps.DivToPua[i - 1] = apiProp.getDivToPua(i);
                outProps.DivToAccum[i - 1] = apiProp.getDivToAccum(i);
                outProps.WithDeathBenefit[i - 1] = apiProp.getWithDeathBenefit(i);
                outProps.GtdReducePaidUp[i - 1] = apiProp.getGtdReducePaidUp(i);
                outProps.CurReducePaidUp[i - 1] = apiProp.getCurReducePaidUp(i);

                outProps.ProjCoiRate[i - 1] = new double[5];
                outProps.ProjCashVal[i - 1] = new double[5];
                outProps.ProjSurrVal[i - 1] = new double[5];
                outProps.ProjDeathBen[i - 1] = new double[5]; 

                for (int i2=1;i2<5;i2++)
                {
                    outProps.ProjCoiRate[i-1] [i2-1] = apiProp.getProjCoiRate(i, i2);
                    outProps.ProjCashVal[i-1] [i2-1] = apiProp.getProjCashVal(i, i2);
                    outProps.ProjSurrVal[i-1] [i2-1] = apiProp.getProjSurrVal(i, i2);
                    outProps.ProjDeathBen[i-1] [i2-1] = apiProp.getProjDeathBen(i, i2);
                }
            }

            for (i = 1; i <= 2; i++)
            {
                outProps.ProjMiAtD12[i - 1] = new double[5];
                outProps.ProjMiAtMat[i - 1] = new double[5];

                for (int i2 = 1; i2 <= 5; i2++)
                {
                    outProps.ProjMiAtD12[i - 1] [i2 - 1] = apiProp.getProjMiAtD12(i, i2);
                    outProps.ProjMiAtMat[i - 1] [i2 - 1] = apiProp.getProjMiAtMat(i, i2);
                }
            }


            for (i=1;i<count2;i++) {
                outProps.TrInitCurrAnnual[i-1] = apiProp.getTrInitCurrAnnual(i);
                outProps.TrInitCurrSemi[i-1] = apiProp.getTrInitCurrSemi(i);
                outProps.TrInitCurrQtrly[i-1] = apiProp.getTrInitCurrQtrly(i);
                outProps.TrInitCurrMnthly[i-1] = apiProp.getTrInitCurrMnthly(i);
                outProps.TrInitCurrPac[i-1] = apiProp.getTrInitCurrPac(i);
                outProps.TrInitGuarAnnual[i-1] = apiProp.getTrInitGuarAnnual(i);
                outProps.TrInitGuarSemi[i-1] = apiProp.getTrInitGuarSemi(i);
                outProps.TrInitGuarQtrly[i-1] = apiProp.getTrInitGuarQtrly(i);
                outProps.TrInitGuarMnthly[i-1] = apiProp.getTrInitGuarMnthly(i);
                outProps.TrInitGuarPac[i-1] = apiProp.getTrInitGuarPac(i);
            }

            for (i=1;i<5;i++) {
                outProps.CurrMiAge[i-1] = apiProp.getCurrMiAge(i);
                outProps.GuarMiAge[i-1] = apiProp.getGuarMiAge(i);
            }


            return outProps ;
        }

        public ProposalRequest LoadExistingPolicy(string company, string policy, int effectivedate, out int returncode, out string message)
        {
            apiProp.setCompanyCode(company);
            apiProp.setPolicyNumber(policy);
            apiProp.setEffectiveDate(effectivedate);

            int rc = apiProp.LoadExistingPolicy();

            // A Proposal Input object will be sent back to client with default values loaded for certain values.
            // Not ALL ProposalRequest values are accounted for, only those loaded by PSTAKBLD (in the WSTAK copybook).
            ProposalRequest overrides = new ProposalRequest();
            if (rc == 0)
            {
                LoadOverrides(overrides);
            }

            returncode = rc;
            message = apiProp.getErrorMessage();
            return overrides;

        }

        public void AcceptSurrenderQuote(ISurQuote isurquote)
        {
            SurQuote sq = (SurQuote)isurquote;
            apiProp.AcceptSurrenderQuote(sq.ReturnSurQuoteObj());

        }

        public void AcceptDeathQuote(IDthQuote idthquote)
        {
            DthQuote dq = (DthQuote)idthquote;
            apiProp.AcceptDeathQuote(dq.ReturnDthQuoteObj());
        }

        /*
         * InitAirTable is not useful to remote clients.  Remove.
        public void InitAirTable()
        {
            // No inputs or outputs, this is just a request to initialize
            apiProp.initAirTable();
        }
         */

        public ProposalRequest InitFutrTable(ProposalRequest inProps)
        {

            // Use those values of inProps that may effect the initFutrTable function.

            SetProposalRequest(inProps);
            apiProp.initFutrTable();

            ProposalRequest overrides = new ProposalRequest();
            // Only load those override values that are Future table related.
            LoadOverrides(overrides);

            return overrides;
        }

        private void SetProposalRequest(ProposalRequest inProps)
        {

            apiProp.setmoneyPurchasePremPct(inProps.MoneyPurchasePremPct);
            apiProp.setUseDefaultRules(inProps.UseDefaultRules);
            apiProp.setMinAge(inProps.MinAge);
            apiProp.setMaxAge(inProps.MaxAge);
            apiProp.setMaxMaturityAge(inProps.MaxMaturityAge);
            apiProp.setMinMaturityAge(inProps.MinMaturityAge);
            apiProp.setprMinIssueAmount(inProps.PrMinIssueAmount);
            apiProp.setprMaxIssueAmount(inProps.PrMaxIssueAmount);
            apiProp.setMinMonthlyPrem(inProps.MinMonthlyPrem);
            apiProp.setMaxMonthlyPrem(inProps.MaxMonthlyPrem);
            apiProp.setMinQuarterlyPrem(inProps.MinQuarterlyPrem);
            apiProp.setMaxQuarterlyPrem(inProps.MaxQuarterlyPrem);
            apiProp.setMinAnnualPrem(inProps.MinAnnualPrem);
            apiProp.setMaxAnnualPrem(inProps.MaxAnnualPrem);
            apiProp.setMinCoverPeriod(inProps.MinCoverPeriod);
            apiProp.setMaxCoverPeriod(inProps.MaxCoverPeriod);
            apiProp.setMinMthlyPremPeriod(inProps.MinMthlyPremPeriod);
            apiProp.setMinQtrlyPremPeriod(inProps.MinQtrlyPremPeriod);
            apiProp.setMinAnnualPremPeriod(inProps.MinAnnualPremPeriod);
            apiProp.setMinSinglePrem(inProps.MinSinglePrem);
            apiProp.setMaxSinglePrem(inProps.MaxSinglePrem);
            apiProp.setAgeBasis(inProps.AgeBasis);
            apiProp.setLastAccessDate(inProps.LastAccessDate);
            apiProp.setPlancode(inProps.Plancode);
            apiProp.setPlanMarketName(inProps.PlanMarketName);
            apiProp.setCoverageId(inProps.CoverageId);
            apiProp.setLob(inProps.Lob);
            apiProp.setIssueDate(inProps.IssueDate);
            apiProp.setDob(inProps.Dob);
            apiProp.setDobDdate(inProps.DobDdate);
            apiProp.setIssueAge(inProps.IssueAge);
            apiProp.setSexCode(inProps.SexCode);
            apiProp.setUwcls(inProps.Uwcls);
            apiProp.setUwclsDesc(inProps.UwclsDesc);
            apiProp.setDob2(inProps.Dob2);
            apiProp.setDob2Ddate(inProps.Dob2Ddate);
            apiProp.setIssueAge2(inProps.IssueAge2);
            apiProp.setSexCode2(inProps.SexCode2);
            apiProp.setUwcls2(inProps.Uwcls2);
            apiProp.setUwclsDesc2(inProps.UwclsDesc2);
            apiProp.setSpecified(inProps.Specified);
            apiProp.setSuppressSpecAmtChg(inProps.SuppressSpecAmtChg);
            apiProp.setNewWDAmount(inProps.NewWDAmount);
            apiProp.setCoveragePeriodFlag(inProps.CoveragePeriodFlag);
            apiProp.setCoveragePeriodYears(inProps.CoveragePeriodYears);

            // inProps.CoverageOption and inProps.DividendOption translate to the same byte
            // in WSTAKCPY.  Must decide which one to use to set STAK byte
            // based on type of business.
            if (inProps.Lob != null
                && (inProps.Lob == "U" ||
                     inProps.Lob == "A"))
                apiProp.setCoverageOption(inProps.CoverageOption);
            else
                apiProp.setDividendOption(inProps.DividendOption);

            apiProp.setExcessDividendOption(inProps.ExcessDividendOption);
            apiProp.setCalModesOverride(inProps.CalModesOverride);
            apiProp.setPaymentMode(inProps.PaymentMode);
            apiProp.setBillingForm(inProps.BillingForm);
            apiProp.setLoanRepayMode(inProps.LoanRepayMode);
            apiProp.setPaymentPeriodFlag(inProps.PaymentPeriodFlag);
            apiProp.setPaymentPeriodYears(inProps.PaymentPeriodYears);
            apiProp.setRedPayForDefra(inProps.RedPayForDefra);
            apiProp.setAddlLumpSum(inProps.AddlLumpSum);
            apiProp.setIndexRule(inProps.IndexRule);
            apiProp.setIndexRate(inProps.IndexRate);
            apiProp.setIndexYear(inProps.IndexYear);
            apiProp.setSearchCv(inProps.SearchCv);
            apiProp.setSearchFlag(inProps.SearchFlag);
            apiProp.setSearchYear(inProps.SearchYear);
            apiProp.setSearchBasis(inProps.SearchBasis);
            apiProp.setTable(inProps.Table);
            apiProp.setTableRating(inProps.TableRating);
            apiProp.setTableDuration(inProps.TableDuration);
            apiProp.setFlatRating(inProps.FlatRating);
            apiProp.setFlatDuration(inProps.FlatDuration);
            apiProp.setTable2(inProps.Table2);
            apiProp.setTableRating2(inProps.TableRating2);
            apiProp.setTableDuration2(inProps.TableDuration2);
            apiProp.setFlatRating2(inProps.FlatRating2);
            apiProp.setFlatDuration2(inProps.FlatDuration2);
            apiProp.setStartingRate(inProps.StartingRate);
            apiProp.setStartingYear(inProps.StartingYear);
            apiProp.setUltimateRate(inProps.UltimateRate);
            apiProp.setUltimateYear(inProps.UltimateYear);
            apiProp.setSecondRate(inProps.SecondRate);
            apiProp.setSecondYear(inProps.SecondYear);
            apiProp.setMinIssueAmount(inProps.MinIssueAmount);
            apiProp.setMaxIssueAmount(inProps.MaxIssueAmount);
            apiProp.setMiAge1(inProps.MiAge1);
            apiProp.setMiAge2(inProps.MiAge2);
            apiProp.setMiAge3(inProps.MiAge3);
            apiProp.setFutrMaxIndex(inProps.FutrMaxIndex);
            apiProp.setClientName(inProps.ClientName);
            apiProp.setClientStreet(inProps.ClientStreet);
            apiProp.setClientCity(inProps.ClientCity);
            apiProp.setClientState(inProps.ClientState);
            apiProp.setClientZipCode(inProps.ClientZipCode);
            apiProp.setClientPhoneNumber(inProps.ClientPhoneNumber);
            apiProp.setAgentName(inProps.AgentName);
            apiProp.setAgentAddress(inProps.AgentAddress);
            apiProp.setAgentStreet(inProps.AgentStreet);
            apiProp.setAgentCity(inProps.AgentCity);
            apiProp.setAgentState(inProps.AgentState);
            apiProp.setAgentZipCode(inProps.AgentZipCode);
            apiProp.setAgentPhoneNumber(inProps.AgentPhoneNumber);
            apiProp.setAirMaxIndex(inProps.AirMaxIndex);
            apiProp.setPrintScreen(inProps.PrintScreen);
            apiProp.setPrintCover(inProps.PrintCover);
            apiProp.setPrintSummary(inProps.PrintSummary);
            apiProp.setPrintDetailFlag(inProps.PrintDetailFlag);
            apiProp.setPrintDetailYears(inProps.PrintDetailYears);
            apiProp.setCompanyCode(inProps.CompanyCode);
            //apiProp.setMaturityDate(inProps.MaturityDate);
            apiProp.setMoneyPurchaseFlag(inProps.MoneyPurchaseFlag);
            apiProp.setProposalNumberKey(inProps.ProposalNumberKey);
            apiProp.setPremium(inProps.Premium);

            apiProp.setFunction(inProps.Function);
            apiProp.setPolicyNumber(inProps.PolicyNumber);
            apiProp.setEffectiveDate(inProps.EffectiveDate);
            apiProp.setPolicyYear(inProps.PolicyYear);
            apiProp.setPolicyMonth(inProps.PolicyMonth);
            apiProp.setInfPuaAmount(inProps.InfPuaAmount);
            apiProp.setInfDivAccums(inProps.InfDivAccums);
            apiProp.setInfPremDepFund(inProps.InfPremDepFund);
            apiProp.setInfLoanBalance(inProps.InfLoanBalance);
            apiProp.setInfLoanAccrualDate(inProps.InfLoanAccrualDate);
            apiProp.setInfLoanAmtAvail(inProps.InfLoanAmtAvail);
            apiProp.setNewLoanAmt(inProps.NewLoanAmt);

            //20160526-007-01   SAP  Added properties for Mortgage Special Premiums
            int count = 1;
            if (inProps.BillingForm == "S")
            {
                for (int num = 0; num < inProps.IllustrationID.Length; num++)
                {
                    if (inProps.PayType[num] == "S" || inProps.PayType[num] == "P" || inProps.PayType[num] == "A")
                    {
                        apiProp.setIllustrationID(inProps.IllustrationID[num], count);
                        apiProp.setDraftDate(inProps.DraftDate[num], count);
                        apiProp.setPayType(inProps.PayType[num], count);
                        apiProp.setPremOutlayPayment(inProps.PremiumOutlayPayment[num], count);
                        count++;
                    }
                }

            }


            int i;

            // Revise to only set Future properties for values less than FutrMaxIndex.

            // For web service calls, do not assume input arrays have been initialized.  In this case, 
            // wrap each property assignment in try/catch.  
            for (i = 0; i < inProps.FutrMaxIndex; i++)
            {
                try
                {
                    if (inProps.FutrYear.Length > i)
                        apiProp.setFutrYear(inProps.FutrYear[i], i + 1);
                }
                catch { }

                try
                {
                    if (inProps.FutrAge.Length > i)
                        apiProp.setFutrAge(inProps.FutrAge[i], i + 1);
                }
                catch { }

                try
                {
                    if (inProps.FutrPremium.Length > i)
                        apiProp.setFutrPremium(inProps.FutrPremium[i], i + 1);
                }
                catch { } 

                try 
                {

                if (inProps.FutrSpecified.Length > i)
                    apiProp.setFutrSpecified(inProps.FutrSpecified[i], i + 1);
                }
                catch {}

                try
                {
                    if (inProps.FutrDbOption.Length > i)
                        apiProp.setFutrDbOption(inProps.FutrDbOption[i], i + 1);
                }
                catch { }

                try
                {
                    if (inProps.FutrTargetCv.Length > i)
                        apiProp.setFutrTargetCv(inProps.FutrTargetCv[i], i + 1);
                }
                catch { }

                try
                {
                    if (inProps.FutrDepositWithdrl.Length > i)
                        apiProp.setFutrDepositWithdrl(inProps.FutrDepositWithdrl[i], i + 1);
                }
                catch { }

                try
                {
                    if (inProps.FutrLoan.Length > i)
                        apiProp.setFutrLoan(inProps.FutrLoan[i], i + 1);
                }
                catch { }

                try
                {
                    if (inProps.FutrLoanOption.Length > i)
                        apiProp.setFutrLoanOption(inProps.FutrLoanOption[i], i + 1);
                }
                catch { }  

            }



            for (i = 0; i < inProps.AirMaxIndex; i++)
            {
                try
                {
                    if (inProps.AirCoverageCode.Length > i)
                        apiProp.setAirCoverageCode(inProps.AirCoverageCode[i], i + 1);
                }
                catch { }

                try
                {
                    if (inProps.AirCoverageId.Length > i)
                        apiProp.setAirCoverageId(inProps.AirCoverageId[i], i + 1);
                }
                catch { }

                try
                {
                    if (inProps.AirDob.Length > i)
                        apiProp.setAirDob(inProps.AirDob[i], i + 1);
                }
                catch { }

                try
                {
                    if (inProps.AirAge.Length > i)
                        apiProp.setAirAge(inProps.AirAge[i], i + 1);
                }
                catch { }

                try
                {
                    if (inProps.AirSexCode.Length > i)
                        apiProp.setAirSexCode(inProps.AirSexCode[i], i + 1);
                }
                catch { }

                try
                {
                    if (inProps.AirUwcls.Length > i)
                        apiProp.setAirUwcls(inProps.AirUwcls[i], i + 1);
                }
                catch { }

                try
                {
                    if (inProps.AirAmount.Length > i)
                        apiProp.setAirAmount(inProps.AirAmount[i], i + 1);
                }
                catch { }

                try
                {
                    if (inProps.AirStatus.Length > i)
                        apiProp.setAirStatus(inProps.AirStatus[i], i + 1);
                }
                catch { }

                try
                {
                    if (inProps.AirPrimaryInsured.Length > i)
                        apiProp.setAirPrimaryInsured(inProps.AirPrimaryInsured[i], i + 1);
                }
                catch { }

                try
                {
                    if (inProps.AirModePremium.Length > i)
                        apiProp.setAirModePremium(inProps.AirModePremium[i], i + 1);
                }
                catch { }

                try
                {
                    if (inProps.AirIssueDate.Length > i)
                        apiProp.setAirIssueDate(inProps.AirIssueDate[i], i + 1);
                }
                catch { }

                try
                {
                    if (inProps.AirUwcls.Length > i)
                        apiProp.setAirUwcls(inProps.AirUwcls[i], i + 1);
                }
                catch { }

                try
                {
                    if (inProps.AirAmount.Length > i)
                        apiProp.setAirAmount(inProps.AirAmount[i], i + 1);
                }
                catch { }

                try
                {
                    if (inProps.AirInForceFlag.Length > i)
                        apiProp.setAirInForceFlag(inProps.AirInForceFlag[i], i + 1);
                }
                catch { }

                try
                {
                    if (inProps.AirInForceYears.Length > i)
                        apiProp.setAirInForceYears(inProps.AirInForceYears[i], i + 1);
                }
                catch { }

                try
                {
                    if (inProps.AirTable.Length > i)
                        apiProp.setAirTable(inProps.AirTable[i], i + 1);
                }
                catch { }

                try
                {
                    if (inProps.AirTableRating.Length > i)
                        apiProp.setAirTableRating(inProps.AirTableRating[i], i + 1);
                }
                catch { }

                try
                {
                    if (inProps.AirTableDur.Length > i)
                        apiProp.setAirTableDur(inProps.AirTableDur[i], i + 1);
                }
                catch { }

                try
                {
                    if (inProps.AirFlat.Length > i)
                        apiProp.setAirFlat(inProps.AirFlat[i], i + 1);
                }
                catch { }


                try
                {
                    if (inProps.AirFlatDur.Length > i)
                        apiProp.setAirFlatDur(inProps.AirFlatDur[i], i + 1);
                }
                catch { }


                try
                {
                    if (inProps.AirComponentNum.Length > i)
                        apiProp.setAirComponentNum(inProps.AirComponentNum[i], i + 1);
                }
                catch { }

                try
                {
                    if (inProps.AirDefaultType.Length > i)
                        apiProp.setAirDefaultType(inProps.AirDefaultType[i], i + 1);
                }
                catch { }

                try
                {
                    if (inProps.AirAmtBasis.Length > i)
                        apiProp.setAirAmtBasis(inProps.AirAmtBasis[i], i + 1);
                }
                catch { }

                try
                {
                    if (inProps.AirMinIssueAmt.Length > i)
                        apiProp.setAirMinIssueAmt(inProps.AirMinIssueAmt[i], i + 1);
                }
                catch { }

                try
                {
                    if (inProps.AirMaxIssueAmt.Length > i)
                        apiProp.setAirMaxIssueAmt(inProps.AirMaxIssueAmt[i], i + 1);
                }
                catch { }  
            }


        }


        private void LoadOverrides(ProposalRequest overrides)
        {

            overrides.Plancode = apiProp.getPlancode().Trim();
            overrides.PlanMarketName = apiProp.getPlanMarketName().Trim();
            overrides.CoverageId = apiProp.getCoverageId().Trim();
            overrides.Lob = apiProp.getLob().Trim();
            overrides.IssueDate = apiProp.getIssueDate();
            overrides.Dob = apiProp.getDob();
            overrides.IssueAge = apiProp.getIssueAge();
            overrides.SexCode = apiProp.getSexCode().Trim();
            overrides.Uwcls = apiProp.getUwcls().Trim();
            overrides.UwclsDesc = apiProp.getUwclsDesc().Trim();
            overrides.Dob2 = apiProp.getDob2();
            overrides.IssueAge2 = apiProp.getIssueAge2();
            overrides.SexCode2 = apiProp.getSexCode2().Trim();
            overrides.Uwcls2 = apiProp.getUwcls2().Trim();
            overrides.Specified = apiProp.getSpecified();
            overrides.SuppressSpecAmtChg = apiProp.getSuppressSpecAmtChg();
            overrides.NewWDAmount = apiProp.getNewWDAmount();
            overrides.CoveragePeriodFlag = apiProp.getCoveragePeriodFlag().Trim();
            overrides.CoveragePeriodYears = apiProp.getCoveragePeriodYears();
            overrides.CoverageOption = overrides.DividendOption = "";
            if (overrides.Lob == "U" ||
                overrides.Lob == "A")
                overrides.CoverageOption = apiProp.getCoverageOption().Trim();
            else
                overrides.DividendOption = apiProp.getDividendOption().Trim();
            overrides.ExcessDividendOption = apiProp.getExcessDividendOption().Trim();
            overrides.CalModesOverride = apiProp.getCalModesOverride();

            overrides.CoverageOption = apiProp.getCoverageOption().Trim();
            overrides.NewLoanAmt = apiProp.getNewLoanAmt();
            overrides.Premium = apiProp.getPremium();
            overrides.PaymentMode = apiProp.getPaymentMode().Trim();
            overrides.BillingForm = apiProp.getBillingForm().Trim();
            overrides.LoanRepayMode = apiProp.getLoanRepayMode().Trim();
            overrides.PaymentPeriodFlag = apiProp.getPaymentPeriodFlag().Trim();
            overrides.PaymentPeriodYears = apiProp.getPaymentPeriodYears();
            overrides.RedPayForDefra = apiProp.getRedPayForDefra().Trim();
            overrides.AddlLumpSum = apiProp.getAddlLumpSum();
            overrides.IndexRule = apiProp.getIndexRule().Trim();
            overrides.IndexRate = apiProp.getIndexRate();
            overrides.IndexYear = apiProp.getIndexYear();
            overrides.SearchCv = apiProp.getSearchCv();
            overrides.SearchFlag = apiProp.getSearchFlag().Trim();
            overrides.SearchYear = apiProp.getSearchYear();
            overrides.SearchBasis = apiProp.getSearchBasis();
            overrides.Table = apiProp.getTable().Trim();
            overrides.TableRating = apiProp.getTableRating();
            overrides.TableDuration = apiProp.getTableDuration();
            overrides.FlatRating = apiProp.getFlatRating();
            overrides.FlatDuration = apiProp.getFlatDuration();
            overrides.Table2 = apiProp.getTable2().Trim();
            overrides.TableRating2 = apiProp.getTableRating2();
            overrides.TableDuration2 = apiProp.getTableDuration2();
            //overrides.StartingRate = apiProp.getStartingRate();
            //overrides.StartingYear = apiProp.getStartingYear();
            //overrides.SecondRate = apiProp.getSecondRate();
            //overrides.SecondYear = apiProp.getSecondYear();
            //overrides.UltimateRate = apiProp.getUltimateRate();
            //overrides.UltimateYear = apiProp.getUltimateYear();
            //overrides.MinIssueAmount = apiProp.getMinIssueAmount();
            //overrides.MaxIssueAmount = apiProp.getMaxIssueAmount();
            overrides.MiAge1 = apiProp.getMiAge1();
            overrides.MiAge2 = apiProp.getMiAge2();
            overrides.MiAge3 = apiProp.getMiAge3();
            overrides.PolicyYear = apiProp.getPolicyYear();
            overrides.PolicyMonth = apiProp.getPolicyMonth();
            overrides.EffectiveDate = apiProp.getEffectiveDate();
            overrides.InfPuaAmount = apiProp.getInfPuaAmount();
            overrides.InfDivAccums = apiProp.getInfDivAccums();
            overrides.InfPremDepFund = apiProp.getInfPremDepFund();
            overrides.InfLoanBalance = apiProp.getInfLoanBalance();
            overrides.InfLoanAccrualDate = apiProp.getInfLoanAccrualDate();
            overrides.InfLoanAmtAvail = apiProp.getInfLoanAmtAvail();

            overrides.ClientName = apiProp.getClientName().Trim();
            overrides.ClientStreet = apiProp.getClientStreet().Trim();
            overrides.ClientCity = apiProp.getClientCity().Trim();
            overrides.ClientState = apiProp.getClientState().Trim();
            overrides.ClientZipCode = apiProp.getClientZipCode().Trim();
            overrides.ClientPhoneNumber = apiProp.getClientPhoneNumber();
            overrides.AgentName = apiProp.getAgentName().Trim();
            overrides.AgentStreet = apiProp.getAgentStreet().Trim();
            overrides.AgentCity = apiProp.getAgentCity().Trim();
            overrides.AgentState = apiProp.getAgentState().Trim();
            overrides.AgentZipCode = apiProp.getAgentZipCode();
            overrides.AgentPhoneNumber = apiProp.getAgentPhoneNumber();


            int rows = apiProp.getAirMaxIndex();
            overrides.AirMaxIndex = rows;

            overrides.AirCoverageCode = new string[rows];
            overrides.AirCoverageId = new string[rows];
            overrides.AirDob = new int[rows];
            overrides.AirAge = new int[rows];
            overrides.AirSexCode = new string[rows];
            overrides.AirUwcls = new string[rows];
            overrides.AirAmount = new double[rows];
            overrides.AirStatus = new string[rows];
            overrides.AirIssueDate = new int[rows];
            overrides.AirModePremium = new double[rows];
            overrides.AirInForceFlag = new string[rows];
            overrides.AirInForceYears = new int[rows];
            overrides.AirPrimaryInsured = new string[rows];   
            overrides.AirTable = new string[rows];
            overrides.AirTableRating = new int[rows];
            overrides.AirTableDur = new int[rows];
            overrides.AirFlat = new double[rows];
            overrides.AirFlatDur = new int[rows];
            overrides.AirComponentNum = new int[rows];
            overrides.AirDefaultType = new string[rows];
            overrides.AirAmtBasis = new string[rows];
            overrides.AirMinIssueAmt = new int[rows];
            overrides.AirMaxIssueAmt = new int[rows];

            for (int i = 0; i < rows; i++)
            {
                overrides.AirCoverageCode[i] = apiProp.getAirCoverageCode(i + 1).Trim();
                overrides.AirCoverageId[i] = apiProp.getAirCoverageId(i + 1).Trim();
                overrides.AirDob[i] = apiProp.getAirDob(i + 1);
                overrides.AirAge[i] = apiProp.getAirAge(i + 1);
                overrides.AirSexCode[i] = apiProp.getAirSexCode(i + 1).Trim();
                overrides.AirUwcls[i] = apiProp.getAirUwcls(i + 1);
                overrides.AirAmount[i] = apiProp.getAirAmount(i + 1);
                overrides.AirIssueDate[i] = apiProp.getAirIssueDate(i + 1);
                overrides.AirStatus[i] = apiProp.getAirStatus(i + 1);
                overrides.AirPrimaryInsured[i] = apiProp.getAirPrimaryInsured(i + 1);   
                overrides.AirModePremium[i] = apiProp.getAirModePremium(i + 1);
                overrides.AirInForceFlag[i] = apiProp.getAirInForceFlag(i + 1).Trim();
                overrides.AirInForceYears[i] = apiProp.getAirInForceYears(i + 1);
                overrides.AirTable[i] = apiProp.getAirTable(i + 1);
                overrides.AirTableRating[i] = apiProp.getAirTableRating(i + 1);
                overrides.AirTableDur[i] = apiProp.getAirTableDur(i + 1);
                overrides.AirFlat[i] = apiProp.getAirFlat(i + 1);
                overrides.AirFlatDur[i] = apiProp.getAirFlatDur(i + 1);
                overrides.AirComponentNum[i] = apiProp.getAirComponentNum(i + 1);
                overrides.AirDefaultType[i] = apiProp.getAirDefaultType(i + 1);
                overrides.AirAmtBasis[i] = apiProp.getAirAmtBasis(i + 1);
                overrides.AirMinIssueAmt[i] = apiProp.getAirMinIssueAmt(i + 1);
                overrides.AirMaxIssueAmt[i] = apiProp.getAirMaxIssueAmt(i + 1);
            }


            rows = apiProp.getFutrMaxIndex();
            overrides.FutrMaxIndex = rows;

            overrides.FutrYear = new int[rows];
            overrides.FutrAge = new int[rows];
            overrides.FutrPremium = new double[rows];
            overrides.FutrSpecified = new int[rows];
            overrides.FutrDbOption = new string[rows];
            overrides.FutrTargetCv = new int[rows];
            overrides.FutrDepositWithdrl = new int[rows];
            overrides.FutrLoan = new int[rows];
            overrides.FutrLoanOption = new string[rows];

            for (int i = 0; i < rows; i++)
            {
                overrides.FutrYear[i] = apiProp.getFutrYear(i + 1);
                overrides.FutrAge[i] = apiProp.getFutrAge(i + 1);
                overrides.FutrPremium[i] = apiProp.getFutrPremium(i + 1);
                overrides.FutrSpecified[i] = apiProp.getFutrSpecified(i + 1);
                overrides.FutrDbOption[i] = apiProp.getFutrDbOption(i + 1);
                overrides.FutrTargetCv[i] = apiProp.getFutrTargetCv(i + 1);
                overrides.FutrDepositWithdrl[i] = apiProp.getFutrDepositWithdrl(i + 1);
                overrides.FutrLoan[i] = apiProp.getFutrLoan(i + 1);
                overrides.FutrLoanOption[i] = apiProp.getFutrLoanOption(i + 1).Trim();
            }

        }



        public ProposalRequest IndexPremium (ProposalRequest inProps)
        {

            SetProposalRequest(inProps);
            apiProp.indexPremium();

            ProposalRequest overrides = new ProposalRequest();
            // Only load those override values that are Future table related.
            LoadOverrides(overrides);
            return overrides;
        }

        /*
        public void InitNameAddrData ()
        {
            apiProp.initNameAddrData ();
        }
         */

        public string LoadTradTable ()
        {

            return apiProp.loadTradTable () ;
        }
        public string LoadUlTable ()
        {

            return apiProp.loadUlTable () ;
        }


    }
}

