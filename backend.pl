:-dynamic getWeekday/7.
%setting up the database
%====================================================================
%:-dynamic
%:-[api].
:- use_module(library(persistency)).

:- persistent pill(name:atom,noOfDoses:integer,stock:integer,purpose:atom,eMonth:integer,eYear:integer).

:- persistent pill_day(name:atom,day:integer).

:- persistent pill_timing(name:atom,timing:integer).

:- persistent pill_taken(name:atom,year:integer,month:integer,day:integer,dayOfWeek:integer,hour:integer).

:- initialization(db_attach('pillsWorld.pl',[])).



record_pill_taken(Name,Hour) :-
    date_today(Y,M,D),
    daynum_today(DayOfWeek),
    add_pill_taken_to_db(Name,Y,M,D,DayOfWeek,Hour).


%Getting Details of a Pill
get_pill :-
    write("Enter Pill Name For Details "),
    flush_output(current_output),
    readln([NameP|X]),
    pill(NameP,_,Doses,_,Stock,Purpose,EMonth,EYear),
    Stock>0,
    list_days_for_pill(NameP,Days),
    list_timings_for_pill(NameP,Timings),
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


list_pills_for_today(NameList) :-
    daynum_today(DayNum),
    list_pill_names_for_day(DayNum,NameList).

list_pills_not_taken_today(NameList) :-
    get_pills_for_today(TodayPills),
    list_names_of_pills_token_today(TakenPills),
    remove_list_b_from_list_a(TodayPills, TakenPills, NameList).


%RREMOVING PILLS
%Removing pill manually
remove_pill_by_name(Name) :- remove_pill_from_db(Name).

%Removing expired pills
removeExpiredPills:-
    pill(NameP,_,_,_,EMonth,EYear),
    isExpired(EMonth,EYear),
    remove_pill_from_db(NameP).

get_pill :-
    write("Enter the name of the pill that you want the stock "),
    flush_output(current_output),
    readln([NameP|X]),
    pill(NameP,_,Doses,_,Stock,Purpose),
    list_days_for_pill(Name,Days),
    list_timings_for_pill(Name,Timings),
    write(NameP),
    %takePillFucntion
    write("is available"),
    write("It is so and so day today"), %use oneof here to check if the it is
                                       %todays day number for recommend.
    write("So and so doses are left. Take it around time so").
                                       %adding the feature of comparing current
                                       %timestamps with given time taken and
                                       %updating stocks accordingly
                                       %to be implemented in take function.


%Removing Pill from DataBase
remove_pill :- 
    write("Enter the name of the pill to remove: "),
    flush_output(current_output),
    readln([Name|X]),
    removePillByName(Name).

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
add_stock :-
    write("Enter the name of the pill you want to update the stock of "),
    flush_output(current_output),
    readln([NameP|X]),
    pill(NameP,_,_,_,Z,_,_,_),
    readln([Name|X]),
    pill(Name,_,_,_,_,_,Z,_),
    write("How many pills would you like to add to the stock? "),
    flush_output(current_output),
    readln([NoP|X]),
    NS is (Z+NoP),
    removePill(NameP,Days,Doses,Timing,Stock,Purpose),
    addPill(NameP,Days,Doses,Timing,NS,Purpose),
    write("Pill successfully added").
    update_stock(Name,NS).
    %print message needs to be added here and made a helper function.

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
date_today(Year,Month,Year):-
    get_time(TS),
    stamp_date_time(TS,D,local),
    date_time_value(day,D,Day),
    date_time_value(month,D,Month),
    date_time_value(year,D,Year).


%Current Weekday
daynum_today(DayNum) :- date_today(Y,M,D), day_of_the_week(date(Y,M,D),DayNum).

%Weekday Clauses
day(1,"Monday").
day(2,"Tuesday").
day(3,"Wednesday").
day(4,"Thursday").
day(5,"Friday").
day(6,"Saturday").
day(7,"Sunday").


%CHECKING EXPIRATION DATES FOR PILLS
isExpired(Em,Ey):-
    dateRightNow(D,M,Y),
    Ey<Y,
    write("The pill is expired").

isExpired(Em,Y):-
    dateRightNow(D,M,Y),
    Em<M,
    write("The pill is expired").


