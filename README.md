# Hanlon Diagonal 

#### Overview
This is a function for generating diagonal CellenONE dispensing profiles of custom size and number of indexse. 

1. Collect indexes from 384-well plate (integer 1-96)
2. Create custom grid within 5184-well Wafergen chip (square or rectangular, columns x rows)
3. Compute optimal pattern for fitting indexes in custom grid
4. Output plot showing optimal pattern and CellenONE-formatted dispensing program

#### Quick use
Run `Rscript hanlonDiagonal.R [num of indexes] [num of columns] [num of rows] [index chip pattern 1/2]` on command line

#### Example run
![alt text](https://github.com/zhamadeh/HanlonDiagonal/blob/main/wafergen_24x24_24_indexes_1reps.png)
