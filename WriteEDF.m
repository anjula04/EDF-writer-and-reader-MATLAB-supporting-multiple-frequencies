% Writes a file in EDF format (Kemp et. al. 1992).
% Input data 
%     format: cell
%     variable: data_write
% Sampling frequencies 
%     format: array
%     variabl: SmpFrq
%  Header infomation
%     insert in HeaderInfo.m

clearvars; clc;
spc = 32;
file_name = 'edf_test'; % name of the created EDF file

%% Importing data and Header info ***********************

[data_write, SmpFrq] = DummyData();
Header_w = HeaderInfo();

%% Defining variables and data ***********************

NfRecords       = length(data_write{1})/SmpFrq(1);
DuRecord        = 1;                  % in seconds
NfSignals       = length(data_write); 
NfBytesHeader   = 256*(1+NfSignals);    
NfSmpDatRec     = SmpFrq;             % maximum samples per data record is 61440 (Kemp et. al. 1992)

% Check for equal number of NfRecords (ensures a recording of a fixed time window)
for i = 2:NfSignals
    if NfRecords ~= length(data_write{i})/SmpFrq(i)
        error('Signals are not of the same duration');
    end
end

% Get min/max int and cast to double to avoid computation errors.
for i = 1:NfSignals
    DigiMin(i,1) = cast(intmin('int16'),'like',data_write{i});
    DigiMax(i,1) = cast(intmax('int16'),'like',data_write{i});
end

for i = 1:NfSignals
    PhysMin(i,1) = floor(min(data_write{i}));
    PhysMax(i,1) = ceil(max(data_write{i}));
end

% Physical max can't be equal to physical min
isEqual = PhysMax==PhysMin;
PhysMin(isEqual) = PhysMin(isEqual) - 0.5;
PhysMax(isEqual) = PhysMax(isEqual) + 0.5;

% Mapping input data to 'int16'
m = (DigiMax - DigiMin)./(PhysMax - PhysMin);
c = DigiMax - m.*PhysMax;
for i = 1:NfSignals
    data_write_map{i,1} = m(i)*data_write{i} + c(i);
end

%% Check input header information

% Local Patient ID **********************
if isempty(Header_w.LocalPatientID)
    Header_w.LocalPatientID = 'X';
    warning('Patient_ID not mentioned. Default ''X'' inserted.');
else
    if length(Header_w.LocalPatientID)>80
        error('Patient_ID has %d characters. Maximum allowed 80 characters.',length(Header_w.LocalPatientID))
        % TODO check for spaces and replace with '_'
    end
end

% Local Record ID **********************
if isempty(Header_w.LocalRecordID)
    Header_w.LocalRecordID = 'X';
    warning('Record_ID not mentioned. Default ''X'' inserted.');
else
    if length(Header_w.LocalRecordID)>80
        error('Record_ID has %d characters. Maximum allowed 80 characters.',length(Header_w.LocalRecordID))
        % TODO check for spaces and replace with '_'
    end
end

% Labels **********************
for i = 1:NfSignals
    if isempty(Header_w.Label{i})
        Header_w.Label{i,:} = ['Signal',num2str(i),repmat(' ',1,10-length(num2str(i)))];
        warning('No label for signal %d. Default ''Signal#'' used\n',i)
    else
        if length(Header_w.Label{i})>16
            error('Label %d has %d characters. Maximum allowed 16 characters.',i,length(Header_w.Label{i}))
        end
    end
        
end

% Transducer information **********************
for i = 1:NfSignals
    if length(Header_w.Transducer{i})>80
        error('Transducer information in Signal %d has %d characters. Maximum allowed 80 characters.',i,length(Header_w.Transducer{i}))
    end
end

% Physical dimension **********************
for i = 1:NfSignals
    if length(Header_w.PhysDim{i})>8
        error('Physical dimensions in Signal %d has %d characters. Maximum allowed 8 characters.',i,length(Header_w.PhysDim{i}))
    end
