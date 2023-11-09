/*  */
/*  */
/*  */
/* SETUP FROM PREVIOUS ACTIVITY */
/*  */
/*  */
/*  */
libname BookData "/home/u63548322/my_shared_file_links/blumj/BookData/SASData";
libname RawData '/home/u63548322/my_shared_file_links/blumj/BookData/SomeRawData/';


/* 2005 */
data ipums2005Utility;
  infile '/home/u63548322/my_shared_file_links/blumj/BookData/SomeRawData/Utility Cost 2005.txt' 
  	dlm='09'x dsd firstobs=4;
  input serial electric:comma. gas:comma. water:comma. fuel:comma.;
  format electric gas water fuel dollar.;
run;
 
data All2005;
  merge BookData.ipums2005basic ipums2005Utility;
  by serial;
  if homevalue eq 9999999 then homevalue=.;
  if electric ge 9000 then electric=.;
  if gas ge 9000 then gas=.;
  if water ge 9000 then water=.;
  if fuel ge 9000 then fuel=.;
  year = 2005;
run;


/* 2010 */
data ipums2010Utility;
   infile '/home/u63548322/my_shared_file_links/blumj/BookData/SomeRawData/Utility Costs 2010.csv' 
      firstobs=5 dsd;
   input Serial:comma. Water:comma. Gas:dollar. Electric:comma.  Fuel:comma.;
   if electric ge 9990 then electric = .;
   if Gas ge 9990 then Gas = .;
   if water ge 9990 then water = .;
   if fuel ge 9990 then fuel = .;
   format electric--fuel dollar10.;
   label Electric='Electricity Cost';
   year=2010;
run;

data All2010;
  merge bookdata.ipums2010basic ipums2010utility;
  by serial;
  if HomeValue eq 9999999 then HomeValue = .;
  if HHIncome eq 9999999 then HHIncome = .;
run;


/* 2015 */ 
data ipums2015Utility (drop=electricity);
   infile '/home/u63548322/my_shared_file_links/blumj/BookData/SomeRawData/2015 Utility Cost.dat' 
   		firstobs=8;
   input @1 Serial comma8. @9 Water dollar5. @14 Gas dollar5. 
   		@19 Electricity dollar5. @24 Fuel dollar5.;
   if water ge 9990 then water = .;
   if Gas ge 9990 then Gas = .;
   if electricity ge 9990 then electricity = .;
   if fuel ge 9990 then fuel = .;
   electric = electricity;
   format water--fuel dollar10.;
run;

	/* Get new columns: Serial, Metro, HHIncome */
data ipums2015basicB (drop=SerialID MetroCat Income Population);
	set bookdata.ipums2015basic;
	Serial=input(compbl(SerialID),best.);
	Metro = input(MetroCat,best.);
	HHIncome=input(Income,best.);
	Citypop = population;
	Year=2015;
run;

data All2015;
  merge ipums2015basicB ipums2015Utility;
  by serial;
  if HomeValue eq 9999999 then HomeValue = .;
  if HHIncome eq 9999999 then HHIncome = .;
run;

/* Everything for All Years */
data AllAll;
	set All2005 All2010 All2015;
run;


/*  */
/*  */
/*  */
/* CHAPTER 6 */
/*  */
/*  */
/*  */


/* Output 6.2.1: Electricity Cost Summary Statistics */
proc report data=AllAll;
	where state in ('Connecticut' 'Massachusetts' 'New Jersey' 'New York');
  	column state year electric,(mean median std) ;
  	define State / group 'State';
  	define year / group 'Year';
  	define electric / 'Electricity Cost';
  	define mean / 'Mean' format=dollar12.2;
  	define median / 'Median';
  	define std / 'Std. Dev.';
	break after state / summarize suppress;
run;


/* Output 6.2.2: Home Value Summary Statistics */
proc report data=AllAll;
	where state in ('Connecticut' 'Massachusetts' 'New Jersey' 'New York');
  	column state homevalue,Year,(mean median);
  	define year / across 'Home Value Statistics';
  	define state / group 'State';
  	define homevalue / '';
  	define mean / 'Mean' format=dollar12.;
  	define median / 'Median' format=dollar12.;
