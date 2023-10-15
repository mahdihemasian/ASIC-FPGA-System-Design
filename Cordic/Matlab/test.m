clear all; clc;


fileID = fopen('hex.txt','r');
a = fscanf(fileID,'%x');
fclose(fileID);



fileID = fopen('matlab_ans.txt','w');

for i = 1:11
   
phi = cordic(a(2*i-1),a(2*i));

fprintf(fileID,'%s\n',phi);
 
    
    
end
fclose(fileID);