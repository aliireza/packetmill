PM_TH = readtable("csv/PacketMillTHROUGHPUT.csv");
PM_TH.Properties.VariableNames = {'WP_N', 'WP_S', 'WP_W', 'run1', 'run2', 'run3', 'run4', 'run5'};
PM_TH.avg=mean(PM_TH{:,4:end},2);

VN_TH = readtable("csv/VanillaTHROUGHPUT.csv");
VN_TH.Properties.VariableNames = {'WP_N', 'WP_S', 'WP_W', 'run1', 'run2', 'run3', 'run4', 'run5'};
VN_TH.avg=mean(VN_TH{:,4:end},2);

diff = PM_TH(:,1:3);
diff.TH_IMP_P = (PM_TH.avg - VN_TH.avg)*100./ VN_TH.avg;
diff.TH_IMP = (PM_TH.avg - VN_TH.avg);
diff.VN_TH = VN_TH.avg;

[X,Y] = meshgrid(0:20,[0,4,8,12,16,20]);

 map_1 = [1.0 1.0 1.0
     1.0 1.0 0.8
    0.85 0.94 0.64
    0.68 0.87 0.56
    0.47 0.78 0.47
    0.19 0.64 0.33
    0.0 0.41 0.22];

 map_2 = [1.0 1.0 1.0
     1.0 1.0 0.8
    0.94 0.98 0.91
    0.73 0.89 0.74
    0.48 0.80 0.77
    0.26 0.64 0.79
    0.03 0.41 0.67];
colormap(map_1)

IMP_TH_P=diff(diff.WP_N==1,:).TH_IMP_P;
TH_BASE=diff(diff.WP_N==1,:).VN_TH;
Z = (reshape(IMP_TH_P,21,6))';
C = (reshape(TH_BASE,21,6))' ./ 1000000000;


h1 = surf(X,Y,Z,C);
xlim([0,20]);
xlabel("Memory Intensiveness");
ylim([0,20]);
ylabel("Compute Intensiveness");
zlim([0 inf]);
zlabel("Throughput Improvements (%)");
cl = colorbar;
ylabel(cl, "Vanilla Throughput (Gbps)");
caxis([0 max(VN_TH.avg)/1000000000]);
legend([h1], {'1 Access PP'});

figure 

h1 = surf(X,Y,Z,C);
xlim([0,20]);
xlabel("Memory Intensiveness");
ylim([0,20]);
ylabel("Compute Intensiveness");
zlim([0 inf]);
zlabel("Throughput Improvements (%)");
cl = colorbar;
ylabel(cl, "Vanilla Throughput (Gbps)");
caxis([0 max(VN_TH.avg)/1000000000]);
colormap(map_1)


hold on

IMP_TH_P=diff(diff.WP_N==5,:).TH_IMP_P;
TH_BASE=diff(diff.WP_N==5,:).VN_TH;
Z = (reshape(IMP_TH_P,21,6))';
C = (reshape(TH_BASE,21,6))' ./ 1000000000;


h2 = surf(X,Y,Z,C);
%colormap(map_2)
legend([h1, h2], {'1 Access PP', '5 Access PP'});
 