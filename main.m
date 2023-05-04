
% Mid Project for Medical Signal Processing
% Created 2023.4.18
% Author Gr

close all;
clear;

% Get 111 and 113 channel signal
% The data is stored in data file, 111.csv and 113.csv

% All variables notation:
    % path_111: Record 111 path
    % path_115: Record 115 path
    % time_start : Signal start time
    % time_end : Signal endd time
    % s1,s2: 111,115 signal
    % t1,t2: 111,115 Time
    % fs: Sampling rate
    % window: STFT window length
    % nfft: STFT freq length
    % s: s1 after baseline filter
    % s_60 : s after 60 Hz noise filter

path_111 = 'data\111.csv';
path_115 = 'data\115.csv';

%% Problem 1
% Get data and Graph them
time_start = 0;
time_end = 30.0;
[t1,s1] = get_data(path_111,time_start,time_end);
[t2,s2] = get_data(path_115,time_start,time_end);
drawSignal(s1,t1,s2,t2);

%% Problem 2
% Problem 2.1
% Average Heartbeat in 30 seconds
time_start = 0;
time_end = 30.0;
[avg_Hb_1, points1] = get_Hb(s1, time_start, time_end);
[avg_Hb_2, points2] = get_Hb(s2, time_start, time_end);
% Problem 2.2
% Short time heatbeat in 5 seconds, and update step = 1 second 
% Use figure to show the results
Hb1 = get_Hb_5s(path_111);
Hb2 = get_Hb_5s(path_115);
t = 1:25;
figure;
   plot(Hb1,'-*r');
   ylim([50,80]);
   hold on;
   plot(Hb2,'-*b')
   legend('Channel 111','Channel 115');
   saveas(gcf,'Fig/Problem2.jpg')

%% Problem 3&4
% Sampling Frequency = 360Hz
% First, we can use Simple Fourier Transformation
fs = 360;
N = length(s1);
y = fft(s1,N);
y = y(1:(N-1)/2);
f = (0: N-1) * fs/ N;
f = f(1:(N-1)/2);
figure;
    subplot(211);
    plot(f,abs(y),'blue');
    title('Fourier Transform');
    xlim([0,100]);
    xlabel('Frequency(Hz)');
    subplot(212);
    plot(f,abs(y),'r')
    xlim([0,4]);
    title('Fourier Transformation')
    xlabel('Frequency(Hz)')
    saveas(gcf,'Fig/Problem3_1.jpg')

% For Short Time Fourier Transformation, We are using Spectromgram
window = 256;
overlap = window/2;
nfft = 1024;
fs = 360;
[s,f,t,p] = spectrogram(s1, window, overlap, nfft, fs);
[s5,f5,t5,p5] = spectrogram(s2,window,overlap,nfft,fs);

figure;
    subplot(211);
    imagesc(t, f, 20*log10((abs(s))));xlabel('Seconds(s)'); ylabel('Freqency(Hz)');
    colorbar;
    title('Short Time Fourier Transformation Channel 111')
    subplot(212);
    imagesc(t5, f5, 20*log10((abs(s5))));xlabel('Seconds(s)'); ylabel('Freqency(Hz)');
    title('Short Time Fourier Transformation Channel 115')
    colorbar;
    saveas(gcf,'Fig/Problem3_2.jpg')

%% Problem 4
% Calculate and analyze baseline noise and other low-freq noises
% Method 1. Using High Pass Filter or Low Pass Filter 
fmax = 2;
fs = 360;
[s,s_low] = baseline_filter(s1,fs,fmax);

figure;
    subplot(211);
    plot(s1);
    title('Raw Signal')
    subplot(212);
    plot(s_low);
    title('Baseline noise(Low Frequency Noise');
    saveas(gcf,'Fig/Problem4_1.jpg');
% ******
% Method 2. Using wavelet to extract Bandpass noise( More Recommended)
% ******
wname = 'db4';
lev = 8; % 分解7尺度8层（不知道怎么用英语说了）
figure;
   for i = 1:lev
      wav_low = wavelet_bandpass(s1,wname,i);
      subplot(lev,1,i);
        plot(wav_low);
        saveas(gcf,'Fig/Problem4_2_1.jpg');
        title(sprintf("第%d层近似分量", i));
   end
figure;
   wav_low = wavelet_bandpass(s1,wname,lev);
   plot(wav_low);
   saveas(gcf,'Fig/Problem4_2_2.jpg');
   title(sprintf("第8层近似分量"));
