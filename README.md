# EDF writer and reader supporting multiple frequencies
European Data Format writer and reader supporting multiple frequencies written in MATLAB.
## WriteEDF.m
Writes a file in EDF format (Kemp et. al. 1992).
- Input data should be in cells 
- Sampling frequencies should be in an array
- Header information should be entered separately in the HeaderInfo.m
### Limitations
- Sampling frequency is assumed >=1Hz with the default 'samples per data block' defined to samples per second. Therefore, sampling frequencies <1Hz will not be meaningfull.
- Data and time formats are not verified before writing to the file. 
## HeaderInfo.m
All the header information should be entered to this file before executing WriteEDF.m
### Limitations
- Start data and start time should be entered in the format dd.mm.yy and hh.mm.ss respectively. This will not be checked while writing or reading.
- Header_w.Reserved2 should have equal number of empty cells to that of number of signals included in the file. Default is 3 empty cells.
## ReadEDF.m
Read .edf files in EDF format (Kemp et. al. 1992).
### Limitations
- Reading EDF+ format (Kemp et. al. 2003) will give errors or will produce erroneous data.
## DummyData.m
This can be used to generate data to test the WriteEDF.m
