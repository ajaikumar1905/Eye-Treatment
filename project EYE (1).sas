OPTIONS VALIDVARNAME=V7; 
%web_drop_table(WORK.IMPORT);
FILENAME REFFILE '/home/u64367354/Finel Data.xlsx';
PROC IMPORT DATAFILE=REFFILE
	DBMS=XLSX
	OUT=WORK.IMPORT;
	GETNAMES=YES;
RUN;
PROC CONTENTS DATA=WORK.IMPORT; RUN;
%web_open_table(WORK.IMPORT);


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