end

% Prefilter information **********************
for i = 1:NfSignals
    if length(Header_w.PreFilt{i})>80
        error('Prefilter information in Signal %d has %d characters. Maximum allowed 80 characters.',i,length(Header_w.PreFilt{i}))
    end
end

%% Write header record

machinefmt = 'ieee-le'; encodingIn = 'US-ASCII';
fileID = fopen(strcat(file_name, '.edf'),'w', machinefmt, encodingIn);

% Write records to file ******************
fwrite(fileID, [Header_w.Version repmat(spc,1,7)], 'char*1');
fwrite(fileID, [Header_w.LocalPatientID repmat(spc,1,80-length(Header_w.LocalPatientID))], 'char*1');
fwrite(fileID, [Header_w.LocalRecordID repmat(spc,1,80-length(Header_w.LocalRecordID))], 'char*1'); 
fwrite(fileID, Header_w.StartDate, 'char*1');
fwrite(fileID, Header_w.StartTime, 'char*1');
fwrite(fileID, [num2str(NfBytesHeader) repmat(spc,1,8-length(num2str(NfBytesHeader)))],'char*1');
fwrite(fileID, [Header_w.Reserved1 repmat(spc,1,44-length(Header_w.Reserved1))], 'char*1');
fwrite(fileID, [num2str(NfRecords) repmat(spc,1,8-length(num2str(NfRecords)))]);
fwrite(fileID, [num2str(DuRecord) repmat(spc,1,8-length(num2str(DuRecord)))]);
fwrite(fileID, [num2str(NfSignals) repmat(spc,1,4-length(num2str(NfSignals)))]);

for i = 1:NfSignals
    fwrite(fileID, [Header_w.Label{i} repmat(spc,1,16-length(Header_w.Label{i}))], 'char*1');
end
for i = 1:NfSignals
    fwrite(fileID, [Header_w.Transducer{i} repmat(spc,1,80-length(Header_w.Transducer{i}))], 'char*1');
end
for i = 1:NfSignals
    fwrite(fileID, [Header_w.PhysDim{i} repmat(spc,1,8-length(Header_w.PhysDim{i}))], 'char*1');
end
for i = 1:NfSignals
    fwrite(fileID, [num2str(PhysMin(i,:)) repmat(spc,1,8-length(num2str(PhysMin(i,:))))]);
end
for i = 1:NfSignals
    fwrite(fileID, [num2str(PhysMax(i,:)) repmat(spc,1,8-length(num2str(PhysMax(i,:))))]);
end
for i = 1:NfSignals
    fwrite(fileID, [num2str(DigiMin(i,:)) repmat(spc,1,8-length(num2str(DigiMin(i,:))))]);
end
for i = 1:NfSignals
    fwrite(fileID, [num2str(DigiMax(i,:)) repmat(spc,1,8-length(num2str(DigiMax(i,:))))]);
end
for i = 1:NfSignals
    fwrite(fileID, [Header_w.PreFilt{i} repmat(spc,1,80-length(Header_w.PreFilt{i}))], 'char*1');
end
for i = 1:NfSignals
    fwrite(fileID, [num2str(NfSmpDatRec(i,:)) repmat(spc,1,8-length(num2str(NfSmpDatRec(i,:))))]);
end
for i = 1:NfSignals
    fwrite(fileID, [Header_w.Reserved2{i} repmat(spc,1,32-length(Header_w.Reserved2{i}))], 'char*1');
end

%% Write data to the file**************************

% Data in a cell
for i = 1:NfRecords 
    for j = 1:NfSignals
        temp_data = data_write_map{j}((NfSmpDatRec(j)*(i-1)+1) : NfSmpDatRec(j)*i); % rearranging data to [1 1 1 2 2 2 3 3 3 1 1 1 2 2 2 3 3 3]
        fwrite(fileID,temp_data,'int16');
    end
end

fclose(fileID);
fprintf('''%s.edf'' successfully created.\n',file_name);