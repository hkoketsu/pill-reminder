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
    pill(Name,Doses,_,Purpose,EMonth,EYear),
    remove_pill(Name),
    add_pill(Name,Doses,NewStock,Purpose,EMonth,EYear).

list_pills_for_today(NameList) :-
    daynum_today(DayNum),
    list_pill_names_for_day(DayNum,NameList).


list_all_pill_names(L) :- findall(Name,pill(Name,_,_,_,_,_),L).
list_pill_names_for_day(Day,L) :- findall(Name,pill_day(Name,Day),L).

list_days_for_pill(Name,L) :- findall(Day,pill_day(Name,Day),L).
list_timings_for_pill(Name,L) :- findall(Timing,pill_timing(Name,Timing),L).

list_pills_taken_today(L) :- 
    date_today(Y,M,D),
    findall((Name, Hour),pill_taken(Name,Y,M,D,_,Hour),L).

%RREMOVING PILLS
%Removing pill manually
remove_pill_by_name(Name) :- remove_pill_from_db(Name).

%Removing expired pills
remove_expired_pills([]).
remove_expired_pills([Name|R]) :-
    pill(Name,_,_,_,EMonth,EYear),
    isExpired(EMonth,EYear),
    remove_pill_from_db(Name),
    remove_expired_pills(R).

remove_expired_pills([Name|R]) :-
    pill(Name,_,_,_,EMonth,EYear),
    not(isExpired(EMonth,EYear)),
    remove_expired_pills(R).

%CHECKING EXPIRATION DATES FOR PILLS
isExpired(_,Ey):-
    date_today(Y,_,_),
    Ey<Y.
isExpired(Em,Ey):-
    date_today(Y,M,_),
    Ey=:=Y,
    Em<M.

%helper functions
%=======================================================================
%TIME & DATE

%Current Time
timeRightNow(Hour,Minute,Second):-
    get_time(TS),
    stamp_date_time(TS,D,local),
    date_time_value(hour,D,Hour),
    date_time_value(minute,D,Minute),
    date_time_value(second,D,Second).

%Current Day
date_today(Year,Month,Day):-
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


% Database
%Adding a pill to the database
add_pill_to_db(Name,Days,Doses,Timings,Stock,Purpose,EMonth,EYear) :-
    not(isExpired(EMonth,EYear)),
    add_pill(Name,Doses,Stock,Purpose,EMonth,EYear),
    add_pill_days(Name,Days),
    add_pill_timings(Name,Timings).

add_pill_to_db(_,_,_,_,_,_,EMonth,EYear) :-
    isExpired(EMonth,EYear),
    writeln("Sorry, the pill is expired and cannot be registered.").

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
    remove_pill_timings(Name),
    remove_pill_taken(Name).

remove_pill(Name) :- with_mutex(pill_db,retract_pill(Name,_,_,_,_,_)).
remove_pill_days(Name) :- with_mutex(pill_db,retractall_pill_day(Name,_)).
remove_pill_timings(Name) :- with_mutex(pill_db,retractall_pill_timing(Name,_)).
remove_pill_taken(Name) :- with_mutex(pill_db,retractall_pill_taken(Name,_,_,_,_,_)).



%printing best course of action based on current Stocks
% isStockAvailable(Name,NoOfDoses,Stock):-
%     N is (Stock/NoOfDoses),
%     N < 7,
%     write("Running Low.See the pharmacy details").
%     %add api here maybe hiroki

% isStockAvailable(Name,NoOfDoses,Stock):-
%     write("The Stock is good enough").
% printStockNeeds(Name,NoOfDoses,Stock):-
%     write("you have enough for now").

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
    print_pill(Name,Days,Doses,Timings,Stock,Purpose,EMonth,EYear),
    print_pills_from_name_list(R).

print_pill(Name,Days,Doses,Timings,Stock,Purpose,EMonth,EYear) :- 
    write(Name), write(" ("), write(Purpose), write("), Stock: "), writeln(Stock),
    write("Take "), write(Doses), write(" doses at once at "), write_list(Timings, ", "),  write(" on "), write_daynum_list(Days, ", "), write("\n"),
    write("Expires at: "), write(EYear), write("/"), write(EMonth), write("\n\n").

print_pill_stock_from_name_list([]).
print_pill_stock_from_name_list([Name|R]) :-
    pill(Name,_,Stock,_,EMonth,EYear),
    print_pill_stock(Name,Stock,EMonth,EYear),
    print_pill_stock_from_name_list(R).

print_pills_to_take([]).
print_pills_to_take([Name|R]) :-
    pill_timing(Name,Time),
    write(Name), write(" at "), writeln(Time),
    print_pills_to_take(R).

print_pills_taken([]).
print_pills_taken([(Name,Time)|R]) :-
    write(Name), write(" at "), writeln(Time),
    print_pills_to_take(R).


print_pill_stock(Name,Stock,EMonth,EYear) :-
    write(Name), write(": "), write(Stock), write(" ,expiring in "), write(EYear), write("/"), writeln(EMonth).

write_list([], _).
write_list([H], _) :- write(H).
write_list([H|R], Separator) :- write(H), write(Separator), write_list(R, Separator).

write_daynum_list([], _).
write_daynum_list([DayNum], _) :- day(DayNum, Day), write(Day).
write_daynum_list([DayNum|R], Separator) :- day(DayNum, Day), write(Day), write(Separator), write_daynum_list(R, Separator).

remove_list_b_from_list_a(A,[],A).
remove_list_b_from_list_a(A,[H|B], AMinusB) :- delete(A, H, AMinusH), remove_list_b_from_list_a(AMinusH, B, AMinusB).

append([],L,L).
append([H|T],L,[H|R]) :- append(T,L,R).