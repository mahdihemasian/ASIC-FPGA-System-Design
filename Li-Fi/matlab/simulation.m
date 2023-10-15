clear all;
clc;
close all;
Codeword_length = 7;     % Codeword length
Message_length = 4;      % Message length
PAN_levels = 4;          % PAM Length
Hadamard_order = 16;     % hadamard Length
total_number_input_data = Message_length*log2(PAN_levels)*(Hadamard_order-1)*200;
number_codding_frame = total_number_input_data/Message_length;
total_number_encode_data = Codeword_length*number_codding_frame;
number_lifi_frame = total_number_encode_data/log2(PAN_levels)/(Hadamard_order-1);

input_data = randi([0 1],total_number_input_data,1);    % initialize input data vector with random valeu
encode_data = zeros(total_number_encode_data,1);        % initialize encoded data vector
output_data = zeros(total_number_input_data,1);         % initialize decoded data vector
input_vector_Hadamard_matrix = fi(zeros(1,Hadamard_order),0,log2(PAN_levels),0);           % input hadamard vector 
output_vector_hadamard_matrix = fi(zeros(1,Hadamard_order),0,log2(PAN_levels),0);          % output hadamard vector 
output_hadamard_transmitter  = zeros(number_lifi_frame,Hadamard_order);
output_hadamard_reciever  = zeros(total_number_input_data,1);
% encode data
for i = 1:number_codding_frame
    encode_data((i-1)*Codeword_length+1:i*Codeword_length) = ...
        encode(input_data((i-1)*Message_length+1:i*Message_length),Codeword_length,Message_length,'hamming/binary');
end

% Hadamard transmitter

H = hadamard(Hadamard_order);           % create Hadamard matrix
H(H==-1)=0;                             % binary Hadamard
H = fi(H,1,2,0);                        % fixe pointing hadamard matrix 
Hb=1-H;                                 % complement of H   

trans_bias = ones(1,Hadamard_order);
trans_bias(1,1)=0;
trans_bias=fi(trans_bias.*(Hadamard_order/2),1,log2(Hadamard_order/2)+2,0);        % create trans_bias vector

for k = 1 : number_lifi_frame      % iteration through Hadamard frames 
    input_vector_Hadamard_matrix(1)=fi(0,0,log2(PAN_levels),0); 
    for i = 2 : Hadamard_order 
        PAM_symbol = 0;
        for j = 1:log2(PAN_levels) % PAM modulation
            PAM_symbol = PAM_symbol + encode_data((k-1)*(log2(PAN_levels)*(Hadamard_order-1))+log2(PAN_levels)*(i-2)+j)*2^(j-1);
        end
        input_vector_Hadamard_matrix(i)=fi(PAM_symbol,0,log2(PAN_levels),0); 
    end

    y = input_vector_Hadamard_matrix * (H - Hb);       % matrix multiplication
    y = y + trans_bias;                                % trans_biassing
    output_hadamard_transmitter(k,:) = y - min(y);              % level shifting
    output_hadamard_transmitter(k,:)= fi(output_hadamard_transmitter(k,:),0,log2(PAN_levels)+log2(Hadamard_order)+1,0);
    
end



% reciever

rec_bias = ones(1,Hadamard_order);
rec_bias(1,1) = 1-Hadamard_order;
rec_bias = rec_bias.*(1/2);                 % iteration through Hadamard frames
rec_bias=fi(rec_bias,1,log2(PAN_levels)+2,1); 

% Simulating AWGN channel with varying SNR and plotting BER

% Define the SNR values (in dB)
snr_values = 1:20;

% Initialize the BER vector
ber = zeros(1, length(snr_values));

% Simulate the AWGN channel for each SNR value 

for i = 1:length(snr_values) 
    output_AWGN_channel = fi(awgn(double(output_hadamard_transmitter),snr_values(i)),0,log2(PAN_levels)+log2(Hadamard_order)+1,0);
    
    output_hadamard_transmitter(k,:)= fi(output_hadamard_transmitter(k,:),1,log2(PAN_levels)+log2(Hadamard_order)+2,0);
    clear output_vector_hadamard_matrix output_hadamard_reciever;
    % Hadamard reciever
    for k = 1 : number_lifi_frame        % iteration through Hadamard frames
        output_vector_hadamard_matrix(k,:) = fi(output_AWGN_channel(k,:)*(H'-Hb'),1,2*log2(Hadamard_order)+log2(PAN_levels)+2,0); % matrix multiplication
        output_vector_hadamard_matrix(k,:) = fi(1/Hadamard_order*output_vector_hadamard_matrix(k,:) + rec_bias ,1,2*log2(Hadamard_order)+log2(PAN_levels)+3,1);% rec_biassing
    end
    output_vector_hadamard_matrix=fi(output_vector_hadamard_matrix,0,log2(PAN_levels),0);
    for k = 1 : number_lifi_frame        % iteration through Hadamard frames
        for m = 2 : Hadamard_order
             
            PAM_symbol = bin(output_vector_hadamard_matrix(k,m));
            for j = 1:log2(PAN_levels)
                output_hadamard_reciever((k-1)*(log2(PAN_levels)*(Hadamard_order-1))+log2(PAN_levels)*(m-2)+j)=...
                    str2num(PAM_symbol(log2(PAN_levels)-j+1)); %PAM demodulation
            end
        end
    end
    
    % decoding 
    for j = 1:number_codding_frame
        output_data((j-1)*Message_length+1:j*Message_length) = ...
            decode(output_hadamard_reciever((j-1)*Codeword_length+1:j*Codeword_length),Codeword_length,Message_length,'hamming/binary');
    end
    
    numerr = biterr(output_data,input_data);
        
    % Calculate the bit error rate
    ber(i) = numerr / total_number_input_data;
end

% Plot the BER vs SNR
figure;
plot(snr_values, ber, 'bo-');
grid on;
xlabel('SNR (dB)');
ylabel('Bit Error Rate (BER)');
title('BER vs SNR');

