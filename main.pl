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
    q.

q :-
    write("Ask a query: "),
    flush_output(current_output),
    readln(Ln),
    query(Ln).


query(['quit']) :- quit.
query(['help']) :- help, q.
query(Query) :- answer(Query), q.

quit :- write("Finishig the application...").

help :-
    write("quit - finish the application\n"). % TODO

query(['1']) :- action_register_new_pill.
query(['2']) :- action_remove_pill.
query(['3']) :- action_add_stock.
query(['4']) :- action_pills_for_today.
query(['5']) :- action_list_stocks.
query(['6']) :- action_take_pill.
query(['7']) :- action_suggest_pharmacy.