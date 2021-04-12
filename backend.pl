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


%Update stock of pill
update_stock(Name, NewStock) :- 
    pill(Name,Doses,Stock,Purpose,EMonth,EYear),
    remove_pill(Name),
    add_pill(Name,Doses,NewStock,Purpose,EMonth,EYear).

list_pills_for_today(NameList) :-
    daynum_today(DayNum),
    list_pill_names_for_day(DayNum,NameList).

list_pills_not_taken_today(NameList) :-
    get_pills_for_today(TodayPills),
    list_names_of_pills_token_today(TakenPills),
    remove_list_b_from_list_a(TodayPills, TakenPills, NameList).

list_all_pill_names(L) :- findall(Name,pill(Name,_,_,_,_,_),L).
list_pill_names_for_day(Day,L) :- findall(Name,pill_day(Name,Day),L).

list_days_for_pill(Name,L) :- findall(Day,pill_day(Name,Day),L).
list_timings_for_pill(Name,L) :- findall(Timing,pill_timing(Name,Timing),L).

list_names_of_pills_token_today(L) :- 
    date_today(Y,M,D),
    findall(Name,pill_taken(Name,Y,M,D,_,_)).

%RREMOVING PILLS
%Removing pill manually
remove_pill_by_name(Name) :- remove_pill_from_db(Name).

%Removing expired pills
remove_expired_pills:-
    pill(NameP,_,_,_,EMonth,EYear),
    isExpired(EMonth,EYear),
    remove_pill_from_db(NameP).

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



% Database
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

% Utils
%creating a super main function in different file to finalise the flow of
%control for a smooth user interface.
print_pills_from_name_list([]).
print_pills_from_name_list([Name|R]) :-
    pill(Name,Doses,Stock,Purpose,EMonth,EYear),
    list_days_for_pill(Name,Days),
    list_timings_for_pill(Name,Timings),
    print_pill(Name,Days,Doses,Timing,Stock,Purpose,EMonth,EYear).


print_pill(Name,Days,Doses,Timing,Stock,Purpose,EMonth,EYear) :- 
    write(Name), write(" ("), write(Purpose), writeln(")"),
    write("Take "), write(Doses), write(" doses at once "), write_list(Timing, "/"),  write(" on "), write_list(Days, ", "), write("\n"),
    write("Expires at: "), write(EYear), write("/"), write(EMonth), write("\n\n").

print_pill_stock_from_name_list([]).
print_pill_stock_from_name_list([Name|R]) :-
    pill(Name,_,Stock,_,EMonth,EYear),
    print_pill_stock(Name,Stock,EMonth,EYear),
    print_pill_stock_from_name_list(R).


print_pill_stock(Name,Stock,EMonth,EYear) :-
    pill(Name,Doses,Stock,Purpose,EMonth,EYear),
    write(Name), write(": "), write(Stock), write(" expiring in "), write(EYear), write("/"), write(EMonth).

write_list([], _).
write_list([H], Separator) :- write(H).
write_list([H|R], Separator) :- write(H), write(Separator), write_list(R, Separator).


remove_list_b_from_list_a(A,[],A).
remove_list_b_from_list_a(A,[H|B], AMinusB) :- delete(A, H, AMinusH), remove_list_b_from_list_a(AMinusH, B, AMinusB).

append([],L,L).
append([H|T],L,[H|R]) :- append(T,L,R).