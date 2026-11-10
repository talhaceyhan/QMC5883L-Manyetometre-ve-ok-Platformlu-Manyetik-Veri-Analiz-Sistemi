port = "COM6"; 
baudrate = 9600; 
threshold = 500; 

if exist('s', 'var')
    clear s
end

try
    s = serialport(port, baudrate);
    configureTerminator(s, "LF");
    flush(s); 
    fprintf('%s portuna %d hızında bağlandı.\n', port, baudrate);
catch e
    fprintf('HATA: Port açılamadı. Kablonun takılı ve portun doğru olduğundan emin ol.\n');
    return;
end

fig = figure('Color', 'w', 'Name', 'Manyetik Alan Analizi (Gerçek Zamanlı)');

subplot(2,1,1);
h_line = animatedline('Color', [0 0.4470 0.7410], 'LineWidth', 2);
grid on; hold on;
yline(threshold, 'r--', 'Eşik Değeri (500 uT)', 'LineWidth', 2); 
title('Toplam Manyetik Alan Şiddeti |B|');
xlabel('Zaman (s)'); ylabel('Şiddet (\muT)');
ylim([0 threshold + 500]);

subplot(2,1,2);
grid on;
title('3B Manyetik Alan Yönü (Vektör)');
xlabel('Bx'); ylabel('By'); zlabel('Bz');
view(3); 
axis([-100 100 -100 100 -100 100]); 

while ishandle(fig) 
    try
        if s.NumBytesAvailable > 0
            data = readline(s);
            flush(s); 
            
            vals = str2double(split(data, ',')); 
            
            if numel(vals) == 5
                t = vals(1)/1000; 
                x = vals(2); y = vals(3); z = vals(4); b_mag = vals(5);
                
                addpoints(h_line, t, b_mag);
                
                if t > 10
                    xlim([t-10 t]);
                end
                
                subplot(2,1,2);
                cla; 
                quiver3(0, 0, 0, x, y, z, 'LineWidth', 2, 'Color', 'r', 'MaxHeadSize', 0.5);
                axis([-100 100 -100 100 -100 100]); 
                
                subplot(2,1,1);
                if b_mag > threshold
                    title('!!! YÜKSEK ALAN ALARMI (LED AKTİF) !!!', 'Color', 'r');
                else
                    title('Toplam Manyetik Alan Şiddeti |B|', 'Color', 'k');
                end
                
                drawnow limitrate; 
            end
        end
    catch
        continue; 
    end
end
