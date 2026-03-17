data HealthStudy;
    input Gender $ Age_Group $ Diabetes $ Count;
datalines;
Male 20-29 Yes 12
Male 20-29 No 38
Male 30-39 Yes 25
Male 30-39 No 45
Female 20-29 Yes 10
Female 20-29 No 40
Female 30-39 Yes 20
Female 30-39 No 50
;
run;

proc sgplot data=HealthStudy;
vbar Gender /response=Count group=Diabetes groupdisplay=cluster;
xaxis label="Gender";
yaxis label="Number of Individuals";
    title "Bar Chart Showing Diabetes Distribution by Gender";
run;

data BloodPressure;
    input Gender $ SBP;
datalines;
Male 122
Male 135
Male 128
Male 140
Male 138
Male 130
Female 118
Female 125
Female 132
Female 128
Female 120
Female 115
;
run;

/* Create Box Plot */
proc sgplot data=BloodPressure;
vbox SBP / category=Gender;
xaxis label="Gender";
yaxis label="Systolic Blood Pressure (mmHg)";
    title "Box Plot of Systolic Blood Pressure by Gender";
run;

data BloodPressure;
    input Gender $ SBP;
datalines;
Male 122
Male 135
Male 128
Male 140
Male 138
Male 130
Female 118
Female 125
Female 132
Female 128
Female 120
Female 115
;
run;

/* Create Box Plot */
proc sgplot data=BloodPressure;
vbox SBP / category=Gender;
xaxis label="Gender";
yaxis label="Systolic Blood Pressure (mmHg)";
    title "Box Plot of Systolic Blood Pressure by Gender";
run;

data RegressionData;
    input ID Weight SBP;
datalines;
1 55 118
2 60 120
3 65 125
4 70 128
5 75 133
6 80 137
7 85 142
8 90 146
9 95 150
10 100 155
;
run;

/* Step 2: Run Simple Linear Regression */
proc reg data=RegressionData;
    model SBP = Weight;
    title "Simple Linear Regression: SBP vs Weight";
run;

data onewayanova;
input school$score;
datalines;
a 78
a 82
a 80
b 88
b 90
b 85
c 70
c 75
c 72
;
run;
proc anova data=onewayanova;
class school;
model score=school;
run;

data diet;
input diet$exec$wl;
datalines;
v l 2.1
v l 2.5
v h 3.8
v h 4.0
nv l 1.8
nv l 2.0
nv h 3.5
nv h 3.7
;
run;
proc anova data=diet;
class diet exec;
model wl= diet*exec;
run;

data correlation;
input h s;
datalines;
1 10
2 20
3 30
4 40 
5 50
;
run;
proc corr data=correlation;
var h s;
run;


data logistic;
input y x;
datalines;
1 8
1 7
0 2
0 3
1 9
0 1
1 10
0 4
1 6
0 2
;
run;
proc logistic data=logistic;
class y;
model y=x;
run;

data binomal;
n=10;
p=0.5;
x=6;
prob=pdf('binomial',x,p,n);
cprob=cdf('binomial',x,p,n);
run;
proc print data=binomal ;
title'binomial 6 head';
run;

data ancova;
input id meth$ test ptest;
datalines;
1 a 45 55
2 a 42 50 
3 a 40 48
4 b 44 60
5 b 46 62
6 b 43 59
7 c 47 70
8 c 49 72
9 c 48 68
;
run;
proc glm data=ancova;
model ptest=test;
run;

data ttest;
input table fac$ str;
datalines;
1 a 450
2 a 470
3 a 465
4 a 455
5 a 460
6 b 440
7 b 445
8 b 430
9 b 460
10 b 450
;
run;
proc ttest data=ttest;
class fac;
var str;
run;


data chi;
input gen$ per$ count;
datalines;
m y 30
m n 20
f y 40
f n 10
;
run;
proc freq data= chi;
tables gen*per/chisq;
weight count;
run;