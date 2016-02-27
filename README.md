# powershell-tidydata
Application of the Tidy Data concept of Hadley Wickham using Powershell lingo.

https://cran.r-project.org/web/packages/tidyr/vignettes/tidy-data.html  
http://vita.had.co.nz/papers/tidy-data.pdf
  
# Commands  
Pivot-Object
Unpivot-Object  
Transform-Member  
Split-Member  
Rename-Member  
Cast-Member  
  
#Pivot-Object  
Allows to transform

| row | column | value |
|-----|--------|-------|
| A   | a | 1 |
| B   | a | 2 |
| C   | a | 3 |
| A   | b | 4 |
| B   | b | 5 |
| C   | b | 6 |
| A   | c | 7 |
| B   | c | 8 |
| C   | c | 9 |  

in to  

| row | a | b | c |
|-----|---|---|---|
| A   | 1 | 4 | 7 |
| B   | 2 | 5 | 8 |
| C   | 3 | 6 | 9 |

#Unpivot-Object  
(melt in Hadley´s words)  
Allows to transform  

| row | a | b | c |
|-----|---|---|---|
| A   | 1 | 4 | 7 |
| B   | 2 | 5 | 8 |
| C   | 3 | 6 | 9 |

in to

| row | column | value |
|-----|--------|-------|
| A   | a | 1 |
| B   | a | 2 |
| C   | a | 3 |
| A   | b | 4 |
| B   | b | 5 |
| C   | b | 6 |
| A   | c | 7 |
| B   | c | 8 |
| C   | c | 9 |
