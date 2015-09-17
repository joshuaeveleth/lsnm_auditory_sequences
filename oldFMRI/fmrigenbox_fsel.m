%  fmrigenbox_fsel.m  -- May 1998
%
%  FORMAT:	    fmrigenbox_fsel
%__________________________________________________________
%
%  This program generates a user-defined boxcar for the shape selective
%  part of the suec simulations (bxsynact4).
%  It then will generate the sampled hemodynamically-delayed
%  boxcar (integrated activity over Ti, sampled every Tr)
%  (bxfmriact2) that would be used by fMRI.  It also
%  produces the hemodynamically delayed boxcar (bxact4). All have
%  time units in seconds.  The first trial is removed.
%  
%  The input parameters are: 
%
%  Tinit=time of initial part of activity that is not cycled.
%  Ti=neural synaptic time interval
%  lambda=parameter (in sec.) for the Poisson distributed hemodyn. delay
%  T=total time of scanning experiment
%  Tr=frame time (time needed to sample hemo activity to produce each
%                          fMRI image)
%  delay=time interval between beginning of study and when fMRI data
%             starts to be acquired.
%  Ttrial=time (in sec.) for one complete trial
%  n=number of cyles in boxcar
%
%  All time units are in seconds. 
%
%  The output matrices, bxsynact4, bxact4 and bxfmriact2 have as their
%  first column the time (in seconds), the second represents the boxcar
%  activity.
%
%  Two time vectors (Tsyn4 and Tmr2) also are computed; the former
%  is in steps of Ti, the latter in steps of Tr; units are in seconds.
%
%  Finally, we delete the first stimulus trial to get our final time courses
%  and make sure the beginning and ending time points are the same for
%  bxfmriact2, bxact4, and bxsynact4.
%
%  Final output variables are called bxsynact4, bxact4, bxfmriact2, Tsyn4
%  and Tmr2.
%
%  The initially generated boxcar is scaled to have a maximum value of
%  100.
%
%----------------------------------------------

%  Written 5-98 by B. Horwitz

%  Generate Boxcar

disp(' '); disp('Enter boxcar parameters: ');
boxparam=input('i.e., [n,Tinit,T0,T1,T2,T3,T4,T5,T6,T7,T8,Ti]:   ');

bx=boxcar_fsel(boxparam(1),boxparam(2),boxparam(3),boxparam(4),...
    boxparam(5),boxparam(6),boxparam(7),boxparam(8),boxparam(9),...
    boxparam(10),boxparam(11),boxparam(12));

bx=bx*100;

[r c]=size(bx);
 
begin=zeros(1,2);
 
bxsynact1=[begin;(1:r)' bx];
 
Tsyn=(0:Ti:T)';
 
bxsynact1(:,1)=Tsyn;


bxact=convol(bxsynact1,lambda,Ti,T);
bxact(:,1)=Tsyn;


%  Convert seconds to Ti units

delaynew=round(delay/Ti);
TRnew=round(Tr/Ti);


% Generate fMRI activity

[r c]=size(bxact);
act1rows=fix((r-delaynew)/TRnew);
bxactivity1=zeros(act1rows,c);

for i=1:act1rows
	A=delaynew+1+i*TRnew;
	bxactivity1(i,:)=bxact(A,:);
end
v=(delay+Tr):Tr:T;
bxactivity1(:,1)=v';
Tmr=v';
bxfmriact1=bxactivity1;

%  Remove first trial

synticks=Ttrial/Ti+1; 
mrticks=round(Ttrial/Tr);

Tsyn2=Tsyn(synticks+1:length(Tsyn));
bxsynact2=bxsynact1(synticks+1:length(Tsyn),:);
bxact2=bxact(synticks+1:length(Tsyn),:);

Tmr2=Tmr(mrticks:length(Tmr)); 
bxfmriact2=bxfmriact1(mrticks:length(Tmr),:);

%  Make beginning and end time points the same for 
%  the hemodyn. synaptic activity and the fMRI activity

ivalue=1; jvalue=length(Tsyn2);

%  First, the beginning time points

tmax1=length(Tmr2); tmax2=length(Tsyn2);

if Tmr2(1)==Tsyn2(1)
  bxact3=bxact2;
  bxsynact3=bxsynact2;
  Tsyn3=Tsyn2;
elseif Tmr2(1)>Tsyn2(1);
  ivalue=find(Tsyn2==Tmr2(1));
  Tsyn3=Tsyn2(ivalue:tmax2);
  bxact3=bxact2(ivalue:tmax2,:);
  bxsynact3=bxsynact2(ivalue:tmax2,:);
  jvalue=length(Tsyn3);
elseif Tmr2(1)<Tsyn2(1);
  Tmr2=Tmr2(2:tmax1);
  bxfmriact2=bxfmriact2(2:tmax1,:);
  tmax1=length(Tmr2);
  ivalue=find(Tsyn2==Tmr2(1));
  Tsyn3=Tsyn2(ivalue:tmax2);
  bxact3=bxact2(ivalue:tmax2,:);
  bxsynact3=bxsynact2(ivalue:tmax2,:);
  jvalue=length(Tsyn3);
end

%  Now, the end time points

tmax3=length(Tsyn3); 

if Tmr2(tmax1)==Tsyn3(tmax3)
  bxact4=bxact3;
  bxsynact4=bxsynact3;
  Tsyn4=Tsyn3;
elseif Tmr2(tmax1)<Tsyn3(tmax3)
  jvalue=find(Tsyn3==Tmr2(tmax1));
  Tsyn4=Tsyn3(1:jvalue);
  bxact4=bxact3(1:jvalue,:);
  bxsynact4=bxsynact3(1:jvalue,:);
elseif Tmr2(tmax1)>Tsyn3(tmax3)
  Tmr2=Tmr2(1:tmax1-1);
  jvalue=find(Tsyn3==Tmr2(length(Tmr2)));
  Tsyn4=Tsyn3(1:jvalue);
  bxact4=bxact3(1:j,:);
  bxsynact4=bxsynact3(1:jvalue,:);
  bxfmriact2=bxfmriact2(1:length(Tmr2),:);
end