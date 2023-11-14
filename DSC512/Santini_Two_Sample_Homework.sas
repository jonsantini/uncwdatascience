%let rc=%sysfunc(dlgcdir('/home/u63548322/SantiniFiles'));
options nodate pageno=1;
ods pdf file='Two Sample Exercise Homework.pdf';

data races;
set ipedsdat.graduationextended;
by unitid;
cohortW = lag1(grwhitt);
cohortNW = lag1(sum(graiant,grasiat,grbkaat,grhispt,grnhpit,gr2mort,grunknt));
if last.unitid and last.unitid ne first.unitid;
rateW = grwhitt/cohortw;
rateNW = sum(graiant,grasiat,grbkaat,grhispt,grnhpit,gr2mort,grunknt)/cohortNW;
output;
format rateW rateNW percentn8.2;
keep unitid rateW rateNW cohortW cohortNW;
run;

ods select none;
ods graphics off;
proc ttest data=races;
paired ratew*ratenw;
ods output ttests=test1a conflimits=ci1a;
run;

data use1;
  merge test1a ci1a;
run;

ods select all;
ods startpage=off;
proc odstext;
h 
'Problem 1'
      / style=[font_size=14pt];
h 
'All Institutions'
      / style=[font_size=12pt];
p 
'For the average graduation rate across all institutions (based on completion within 150% of time), the following table
 gives a confidence interval and test for a difference between whites and nonwhites in average graduation rates.'
      / style=[font_size=12pt];
run;

proc report data=use1
  style(column) = [just=center cellwidth=1.25in];
  column ('Difference in Graduation Rates: (Whites-Nonwhites)' lowerCLmean mean upperCLmean)
          ('T-test for Ho: No Difference' tvalue probt);
  define lowerCLmean / display 'Lower 95% Limit';
  define mean / display;
  define upperCLmean / display 'Upper 95% Limit';
  define tvalue / display 'T Statistic';
  define probt / display 'p-value';
  format lowerCLmean mean upperCLmean percentn9.3;
run;

proc odstext;
p 
'The difference between graduation rates is highly significant (p-value < 0.0001), with graduation rates for whites being higher
 by 8.66% +/- 0.79% (with 95% confidence)'
      / style=[font_size=12pt];
run;


ods select none;
ods graphics off;
proc ttest data=races;
  where sum(cohortw, cohortnw) ge 500;
  paired ratew*ratenw;
  ods output ttests=test1c conflimits=ci1c;
run;

data use1c;
  merge test1c ci1c;
run;

ods select all;
proc odstext;
h
' '
      / style=[font_size=12pt];
h 
'Cohorts of at least 500 people'
      / style=[font_size=12pt];
p
'For the average graduation rate across institutions with an incoming cohort of at least 500 individuals, the following table
 gives a confidence interval and test for a difference between whites and nonwhites in average graduation rates.'
      / style=[font_size=12pt];
run;

proc report data=use1c
  style(column) = [just=center cellwidth=1.25in];
  column ('Difference in Graduation Rates: (whites-nonwhites)' lowerCLmean mean upperCLmean)
          ('T-test for Ho: No Difference' tvalue probt);
  define lowerCLmean / display 'Lower 95% Limit';
  define mean / display;
  define upperCLmean / display 'Upper 95% Limit';
  define tvalue / display 'T Statistic';
  define probt / display 'p-value';
  format lowerCLmean mean upperCLmean percentn9.3;
run;

proc odstext;
p
'The difference between graduation rates is highly significant (p-value < 0.0001), with graduation rates for whites being higher
 by 7.58%% +/- 0.66% (with 95% confidence)'
      / style=[font_size=12pt];
run;

proc format;
  value atLeastSixty
   low - < 0.6 = 'Under 60%'
   0.6 - high = '60% or more'
   ;
run;

ods graphics off;
ods noproctitle;
proc odstext;
h
' '
      / style=[font_size=12pt];
h
'Graduation rates of at least 60%'
      / style=[font_size=12pt];
p 
'For institutions with an incoming cohort of at least 500 people, the following table
 gives a test for the difference in proportion of instituitions with graduation rates
 of 60% or more for whites and nonwhites.'
      / style=[font_size=12pt];
run;

proc freq data=races(rename=(rateW='Rate for Whites'n
                                rateNW='Rate for NonWhites'n));
  where sum(cohortw, cohortnw) ge 500;
  table 'Rate for Whites'n*'Rate for NonWhites'n / agree norow nocol;
  format 'Rate for Whites'n 'Rate for NonWhites'n atLeastSixty.;
  ods select crosstabfreqs McNemarsTest;
run;

proc odstext;
p 
'The difference in the proportion of institutions with graduation rates of over 60% for whites vs nonwhites is highly significant
 (p-value < 0.0001), the estimated difference is 22.12% (64.37% - 42.25%)'
      / style=[font_size=12pt];
run;

/***Exercise 2**/

proc format cntlin=ipedsdat.ipedsformats;
run;

data rates;
set ipedsdat.graduation;
by unitid;
incoming = lag1(total);
if last.unitid and last.unitid ne first.unitid;
gradrate = total/incoming;
output;
format gradrate percentn8.2;
keep unitid incoming gradrate;
run;

proc format;
	value hloffer
	0 = 'No Doctoral'
	1 = 'Doctoral'
	;
run;