figure;
   subplot(2,1,1);
   plot(s_low);
   title('利用低通滤波器获得的低频信号')
   subplot(2,1,2);
   plot(wav_low);
   title('利用小波变换第8层得到的低频信号')
   saveas(gcf,'Fig/Problem4_2_3.jpg');

%% Problem 5
% Method1. Filter
s_60 = bandpass_60(s,fs);
figure;
    subplot(411)
    plot(s1,'r');
    title('Raw signal');
    subplot(412)
    plot(s,'b');
    title('Baseline Drift Filter');
    subplot(413)
    plot(s_60,'g');
    title('60 Hz Filter');
    subplot(414)
    plot(s1,'r');
    hold on;
    plot(s,'b');
    plot(s_60,'g')
    saveas(gcf,'Fig/Problem5_1.jpg')
[s,f,t,p] = spectrogram(s1, window, overlap, nfft, fs);
[s2,f2,t2,p2] = spectrogram(s_60,window,overlap,nfft,fs);
figure;
    subplot(211);
    imagesc(t, f, 20*log10((abs(s))));xlabel('Seconds(s)'); ylabel('Freqency(Hz)');
    colorbar;
    title('Raw Signal STFT')
    subplot(212);
    imagesc(t2, f2, 20*log10((abs(s2))));xlabel('Seconds(s)'); ylabel('Freqency(Hz)');
    title('After baseline filter and 60 Hz filter STFT')
    colorbar;
    saveas(gcf,'Fig/Problem5_2.jpg')

% Method2. Using wavelet
y = wavelet_filter(s1,wname,i);
[s3,f3,t3,p3] = spectrogram(y, window, overlap, nfft, fs);
figure;
    plot(y);
    saveas(gcf,'Fig/Problem5_3.jpg')
figure;
    subplot(211);
    imagesc(t, f, 20*log10((abs(s))));xlabel('Seconds(s)'); ylabel('Freqency(Hz)');
    colorbar;
    title('Raw Signal STFT')
    subplot(212);
    imagesc(t3, f3, 20*log10((abs(s3))));xlabel('Seconds(s)'); ylabel('Freqency(Hz)');
    title('After wavelet filter')
    colorbar;
    saveas(gcf,'Fig/Problem5_4.jpg')

 %% Problem 6
 % Get R wave and RR_interval
[R,rr_interval] = get_Rwave(s_60,time_start,time_end);
avg_rr = mean(rr_interval);
figure;
        plot(t1,s_60);
        xlabel('Seconds(s)');
        ylabel('Amplitude(mV)');
        hold on;
        plot(t1(R),s_60(R),'.r');
        %plot(t1(points),s_60(points),'.b');
        legend('Signal','Rwave');
        saveas(gcf,'Fig/Problem6.jpg')
        

% Function Explanation:
    % get_data(): get data, [time_start, time_end]
    % drawSignal(): draw Signal picture;
    % get_Hb(): get average Heartbeat, depends on [time_start, time_end]
    % get_Hb_5s: get 5s unpdate Heartbeat, [0,5] -> [25,30] seconds
    % baseline_filter(): baseline filter
    % bandpass_60(): filter 60 Hz noises
    % get_Rwave: get R wave points and return RR_interval



function [second, signal] = get_data(file_path,time_start,time_end)
    % csv has 2 columns, first is time, second is amplitude
    data = readtable(file_path,"VariableNamingRule","preserve");
    n = size(data);
    col1 = data(2:n(1),1);
    col2 = data(2:n(1),2);


   % Process time info in col1
   a = col1{:,1};
   b = cell2mat(a);
   c = string(b);
   timeStr = strip(c,"'");
   timeObj = datetime(timeStr, 'InputFormat', 'm:ss.SSS');
   timeDuration = timeObj - timeObj(1);
   timeSeconds = seconds(timeDuration);
   Signal = table2array(col2);
   
   % Get seconds
   for i = 1:length(timeSeconds)
        if timeSeconds(i) >= time_start
            break;
        end
    end
    i_start = i;
    for i = i_start:length(timeSeconds)
        if  timeSeconds(i) >= time_end
            break;
        end
    end
    i_end = i;
    second = timeSeconds(i_start:i_end);
    signal = Signal(i_start:i_end);

end

