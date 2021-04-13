# pill-reminder

This is a class project of UBC CPSC 312, Functional and Logical Programming. This Prolog application stores pill information in a database file based on user's input. Also, it suggests nearby pharmacy by using Google Place API.

## How to run the application

```
swipl main.pl
?- start.
```

### Google API setting

This application uses Google API for suggesting a nearby pharmacy. To use the function, you need to set your own Google client key in key.pl. 

e.g.
```
key.pl
client_key("AAABBBCCC").
```
