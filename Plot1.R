# Download and save file
sourceFile <- "https://d396qusza40orc.cloudfront.net/exdata%2Fdata%2Fhousehold_power_consumption.zip"
destination <- "zipArchive"
download.file(sourceFile, destination, mode="wb") # Download file
unzip("zipArchive") # Extract zip archive from the current working directory

# Read raw data - over 2 M records (2,075,259)
datRaw <- read.csv("household_power_consumption.txt", 
                   header = TRUE, 
                   sep=';',
                   stringsAsFactors = FALSE)

# Condition Data: Format dates and times
DT <- as.data.table(datRaw)
DT[, Time := paste(Date, Time, sep=" ")]
DT[, Date := as.Date(Date, format="%d/%m/%Y")]
DT[, Time := as.POSIXct(as.character(Time), format="%d/%m/%Y %H:%M:%S")]
DT[,lapply(.SD, class)]

setkey(DT, Date)

# Condition Data: Subset and convert strings to numbers
day01 <- as.Date("2007-02-01", format="%Y-%m-%d")
day02 <- as.Date("2007-02-02", format="%Y-%m-%d")
DT_ <- DT[Date %in% c(day01, day02)]
DT_[, Global_active_power := as.numeric(Global_active_power)]
DT_[, 4:9 := lapply(.SD, as.numeric), .SDcols=4:9]

# Plot 1
png("Plot1.png", 480, 480)
DT_[, hist(Global_active_power, col="red", 
                                xlab="Global Active Power (kilowatts)",
                                ylab="Frequency",
                                main="Global Active Power")]

dev.off()