function [] = drawSignal(s1,t1,s2,t2)

    figure;
        subplot(211);
        plot(t1, s1);

        grid on;
        title('Record 111(first 30 seconds)');
        subplot(212);
        plot(t2, s2);
        title('Record 115(first 30 seconds)');
        grid on;
        saveas(gcf,'Fig/Problem1.jpg')
end

function [avg_Hb,points] = get_Hb(s, start_time, end_time)

    thr = max(s) * 0.4; % Quite useful to detect QRS wave
    points = [];
    cnt = 0;
    i = 1;
    while i <= length(s)
        if s(i) >= thr
            points = [points,i];
            cnt = cnt + 1;
            i = i + 72; 
        else
            i = i + 1;
        end
    end
    duration = end_time - start_time;
    avg_Hb = cnt * 60.0 / duration;
    
end

function [R,RR_interval] = get_Rwave(s,time_start,time_end)
    
    % R, Array[float] : return every R wave time dots;
    % RR_interval Array[int] : return RR_interval, the num should = R - 1; 
    
    [a,points] = get_Hb(s,time_start,time_end);
    clear a;
    t = 1:length(s);
    t = t / 360;
    max_num = 0;
    R = [];
    for i = 1:length(points)
        max = 0;
        for j = points(i): points(i) + 72
            if j >= length(s) - 1
                break;
            end
            if (s(j+1)>=s(j)) && (s(j+1)>=s(j+2))
                if max <= s(j+1)
                      max = s(j+1);
                      max_num = j+1;
                end
            end
                 
        end
        R = [R,max_num];
    end
    RR_interval = [];
    for i = 1:length(R)-1
        interval = R(i+1) - R(i);
        RR_interval = [RR_interval,interval]; 
    end
    RR_interval = RR_interval/360;
    %figure;
        %plot(t,s);
        %xlabel('Seconds(s)');
        %ylabel('Amplitude(mV)');
        %hold on;
        %plot(t(R),s(R),'.r');
        %plot(t(points),s(points),'.b');
        %legend('Signal','Rwave');
        %saveas(gcf,'Fig/Problem6.jpg')
        
end

function Hb = get_Hb_5s(file_path)

    Hb = [];
    for i = 0:25
        time_start = i;
        time_end = i + 5;
        [t,s] = get_data(file_path,time_start,time_end);
        [R,RR_interval] = get_Rwave(s,time_start,time_end);
        %[avg_Hb,points] = get_Hb(s, time_start, time_end);
        rr_interval = mean(RR_interval);
        hb = 60 / rr_interval;
        Hb = [Hb, hb];
        Hb = Hb;
    end

end

function [s,s_low] = baseline_filter(s1,fs,fmax)
    [b,a] = butter(1,fmax*2/fs,'low');
    s_low = filtfilt(b,a,s1);
    s = s1 - s_low;

end

function s = bandpass_60(s1,fs)

    d = designfilt('bandstopiir','FilterOrder',2, ...
               'HalfPowerFrequency1',59,'HalfPowerFrequency2',61, ...
               'DesignMethod','butter','SampleRate',fs);
    s= filtfilt(d,s1); 
end


function y = wavelet_bandpass(s,wname,lev)   
    [c,l] = wavedec(s,lev,wname);
    A = appcoef(c,l,wname,lev); % Extract low frequency part
    D = zeros(1,lev);
    for i = 1:lev
        d = [];
        d = detcoef(c,l,i);
        d = zeros(1,length(d));
        D = [D,d];
    end
    c2 = [A',D];
    y = waverec(c2,l,wname);
    
end

function y = wavelet_filter(s,wname,lev) 
    [c,l] = wavedec(s,lev,wname);
    A = appcoef(c,l,wname,lev); % Extract low frequency part
    D1=detcoef(c,l,1);
    D2=detcoef(c,l,2);
    D3=detcoef(c,l,3);
    D4=detcoef(c,l,4);
    D5=detcoef(c,l,5);
    D6=detcoef(c,l,6);
    D7=detcoef(c,l,7);
    D8=detcoef(c,l,8);
    D1= zeros(1,length(D1))'; %去掉高频噪声
    D2= zeros(1,length(D2))';
    D3 = zeros(1,length(D2))';
    D4 = zeros(1,length(D2))';
    A=zeros(1,length(A));
    C2 = [A,D8',D7',D6',D5',D4',D3',D2',D1']; 
    y = waverec(C2,l,wname);
end