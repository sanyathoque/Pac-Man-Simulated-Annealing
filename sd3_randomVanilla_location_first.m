clear all;clc;
% sd3_randomVanilla_location_first
load vanilla_2a.mat
x2a = [distance1_array1;
     distance1_array2;
     distance1_array3;
     distance1_array4;
     distance1_array5;
     distance1_array6;
     distance1_array7;
     distance1_array8;
     distance1_array9;
     distance1_array10;
     distance1_array11;
     distance1_array12;
     distance1_array13;
     distance1_array14;
     distance1_array15;
     distance1_array16;
     distance1_array17(1:400);
     distance1_array18 zeros(1,400-296);
     distance1_array19;
     distance1_array20 zeros(1,400-258);];

% x = [1 2 3 5;
%     4 5 6 5;
%     7 8 9 5];
% A = sum(x(1:3,1))/3
% B = sum(x(1:3,2))/3
% C = sum(x(1:3,1:4))/3


mean2a = sum(x2a(1:20,1:400))/20   ; %row,clomn
sd2a = std(x2a) ;
upper_bound2a = mean2a+sd2a ;
lower_bound2a = mean2a-sd2a ;

save('mean2a.mat','mean2a');
save('sd2a.mat','sd2a');
save('upper_bound2a.mat','upper_bound2a');
save('lower_bound2a.mat','lower_bound2a');

save sd3.mat mean2a lower_bound2a upper_bound2a
%%
% load('distance1_array16a11.mat','distance1_array');
% distance1_array1 = distance1_array
% load('distance1_array16b11.mat','distance1_array');
% distance1_array2 = distance1_array
% load('distance1_array16c11.mat','distance1_array');
% distance1_array3 = distance1_array
% load('distance1_array16d11.mat','distance1_array');
% distance1_array4 = distance1_array
% load('distance1_array16e11.mat','distance1_array');
% distance1_array5 = distance1_array
% load('distance1_array16f11.mat','distance1_array');
% distance1_array6 = distance1_array
% load('distance1_array16g11.mat','distance1_array');
% distance1_array7 = distance1_array
% load('distance1_array16h11.mat','distance1_array');
% distance1_array8 = distance1_array
% load('distance1_array16i11.mat','distance1_array');
% distance1_array9 = distance1_array
% load('distance1_array16j11.mat','distance1_array');
% distance1_array10 = distance1_array
% load('distance1_array16k11.mat','distance1_array');
% distance1_array11 = distance1_array
% load('distance1_array16l11.mat','distance1_array');
% distance1_array12 = distance1_array
% load('distance1_array16m11.mat','distance1_array');
% distance1_array13 = distance1_array
% load('distance1_array16n11.mat','distance1_array');
% distance1_array14 = distance1_array
% load('distance1_array16o11.mat','distance1_array');
% distance1_array15 = distance1_array
% load('distance1_array16p11.mat','distance1_array');
% distance1_array16 = distance1_array
% load('distance1_array16q11.mat','distance1_array');
% distance1_array17 = distance1_array
% load('distance1_array16r11.mat','distance1_array');
% distance1_array18 = distance1_array
% load('distance1_array16s11.mat','distance1_array');
% distance1_array19 = distance1_array
% load('distance1_array16t11.mat','distance1_array');
% distance1_array20 = distance1_array
% save vanilla_3.mat distance1_array1 distance1_array2 distance1_array3 distance1_array4 distance1_array5 distance1_array6 distance1_array7 distance1_array8 distance1_array9 distance1_array10 distance1_array11 distance1_array12 distance1_array13 distance1_array14 distance1_array15 distance1_array16 distance1_array17 distance1_array18 distance1_array19 distance1_array20
% load vanilla_3.mat
% distance1_array1 = distance1_array
%%

% load('distance1_array16a.mat','distance1_array');
% distance1_array1 = distance1_array
% load('distance1_array16b.mat','distance1_array');
% distance1_array2 = distance1_array
% load('distance1_array16c.mat','distance1_array');
% distance1_array3 = distance1_array
% load('distance1_array16d.mat','distance1_array');
% distance1_array4 = distance1_array
% load('distance1_array16e.mat','distance1_array');
% distance1_array5 = distance1_array
% load('distance1_array16f.mat','distance1_array');
% distance1_array6 = distance1_array
% load('distance1_array16g.mat','distance1_array');
% distance1_array7 = distance1_array
% load('distance1_array16h.mat','distance1_array');
% distance1_array8 = distance1_array
% load('distance1_array16i.mat','distance1_array');
% distance1_array9 = distance1_array
% load('distance1_array16j.mat','distance1_array');
% distance1_array10 = distance1_array
% load('distance1_array16k.mat','distance1_array');
% distance1_array11 = distance1_array
% load('distance1_array16l.mat','distance1_array');
% distance1_array12 = distance1_array
% load('distance1_array16m.mat','distance1_array');
% distance1_array13 = distance1_array
% load('distance1_array16n.mat','distance1_array');
% distance1_array14 = distance1_array
% load('distance1_array16o.mat','distance1_array');
% distance1_array15 = distance1_array
% load('distance1_array16p.mat','distance1_array');
% distance1_array16 = distance1_array
% load('distance1_array16q.mat','distance1_array');
% distance1_array17 = distance1_array
% load('distance1_array16r.mat','distance1_array');
% distance1_array18 = distance1_array
% load('distance1_array16s.mat','distance1_array');
% distance1_array19 = distance1_array
% load('distance1_array16t.mat','distance1_array');
% distance1_array20 = distance1_array
% save vanilla_2a.mat distance1_array1 distance1_array2 distance1_array3 distance1_array4 distance1_array5 distance1_array6 distance1_array7 distance1_array8 distance1_array9 distance1_array10 distance1_array11 distance1_array12 distance1_array13 distance1_array14 distance1_array15 distance1_array16 distance1_array17 distance1_array18 distance1_array19 distance1_array20
% load vanilla_2a.mat