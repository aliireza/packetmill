PM_TH = readtable("PacketMillTHROUGHPUT.csv");
PM_TH.Properties.VariableNames = {'WP_N', 'WP_S', 'WP_W', 'run1', 'run2', 'run3', 'run4', 'run5'};
PM_TH.avg=mean(PM_TH{:,4:end},2);

VN_TH = readtable("VanillaTHROUGHPUT.csv");
VN_TH.Properties.VariableNames = {'WP_N', 'WP_S', 'WP_W', 'run1', 'run2', 'run3', 'run4', 'run5'};
VN_TH.avg=mean(VN_TH{:,4:end},2);

diff = PM_TH(:,1:3);
diff.TH_IMP_P = (PM_TH.avg - VN_TH.avg)*100./ VN_TH.avg;
diff.TH_IMP = (PM_TH.avg - VN_TH.avg);
diff.VN_TH = VN_TH.avg;

[X,Y] = meshgrid(0:20,[0,4,8,12,16,20]);

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


hold on

IMP_TH_P=diff(diff.WP_N==5,:).TH_IMP_P;
TH_BASE=diff(diff.WP_N==5,:).VN_TH;
Z = (reshape(IMP_TH_P,21,6))';
C = (reshape(TH_BASE,21,6))' ./ 1000000000;


h2 = surf(X,Y,Z,C);
legend([h1, h2], {'1 Access PP', '5 Access PP'});
 