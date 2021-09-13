clear;clc;close all;


%% 集装箱参数
c_len = 6.058;
c_wid = 2.438;
c_hei = 2.591;

%前后间隔(可变)
l_interval = 0.076;
w_interval = 0.080;
u_interval = 0.030;

%% 信号参数
extract_accuracy = 0.01;                                     %10mm为精度进行边缘提取
data_step = 0.01;                                            %文件采样间隔10mm
T = 0.001;                                                   %插值后，采样间隔相当于1mm = 0.001m
fs = 1/T;                                                    %采样频率
%ante_location = [-l_interval/2 c_wid/2 c_hei+u_interval/2]; %天线坐标-靠前端板宽棱中点
%ante_location = [c_len+l_interval/2 c_wid/2 c_hei+u_interval/2];  %天线坐标-靠门板宽棱中点
ante_location = [c_len+l_interval/2 c_wid+w_interval/2 c_hei+u_interval/2];  %天线坐标-门板右顶角点


%% 433MHz 顶棱中点 顶面 路径损耗分析
[path_loss,P_total,Axis1,Axis2,sort_P,sort_loss,sort_d,sort_d1,sort_d2] = power_process(520,'P433Clside',ante_location,data_step,T,extract_accuracy,'side');

%% 边缘提取，对上界和下界分别拟合

[upper,lower,d,d1,d2] = edge_extract(sort_d, sort_d1, sort_d2, sort_loss, extract_accuracy);

%% 绘制
figure;
surf(Axis1,Axis2, P_total);xlabel('X(length)/m');ylabel('Y(width)/m');zlabel('Z(Pav)/(W/m^2)');title('平均坡印廷矢量幅度vs坐标 f=433M 左侧面 天线门板右顶角');
shading interp;

figure;
surf(Axis1,Axis2,path_loss);xlabel('X(Distance)/m');ylabel('Y(PathLoss)/dB');title('路径损耗vs坐标 f=433M 左侧面 天线门板右顶角');
shading interp;

figure;
plot( sort_d, sort_P,'.' );xlabel('X(Distance)/m');ylabel('Y(Pav)/(W/m^2)');title('平均坡印廷矢量幅度vs距离 f=433M 左侧面 天线门板右顶角');

figure;
plot(sort_d,sort_loss);hold on;
plot(d,upper,'.-k');hold on;
plot(d,lower,'--r');xlabel('X(Distance)/m');ylabel('Y(PathLoss)/dB');legend('上界','下界');title('路径损耗vs距离 f=868M f=433M 左侧面 天线门板右顶角');