clc; clear all;
N = 16;                 % Length of Walsh (Hadamard) functions
M = 8;                   % PAM Length
u = randi([0 M-1],100,N);  % create random number

y = u*hadamard(N);

fileID = fopen('input_mult.mem','w');
for j = 1 : 100
    for i = N : -1 : 1 
        fprintf(fileID,"%02x",u(j,i));
    end
    fprintf(fileID,"\n");
end
fclose(fileID);



fileID = fopen('output_mult.mem','w');
for j = 1 : 100
    for i = N : -1 : 1 
        fprintf(fileID,"%s",dec2hex(y(j,i),3));
    end
    fprintf(fileID,"\n");
end
fclose(fileID);
%%
clc
f = fi(-3,1,16,0)<0
 s = dec2hex(-3)
        while length(s)<2
            if(f)
                s = append('F',s)
            else
                s = append('0',s);
            end
        end
        s