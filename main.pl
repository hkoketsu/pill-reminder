:- include('action.pl').

/**
 * Pill reminder app.
 * 
 * What can it do?
 * - 1. register new pill (name, when to take, how much stock do you have)
 * - 2. remove pill from list (by name)
 * - 3. add stocks of pill
 * - 4. list today's pills to take
 * - 5. list stocks
 * - 6. check a pill as 'taken today'
 * - 7. suggest nearby pharmacy if stock is running out
 * 
 */


start :- 
    write("---- Pill Reminder ---- \n\n"),
    write("Type in 'help.' if you want to know what I can do.\n\n"),
    action_remove_expired_pills,
    q.

q :-
    write("Ask a query: "),
    flush_output(current_output),
    readln([Input|_]),
    query(Input).


quit :- write("Finishig the application...").

help :-
    writeln("1 - register new pill"), 
    writeln("2 - remove pill from list"), 
    writeln("3 - add stocks of pill"), 
    writeln("4 - list today's pills to take"), 
    writeln("5 - list stocks"), 
    writeln("6 - list all pills"), 
    writeln("7 - check a pill as 'taken today'"), 
    writeln("8 - suggest nearby pharmacy"),     
    writeln("quit - finish the application\n").

query('quit') :- quit.
query('help') :- help, q.

query(1) :- action_register_new_pill, q.
query(2) :- action_remove_pill, q.
query(3) :- action_add_stock, q.
query(4) :- action_pills_for_today, q.
query(5) :- action_list_stocks, q.
query(6) :- action_list_pills, q.
query(7) :- action_take_pill, q.
query(8) :- action_suggest_pharmacy, q.

query(_) :- writeln("We could not get that, sorry. Please try again."), q.