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
ante_location = [c_len+l_interval/2 c_wid/2 c_hei+u_interval/2];  %天线坐标-靠门板宽棱重点



%% 433MHz 顶棱中点 顶面 路径损耗分析
[PL,P,Axis1,Axis2,sort_P,sort_loss,sort_d,sort_d1,sort_d2] = power_process(4.1312e3,'P433Wup',ante_location,data_step,T,extract_accuracy,'up');
   

%% 边缘提取，对上界和下界分别拟合

[upper,lower,d,~,~] = edge_extract(sort_d, sort_d1, sort_d2, sort_loss, extract_accuracy);

%% 拟合曲线
%LoS路径

% 上界
alpha0 = 1.374;
alpha1 = 41.21;
upper_fit = 10*alpha0*log10(d)+alpha1;
% 下界
alpha0 = 0.6173;
alpha1 = 27.37;
lower_fit = 10*alpha0*log10(d)+alpha1;


%% 绘制
figure;
surf(Axis1,Axis2, P);xlabel('X(length)/m');ylabel('Y(width)/m');zlabel('Z(Pav)/(W/m^2)');title('P_a_v vs Coordinates(f=433M, Top Panel, location=width edge)');
shading interp;

figure;
surf(Axis1,Axis2,PL);xlabel('X(length)/m');ylabel('Y(width)/m');zlabel('Z(PathLoss)/dB');title('PathLoss v Cordinates(f=433M, Top Panel, location=width edge)');
shading interp;

figure;
plot( sort_d, sort_P,'.' );xlabel('X(Distance)/m');ylabel('Y(Pav)/(W/m^2)');title('P_a_v vs Distance(f=433M, Top Panel, location=width edge)');

figure;
plot(sort_d,sort_loss);hold on;
plot(d,upper,'.-k');hold on;
plot(d,lower,'--r');xlabel('X(Distance)/m');ylabel('Y(PathLoss)/dB');legend('Upperbound','Lowerbound');title('PathLoss v Distance(f=433M, Top Panel, location=width edge)');

% 拟合曲线与原始曲线的 2D图像
figure;
plot(d,upper_fit);hold on;
plot(d,upper);
xlabel('X(Distance)/m');ylabel('Y(PathLoss)/dB');legend('fitted curve','simulation curve');title('Top(upperbound)-PathLoss v Distance(f=433M,location=width edge)');

figure;
plot(d,lower_fit);hold on;
plot(d,lower);
xlabel('X(Distance)/m');ylabel('Y(PathLoss)/dB');legend('fitted curve','simulation curve');title('Top(lowerbound)-PathLoss v Distance(f=433M,location=width edge)');