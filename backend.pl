% :- module(pop_a_pill)
:-dynamic getWeekday/7.
%setting up the database
%====================================================================
%:-dynamic
%:-[api].
:- use_module(library(persistency)).

:- persistent pill(name:atom,daysToTake:atom,noOfDoses:integer,timing:integer,
                   stock:integer,purpose:atom,eMonth:integer,eYear:integer).

:- initialization(db_attach('pillsWorld.pl',[])).

register_new_pill:-
    write("Enter name of the pill: "),
    flush_output(current_output),
    readln([Ln0|X]),

    write("Enter the days you want to take the pill: "),
    flush_output(current_output),
    readln(Ln1),

    write("Enter the number of doses needed at once: "),
    flush_output(current_output),
    readln([Ln2|X]),

    write("Enter when you need to take the pill (enter whole numbers 0-23): "),
    flush_output(current_output),
    readln(Ln3),

    write("Enter the number of pills you have: "),
    flush_output(current_output),
    readln([Ln4|X]),

    write("Enter the purpose of taking the pill: "),
    flush_output(current_output),
    readln([Ln5|X]),

    write("Enter the expiration month: "),
    flush_output(current_output),
    readln([Ln6|X]),

    write("Enter the expiration year: "),
    flush_output(current_output),
    readln([Ln7|X]),

    not(isExpired(Ln6,Ln7)),

    %print_pill(Ln0,Ln1,Ln2,Ln3,Ln4,Ln5),

    add_pill(Ln0,Ln1,Ln2,Ln3,Ln4,Ln5,Ln6,Ln7).



% takePill:- (buffer of around 10 minutes on either side to take the pill)



print_pill(Name,Days,Doses,Timing,Stock,Purpose) :-
    write(Name), write(" ("), write(Purpose), writeln(")"),
    write("Take "), write(Doses), write(" doses at once "), write_list(Timing, "/"),  write(" on "), write_list(Days, ", "), write("\n\n").


write_list([], _).
write_list([H], Separator) :- write(H).
write_list([H|R], Separator) :- write(H), write(Separator), write_list(R, Separator).



%Getting Details of a Pill
getPill :-
    write("Enter Pill Name For Details "),
    flush_output(current_output),
    readln([NameP|X]),
    pill(NameP,Days,Doses,Timing,Stock,Purpose,EMonth,EYear),
    Stock>0,
    print_pill(NameP,Days,Doses,Timing,Stock,Purpose).

getPillForPurpose :-
    write("For what do you need the pill "),
    flush_output(current_output),
    readln([Purpose|X]),
    pill(Name,Days,Doses,Timing,Stock,Purpose,EMonth,EYear),
    Stock>0,
    print_pill(Name,Days,Doses,Timing,Stock,Purpose).

getPillForWeekday :-
    write("Enter Weekday for pills for checking pills for that day "),
    flush_output(current_output),
    readln([Days]),
    pill(Name,Days,Doses,Timing,Stock,Purpose,EMonth,EYear),
    Stock>0,
    print_pill(Name,Days,Doses,Timing,Stock,Purpose).

getPillForToday :-
    gettingWeekDay(WD,NameDay),
    pill(NameDay,Days,Doses,Timing,Stock,Purpose,EMonth,EYear),
    Stock>0,
    print_pill(Name,Days,Doses,Timing,Stock,Purpose).    



%RREMOVING PILLS
%Removing pill manually
removePillByName(Name) :-
    with_mutex(pill_db,retractall_pill(Name,_,_,_,_,_,_,_)).

%Removing expired pills
removeExpiredPills:-
    pill(NameP,Days,Doses,Timing,Stock,Purpose,EMonth,EYear),
    isExpired(EMonth,EYear),
    removePill(NameP,Days,Doses,Timing,EMonth,EYear,Stock,Purpose).



%CheckStock
checkStockForAPill :-
    write("Enter the name of the pill that you want the stock "),
    flush_output(current_output),
    readln([NameP|X]),
    pill(NameP,_,NDoses,_,Z,_,_,_),
    isStockAvailable(NameP,NDoses,Z).

checkStockForAll :-
    pill(Name,_,Doses,_,Z,_,_,_),
    isStockAvailable(Name,Doses,Z).



%Manually adding to stock after pharmacy run. Use in main after pharmacy stuff
refill :-
    write("Enter the name of the pill you want to update the stock of "),
    flush_output(current_output),
    readln([NameP|X]),
    pill(NameP,_,_,_,Z,_,_,_),
    write("How many pills would you like to add to the stock? "),
    flush_output(current_output),
    readln([NoP|X]),
    NS is (Z+NoP),
    removePill(NameP,Days,Doses,Timing,Stock,Purpose),
    addPill(NameP,Days,Doses,Timing,NS,Purpose),
    write("Pill successfully added").

%helper functions
%=======================================================================
%TIME & DATE

%Current Time
timeRightNow(Hour,Minute,Second):-
    get_time(TS),
    stamp_date_time(TS,D,local),
    date_time_value(hour,D,H),
    date_time_value(minute,D,M),
    date_time_value(second,D,S).

%Current Day
dateRightNow(Day,Month,Year):-
    get_time(TS),
    stamp_date_time(TS,D,local),
    date_time_value(day,D,Day),
    date_time_value(month,D,Month),
    date_time_value(year,D,Year).

%Current Weekday
gettingWeekDay(WD,NameDay):-
    get_time(TS),
    stamp_date_time(TS,D,local),
    date_time_value(date,D,Date),
    day_of_the_week(Date,WD),
    getWeekday(WD,NameDay).

%Weekday Clauses
getWeekday(1,monday).
getWeekday(2,tuesday).
getWeekday(3,wednesday).
getWeekday(4,thursday).
getWeekday(5,friday).
getWeekday(6,saturday).
getWeekday(7,sunday).



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
add_pill(Name,Days,Doses,Timings,Stock,Purpose,EMonth,EYear) :-
    add_pill_for_all_days(Name,Days,Doses,Timings,Stock,Purpose,EMonth,EYear).

add_pill_for_all_days(_,[],_,_,_,_,_,_).
add_pill_for_all_days(Name,[Day|R],Doses,Timing,Stock,Purpose,EMonth,EYear) :-
    add_pill_for_all_timings(Name,Day,Doses,Timing,Stock,Purpose,EMonth,EYear),
    add_pill_for_all_days(Name,R,Doses,Timing,Stock,Purpose,EMonth,EYear).

add_pill_for_all_timings(_,_,_,[],_,_,_,_).
add_pill_for_all_timings(Name,Day,Doses,[Timing|R],Stock,Purpose,EMonth,EYear) :-
    with_mutex(pill_db,assert_pill(Name,Day,Doses,Timing,Stock,Purpose,EMonth,EYear)),
    add_pill_for_all_timings(Name,Day,Doses,R,Stock,Purpose,EMonth,EYear).



%Removing a pill from the database
removePill(Name,Days,Doses,Timing,EMonth,EYear,Stock,Purpose):-
        with_mutex(pill_db,retract_pill(Name,Days,Doses,Timing,EMonth,EYear,Stock,Purpose)).



%printing best course of action based on current Stocks
isStockAvailable(Name,NoOfDoses,Stock):-
    N is (Stock/NoOfDoses),
    N < 7,
    write("Running Low.See the pharmacy details").
    %add api here maybe hiroki

isStockAvailable(Name,NoOfDoses,Stock):-
    write("The Stock is good enough").
