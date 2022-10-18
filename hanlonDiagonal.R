########################################################################
							# Packages #
########################################################################
# Install & load tidyr
library("tidyr")
library("ggplot2")
#install.packages("viridis")  
library("viridis") 
args=commandArgs(trailingOnly = T)

########################################################################
							# Function #
########################################################################

# Input
## Indexes: numerical, how many indexes you want to use
## Rows: numerical, size of desired grid
## Columns: numerical, size of desired grid
## numOfReps: numerical, how many replicates of the same index
indexes_all=as.character(read.table(paste0("Input/384well_",args[4],".txt"),header = F)$V1)

hanlonDiagonal = function(indexes, rows, columns){
	
	#Convert to numeric
	columns=as.numeric(columns)
	rows=as.numeric(rows)
	
	# Determine ideal number of replicates to use
	numOfReps=ceiling(as.numeric(columns)/as.numeric(args[1]))
	if ((columns %% 2) != 0){
		indexes=indexes[1:((as.numeric(columns)/numOfReps)+1)]
		indexes= rep(indexes,each=numOfReps)
		
	} else{
		indexes=indexes[1:(as.numeric(columns)/numOfReps)]
		indexes= rep(indexes,each=numOfReps)
	}
	
	message("Using ", length(unique(indexes))," indexes repeated ",numOfReps," times")
	# Create empty matrix
	mat=matrix(nrow = rows,ncol=columns,data = NA)
	
	# Append indexes into matrix, row by row, shifting positions each row
	for (row in 1:nrow(mat)){
		mat[row,]=indexes[1:ncol(mat)]
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
	out$vol = paste0(2400,",")
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
	filename=paste0("wafergen_",columns,"x",rows,"_",length(unique(indexes)),"_indexes_",numOfReps,"reps.fld")
	file.copy(from = "Input/header_wafergen.txt",to = filename)
	write.table(final_dataset,filename,row.names = F,col.names=F,quote = F,append = T,sep="\t")
}

hanlonDiagonal(indexes=indexes_all[1:args[1]],rows=args[2],columns=args[3])






