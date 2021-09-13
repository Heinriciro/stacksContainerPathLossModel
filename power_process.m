function [PL,P,Axis1,Axis2,sort_P,sort_loss,sort_d,sort_d1,sort_d2] = power_process(Pmax,data_name,ante_location,data_step,interp_step,min_extract_range,mode,location_mode)

    url = strcat('mat/',data_name,'.mat');
    data_struct = load(url);
    data = getfield(data_struct,data_name);
    data = table2struct(data);
   

    %按照建立的模型，导出的上平面
    %x坐标范围为[-l_interval/2, length + l_interval/2]
    %y坐标范围为[-w_interval/2,  width + w_interval/2]
    %z坐标范围为[-u_interval/2,  hight + u_interval/2]
    %由于集装箱的尺寸不改变，只有间距是可以调整的，于是在程序中给定集装箱长度，将各方向间隔作为变量后续可调整

    %为了计算方便，在导入matlab后，将元模型的坐标范围映射至以天线坐标为轴心的直角坐标系?

    %%集装箱参数%
    c_len = 6.058;
    c_wid = 2.438;
    c_hei = 2.591;
    %%%%%%%%%%%%%
    
    %%前后间隔(可变)%%
    l_interval = 0.076;
    w_interval = 0.080;
    u_interval = 0.030;
    %%%%%%%%%%%%%%%%%


    x_start = -l_interval/2;
    x_end = c_len + l_interval/2;
    y_start = -w_interval/2;
    y_end = c_wid + w_interval/2;
    z_start = -u_interval/2;
    z_end = c_hei + u_interval/2;
    
    %%HFSS中取样的间隔(可变)%%
    x_step = data_step;
    y_step = x_step;
    z_step = y_step;
    %%%%%%%%%%%%%%%%%%%
    
    %%未映射的坐标矢量%%
    x = x_start : x_step : x_end ;
    y = y_start : y_step : y_end ;
    z = z_start : z_step : z_end ;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %%坐标长度%%
    x_len = length(x);
    y_len = length(y);
    z_len = length(z);
    %%%%%%%%%%%%%%%%%%%    
   
    
    if(strcmp(mode,'up')||strcmp(mode,'bottom'))
        
        dim1 = x_len;
        dim2 = y_len;
        axis1 = x;
        axis2 = y;

    elseif(strcmp(mode,'side')||strcmp(mode,'leftside'))
        dim1 = x_len;
        dim2 = z_len;
        
        axis1 = x;
        axis2 = z;
    elseif(strcmp(mode,'door')||strcmp(mode,'front'))
        dim1 = y_len;
        dim2 = z_len;
        
        axis1 = y;
        axis2 = z;
        
    end
    
    
    
    Px = zeros(dim1,dim2);
    Py = zeros(dim1,dim2);
    Pz = zeros(dim1,dim2);
    P = zeros(dim1,dim2);
    dis = zeros(dim1,dim2);
    d1 = zeros(dim1,dim2);
    d2 = zeros(dim1,dim2);

    for a=1:dim1
        for b=1:dim2
            Px(a, b) = data((a-1)*dim2+b).Px;
            Py(a, b) = data((a-1)*dim2+b).Py;
            Pz(a, b) = data((a-1)*dim2+b).Pz;
            
            x_c = data((a-1)*dim2+b).x;
            y_c = data((a-1)*dim2+b).y;
            z_c = data((a-1)*dim2+b).z;

            P(a, b) = 1/sqrt(3)*sqrt( Px(a, b)^2 + Py(a, b)^2 + Pz(a, b)^2 );
            
            if(strcmp(mode,'up'))
                   dis(a, b) = sqrt((abs(ante_location(3) - z_c) + abs(ante_location(2)-y_c))^2 + (x_c - ante_location(1))^2);
                   d1(a, b) = abs(ante_location(3) - z_c)*dis(a, b)/(abs(ante_location(3) - z_c) + abs(ante_location(2)-y_c));
                   d2(a, b) = dis(a, b) - d1(a, b);
            elseif(strcmp(mode,'side'))
                dis(a, b) = sqrt((abs(ante_location(3) - z_c) + abs(ante_location(2)-y_c))^2 + (x_c - ante_location(1))^2);
                d1(a, b) = abs(ante_location(2)-y_c)*dis(a,b)/(abs(ante_location(3) - z_c) + abs(ante_location(2)-y_c));
                d2(a, b) = dis(a, b) - d1(a, b);
            elseif(strcmp(mode,'leftside'))
                dis(a, b) = sqrt((abs(ante_location(2)-y_c)+abs(ante_location(1)-x_c))^2+abs(ante_location(3)-z_c)^2);
                d1(a, b) = (ante_location(2)-y_c)*dis(a, b)/(abs(ante_location(2)-y_c)+abs(ante_location(1)-x_c));
                d2(a, b) = dis(a, b) - d1(a, b);
            elseif(strcmp(mode,'door'))
                dis(a, b) = sqrt((abs(ante_location(3) - z_c) + abs(ante_location(1)-x_c))^2 + (y_c - ante_location(2))^2);
                d1(a, b) = abs(ante_location(1)-x_c)*dis(a,b)/(abs(ante_location(3) - z_c) + abs(ante_location(1)-x_c));
                d2(a, b) = dis(a, b) - d1(a, b);
            elseif(strcmp(mode,'front'))
                if(strcmp(location_mode,'heightedge'))
                    dis(a, b) = sqrt((abs(ante_location(1) - x_c) + abs(ante_location(2)-y_c))^2 + (z_c - ante_location(3))^2);
                    d1(a, b) = abs(ante_location(1)-x_c)*dis(a,b)/(abs(ante_location(1) - x_c) + abs(ante_location(2)-y_c));
                    d2(a, b) = dis(a, b) - d1(a, b);
                else
                    dis(a, b) = sqrt((abs(ante_location(3) - z_c) + abs(ante_location(1)-x_c))^2 + (y_c - ante_location(2))^2);
                    d1(a, b) = abs(ante_location(1)-x_c)*dis(a,b)/(abs(ante_location(3) - z_c) + abs(ante_location(1)-x_c));
                    d2(a, b) = dis(a, b) - d1(a, b);
                end
            elseif(strcmp(mode,'bottom'))
                if(strcmp(location_mode,'corner')||strcmp(location_mode,'heightedge'))
                    dis(a, b) = sqrt((abs(ante_location(3) - z_c) + abs(ante_location(2)-y_c))^2 + (x_c - ante_location(1))^2);
                    d1(a, b) = abs(ante_location(3)-z_c)*dis(a,b)/(abs(ante_location(3) - z_c) + abs(ante_location(2)-y_c));
                    d2(a, b) = dis(a, b) - d1(a, b);
                else
                    dis(a, b) = sqrt((abs(ante_location(3) - z_c) + abs(ante_location(1)-x_c))^2 + (y_c - ante_location(2))^2);
                    d1(a, b) = abs(ante_location(3)-z_c)*dis(a,b)/(abs(ante_location(3) - z_c) + abs(ante_location(1)-x_c));
                    d2(a, b) = dis(a, b) - d1(a, b);
                end
            end
        end
    end        
    
    Pt = max(max(P));
    if(Pt>Pmax)
        Pmax = Pt;
    end

