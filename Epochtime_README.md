# ALE Epoch Time Converter

The script extracts epoch timestamps from ZMQ message published to stdout and converts them to a human readable date/time.  Converted timestamps are written to an output file along with the ALE system time when the message was published to stdout.  By comparing the ZMQ message timestamp and the system time when the message was published, it is possible to understand if the delay between location/presence events and the time when they were published is increasing.  Increasing delta between event timestamps and the time when an event was actually published could indicate that the ALE Engine Executor is overly busy.

## Getting Started

Copy the script by SFTP to /tmp

### Prerequisites

The script requires the embedded Python2.6 interpreter shipped with ALE.  The script leverages the Python module "argparse".  To install argparse on ALE run:

yum install python-argparse

### Executing the Script

/tmp is in the $PATH for root, so the script can be executed as: 

python2.6 /tmp/epoch_feedreader_v0.5.py

The script requires 2 arguments:

-- filename (output filename)
-- time (time in seconds that the program will execute)

For example:

python2.6 /tmp/epoch_feedreader_v0.5.py --filename <path/filname> --time <seconds>

The output file has the format:

epoch <epoch timestamp> for message published <ALE system time> converts to <epoch time converted to UTC>

For example:

epoch 1544900896 for message published @2018-12-15 19:08:26.154530 converts to UTC 2018-12-15 19:08:16
epoch 1544900876 for message published @2018-12-15 19:08:26.155560 converts to UTC 2018-12-15 19:07:56
epoch 1544900896 for message published @2018-12-15 19:08:26.155833 converts to UTC 2018-12-15 19:08:16
epoch 1544900865 for message published @2018-12-15 19:08:26.156517 converts to UTC 2018-12-15 19:07:45
epoch 1544900865 for message published @2018-12-15 19:08:26.157396 converts to UTC 2018-12-15 19:07:45

## Built With

* [PYTHON2.6](https://mypy.readthedocs.io/en/latest/python2.html)

## Contributing

If you wish to contribute, then please contact the owner.

## Versioning

The first version published is v0.5.  Bug fixes go into the current v0.x tree. 

## Authors

David Hardaker Aruba HPE

## License

This project is licensed under the Apache2.0 license - see the LICENSE.md file for details

## Acknowledgments

The HPE Aruba family for building ALE in the first place :)
