
%% 0: Clean up
clear; clc;
close all


%% 1: Set file path

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Specify the location of the libsvm/matlab folder  %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

dir_lib     = ['C:\Fall 2023\ENME691\assignement2\libsvm\matlab\'];

%% 2: Import data

%%%%%%%%%%%%%%%%%%%
% Write your code %
%%%%%%%%%%%%%%%%%%%

% Make sure you change file path

healthy_fileList = dir(fullfile("C:\Fall 2023\ENME691\assignement2\Training\Healthy\", "*.txt"));
faulty1_fileList = dir(fullfile("C:\Fall 2023\ENME691\assignement2\Training\Faulty\Unbalance 1\", "*.txt"));
faulty2_fileList = dir(fullfile("C:\Fall 2023\ENME691\assignement2\Training\Faulty\Unbalance 2\", "*.txt"));
test_fileList = dir(fullfile("C:\Fall 2023\ENME691\assignement2\Testing\", "*.txt"));

% Predefine a 38400 by 20 matrix for normal and faulty data
% 38400 per samples at 20 samples for each dataset
normal_data = zeros(38400, 20);
faulty1_data = zeros(38400, 20);
faulty2_data = zeros(38400, 20);
test_data = zeros(38400, 30);

% Declare an empty array to store the first peak amplitude value after FFT
normal_amplitude = zeros(20,3);
faulty1_amplitude = zeros(20,3);
faulty2_amplitude = zeros(20,3);
test_amplitude = zeros(30,3);

% read from line 6 onwards to until the end of the txt file
datalines = [6, Inf];

% Loop through and read each file for healthy and faulty data
for i = 1:20
    healthy_fileName = "C:\Fall 2023\ENME691\assignement2\Training\Healthy\" + healthy_fileList(i,1).name;
    bad1_fileName = "C:\Fall 2023\ENME691\assignement2\Training\Faulty\Unbalance 1\" + faulty1_fileList(i,1).name;
    bad2_fileName = "C:\Fall 2023\ENME691\assignement2\Training\Faulty\Unbalance 2\" + faulty2_fileList(i,1).name;

    % Import the file data
    healthy_data = import_file_data(healthy_fileName, datalines);
    bad1_data = import_file_data(bad1_fileName, datalines);
    bad2_data = import_file_data(bad2_fileName, datalines);

    % Transcribe it to matrix
    for j = 1:38400
        normal_data(j,i) = healthy_data(j,1);
        faulty1_data(j,i) = bad1_data(j,1);
        faulty2_data(j,i) = bad2_data(j,1);
    end

end

% Loop through and read each file for test data
for i = 1:30
    test_fileName = "C:\Fall 2023\ENME691\assignement2\Testing\" + test_fileList(i,1).name;
    
    % Import the file data
    temp_test_data = import_file_data(test_fileName, datalines);

    % Transcribe it to matrix
    for j = 1:38400
        test_data(j,i) = temp_test_data(j,1);
    end

end

%% 3: Feature extraction / FFT

%%%%%%%%%%%%%%%%%%%
% Write your code %
%%%%%%%%%%%%%%%%%%%

Fs = 2560;            % Sampling frequency                    
T = 1/Fs;             % Sampling period       
L = 38400;            % Length of signal
f = Fs/L*(0:(L/2-1));

frequency_bins = [10 30; 30 50; 50 70];

% Loop through each sample-set and perform FFT and record first peak
for i = 1:20
    
    % Load healthy dataset values
    X = normal_data(:,i);

    for j = 1:3
        X2 = bandpass(X,frequency_bins(j,:),Fs);
        
        % Perform FFT for Single-Sided Amplitude Spectrum
        Y = fft(X2);
        P2 = abs(Y/L);
        P1 = P2(1:L/2);
        P1(2:end-1) = 2*P1(2:end-1);
        
        % Record the first harmonic peak
        normal_amplitude(i,j) = max(P1);
    end
end

% Repeat but for faulty Unbalance 1 dataset
for i = 1:20
    Fs = 2560;            % Sampling frequency                    
    T = 1/Fs;             % Sampling period       
    L = 38400;            % Length of signal
    
    X = faulty1_data(:,i);

    for j = 1:3
        X2 = bandpass(X,frequency_bins(j,:),Fs);

        Y = fft(X2);
        P2 = abs(Y/L);
        P1 = P2(1:L/2);
        P1(2:end-1) = 2*P1(2:end-1);
            
        faulty1_amplitude(i,j) = max(P1);
    end
end

% Repeat but for faulty Unbalance 2 dataset
for i = 1:20   
    X = faulty2_data(:,i);

    for j = 1:3
        X2 = bandpass(X,frequency_bins(j,:),Fs);

        Y = fft(X2);
        P2 = abs(Y/L);
        P1 = P2(1:L/2);
        P1(2:end-1) = 2*P1(2:end-1);
        
        faulty2_amplitude(i,j) = max(P1);
    end
end

% Repeat but for testing dataset
for i = 1:30   
    X = test_data(:,i);

    for j = 1:3
        X2 = bandpass(X,frequency_bins(j,:),Fs);

        Y = fft(X2);
        P2 = abs(Y/L);
        P1 = P2(1:L/2);
        P1(2:end-1) = 2*P1(2:end-1);
        
        test_amplitude(i,j) = max(P1);
    end
end

%% Plot Feature View graph
% figure
% plot(normal_amplitude(:,1), '-b*')
% grid on
% title('Feature View at 1X Harmonic');
% xlabel('Sample Number');
% ylabel('Amplitude');
% hold on
% plot(faulty1_amplitude(:,1), '-square', 'Color', "#00841a")
% plot(faulty2_amplitude(:,1), '-ro')
% hold off
% legend('Healthy Amplitude', 'Unbalanced 1 Amplitude', 'Unbalanced 2 Amplitude');
% 
% figure
% plot(normal_amplitude(:,2), '-b*')
% grid on
% title('Feature View at 2X Harmonic');
% xlabel('Sample Number');
% ylabel('Amplitude');
% hold on
% plot(faulty1_amplitude(:,2), '-square', 'Color', "#00841a")
% plot(faulty2_amplitude(:,2), '-ro')
% hold off
% legend('Healthy Amplitude', 'Unbalanced 1 Amplitude', 'Unbalanced 2 Amplitude');
% 
% figure
% plot(normal_amplitude(:,3), '-b*')
% grid on
% title('Feature View at 3X Harmonic');
% xlabel('Sample Number');
% ylabel('Amplitude');
% hold on
% plot(faulty1_amplitude(:,3), '-square', 'Color', "#00841a")
% plot(faulty2_amplitude(:,3), '-ro')
% hold off
% legend('Healthy Amplitude', 'Unbalanced 1 Amplitude', 'Unbalanced 2 Amplitude');
% 
% figure
% plot(test_amplitude(:,1), '-b*')
% grid on
% title('Feature View at 1X Harmonic');
% xlabel('Sample Number');
% ylabel('Amplitude');
% hold on
% legend('Test Amplitude');
% hold off

%% 4: Plot signals, features

%%%%%%%%%%%%%%%%%%%
% Write your code %
%%%%%%%%%%%%%%%%%%%

%% 

%fs = 2560hz
mean_normal = zeros(20,2);
mean_faulty2 = zeros(20,2);
mean_faulty1 = zeros(20,2);
mean_test = zeros(30,2);

fpass = 70;
interval = 10;

for i = 1:20
    X = lowpass(normal_data(:,i), fpass, Fs);
    % lowpass(faulty2_data(:,1), 70, Fs);
    
    [upper, lower] = envelope(X, interval, 'peak');
    mean_normal(i,1) = mean(upper);
    mean_normal(i,2) = mean(lower);
end


for i = 1:20
    X = lowpass(faulty1_data(:,i), fpass, Fs);
    % lowpass(faulty2_data(:,1), 70, Fs);
    
    [upper, lower] = envelope(X, interval, 'peak');
    mean_faulty1(i,1) = mean(upper);
    mean_faulty1(i,2) = mean(lower);
end


for i = 1:20
    X = lowpass(faulty2_data(:,i), fpass, Fs);
    % lowpass(faulty2_data(:,1), 70, Fs);
    
    [upper, lower] = envelope(X, interval, 'peak');
    mean_faulty2(i,1) = mean(upper);
    mean_faulty2(i,2) = mean(lower);
end

for i = 1:30
    X = lowpass(test_data(:,i), fpass, Fs);
    % lowpass(faulty2_data(:,1), 70, Fs);
    
    [upper, lower] = envelope(X, interval, 'peak');
    mean_test(i,1) = mean(upper);
    mean_test(i,2) = mean(lower);
end

%
% figure
% scatter(normal_amplitude(:,1), std_normal, 'bo')
% hold on
% scatter(faulty1_amplitude(:,1), std_faulty1, 'ro')
% scatter(faulty2_amplitude(:,1), std_faulty2, 'ko')
% scatter(test_amplitude(:,1), std_test, 'go')
% hold off
% 
%
% figure
% plot(std_normal, '-bo')
% hold on
% plot(std_faulty1, '-ro')
% plot(std_faulty2, '-ko')
% hold off

%% 5. SVM

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Before this section, you need prepare 
%  - FeatMat_train: Feature matrix for training data
%  - FeatMat_test : Feature matrix for testing data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% For all the five features
normal_features = [normal_amplitude(:,(1:2)) mean_normal];
faulty1_features = [faulty1_amplitude(:,(1:2)) mean_faulty1];
faulty2_features = [faulty2_amplitude(:,(1:2)) mean_faulty2];

%For first harmonic only
% normal_features = [normal_amplitude(:,1)];
% faulty1_features = [faulty1_amplitude(:,1)];
% faulty2_features = [faulty2_amplitude(:,1)];

% For all frequency domain harmoics
% normal_features = [normal_amplitude(:,(1:2))];
% faulty1_features = [faulty1_amplitude(:,(1:2))];
% faulty2_features = [faulty2_amplitude(:,(1:2))];

%For first harmonic and 
% normal_features = [normal_amplitude(:,1) mean_normal(:,1)];
% faulty1_features = [faulty1_amplitude(:,1) mean_faulty1(:,1)];
% faulty2_features = [faulty2_amplitude(:,1) mean_faulty2(:,1)];

FeatMat_train = [normal_features; faulty1_features; faulty2_features];
FeatMat_test = [test_amplitude(:,(1:2)) mean_test];

cd(dir_lib)

N_train = 60;
Nh = 20;    % number of healthy
Nf1 = 20;   % number of faulty1

% Training data
Train_X = FeatMat_train;
Train_Y = zeros(N_train,1);
Train_Y(1:Nh,1) = 1;                % 1 means healthy
Train_Y(Nh+1:Nh+Nf1,1) = 2;         % 2 means unbalanced 1 screw
Train_Y(Nh+Nf1+1:N_train,1) = 3;    % 3 means unbalanced 2 screw

% Test Data
Test_X = FeatMat_test;
Test_Y = zeros(30,1);
Test_Y( 1:10,1) = 1;
Test_Y(11:20,1) = 2;
Test_Y(21:30,1) = 3;

% train SVM with different kernel

Method_list = {'rbf','linear','polynomial','Sigmoid'}; % kernel function selection

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Here you can select kernel function 
% Try different kernel and check the results
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Method = Method_list{4}; % 1: rbf, 2: linear, 3: polynomial, 4: softmargin

switch Method
    case 'rbf'  
            svmStruct = libsvmtrain(Train_Y,Train_X,'-s 0 -t 2 -g 0.333 -c 1');
            % refer to README file in libsvm for more infomation

    case 'linear'
            svmStruct = libsvmtrain(Train_Y,Train_X,'-s 0 -t 0 -g 0.333 ');
        
    case 'polynomial'
            svmStruct = libsvmtrain(Train_Y,Train_X,'-s 0 -t 1 -g 0.333 ');
            
    case 'Sigmoid'
        svmStruct = libsvmtrain(Train_Y,Train_X,'-s 0 -t 3 -g 0.333 ');
        
end

% Test and predict label
% use trained SVM model for classification
[predicted_result, accuracy,~] = svmpredict(Test_Y,Test_X,svmStruct);


%% 6. Confusion Matrix

%%%%%%%%%%%%%%%%%%%
% Write your code %
%%%%%%%%%%%%%%%%%%%

hold off

class1 = 1 * ones(10,1);
class2 = 2 * ones(10,1);
class3 = 3 * ones(10,1);

all_classes = [class1; class2; class3];

g1 = all_classes';	% Known groups
g2 = predicted_result';	% Predicted groups

C = confusionmat(g1,g2);
confusionchart(C)

% plot(predicted_result)