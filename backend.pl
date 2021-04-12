% :- module(pop_a_pill)

%setting up the database
%====================================================================
%:-dynamic
%:-[api].
:- use_module(library(persistency)).

:- persistent pill(name:atom,daysToTake:atom,noOfDoses:integer,timing:integer,stock:integer,purpose:atom).

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

    write("Enter when you need to take the pill: "),
    flush_output(current_output),
    readln(Ln3),

    write("Enter the number of pills you have: "),
    flush_output(current_output),
    readln([Ln4|X]),

    write("Enter the purpose of taking the pill: "),
    flush_output(current_output),
    readln([Ln5|X]),

    % print_pill(Ln0,Ln1,Ln2,Ln3,Ln4,Ln5),

    add_pill(Ln0,Ln1,Ln2,Ln3,Ln4,Ln5).

% takePill:- (buffer of around 10 minutes on either side to take the pill)


print_pill(Name,Days,Doses,Timing,Stock,Purpose) :- 
    write(Name), write(" ("), write(Purpose), writeln(")"),
    write("Take "), write(Doses), write(" doses at once "), write_list(Timing, "/"),  write(" on "), write_list(Days, ", "), write("\n\n").


write_list([], _).
write_list([H], Separator) :- write(H).
write_list([H|R], Separator) :- write(H), write(Separator), write_list(R, Separator).

%Getting Details of a Pill
get_pill :-
    write("Enter the name of the pill you for which you want the stock "),
    flush_output(current_output),
    readln([NameP|X]),
    pill(NameP,Days,Doses,Timing,Stock,Purpose),
    Stock>0,
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


%Removing Expired Pills from DataBase
removePillByName(Name) :- removePill(Name).

%CheckStock
checkStock :-
    write("Enter the name of the pill that you want the stock "),
    flush_output(current_output),
    readln([NameP|X]),
    pill(NameP,_,NDoses,_,_,_,Z,_),
    printStockNeeds(NameP,NDoses,Z). %make this part of isAvailable

%Adding To stock
refill :-
    write("Enter the name of the pill you want to update the stock of "),
    flush_output(current_output),
    readln([NameP|X]),
    pill(NameP,_,_,_,_,_,Z,_),
    write("How many pills would you like to add to the stock? "),
    flush_output(current_output),
    readln([NoP|X]),
    NS is (Z+NoP),
    removePill(NameP,Days,Doses,Timing,Stock,Purpose),
    addPill(NameP,Days,Doses,Timing,NS,Purpose).
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

%Adding a pill to the database
add_pill(Name,Days,Doses,Timings,Stock,Purpose) :-
    add_pill_for_all_days(Name,Days,Doses,Timings,Stock,Purpose).
add_pill_for_all_days(_,[],_,_,_,_).
add_pill_for_all_days(Name,[Day|R],Doses,Timing,Stock,Purpose) :-
    add_pill_for_all_timings(Name,Day,Doses,Timing,Stock,Purpose),
    add_pill_for_all_days(Name,R,Doses,Timing,Stock,Purpose).

add_pill_for_all_timings(_,_,_,[],_,_).
add_pill_for_all_timings(Name,Day,Doses,[Timing|R],Stock,Purpose) :-
    with_mutex(pill_db,assert_pill(Name,Day,Doses,Timing,Stock,Purpose)),
    add_pill_for_all_timings(Name,Day,Doses,R,Stock,Purpose).


%Removing a pill from the database
removePill(Name) :- with_mutex(pill_db,retractall_pill(Name,_,_,_,_,_)).

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
