
clc; clear; close all;

%% Step 1: Text to Binary
message = 'HELLO';
binary_data = reshape(dec2bin(message, 8).'-'0', 1, []);
disp('Original Binary Data:');
disp(binary_data);

%% Step 2: FSK Modulation
fs = 44100;             % Sampling frequency
bit_duration = 0.1;     % Duration of each bit (in seconds)
t = 0:1/fs:bit_duration-1/fs;

f0 = 1000;              % Frequency for bit 0
f1 = 2000;              % Frequency for bit 1

modulated_signal = [];
for bit = binary_data
    if bit == 0
        tone = sin(2*pi*f0*t);
    else
        tone = sin(2*pi*f1*t);
    end
    modulated_signal = [modulated_signal tone];
end

%% Step 3: Save Audio File
filename = 'acoustic_output.wav';
audiowrite(filename, modulated_signal, fs);
disp(['Audio saved as: ', filename]);

%% Step 4: Plot Zoomed View (First 3 Bits)
num_bits_to_plot = 3;
samples_to_plot = fs * bit_duration * num_bits_to_plot;
figure;
plot(modulated_signal(1:samples_to_plot));
title('FSK Modulated Wave (First 3 Bits)');
xlabel('Sample Index');
ylabel('Amplitude');

%% Step 5: Demodulate Received Audio
samples_per_bit = length(t);
demodulated_bits = [];

for i = 1:samples_per_bit:length(modulated_signal)
    if i + samples_per_bit - 1 > length(modulated_signal)
        break;
    end
    chunk = modulated_signal(i:i+samples_per_bit-1);
    Y = abs(fft(chunk));
    f = (0:length(Y)-1)*fs/length(Y);
    [~, idx] = max(Y(1:floor(end/2)));  % Only look at positive freqs
    peak_freq = f(idx);

    if abs(peak_freq - f0) < abs(peak_freq - f1)
        demodulated_bits = [demodulated_bits 0];
    else
        demodulated_bits = [demodulated_bits 1];
    end
end

%% Step 6: Convert Binary Back to Text
nBits = floor(length(demodulated_bits)/8)*8;
demodulated_bits = demodulated_bits(1:nBits);
char_array = char(bin2dec(reshape(char(demodulated_bits + '0'), 8, []).')).';
disp(['Decoded Message: ', char_array]);
