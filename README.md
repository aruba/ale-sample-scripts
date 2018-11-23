# ALE Data Collection Script

Bash shell script to gather data from Aruba ALE server.  The script extracts counters and values for several key ALE indicators and produces comparisons of them over a period of time.  The data is saved to a user defined file on ALE so it can be exported and graphed using whatever is the preferred application e.g. Excel, Python, etc.  The data gives visibility of ALE performance and data quality, as well insight into trends for different data event volumes e.g. location, presence messages.  Event volume trends allow a structured picture to be built that is relevant to the ALE operating environment e.g. footfall over time for commercial malls, exhibition centers, etc.

The script specifically extracts and compares values for:

- Location Events published
- Presence Events published
- Count of RSSI events decoded
- Stations (end-points) removed from the location module table
- LAA (Locally Administered Addresses) discarded
- ALE Engine Executor Events
- Station Map table count held by the location module

In the case of location, presence, RSSI, stations removed and LAA discards, the script takes the first and last count value for each time period and calculates the diff.  As a result, it can be seen if more or less events of a particular type have been observed during a specific time period.

Processed queries are written to a .csv output file with the format:

<Event Type Name>				
dd/mm/yy	TimeStamp1 TimeStamp2 TimeStamp3 etc ...

For example, below are a series of location events for date range 13/11/18 to 21/11/18, where timestamps queried were 01:00, 10:00, 15:00 and 18:00 

Location Events 				
13/11/18	36824	88159	106082	113534
14/11/18	38917	88496	103466	111995
15/11/18	35513	85302	102925	108239
16/11/18	34957	92003	107724	123366
17/11/18	40548	84739	114724	133339
18/11/18	39439	44730	107299	116068
19/11/18	32557	93886	102739	111018
20/11/18	36505	93238	102203	108723
21/11/18	36396	89594	102047	113327

## Getting Started

Copy the script by SFTP to /tmp and make it executable:

chmod +x data_collection_v5.0.6.sh

### Prerequisites

The script is executed from the ALE bash shell and has no special requirements.

### Executing the Script

/tmp is in the $PATH for root, so the script can be executed as: 

/tmp/data_collection_v5.0.6.sh

The script begins by requesting data input from the user for:

- Destination filename
- Date range to be queried
- Time ranges to be queried

The script first lists any existing .csv files in /tmp and prompts for the destination filename.  The .csv extension is added automatically and is saved to /tmp.

-rw-r--r-- 1 root root 0 Nov 22 23:35 /tmp/ale_perf_data_15Nov_19Nov.csv

*** Destination directory is /tmp ***
--------------------------------------

Please enter destination filename: ale_perf_data_20Nov_21Nov

Destination file PATH is /tmp/ale_perf_data_20Nov_21Nov.csv
--------------------------------------

The user is now prompted for the dates to be queried.  The format is yyyy-mm-dd.

Enter start date (yyyy-mm-dd): 2018-11-20
2018-11-20 ok

Enter end date (yyyy-mm-dd): 2018-11-21
2018-11-21 ok

Total dates to be queried are 2

The script makes rudimentary checks that a date entered is not a future date and is the correct format i.e. valid.  If an invalid dates is entered, the following error is provided:

Enter start date (yyyy-mm-dd): 2019-01-23
Future Datestamps not allowed

Enter start date (yyyy-mm-dd): 2018-30-11
Future Datestamps not allowed

The next prompt defines the number of time ranges to be queried.

For purposes of the script, a "time range" is defined as the start to end of an hour period to the queried e.g. 23:00:00 to 23:59:59.  Only the start time of the hour is required.  The script can query 12 time ranges, however this is an arbitrary value and more time ranges could be searched.

Number of time ranges to be searched (max. 12): 4
Enter 1 time range: 01:00
Enter 1 time range: 10:00
Enter 1 time range: 15:00
Enter 1 time range: 18:00

The script now executes and provides indicators of its progress via stdout:

Processing Location events 2018-11-20  .... please wait
Timestamp 01:00
Timestamp 10:00
.... etc

When the script finishes executing, the results file can be exported (SFTP) and manipulated as required.

## Built With

* [BASH](https://www.gnu.org/software/bash/) - does what it says on the tin!

## Contributing

If you wish to contribute, then please contact the owner.

## Versioning

Versioning is simple.  The first version published is 5.0.6.sh.  Bug fixes go into the current 5.0.x tree.  New features in the second tier e.g. 5.x.x.

## Authors

David Hardaker Aruba HPE

## License

This project is licensed under the Apache2.0 license - see the LICENSE.md file for details

## Acknowledgments

Aruba ALE engineering team for helping to figure out the meaning behind the log messages!

