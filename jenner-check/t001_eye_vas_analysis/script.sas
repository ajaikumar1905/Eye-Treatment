OPTIONS VALIDVARNAME=V7;

/* The original imports "Finel Data.xlsx" via PROC IMPORT. For a self-contained
   run this DATA step recreates WORK.IMPORT with the three columns the analysis
   reads (Type_of_Treatment, First_VAS, Change_in_VAS), using values sampled from
   the study's three treatment modalities. All analysis steps below are unchanged. */
DATA WORK.IMPORT;
    LENGTH Type_of_Treatment $20;
    INFILE DATALINES DLM='|';
    INPUT Type_of_Treatment $ First_VAS Change_in_VAS;
DATALINES;
Surgery & Injection|54.9|21.3
Surgery & Injection|11.14|50.0
Surgery & Injection|11.14|-11.14
Surgery & Injection|0.0|0.0
Surgery & Injection|11.14|23.86
Surgery & Injection|11.14|65.05
Surgery & Injection|35.0|0.0
Surgery & Injection|35.0|-23.86
Surgery & Injection|61.14|-15.05
Injection|69.95|-8.8
Injection|54.9|0.0
Injection|85.0|0.0
Injection|61.14|15.05
Injection|61.14|0.0
Injection|61.14|15.05
Injection|11.14|-11.09
Injection|61.14|8.8
Injection|35.0|0.0
Surgery|0.05|54.85
Surgery|46.09|23.86
Surgery|35.0|26.14
Surgery|11.14|65.05
Surgery|0.05|69.9
Surgery|0.0|0.0
Surgery|46.09|30.1
Surgery|0.05|46.04
Surgery|19.95|56.25
;
RUN;

PROC CONTENTS DATA=WORK.IMPORT; RUN;

/* ============================================================== */
/* 3 & 4. DATA PREPARATION (Main Analysis)                        */
/* ============================================================== */
DATA analysis_data;
    SET WORK.IMPORT;
    WHERE Type_of_Treatment IS NOT MISSING AND Change_in_VAS IS NOT MISSING;
RUN;

/* ============================================================== */
/* 5. DESCRIPTIVE STATISTICS                                      */
/* ============================================================== */
TITLE "Descriptive Statistics by Treatment Type";
PROC MEANS DATA=analysis_data N MEAN MEDIAN STD MAXDEC=2;
    CLASS Type_of_Treatment;
    VAR Change_in_VAS;
RUN;

/* ============================================================== */
/* 6. VISUALIZATION: BOXPLOT OF RECOVERY RATES                    */
/* ============================================================== */
TITLE "Comparison of Visual Acuity Recovery by Treatment Type";
PROC SGPLOT DATA=analysis_data;
    VBOX Change_in_VAS / CATEGORY=Type_of_Treatment GROUP=Type_of_Treatment;
    YAXIS LABEL="Change in Visual Acuity Score (VAS)";
    XAXIS LABEL="Treatment Modality";
RUN;

/* ============================================================== */
/* 7. NON-PARAMETRIC BACKUP (KRUSKAL-WALLIS)                      */
/* ============================================================== */
TITLE "Kruskal-Wallis Rank Sum Test (Non-parametric)";
PROC NPAR1WAY DATA=analysis_data WILCOXON;
    CLASS Type_of_Treatment;
    VAR Change_in_VAS;
RUN;

/* ============================================================== */
/* ==================== EXTENDED ANALYSIS ======================= */
/* ============================================================== */
DATA extended_data;
    SET analysis_data;
RUN;

/* --- IDEA 3: BASELINE VISION VS RECOVERY (Linear Regression) --- */
TITLE "Linear Regression: Baseline Vision predicting Recovery";
PROC REG DATA=extended_data;
    MODEL Change_in_VAS = First_VAS;
RUN;
QUIT;

TITLE "Does Initial Vision Dictate Recovery Size?";
PROC SGPLOT DATA=extended_data;
    REG X=First_VAS Y=Change_in_VAS / CLM LINEATTRS=(COLOR=BLACK) MARKERATTRS=(COLOR=PURPLE SYMBOL=CIRCLEFILLED);
    YAXIS LABEL="Improvement (Change in VAS)";
    XAXIS LABEL="Initial Vision Score (First VAS)";
RUN;

/* Clear Titles */
TITLE;
