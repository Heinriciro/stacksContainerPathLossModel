function [upper_E,lower_E,edge_d,edge_d1,edge_d2] = edge_extract(plot_d, plot_d1, plot_d2, plot_E, max_interval)


    upper_E = [];
    edge_d = [];
    edge_d1 = [];
    edge_d2 = [];
    lower_E = [];
    
    
    cur_d = plot_d(1);
    cur_d1 = plot_d1(1);
    cur_d2 = plot_d2(1);
    cur_E_set = plot_E(1);
    
    for i = 2:length(plot_d)
       if(plot_d(i) - cur_d > max_interval)

           edge_d = [edge_d cur_d];
           edge_d1 = [edge_d1 cur_d1];
           edge_d2 = [edge_d2 cur_d2];
           upper_E = [upper_E max(cur_E_set)];
           
           lower_E = [lower_E min(cur_E_set)];
           
           cur_d = plot_d(i);
           cur_d1 = plot_d1(i);
           cur_d2 = plot_d2(i);
           
           cur_E_set = [];
           
       end
       
       if(abs(plot_d(i) - cur_d)<=max_interval)
          cur_E_set = [cur_E_set plot_E(i)]; 
       end
        
    end
















end