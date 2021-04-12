:- include('backend.pl').
:- include('api.pl').

action_register_new_pill:-
    write("Enter name of the pill: "),
    flush_output(current_output),
    readln([Name|X]),

    write("Enter the days you want to take the pill: "),
    flush_output(current_output),
    readln(Days),
    days_to_dayNums(Days, DayNums),

    write("Enter the number of doses needed at once: "),
    flush_output(current_output),
    readln([Doses|X]),

    write("Enter when you need to take the pill (enter whole numbers 0-23): "),
    flush_output(current_output),
    readln(Timings),

    write("Enter the number of pills you have: "),
    flush_output(current_output),
    readln([Stock|X]),

    write("Enter the purpose of taking the pill: "),
    flush_output(current_output),
    readln([Purpose|X]),

    write("Enter the expiration month: "),
    flush_output(current_output),
    readln([EMonth|X]),

    write("Enter the expiration year: "),
    flush_output(current_output),
    readln([EYear|X]),

    add_pill_to_db(Name,DayNums,Doses,Timings,Stock,Purpose,EMonth,EYear),

    writeln("Registration completed.\n").


action_remove_pill :-
    write("Enter name of the pill to remove: "),
    flush_output(current_output),
    readln([Name|_]),
    remove_pill_by_name(Name),
    writeln("Removal completed.\n").


action_add_stock :-
    write("Enter the name of the pill you want to update the stock of "),
    flush_output(current_output),
    readln([Name|_]),
    pill(Name,_,Stock,_,_,_),
    write("How many pills would you like to add to the stock? "),
    flush_output(current_output),
    readln([NoP|_]),
    NS is (Stock+NoP),
    update_stock(Name,NS),
    writeln("Stock successfully added.\n").


action_pills_for_today :-
    writeln("--- Pills for today ---"),
    list_pills_for_today(NameList),
    print_pills_from_name_list(NameList),
    
    list_pills_taken_today(TakenList),
    not(member(_,TakenList)).

action_pills_for_today :-
    writeln("--- Pills for today ---"),
    list_pills_for_today(NameList),
    print_pills_from_name_list(NameList),

    list_pills_taken_today(TakenList),
    writeln("You have already taken"),
    print_pills_taken(TakenList). 


action_list_pills :-
    list_all_pill_names(NameList),
    print_pills_from_name_list(NameList).


action_list_stocks :-
    list_all_pill_names(NameList),
    print_pill_stock_from_name_list(NameList).


action_take_pill :- 
    write("Enter name of the pill: "),
    flush_output(current_output),
    readln([Name|_]),

    write("Enter what time you took the pill: "),
    flush_output(current_output),
    readln([Time|_]),

    pill_timing(Name,Time),
    pill(Name,_,Stock,_,_,_),

    write("Remaining stock of "), write(Name), write(" is "),
    RS is (Stock-1),
    writeln(RS),
    update_stock(Name,RS),
    record_pill_taken(Name,Time).


action_suggest_pharmacy :-
    write("Where are you at?: "),
    flush_output(current_output),
    readln([Location|_]),
    nearby_pharmacy(Location,Pharmacy),
    write("Nearby pharmacy from here is "),
    write(Pharmacy.name),
    write(" on "),
    writeln(Pharmacy.vicinity).

action_remove_expired_pills :-
    list_all_pill_names(NameList),
    remove_expired_pills(NameList).