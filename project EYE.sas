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
/* 7 & 8. ONE-WAY ANOVA, LEVENE'S TEST & TUKEY HSD                */
/* ============================================================== */
TITLE "One-Way ANOVA & Tukey HSD Post-Hoc Test";
PROC GLM DATA=analysis_data PLOTS=DIAGNOSTICS;
    CLASS Type_of_Treatment;
    MODEL Change_in_VAS = Type_of_Treatment;
    MEANS Type_of_Treatment / HOVTEST=LEVENE TUKEY;
RUN;
QUIT;

/* ============================================================== */
/* 9. NON-PARAMETRIC BACKUP (KRUSKAL-WALLIS)                      */
/* ============================================================== */
TITLE "Kruskal-Wallis Rank Sum Test (Non-parametric)";
PROC NPAR1WAY DATA=analysis_data WILCOXON;
    CLASS Type_of_Treatment;
    VAR Change_in_VAS;
RUN;

/* ============================================================== */
/* ==================== EXTENDED ANALYSIS ======================= */
/* ============================================================== */

/* PREPARE EXTENDED DATASET */
DATA extended_data;
    SET WORK.IMPORT;
    /* FIX: Changed Age_ back to Age */
    WHERE Change_in_VAS IS NOT MISSING AND First_VAS IS NOT MISSING
          AND Age IS NOT MISSING AND Sex IS NOT MISSING;
RUN;

/* --- IDEA 1: PRE VS POST TREATMENT (Paired T-Test) --- */
TITLE "Paired T-Test: First VAS vs Last VAS";
PROC TTEST DATA=extended_data;
    PAIRED Last_VAS * First_VAS;
RUN;

TITLE "Shift in Visual Acuity Scores: Pre vs Post Treatment";
PROC SGPLOT DATA=extended_data;
    DENSITY First_VAS / TYPE=KERNEL LEGENDLABEL="First VAS" LINEATTRS=(COLOR=RED THICKNESS=2);
    DENSITY Last_VAS / TYPE=KERNEL LEGENDLABEL="Last VAS" LINEATTRS=(COLOR=BLUE THICKNESS=2);
    XAXIS LABEL="Visual Acuity Score (VAS)";
RUN;

/* --- IDEA 2: IMPACT OF AGE ON RECOVERY (Correlation & Regression) --- */
TITLE "Correlation: Age vs Change in VAS";
PROC CORR DATA=extended_data;
    VAR Age Change_in_VAS; /* Changed back to Age */
RUN;

TITLE "Effect of Age on Visual Recovery";
PROC SGPLOT DATA=extended_data;
    REG X=Age Y=Change_in_VAS / CLM LINEATTRS=(COLOR=RED) MARKERATTRS=(COLOR=GREEN SYMBOL=CIRCLEFILLED); /* Changed back to Age */
    YAXIS LABEL="Change in VAS (Recovery)";
    XAXIS LABEL="Patient Age";
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

/* --- IDEA 4: GENDER DIFFERENCES IN RECOVERY (T-Test) --- */
TITLE "T-Test: Male vs Female Recovery";
PROC TTEST DATA=extended_data;
    CLASS Sex;
    VAR Change_in_VAS;
RUN;

TITLE "Visual Acuity Recovery by Gender";
PROC SGPLOT DATA=extended_data;
    VBOX Change_in_VAS / CATEGORY=Sex GROUP=Sex;
    YAXIS LABEL="Change in VAS";
    XAXIS LABEL="Gender";
RUN;

/* Clear Titles */
TITLE;