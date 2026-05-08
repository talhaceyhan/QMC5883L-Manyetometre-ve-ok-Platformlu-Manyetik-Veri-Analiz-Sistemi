%% MATLAB Gerçek Zamanlı Manyetik Alan Görselleştirme (GÜNCEL)
% Port ayarları
port = "COM6"; 
baudrate = 9600; % Gecikmeyi önlemek için hız artırıldı
threshold = 500; % Ödevde belirtilen eşik değeri

% Eski bağlantıları temizle
if exist('s', 'var')
    clear s
end

try
    s = serialport(port, baudrate);
    configureTerminator(s, "LF");
    flush(s); % Başlangıçta tamponu boşalt
    fprintf('%s portuna %d hızında bağlandı.\n', port, baudrate);
catch e
    fprintf('HATA: Port açılamadı. Kablonun takılı ve portun doğru olduğundan emin ol.\n');
    return;
end

% Grafik Penceresi Hazırlığı
fig = figure('Color', 'w', 'Name', 'Manyetik Alan Analizi (Gerçek Zamanlı)');

% 1. Grafik: Zaman Serisi ve Eşik Çizgisi[cite: 1]
subplot(2,1,1);
h_line = animatedline('Color', [0 0.4470 0.7410], 'LineWidth', 2);
grid on; hold on;
yline(threshold, 'r--', 'Eşik Değeri (500 uT)', 'LineWidth', 2); 
title('Toplam Manyetik Alan Şiddeti |B|');
xlabel('Zaman (s)'); ylabel('Şiddet (\muT)');
ylim([0 threshold + 500]);

% 2. Grafik: 3B Vektör Alanı (Quiver3)[cite: 1]
subplot(2,1,2);
grid on;
title('3B Manyetik Alan Yönü (Vektör)');
xlabel('Bx'); ylabel('By'); zlabel('Bz');
view(3); 
axis([-100 100 -100 100 -100 100]); % Eksenleri sensör hassasiyetine göre ayarla

% Veri Okuma Döngüsü
while ishandle(fig) % Pencere açık olduğu sürece çalış
    try
        if s.NumBytesAvailable > 0
            % Veriyi oku ve tamponu hemen temizle (Gecikmeyi önleyen kritik adım)
            data = readline(s);
            flush(s); 
            
            vals = str2double(split(data, ',')); % Format: t, Bx, By, Bz, |B|[cite: 1]
            
            if numel(vals) == 5
                t = vals(1)/1000; % ms -> saniye
                x = vals(2); y = vals(3); z = vals(4); b_mag = vals(5);
                
                % Zaman serisini güncelle
                addpoints(h_line, t, b_mag);
                
                % Eksenleri zamanla kaydır (Opsiyonel: Son 10 saniyeyi gösterir)
                if t > 10
                    xlim([t-10 t]);
                end
                
                % 3B Vektörü (Quiver3) güncelle[cite: 1]
                subplot(2,1,2);
                cla; % Eski oku temizle
                quiver3(0, 0, 0, x, y, z, 'LineWidth', 2, 'Color', 'r', 'MaxHeadSize', 0.5);
                axis([-100 100 -100 100 -100 100]); % Eksenleri sabit tut
                
                % Alarm Durumu Kontrolü (Görev 5)[cite: 1]
                subplot(2,1,1);
                if b_mag > threshold
                    title('!!! YÜKSEK ALAN ALARMI (LED AKTİF) !!!', 'Color', 'r');
                else
                    title('Toplam Manyetik Alan Şiddeti |B|', 'Color', 'k');
                end
                
                drawnow limitrate; % Grafiği 20 FPS ile sınırlayarak işlemciyi rahatlat
            end
        end
    catch
        continue; % Hatalı satır gelirse atla
    end
end