list_all_pill_names(L) :- findall(Name,pill(Name,_,_,_,_,_),L).
list_pill_names_for_day(Day,L) :- findall(Name,pill_day(Name,Day),L).

list_days_for_pill(Name,L) :- findall(Day,pill_day(Name,Day),L).
list_timings_for_pill(Name,L) :- findall(Timing,pill_timing(Name,Timing),L).

list_names_of_pills_token_today(L) :- 
    date_today(Y,M,D),
    findall(Name,pill_taken(Name,Y,M,D,_,_)).

%Adding a pill to the database
add_pill_to_db(Name,Days,Doses,Timings,Stock,Purpose,EMonth,EYear) :-
    add_pill(Name,Doses,Stock,Purpose,EMonth,EYear),
    add_pill_days(Name,Days),
    add_pill_timings(Name,Timings).

add_pill(Name,Doses,Stock,Purpose,EMonth,EYear) :-
    with_mutex(pill_db,assert_pill(Name,Doses,Stock,Purpose,EMonth,EYear)).

add_pill_days(_,[]).
add_pill_days(Name,[Day|R]) :-
    with_mutex(pill_db,assert_pill_day(Name,Day)),
    add_pill_days(Name,R).

add_pill_timings(_,[]).
add_pill_timings(Name,[Timing|R]) :-
    with_mutex(pill_db,assert_pill_timing(Name,Timing)),
    add_pill_timings(Name,R).

add_pill_taken_to_db(Name,Year,Month,Day,DayOfWeek,Hour) :-
    with_mutex(pill_db,assert_pill_taken(Name,Year,Month,Day,DayOfWeek,Hour)).

%Removing a pill from the database
remove_pill_from_db(Name) :- 
    remove_pill(Name),
    remove_pill_days(Name),
    remove_pill_timings(Name).

remove_pill(Name) :- with_mutex(pill_db,retract_pill(Name,_,_,_,_,_)).
remove_pill_days(Name) :- with_mutex(pill_db,retractall_pill_day(Name,_)).
remove_pill_timings(Name) :- with_mutex(pill_db,retractall_pill_timing(Name,_)).


%Update stock of pill
update_stock(Name, NewStock) :- 
    pill(Name,Doses,Stock,Purpose,EMonth,EYear),
    remove_pill(Name),
    add_pill(Name,Doses,NewStock,Purpose,EMonth,EYear).

%printing best course of action based on current Stocks
isStockAvailable(Name,NoOfDoses,Stock):-
    N is (Stock/NoOfDoses),
    N < 7,
    write("Running Low.See the pharmacy details").
    %add api here maybe hiroki

isStockAvailable(Name,NoOfDoses,Stock):-
    write("The Stock is good enough").
printStockNeeds(Name,NoOfDoses,Stock):-
    write("you have enough for now").

%isAvailable():- checking if a pill will be available for sometime
%add printing in this.


%creating a super main function in different file to finalise the flow of
%control for a smooth user interface.

print_pills_from_name_list([Name|R]) :-
    pill(Name,Doses,Stock,Purpose,EMonth,EYear),
    list_days_for_pill(Name,Days),
    list_timings_for_pill(Name,Timings),
    print_pill(Name,Days,Doses,Timing,Stock,Purpose,EMonth,EYear).


print_pill(Name,Days,Doses,Timing,Stock,Purpose,EMonth,EYear) :- 
    write(Name), write(" ("), write(Purpose), writeln(")"),
    write("Take "), write(Doses), write(" doses at once "), write_list(Timing, "/"),  write(" on "), write_list(Days, ", "), write("\n"),
    write("Expires at: "), write(EYear), write("/"), write(EMonth), write("\n\n").

write_list([], _).
write_list([H], Separator) :- write(H).
write_list([H|R], Separator) :- write(H), write(Separator), write_list(R, Separator).


remove_dups([], []).
remove_dups([H|R],NewR) :- member(H,R), remove_dups(R,NewR).
remove_dups([H|R],[H|NewR]) :- not(member(H,R)), remove_dups(R,NewR).

remove_list_b_from_list_a(A,[],A).
remove_list_b_from_list_a(A,[H|B], AMinusB) :- delete(A, H, AMinusH), remove_list_b_from_list_a(AMinusH, B, AMinusB).