########################################################################
# Building 384w plate #
########################################################################
# Create 384 well plate
index_plate_matrix = matrix(data = 0,nrow = 16,ncol = 24)

# Label plate with 1:24 and A:P
index_plate_df <- expand.grid(x = LETTERS[c(1,3,5,7,9,11,13,15)], y = c(1,3,5,7,9,11,13,15,17,19,21,23)) 

# Plate number
index_plate_df$plate=1

# Order wells by position
index_plate_df=index_plate_df[order(index_plate_df$x), ]

# Paste together plate number, column number and row letter
index_plate_df$well=paste0(index_plate_df$plate,index_plate_df$x,index_plate_df$y)

# Store well coordinates in vector
indexes_all=index_plate_df$well

write.table(as.data.frame(indexes_all),"Input/384well_pattern_1.txt",row.names = F,col.names=F,quote = F,append = F,sep="\t")

########################################################################
# Building 384w plate #
########################################################################
# Create 384 well plate
index_plate_matrix = matrix(data = 0,nrow = 16,ncol = 24)

# Label plate with 1:24 and A:P
index_plate_df <- expand.grid(x = LETTERS[c(1,3,5,7,9,11,13,15)], y = c(1,3,5,7,9,11,13,15,17,19,21,23)) 

# Plate number
index_plate_df$plate=1

# Order wells by position
index_plate_df=index_plate_df[order(index_plate_df$y), ]

# Paste together plate number, column number and row letter
index_plate_df$well=paste0(index_plate_df$plate,index_plate_df$x,index_plate_df$y)

# Store well coordinates in vector
indexes_all=index_plate_df$well
write.table(as.data.frame(indexes_all),"Input/384well_pattern_2.txt",row.names = F,col.names=F,quote = F,append = F,sep="\t")

