#!/bin/bash 
# HPE Aruba TAC ALE data capture script  - contact David Hardaker (hardaker@hpe.com)
# Not officially supported / maintained by HPE Aruba Networks
# For HPE Aruba TAC use only
# ©HPE Aruba 2018 - All rights reserved 
# ----------------------------------------------------------------------------------

# get filename for results
# ----------------------------------------
# file saved as /tmp/<filename.csv>
# csv file format:
##################################################
# <Name> Events                                  #
#                                                #
# yyyy-mm-dd,timestamp1,timestamp2,timestamp_n   #
# yyyy-mm-dd,timestamp1,timestamp2,timestamp_n   #
#                                                #
##################################################

function DestinationFile
{
   ls -lah /tmp/*.csv
   echo ""
   echo "*** Destination directory is /tmp ***"
   echo "--------------------------------------"
   echo ""
   printf "Please enter destination filename: "
       read -r "DstFile"
       FILENAME=$(echo "/tmp/$DstFile.csv") 2>&1
       echo ""
       echo "Destination file PATH is $FILENAME"
       echo "--------------------------------------"
       echo ""
}

# function DateValidation check date format (yyyy-mm-dd) and that not future date  
# -------------------------------------------------------------------------------

function DateValidation()
{
   if [[ ! $1 =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
     echo "Date $1 invalid format (not yyyy-mm-dd)"
     exit
     else
       DateCheck=$(echo $1 | sed -r 's/-//g')           #convert date format to yyyymmdd
       DateToday=$(echo `date +%F` |  sed -r 's/-//g')  #grab today's date convert to yyyymmdd
          if [ "$DateToday" -le "$DateCheck" ]; then
             echo "Future Datestamps not allowed"
             exit
             else
               echo "$1 ok"
               echo ""
          fi
   fi
}

# function DateRange calculate all the dates in the range
# ------------------------------------

function DateRange() 
{
  DateCount=0
  a1[0]=$StartDate
    while [[ ! $StartDate = $EndDate ]]; do
      StartDate=$(date -d "$StartDate + 1 day" +%F)
      ((DateCount++))
      a1[$DateCount]=$StartDate
      DateCountTotal=$DateCount
    done

  DateCountTotal=`expr $DateCount + 1`
  echo "Total dates to be queried are $DateCountTotal"
  echo ""
  echo ""

  # Convert all the dates in the range to REGEX for subsequent log queries
  # ----------------------------------------------------------------------

  LogArrayCount=0
  a1size=$(echo ${#a1[@]})
    while [[ ! $LogArrayCount = $a1size ]]; do
      StartDate=$(echo ${a1[$LogArrayCount]})
      Year=$(echo ${StartDate:0:4} | sed 's/^.\{4\}/&\\/')
      MonthDay=$(echo ${StartDate:4:7} | sed 's/^.\{3\}/&\\/')
      LogDate=$(echo $Year$MonthDay)   # rewrite date as REGEX to $LogDate
      a2[$LogArrayCount]=$LogDate      # write LogDate to array a2
      ((LogArrayCount++))
    done
}
				   
# function UserDateSelection allows user to select non-contiguous dates
# ---------------------------------------------------------------------

function UserDateSelection()
{
   printf "Number of date ranges to be queried: "
       read -r "MaxDates"
   MaxDatesZerobased=`expr $MaxDates - 1`
   NumDates=0
   while [ $NumDates -le $MaxDatesZerobased ]
   do
       printf "Enter date (format yyyy-mm-dd): "
       read -r "DateStamp"

  # validate datestamp is format (yyyy-mm-dd) && is a valid DATE
  # ------------------------------------------------------------

      if [[ $DateStamp =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]] && date -d "$DateStamp" >/dev/null; then
          a1[$NumDates]=$DateStamp
          year=$(echo ${DateStamp:0:4} | sed 's/^.\{4\}/&\\/')
          monthday=$(echo ${DateStamp:4:7} | sed 's/^.\{3\}/&\\/')
          LogDate=$(echo $year$monthday)      # rewrite $DateStamp as REGEX to VAR $LogDate
          a2[$NumDates]=$LogDate             # write $LogDate to array a2
          ((NumDates++))
          else
             echo "Remember date format is yyyy-mm-dd - BYE!"
             exit
      fi
   done
}
								
# function TimeQuery allows users to select time periods to be queried
# --------------------------------------------------------------------

function TimeQuery()		
{
   printf "Number of time ranges to be searched (max. 12): "
       read -r "MaxTimes"
   MaxTimesZerobased=`expr $MaxTimes - 1`
   NumTimes=0
   while [ $NumTimes -le $MaxTimesZerobased ]
   do
       printf "Enter `expr $num_times + 1` time range: "
       read -r "TimeRange"
       a3[$NumTimes]=$TimeRange
       NewTimeStamp=$(echo $TimeRange | sed 's/:00/:.*\\/')
       a4[$NumTimes]=$NewTimeStamp
       ((NumTimes++))
   done
}

# query ALE perf data for selected dates
# --------------------------------------

   function LogQuery1() 
{
   echo ""
   printf "$Event Events \n" >> $FILENAME                     # csv file location events identifier
   ele_a1=$(echo ${#a1[@]})		                              # get number of elements in a1
   m=`expr $ele_a1 - 1`
   n=0
   while [ $n -le $m ]
   do
       printf "\n" >> $FILENAME                              # carriage return - print to newline for each datestamp
       printf "${a1[$n]}," >> $FILENAME		                 # print timestamp to line
       #echo ${a1[$n]}
       echo "Processing $Event events ${a1[$n]}  .... please wait"
       LogDate=$(echo ${a2[$n]})                             # read n'th LogDate from a2

        ele_a3=$(echo ${#a3[@]})		                     # get number of elements in a3
        x=`expr $ele_a3 - 1`
        y=0
        
        while [ $y -le $x ]   
        do
            LogTime=$(echo ${a4[$y]})	                     # read n'th LogTime from a4 

            # grep for events, returning first and last value for specified time range(s)
            # ---------------------------------------------------------------------------------
            echo "Timestamp ${a3[$y]}"                       # echo to stdout
            
            egrep -R "$LogDate $LogTime $SearchString " $LogFile > /tmp/temp.log
            start=$(egrep -o "count=.*" /tmp/temp.log | awk '{print $1}' | cut -d '=' -f 2 | cut -d ',' -f 1 | sort -n | head -n1)
            end=$(egrep -o "count=.*" /tmp/temp.log | awk '{print $1}' | sort -n | cut -d '=' -f 2 | cut -d ',' -f 1 | sort -n | tail -n1)
	           if [ "$end" -ge "$start" ];
                 then count=$(echo `expr $end - $start`)
                 printf "$count," >> $FILENAME
                 else
                   count=$(echo `expr $start - $end`)
                   printf "$count," >> $FILENAME
               fi

		sleep 2         #2s backoff timer   
        ((y++))         #increase inner while iteration count 
        done            #end inner while loop
   ((n++))                 #increase outer while iteration loop
   done                    #end outer while loop
   echo "" >> $FILENAME
}

function LogQuery2()
{
   echo ""
   printf "$Event \n" >> $FILENAME                              # csv file  event identifier
   ele_a1=$(echo ${#a1[@]})		                             # get number of elements in a1
   m=`expr $ele_a1 - 1`
   n=0
   while [ $n -le $m ]
   do
        printf "\n" >> $FILENAME                                 # carriage return - print to newline for each datestamp
        printf "${a1[$n]}," >> $FILENAME		                 # print timestamp to line
        #echo ${a1[$n]}
        echo "Processing $Event events ${a1[$n]}  .... please wait"
        LogDate=$(echo ${a2[$n]})                               # read n'th LogDate from a2

        ele_a3=$(echo ${#a3[@]})		                     # get number of elements in a3
        x=`expr $ele_a3 - 1`
        y=0
        while [ $y -le $x ]   
        do 	
            LogTime=$(echo ${a4[$y]})	                     # read n't timestamp from a4
            		
			# grep events for specified time period
			# calculate average value for specified time period
			# -------------------------------------------------		
	    	echo "Timestamp ${a3[$y]}" 						# echo to stdout
	    	
            egrep -R "$LogDate $LogTime $SearchString" $LogFile > /tmp/temp.log
            TotalCount=$(egrep -o "value=.*" /tmp/temp.log | sed -r 's/^value=//' | wc -l)
            SumValues=$(egrep -o "value=.*" /tmp/temp.log | sed -r 's/^value=//' | awk '{s+=$1} END {printf "%.0f\n", s}')
            Average=$(echo "scale=2; $SumValues/$TotalCount" | bc)
            printf "$Average," >> $FILENAME
			
		sleep 2         #2s backoff timer   
        ((y++))         #increase inner while iteration count 
        done            #end inner while loop
((n++))                 #increase outer while iteration loop
done                    #end outer while loop
echo "" >> $FILENAME
					}
					
function LogQuery3 {
echo ""
printf "$Event \n" >> $FILENAME                              # csv file  event identifier
ele_a1=$(echo ${#a1[@]})		                             # get number of elements in a1
m=`expr $ele_a1 - 1`
n=0
while [ $n -le $m ]
do
    echo "Processing $Event events ${a1[$n]}  .... please wait"
    LogDate=$(echo ${a2[$n]})                               # read n'th LogDate from a2

        ele_a3=$(echo ${#a3[@]})		                     # get number of elements in a3
        x=`expr $ele_a3 - 1`
        y=0
        while [ $y -le $x ]   
        do 	
            LogTime=$(echo ${a4[$y]})	                     # read n't timestamp from a4		
			# grep $SearchString for specified time period
			# --------------------------------------------			
	    	echo "Timestamp ${a3[$y]}" # echo to stdout
            egrep -R "$LogDate $LogTime $SearchString" $LogFile >> $FILENAME
			echo "" >> $FILENAME
			
		sleep 2         #2s backoff timer   
        ((y++))         #increase inner while iteration count 
        done            #end inner while loop
((n++))                 #increase outer while iteration loop
done                    #end outer while loop
echo "" >> $FILENAME
					}
					
# Main program start

# get destination filename, start/end date range and time ranges to be queried

DestinationFile

printf "Enter start date (yyyy-mm-dd): "
  read -r "StartDate"
DateValidation $StartDate

printf "Enter end date (yyyy-mm-dd): "
  read -r "EndDate"
DateValidation $EndDate

DateRange
TimeQuery

# Execute required log queries
# Each query employs 3 variables - $Event, $SearchString and $LogFile
# The 3 variables are passed to functions as required:
# LogQuery1 - calculates difference between start and end count values of the queried time period
# LogQuery2 - calculates average value for queried time period
# LogQuery3 - dump of log queried log message for evaluated time period 

# query Location events
Event="Location"
SearchString="name=location,"
LogFile="/opt/ale/ale-persistence/logs/"
LogQuery1 $Event $SearchString $LogFile
echo "" >> $FILENAME

# query Presence events
Event="Presence"
SearchString="name=presence,"
LogFile="/opt/ale/ale-persistence/logs/"
LogQuery1 $Event $SearchString $LogFile
echo "" >> $FILENAME

# query RTLS (RSSI) events
Event="RSSI"
SearchString="*com.aruba.ale.common.zeromq.ZmqPacketTranslator.ipc:///tmp/.relay#2,"
LogFile="/opt/ale/ale-location/logs/"
LogQuery1 $Event $SearchString $LogFile
echo "" >> $FILENAME

# query Stations Removed events
Event="Stations Removed"
SearchString="*BasicMatrixHandler.rtls.stationsRemoved,"
LogFile="/opt/ale/ale-location/logs/"
LogQuery1 $Event $SearchString $LogFile
echo "" >> $FILENAME

# query LAA events
Event="LAA"
SearchString="*BasicMatrixHandler.rtls.locallyAdministered,"
LogFile="/opt/ale/ale-location/logs/"
LogQuery1 $Event $SearchString $LogFile
echo "" >> $FILENAME

# query EngineExecutor events
Event="Engine Executor Average"
SearchString="name=com.aruba.ale.location.engine.EngineExecutor.tasks,"
LogFile="/opt/ale/ale-location/logs/"
LogQuery2 $Event $SearchString $LogFile
echo"" >> $FILENAME
#Event="Engine Executor Table"
#LogQuery3 $Event $SearchString $LogFile
#echo "" >> $FILENAME

# query StationMap events
Event="Station Map"
SearchString="*StationMap.rtls.size"
LogFile="/opt/ale/ale-location/logs/"
LogQuery3 $Event $SearchString $LogFile
echo "" >> $FILENAME

rm -f /tmp/temp.log      #delete temp.log file
echo "Thanks for playing! You can check your results in $FILENAME"

# Main program end
