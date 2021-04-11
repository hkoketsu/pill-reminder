%setting up the database
%====================================================================
%:-dynamic
%:-[api].
:- use_module(library(persistency)).

:- persistent pill(name:atom,daysToTake:atom,noOfDoses:integer,timing:integer,eMonth:integer,eYear:integer,stock:integer,purpose:atom).

:- initialization(db_attach('pillsWorld.pl',[])).

addAPill:-
    write("Enter Name of the Pill   "),
    %flush_output(current_output),
    readln([Ln|X]),

    write("Enter The Days You Want To Take The Pill   "),
    flush_output(current_output),
    readln([Ln1|X]),       %see how you can use the list input to get an array of input days

    write("Enter The No. Of Doses Needed in a day.   "),
    flush_output(current_output),
    readln([Ln2|X]),

    write("Enter The Time/Times You want to take the pill.   "),
    flush_output(current_output),
    readln([Ln3|X]),      %see how you can use the list input to get an array of input timings pills in a day

    write("Enter the Expiration Month   "),
    flush_output(current_output),
    readln([Ln4|X]),

    write("Enter the Expiration Year   "),
    flush_output(current_output),
    readln([Ln5|X]),

    write("Enter the No. of Pills you have.   "),
    flush_output(current_output),
    readln([Ln6|X]),

    write("For what are you taking the pill?   "),
    flush_output(current_output),
    readln([Ln7|X]),

    not(isExpired(Ln4,Ln5)),
    addPill(Ln,Ln1,Ln2,Ln3,Ln4,Ln5,Ln6,Ln7).

% takePill:- (buffer of around 10 minutes on either side to take the pill)

%Getting Details of a Pill
getPill:-
    write("Enter the name of the pill you for which you want the stock "),
    flush_output(current_output),
    readln([NameP|X]),
    pill(NameP,Days,Doses,Timing,EMonth,EYear,Stock,Purpose),
    Stock>0,
    write(NameP),
    %takePillFucntion
    write("is available"),
    write("It is so and so day today") %use oneof here to check if the it is
                                       %todays day number for recommend.
    write("So and so doses are left. Take it around time so")
                                       %adding the feature of comparing current
                                       %timestamps with given time taken and
                                       %updating stocks accordingly
                                       %to be implemented in take function.


%Removing Expired Pills from DataBase
removeExpired:-
    pill(NameP,Days,Doses,Timing,EMonth,EYear,Stock,Purpose),
    isExpired(EMonth,EYear),
    removePill(NameP,Days,Doses,Timing,EMonth,EYear,Stock,Purpose).

%CheckStock
checkStock:-
    write("Enter the name of the pill you for which you want the stock "),
    flush_output(current_output),
    readln([NameP|X]),
    pill(NameP,_,NDoses,_,_,_,Z,_),
    printStockNeeds(NameP,NDoses,Z). %make this part of isAvailable

%Adding To stock
addToStock:-
    write("Enter the name of the pill you want to update the stock of "),
    flush_output(current_output),
    readln([NameP|X]),
    pill(NameP,_,_,_,_,_,Z,_),
    write("How many pills would you like to add to the stock? "),
    flush_output(current_output),
    readln([NoP|X]),
    NS is (Z+NoP),
    removePill(NameP,Days,Doses,Timing,EMonth,EYear,Stock,Purpose),
    addPill(NameP,Days,Doses,Timing,EMonth,EYear,NS,Purpose).
    %print message needs to be added here and made a helper function.

%helper functions
%=======================================================================
%TIME & DATE
timeRightNow(Hour,Minute,Second):-
    get_time(TS),
    stamp_date_time(TS,D,local),
    date_time_value(hour,D,H),
    date_time_value(minute,D,M),
    date_time_value(second,D,S).

dateRightNow(Day,Month,Year):-
    get_time(TS),
    stamp_date_time(TS,D,local),
    date_time_value(day,D,Day),
    date_time_value(month,D,Month),
    date_time_value(year,D,Year).


%CHECKING EXPIRATION DATES FOR PILLS
isExpired(Em,Ey):-
    dateRightNow(D,M,Y),
    Ey<Y,
    write("The pill is expired").

isExpired(Em,Y):-
    dateRightNow(D,M,Y),
    Em<M,
    write("The pill is expired").

%Adding a pill to the database
addPill(Name,Days,Doses,Timing,EMonth,EYear,Stock,Purpose):-
    with_mutex(pill_db,assert_pill(Name,Days,Doses,Timing,EMonth,EYear,Stock,Purpose)).

%Removing a pill from the database
removePill(Name,Days,Doses,Timing,EMonth,EYear,Stock,Purpose):-
    with_mutex(pill_db,retract_pill(Name,Days,Doses,Timing,EMonth,EYear,Stock,Purpose)).

%printing best course of action based on current Stocks
printStockNeeds(Name,NoOfDoses,Stock):-
    N is (Stock/NoOfDoses),
    N < 7,
    write("Better get them pills.").
    %add api here maybe hiroki

printStockNeeds(Name,NoOfDoses,Stock):-
    write("you have enough for now").

%isAvailable():- checking if a pill will be available for sometime
%add printing in this.


%creating a super main function in different file to finalise the flow of
%control for a smooth user interface.
