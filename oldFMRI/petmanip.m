%  petmanip.m -- 7/6/98
%
%  FORMAT:  petmanip
%
%----------------------------------------

workdir=pwd;
petvalues=[];

[nrows,ncols]=size(subjectlist);

for i=1:nrows
  eval(['cd ',subjectlist(i,:)]);
  sumsynact2
  petvalues=[petvalues; intgract];
  eval(['cd ',workdir]);
end

meanpet_i=mean(petvalues);
globalmean=mean(meanpet_i(2:9));
petvaluesn=petvalues./globalmean;
petvaluesn=petvaluesn(:,2:9);
meanpet=mean(petvaluesn);
sdpet=std(petvaluesn);
cvpet=(sdpet./meanpet)*100;
corrpet=corrcoef(petvaluesn);

disp(' '); disp('Your analysis is complete'); disp(' ');

