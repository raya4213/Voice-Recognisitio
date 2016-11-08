clc
clear all
Con=0;
delete(instrfind({'Port'},{'COM20'}));                     %To disconnect Arduino from Serial Port 20
X=0;
fs=16000;
test=0;
duration=2;
fprintf('Press any key to record "Connect" Word of recording\n',duration);
pause;
fprintf('Recording.\n');
r=wavrecord(2*fs,fs);                                                                 %To record first word Connect for database
r=r-mean(r);
fprintf('Press any key to record "data" word %g seconds of recording\n',duration);
pause;
fprintf('Recording.\n');
y=wavrecord(2*fs,fs);                                                                 %To record second word data for data base 
y=y-mean(y);
fprintf('Press any key to record %g seconds of recording for matching\n',duration);
pause;
fprintf('Recording.\n');
voice=wavrecord(2*fs,fs);                                                            %To record word for completing Task
voice=voice-mean(voice);
fprintf('Finished Recording.\n');
nfft=min(1023,length(r));
s=specgram(r,nfft,fs,hanning(511),380);                                               %To find Spectrogram of voice sample  512 is the window size and 512-380=132 is the window overlap
s1=specgram(y,nfft,fs,hanning(511),380);
s2=specgram(voice,nfft,fs,hanning(511),380);
absolute=transpose(abs(s));
absolute1=transpose(abs(s1));
absolute2=transpose(abs(s2));
a=sum(absolute);                                                                     %To find sum of all frequency Term 
a1=sum(absolute1);
a2=sum(absolute2);
a_norm=(a-min(a))/(max(a)-min(a));                                                   %To normalize the  sample for comparing
a1_norm=(a1-min(a1))/(max(a1)-min(a1));
a2_norm=(a2-min(a2))/(max(a2)-min(a2));
F=transpose(a_norm);                                                                 % To find transpose of matrix
F1=transpose(a1_norm);
F2=transpose(a2_norm);
[x,lag]=xcorr(F2,F);                                                               %To find cross Correlation of two signal for comparing it with database stored
[mx,indices]=max(x);                                                               %To find Maximum Frequency delay at with correlation is maximum
freq=lag(indices);
[x2,lag2]=xcorr(F2,F1);
[mx2,indices2]=max(x2);
freq2=lag(indices2);
figure(1) 
subplot(1,3,1)
plot(abs(s))                                                                            %To plot Spectogram of Voice sample
xlabel('Frequency')
ylabel('Energy of STFT signal')
title('Spectrogram of 1st word ')
subplot(1,3,2)
plot(abs(s1))
xlabel('Frequency')
ylabel('Energy of STFT signal')
title('Spectogram of 2nd word ')
subplot(1,3,3)
plot(abs(s2))
xlabel('Frequency')
ylabel('Energy of STFT signal')
title('Spectogram of 3rd word ')
figure(2)
subplot(1,3,1)
plot(F)
xlabel('Frequency')
ylabel('Amplitude')
title('Frequency Spectrum ')
subplot(1,3,2)
plot(F1)
xlabel('Frequency')
ylabel('Amplitude')
title('Frequency Spectrum ')
subplot(1,3,3)
plot(F2)
xlabel('Frequency')
ylabel('Amplitude')
title('Frequency Spectrum')
figure(3)
subplot(1,2,1)
plot(x)                                                                                  %To plot cross correlation of word recorded with sample data
title('XCORR of Connect Word')
xlabel('Frequency')
ylabel('Amplitude')
subplot(1,2,2)
plot(x2)
xlabel('Frequency')
ylabel('Amplitude')
title('XCORR of Data Word')
if(abs(abs(freq)-abs(freq2))>=2)                                              %If frequency difference between two correlation is greater than 2
    
    if(abs(freq)>abs(freq2))
        X=X+1;
        fprintf(' The Second word is spoken');
 
        
    else
        Con=Con+1;
         fprintf(' The First word is spoken');
        
    end
else                                                                          %It is used to compare which Correlation has more symmetric Graph
    if(indices<length(x)/2)
        q=1:indices-1;
        p=indices+length(q):-1:indices+1;
        x_left=x(q);                                                          %To find minimum data on left side
        x_right=x(p);                                                           %To find minimum data on right side
        error=mean((abs(x_left-x_right)).^2);                                  %to find the error in cross correlation graph
    else
         q=1+freq*2:indices-1;
        p=length(x):-1:indices+1;
        x_left=x(q);
        x_right=x(p);
        error=mean((abs(x_left-x_right)).^2);  
end
  if(indices2<length(x2)/2)
        q2=1:indices2-1;
        p2=indices2+length(q2):-1:indices2+1;
        x2_left=x2(q2);
        x2_right=x2(p2);
        error2=mean((abs(x2_left-x2_right)).^2);
    else
         q2=1+freq2*2:indices2-1;
        p2=length(x2):-1:indices2+1;
        x2_left=x2(q2);
        x2_right=x2(p2);
        error2=mean((abs(x2_left-x2_right)).^2);  
  end
if(error>error2)                                                              %if error2 is greater than first error then word spoken third time is second word
    X=X+1;
      fprintf(' The Second word is spoken');
    
else
    Con=Con+1;
      fprintf(' The First word is spoken');
end
    if(Con>0)
        a=arduino('COM3')                                                            %To conncet arduino to Serial Port20 if first word is spoken.
    end
        if(X>0)
            delete(instrfind({'Port'},{'COM3'}));                                    %To disconnect arduino if connected
            a=arduino('COM3');
 x=1;
 i=0;
 while(1)
     i=i+1;
     s(i).f1=a.analogRead(1);                                                        %To read data from analog Pin 1
     count=arrayfun(@(x) x.f1,s);
     s(i).f2=a.analogRead(2);                                                        %To read data from analog Pin 2
     count1=arrayfun(@(x) x.f2,s);
     s(i).f3=a.analogRead(3);                                                         %To read data from analog Pin 3
     count2=arrayfun(@(x) x.f3,s);
     subplot(3,1,1);
     title('X AXIS');
   plot(count);                                                                        %To plot data .
    subplot(3,1,2);
     title('y AXIS');
   plot(count1);
    subplot(3,1,3);
     title('z AXIS');
   plot(count2);
   drawnow;
    end 
 end 
end
 


