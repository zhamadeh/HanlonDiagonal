########################################################################
							# Packages #
########################################################################
# Install & load tidyr
library("tidyr")
library("ggplot2")
#install.packages("viridis")  
library("viridis") 
args=commandArgs(trailingOnly = T)
#args=c(12,24,24)

########################################################################
						# Building 384w plate #
########################################################################
# Create 384 well plate
index_plate_matrix = matrix(data = 0,nrow = 16,ncol = 24)

# Label plate with 1:24 and A:P
index_plate_df <- expand.grid(x = LETTERS[1:16], y = 1:ncol(index_plate_matrix)) 

# Plate number
index_plate_df$plate=1

# Order wells by position
index_plate_df=index_plate_df[order(index_plate_df$x), ]

# Paste together plate number, column number and row letter
index_plate_df$well=paste0(index_plate_df$plate,index_plate_df$x,index_plate_df$y)

# Store well coordinates in vector
indexes_all=index_plate_df$well




########################################################################
							# Function #
########################################################################

# Input
## Indexes: numerical, how many indexes you want to use
## Rows: numerical, size of desired grid
## Columns: numerical, size of desired grid
## numOfReps: numerical, how many replicates of the same index

hanlonDiagonal = function(indexes, rows, columns){
	
	#Convert to numeric
	columns=as.numeric(columns)
	rows=as.numeric(rows)
	
	# Determine ideal number of replicates to use
	numOfReps=ceiling(as.numeric(columns)/as.numeric(args[1]))
	indexes=indexes[1:(as.numeric(columns)/numOfReps)]
	indexes= rep(indexes,each=numOfReps)
	
	if (length(indexes)!=columns){
		columns=length(indexes)
	}
	message("Using ", length(unique(indexes))," indexes repeated ",numOfReps," times")
	# Create empty matrix
	mat=matrix(nrow = rows,ncol =columns,data = NA)
	
	# Append indexes into matrix, row by row, shifting positions each row
	for (row in 1:nrow(mat)){
		mat[row,]=indexes
		indexes  = c(indexes[length(indexes)],indexes[-(length(indexes))] )
	}

	# Expand matrix into df of x/y coordinates
	mat_df = expand.grid(x = 1:nrow(mat), y = 1:ncol(mat)) 
	
	# Add Z coordinate for well position in 384w plate
	out <- transform(mat_df, z = mat[as.matrix(mat_df)])
	out$x=as.numeric(out$x)
	out$y=as.numeric(out$y)

	# Print ggplot 
	p=ggplot(out,aes(x,y,fill=z)) +
		geom_tile()+
		geom_text(aes(label=z),size=2.5)+
		scale_fill_viridis(discrete = TRUE, option = "D") +
		theme_classic()+
		scale_x_continuous(expand = c(0, 0)) +
		scale_y_continuous(expand = c(0, 0)) +
		theme(panel.grid = element_blank(),
			  panel.border = element_blank(),
			  legend.position="none")+
		labs(x="x-position",y="y-position")
	p
	ggsave(paste0("wafergen_",columns,"x",rows,"_",length(unique(indexes)),"_indexes_",numOfReps,"reps.png"))

	# Change format to match wafergen file format
	out$pos <- paste0(out$x, "/", out$y)
	out$well <- paste0(out$z,",")
	out$vol = paste0(1000,",")
	out=dplyr::select(out,c(pos,well,vol))
	
	# Merge with empty wafergen file
	output= read.table("Input/example_wafergen.txt",fill=T)
	output$V2=""
	output$V3=""
	colnames(output)[1]="pos"
	join=plyr::join(output,out,by="pos")
	join[is.na(join)] <- ""
	final_dataset=dplyr::select(join,c(pos,well,vol))
	
	# Create new filename, copy header file and append new data into file
	filename=paste0("wafergen_",columns,"x",rows,"_",length(unique(indexes)),"_indexes_",numOfReps,"reps.txt")
	file.copy(from = "Input/header_wafergen.txt",to = filename)
	write.table(final_dataset,filename,row.names = F,col.names=F,quote = F,append = T,sep="\t")
}

hanlonDiagonal(indexes=indexes_all[1:args[1]],rows=args[2],columns=args[3])