data doctoral(keep=unitid incoming gradrate hloffer);
merge rates(in=inrates) ipedsdat.characteristics;
by unitid;
if hloffer = 9 then hloffer = 1;
else hloffer = 0;
if inrates then output;
format hloffer hloffer.;
run;

proc ttest data=doctoral order=formatted;
	class hloffer;
	var gradrate;
	ods output confLimits=CI2 TTests=tests2;
run;

proc sql;
  create table use2 as
  select *
  from CI2 inner join tests2 
    on ci2.method eq tests2.method
  where ci2.method contains 'Satt'
  ;
quit;


ods select all;
ods startpage=now;
proc odstext;
h 
'Problem 2'
      / style=[font_size=14pt];
h 
'All Institutions'
      / style=[font_size=12pt];
p
'For the average graduation rate across all institutions (based on completion within 150% of time), the following table
 gives a confidence interval and test for a difference between institutions that offer doctoral degrees and those that do not in average graduation rates.'
      / style=[font_size=12pt];
run;

ods startpage=off;
proc report data=use2
  style(column) = [just=center cellwidth=1.25in];
  column ('Difference in Graduation Rates: (Doctoral - No Doctoral)' lowerCLmean mean upperCLmean)
          ('T-test for Ho: No Difference' tvalue probt);
  define lowerCLmean / display 'Lower 95% Limit';
  define mean / display;
  define upperCLmean / display 'Upper 95% Limit';
  define tvalue / display 'T Statistic';
  define probt / display 'p-value';
  format lowerCLmean mean upperCLmean percentn9.3;
run;

proc odstext;
p 
'The difference between graduation rates is highly significant (p-value < 0.0001), with graduation rates for doctoral institutions
 being higher by 8.27% +/- 1.77% (with 95% confidence)'
      / style=[font_size=12pt];
run;

proc ttest data=doctoral order=formatted;
  var gradrate;
  class hloffer;
  where incoming ge 500;
  ods output confLimits=CI2c TTests=tests2c;
run;

proc sql;
  create table use2c as
  select *
  from CI2c inner join tests2c 
    on ci2c.method eq tests2c.method
  where ci2c.method contains 'Satt'
  ;
quit;


ods select all;
proc odstext;
h
' '
      / style=[font_size=12pt];
h
'Cohorts of at least 500 people'
      / style=[font_size=12pt];
p 
'For the average graduation rate across institutions with an incoming cohort of at least 500 students, the following table
 gives a confidence interval and test for a difference between institutions that offer doctoral degrees and those that do not in average graduation rates.'
      / style=[font_size=12pt];
run;

proc report data=use2c
  style(column) = [just=center cellwidth=1.25in];
  column ('Difference in Graduation Rates: (Doctoral - No Doctoral)' lowerCLmean mean upperCLmean)
          ('T-test for Ho: No Difference' tvalue probt);
  define lowerCLmean / display 'Lower 95% Limit';
  define mean / display;
  define upperCLmean / display 'Upper 95% Limit';
  define tvalue / display 'T Statistic';
  define probt / display 'p-value';
  format lowerCLmean mean upperCLmean percentn9.3;
run;

proc odstext;
p 
'The difference between graduation rates is highly significant (p-value < 0.0001), with graduation rates for doctoral institutions
 being higher by 3.27% +/- 2.96% (with 95% confidence)'
      / style=[font_size=12pt];
run;

proc format;
  value atLeastSeventy
   low - < 0.7 = 'Under 70%'
   0.7 - high = '70% or more'
   ;
run;

ods select none;
proc freq data=doctoral(rename=(hloffer='Doctoral or No Doctoral'n gradrate='Graduation Rate'n));
  where incoming ge 500;
  table 'Doctoral or No Doctoral'n*'Graduation Rate'n / chisq riskdiff nopercent nocol;
  format 'Graduation Rate'n atLeastSeventy.;
  ods output chisq=indep RiskDiffCol2=CIDiff;
run;

proc sql;
  create table use2d as
  select * 
  from CIDiff, indep
  where substr(statistic,1,3) eq 'Chi' and row = 'Difference'
  ;
run;

ods select all;
proc odstext;
h
' '
      / style=[font_size=12pt];
h 
'Graduation rates of at least 70%'
      / style=[font_size=12pt];
p 
'For institutions with an incoming cohort of at 500, the following table
 give a test and a confidence interval for the difference in proportion for institutions that offer doctoral degrees and
 those that do not with graduation rates of 70% or more.'
      / style=[font_size=12pt];
run;

proc report data=use2d
  style(column) = [just=center cellwidth=1.25in];
  column ('Difference in Proportion with 50%+ Graduation Rates: (Doctoral - No doctoral)' lowerCL risk upperCL)
          ('T-test for Ho: No Difference' value prob);
  define lowerCL / display 'Lower 95% Limit';
  define risk / display 'Difference';
  define upperCL / display 'Upper 95% Limit';
  define value / display 'Chi-Square Statistic';
  define prob / display  'p-value';
  format lowerCL risk upperCL percentn9.3;
run;

proc odstext;
p 
'The difference in the proportion of doctoral vs. non doctoral institutions with graduation rates of over 70% and incoming cohort of at least 500 people
 is insignificant (p-value = 0.7335), we cannot conclude there is a difference in graduation rates of institutions that offer doctoral degrees and those that do not
 with incoming cohort sizes of at least 500 people'
      / style=[font_size=12pt];
run;
ods pdf close;