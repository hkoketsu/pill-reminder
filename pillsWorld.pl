created(1618080921.319079).
assert(pill(advil,monday,2,2,5,2022,10,headache,1000)).
assert(pill(adviltwo,mon,2,2,3,2020,2,headache)).
assert(pill(advilfour,mon,2,2,4,2021,2,head)).
retract(pill(advilfour,mon,2,2,4,2021,2,head)).
assert(pill(advilNew,mon,2,2,5,2021,5,head)).
retract(pill(advilNew,mon,2,2,5,2021,5,head)).
assert(pill(advilStock,mon,2,2,5,2021,5,head)).
retract(pill(advilStock,mon,2,2,5,2021,5,head)).
assert(pill(advilF,mon,2,2,5,3021,5,heady)).
retract(pill(advilF,mon,2,2,5,3021,5,heady)).
assert(pill(advilF,mon,2,2,5,3021,7,heady)).
retract(pill(advilF,mon,2,2,5,3021,7,heady)).
assert(pill(advilF,mon,2,2,5,3021,8,heady)).
retract(pill(advilF,mon,2,2,5,3021,8,heady)).
assert(pill(advilF,mon,2,2,5,3021,18,heady)).