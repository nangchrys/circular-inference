folder = 'data/discarded';
filelist = dir(fullfile(folder, '*.csv'));

for i = 1:n
    filename = filelist(i).name;
    file = readtable(fullfile(data_folder, filename));
    file = file(end - 141:end - 1, ["mouse_x", "mouse_y"]);
    mousex = table2array(file(12:end, 1));
    mousey = table2array(file(12:end, 2));

    f = figure('Position', [400 200 750 450]); hold on;
    scatter(mousex, mousey, 100, [100 100 100] / 255, 'filled', ...
        'MarkerEdgeAlpha', 0.3, 'MarkerFaceAlpha', 0.3)
    axis equal;
    title(filename)
    ylim([-0.47 -0.179]); xlim([-0.2425 0.2425])
    th = linspace(0, pi, 100); th2 = linspace(0, pi, 100);
    x = 0.11 * cos(th); y = 0.11 * sin(th) - 0.415;
    plot(x, y, 'b', 'Linewidth', 2.5);
    x = 0.205 * cos(th2); y = 0.205 * sin(th2) - 0.415;
    plot(x, y, 'b', 'Linewidth', 2.5);
    plot([-0.11 -0.11], [-0.4145 -0.435], 'b', 'Linewidth', 2.5)
    plot([0.11 0.11], [-0.4145 -0.435], 'b', 'Linewidth', 2.5)
    plot([-0.205 -0.205], [-0.4145 -0.435], 'b', 'Linewidth', 2.5)
    plot([0.205 0.205], [-0.4145 -0.435], 'b', 'Linewidth', 2.5)
    %exportgraphics(f, strcat(data_folder, string(i), '.png'));
    set(gca, 'XColor', 'none', 'YColor', 'none')%, 'TickDir', 'out')
end