%     Pmax = Pt;
    
    PL = 10*log10(Pmax./P);
    [Axis2,Axis1] = meshgrid(axis2,axis1);
    

    
    
    %按距离排序
    Pv = reshape(P,dim1*dim2,1);
    PLv = reshape(PL,dim1*dim2,1);
    disv = reshape(dis,dim1*dim2,1);
    d1v = reshape(d1,dim1*dim2,1);
    d2v = reshape(d2,dim1*dim2,1);
    [sort_d,sort_idx] = sort(disv);
    sort_d1 = d1v(sort_idx);
    sort_d2 = d2v(sort_idx);
    sort_P = Pv(sort_idx);
    sort_loss = PLv(sort_idx);
    

    
    
   
    
    %边缘提取
%     [upper_E,lower_E,edge_d] = edge_extract(sort_d, sort_P, min_extract_range);
   
    
    %绘制提取出的场强-距离,以及边缘数据
%     figure;
%     plot( sort_d, sort_P,'.' );hold on;
%     plot(edge_d,upper_E,'.-k');hold on;
%     plot(edge_d,lower_E,'--r');xlabel('X(Distance)/m');ylabel('Y(Pav)/(W/m^2)');title('集装箱顶面 平均坡印廷矢量幅度vs距离 f=433M ');
%     
%     figure;
%     plot(sort_d,sort_loss);xlabel('X(Distance)/m');ylabel('Y(PathLoss)/dB');title('集装箱顶面 路径损耗vs距离 f=433M ');
    
%     inter_d = (min(edge_d):interp_step:max(edge_d));
%     inter_upper_P = interp1(edge_d,upper_E ,inter_d);
%     inter_upper_P( isnan(inter_upper_P) ) = inter_upper_P(2);
%     inter_lower_P = interp1(edge_d,lower_E ,inter_d);
%     inter_lower_P( isnan(inter_lower_P) ) = inter_lower_P(2);
% 
%     inter_upper_P = [fliplr(inter_upper_P(2:end)) inter_upper_P];
%     inter_d = [-fliplr(inter_d(2:end)-min(inter_d)) inter_d-min(inter_d)];
%     inter_lower_P = [fliplr(inter_lower_P(2:end)) inter_lower_P];

 
end