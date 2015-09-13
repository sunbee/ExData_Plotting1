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

# Plot 4
png("Plot4.png", 480, 480)
defaults <- par()
par(mfrow=c(2,2), mar=c(4, 4, 4, 4))
DT_[, plot(Time, Global_active_power, type="l", xlab="", ylab="Global Active Power") ]
DT_[, plot(Time, Voltage, type="l", xlab="datetime", ylab="Voltage") ]
DT_[, {plot(Time, Sub_metering_1, type="n", ylab="Energy sub metering", xlab="");
       legend("topright", lty=c(1,1,1), 
              legend=c("Sub_metering_1", "Sub_metering_2", "Sub_metering_3"), 
              lwd=c(2.5,2.5,2.5),
              col=c("gray", "green", "blue"),
              cex=0.75, bty="n");
       lines(Time, Sub_metering_1, col="gray");
       lines(Time, Sub_metering_2, col="green");
       lines(Time, Sub_metering_3, col="blue")} ]
DT_[, plot(Time, Global_reactive_power, type='l', 
           xlab="datetime", ylim=c(0, 0.5))]
par <- defaults
dev.off()