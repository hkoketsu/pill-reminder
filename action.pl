:- include('backend.pl').
:- include('api.pl').

action_register_new_pill:-
    write("Enter name of the pill: "),
    flush_output(current_output),
    readln([Name|X]),

    write("Enter the days you want to take the pill: "),
    flush_output(current_output),
    readln(Days),

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

    not(isExpired(EMonth,EYear)),

    add_pill_to_db(Name,Days,Doses,Timings,Stock,Purpose,EMonth,EYear).


action_remove_pill :-
    write("Enter name of the pill to remove: "),
    flush_output(current_output),
    readln([Name|X]),
    remove_pill_by_name(Name).

action_add_stock :-
    write("Enter the name of the pill you want to update the stock of "),
    flush_output(current_output),
    readln([NameP|X]),
    pill(NameP,_,Stock,_,_,_),
    write("How many pills would you like to add to the stock? "),
    flush_output(current_output),
    readln([NoP|X]),
    NS is (Stock+NoP),
    update_stock(Name,NS),
    write("Pill successfully added").

action_pills_for_today :-
    write("Pills for today"),
    list_pills_for_today(NameList),
    print_pills_from_name_list(NameList).

action_list_stocks :-
    list_all_pill_names(NameList),
    print_pill_stock_from_name_list(NameList).

action_take_pill :- 
    write("Enter name of the pill: "),
    flush_output(current_output),
    readln([Name|X]),

    write("Enter what time you took the pill: "),
    flush_output(current_output),
    readln([Time|X]),

    pill_timing(Name,Time),

    write("Remaining stock is "),
    RS is (Stock-1),
    writeln(RS),
    update_stock(Name,RS),
    record_pill_taken(Name,Time).


action_suggest_pharmacy :-
    write("Where are you at?: "),
    flush_output(current_output),
    readln([Location|X]),
    nearby_pharmacy(Location,Pharmacy),
    write("Nearby pharmacy from here is "),
    write(Pharmacy.name),
    write(" on "),
    writeln(Pharmacy.vicinity).