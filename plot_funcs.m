function plot_funcs = plot
    
    plot_funcs.draw_single_graph = @draw_single_graph
    plot_funcs.draw_compare_graph = @draw_compare_graph
    plot_funcs.draw_together_graph = @draw_together_graph
    plot_funcs.draw_together_semiGraph = @draw_together_semiGraph
    plot_funcs.draw_together_plot = @draw_together_plot
    plot_funcs.draw_two_plot = @draw_two_plot
end

function draw_single_graph(A, B, figure_num)

figure(figure_num);
f = fit(A', B', 'poly3');
plot(f, A, B);

if(figure_num == 1)
    title('uplink association algorthim ');

elseif (figure_num == 2)
    title('downlink association algorthim ');
end

xlabel('number of target UDs');
ylabel('algorithm running time(s)');
end

function draw_compare_graph(x, y1, y2, figure_num, figure_type)

figure(figure_num);
f1 = fit(x', y1', 'poly3');
f2 = fit(x', y2', 'poly3');

hold on;
plot(x, y1, 'go')
plot(x, y2, 'ro')
plot(f1, 'g');
plot(f2, 'r');
if(figure_type == 1)
    title('uplink-downlink association algorthim ');
    legend('uplink(blue)','downlink(red)','uplink(blue)','downlink(red)');
    xlabel('number of target UDs');
    ylabel('algorithm running time(s)');
elseif (figure_type == 2)
    title('Parallelization Comparison of Uplink association Algorithm');
    legend('non-parallel(blue)','parallel(red)','non-parallel(blue)','parallel(red)');
    xlabel('number of target UDs');
    ylabel('algorithm running time(s)');
elseif (figure_type == 3)
    title('Parallelization Comparison of Downlinklink association Algorithm');
    legend('non-parallel(blue)','parallel(red)','non-parallel(blue)','parallel(red)');
    xlabel('number of target UDs');
    ylabel('algorithm running time(s)');
elseif (figure_type == 4)
    title('Average uplink and downlink latency');
    legend('Randomly assigned(blue)','UDA algorithm(red)','Randomly assigned(blue)','UDA algorithm(red)');
    xlabel('number of target UDs');
    ylabel('average latency of UDs(s)');
elseif (figure_type == 5)
    title('sum of uplink and downlink latency');
    legend('Randomly assigned(blue)','UDA algorithm(red)','Randomly assigned(blue)','UDA algorithm(red)');
    xlabel('number of target UDs');
    ylabel('sum latency of UDs(s)');
end
hold off;
end

function draw_together_graph(x, y1, y2, y3, y4, figure_num, figure_type)

figure(figure_num);


plot(x, y1, '-ro');
hold on;
plot(x, y2, '-gs');
plot(x, y3, '-b^');
plot(x, y4, '-kd');

    title('---------- ');
    legend('forced(red)','coupled(green)','dynamic(blue)','random(black)' );
    xlabel('number of target UDs');
    ylabel('The average latency of all UDs after run 100times');

hold off;
end

function draw_two_plot(x, y1, y2, figure_num, figure_type)
figure(figure_num);


plot(x, y1, '-ro');
hold on;
plot(x, y2, '-gs');

    title('---------- ');
    legend('forced-4G(red)','forced-4G/5G(green)');
    xlabel('number of target UDs');
    ylabel('The average latency of all UDs after run 100times');

hold off;
end

function draw_together_plot(x, y1, y2, y3, y4, figure_num, figure_type)
figure(figure_num);
f1 = fit(x', y1', 'poly3');
f2 = fit(x', y2', 'poly3');
f3 = fit(x', y3', 'poly3');
f4 = fit(x', y4', 'poly3');

hold on;  % 保持当前图像并添加新的图像
plot(f1, 'r');  % 红色实线
plot(f2, 'g');  % 绿色虚线
plot(f3, 'b');  % 蓝色点线
plot(f4, 'm');  % 洋红色点虚线

    legend('forced(red)','coupled(green)','dynamic(blue)','random(black)' );
    xlabel('number of target UDs');
    ylabel('The average latency of all UDs after run 100times');
end


function draw_together_semiGraph(x, y1, y2, y3, y4, figure_num, figure_type)
figure(figure_num);
f1 = fit(x', y1', 'poly3');
f2 = fit(x', y2', 'poly3');
f3 = fit(x', y3', 'poly3');
f4 = fit(x', y4', 'poly3');

% semilogy(x, y1, 'r-', 'LineWidth', 2);  % 红色实线
% hold on;  % 保持当前图像并添加新的图像
% semilogy(x, y2, 'g--', 'LineWidth', 2);  % 绿色虚线
% semilogy(x, y3, 'b-.', 'LineWidth', 2);  % 蓝色点线
% semilogy(x, y4, 'm:', 'LineWidth', 2);  % 洋红色点虚线

hold on;  % 保持当前图像并添加新的图像
plot(f1, 'r');  % 红色实线
plot(f2, 'g');  % 绿色虚线
plot(f3, 'b');  % 蓝色点线
plot(f4, 'm');  % 洋红色点虚线

% 添加标题、标签和图例
title('Semilogy Plot of Four Data Series');
% xlabel('X Axis');
% ylabel('Y Axis (Log Scale)');
xlabel ('the number of UDs','FontSize' ,13 ,'FontWeight','bold ') ;
ylabel ('The sum of the communication latency of all UDs','FontSize' ,13 ,'FontWeight','bold ') ;
legend('Data 1-force', 'Data 2-dynamic', 'Data 3-coulpled', 'Data random');

hold off;
end