run;


/*  */
/*  */
/*  */
/* CHAPTER 7 */
/*  */
/*  */
/*  */

/* Output 7.2.1: Electricity Cost Summary Statistics  */
proc report data=AllAll
	style(header) = [background = cx9999FF color=darkblue fontweight=bold]
	style(column)=[backgroundcolor=grayF3];
	
	where state in ('Connecticut' 'Massachusetts' 'New Jersey' 'New York');
  	
  	column state year electric,(mean median) diff electric,std dummy;
  	
  	define State / group 'State';
  	define year / group 'Year';
  	define electric / '';
  	define mean / 'Mean' format=dollar12.2;
  	define median / 'Median' format=dollar12.2;
  	define std / 'Std. Dev.' format=dollar12.2;
  	define diff / computed 'Diff: Mean - Median' format=dollar12.2;
  	define dummy / computed noprint;
	
	break after state / summarize suppress style=[background=cxDCDCDC];
  	
  	/* Make sure high means are red text Method1 */
/*   	compute diff; */
/*     	diff=electric.mean - electric.median; */
/*     if electric.mean ge (1.25*electric.median)  */
/*     	then call define('_c6_','style','style=[color=cxFF3333]'); */
/*   	endcomp; */
  	
  	/* Make sure high means are red text Method2 */
  	compute diff;
    	diff=_c3_ - _c4_;
    if _c3_ ge (1.25*_c4_) 
    	then call define('_c5_','style','style=[color=orangered]');
  	endcomp;
  	
  	/* alternate coloring the rows */
  	compute dummy;
    if lowcase(_break_) eq 'state' then do;
      c=0;
    end;
      else if _break_ eq '' then do;
        c+1; 
        if mod(c,2) eq 0 then call define(_row_,'style','style=[backgroundcolor=cxDCDCDC]');
      end;
  	endcomp;
  	
  	/* try and fix header */
  	compute before _page_ / 
  		style=[color=darkblue backgroundcolor=cx9999FF fontweight=bold];
    	line 'Electricity Cost';
  	endcomp;
  	
  	/* Add a line after */
  	compute after / style=[color=cxFF3333 backgroundcolor=grayCC just=right];
    	line 'Mean Exceeds Median Value by More than 25%';
  	endcomp;
run;



/* Output 7.2.2: Home Value Summary Statistics */
proc report data=AllAll
	style(header) = [background = gray33 color=white fontweight=bold]
    style(column) = [background = grayEE];

	where state in ('Connecticut' 'Massachusetts' 'New Jersey' 'New York');
	
  	column state homevalue,Year,(mean median) dummy;
  	
  	define year / across 'Home Value Statistics';
  	define state / group 'State' style(column)=[backgroundcolor=cxE5E4E2] ;
  	define homevalue / '';
  	define mean / 'Mean' format=dollar12.;
  	define median / 'Median' format=dollar12.;
  	define dummy / computed noprint;
  	
	compute dummy;
    	if _c2_ ge (1.25*_c3_) 
    	then call define('_c2_','style','style=[color=orangered]');
    	if _c4_ ge (1.25*_c5_) 
    	then call define('_c4_','style','style=[color=orangered]');
    	if _c6_ ge (1.25*_c7_) 
    	then call define('_c6_','style','style=[color=orangered]');
    	if _c6_ ge (1.5*_c7_) 
    	then call define('_c6_','style','style=[color=darkred]');
  	endcomp;


	compute after / style=[color=orangered backgroundcolor=grayCC just=right];
    	line 'Mean Exceeds Median Value by More Than 25%';
  	endcomp;
  	
  	
  	compute after _page_ / style=[color=darkred backgroundcolor=grayCC just=right];
    	line 'Mean Exceeds Median Value by More Than 50%';
  	endcomp;
run;
