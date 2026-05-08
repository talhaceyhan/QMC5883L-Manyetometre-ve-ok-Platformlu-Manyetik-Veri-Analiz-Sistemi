import serial
import matplotlib.pyplot as plt
import numpy as np
from matplotlib.animation import FuncAnimation

# ÇÖZÜM 1: timeout=0.1 eklendi. Böylece veri gelmezse Python kilitlenmez.
ser = serial.Serial('COM6', 9600, timeout=0.1)

fig = plt.figure(figsize=(12, 6))
ax1 = fig.add_subplot(121) # Zaman serisi için
ax2 = fig.add_subplot(122, projection='3d') # 3B Vektör için

times, total_b = [], []

def update(i):
    # Eğer port kapalıysa veya hata varsa program çökmesin diye try-except içine aldık
    try:
        line = ser.readline().decode('utf-8').strip()
        if line:
            # Gelen veriyi siyah ekranda da görelim ki Arduino'dan ne geldiğinden emin olalım
            print("Gelen Veri:", line) 
            
            # Gelen veriyi 5 parçaya böl [t, x, y, z, |B|][cite: 1]
            t, x, y, z, b_mag = [float(val) for val in line.split(',')]
            
            # Zaman Serisi Grafiği (Zorunlu Çıktı)[cite: 1]
            times.append(t / 1000)
            total_b.append(b_mag)
            ax1.cla()
            ax1.plot(times[-50:], total_b[-50:], 'r-')
            ax1.set_title(f"Alan Siddeti: {b_mag:.2f} uT")
            
            # 3B Vektör (Quiver) Gösterimi[cite: 1]
            ax2.cla()
            # Vektör boyutunu büyütmek için length=1.0 yaptık
            ax2.quiver(0, 0, 0, x, y, z, length=1.0, normalize=True)
            ax2.set_xlim([-1, 1]); ax2.set_ylim([-1, 1]); ax2.set_zlim([-1, 1])
            ax2.set_title("Manyetik Alan Yonu")
            
    except ValueError as e:
        # Eğer Arduino'dan eksik virgül gelirse burası çalışır ve hatayı gösterir
        print("Veri ayirma hatasi (Beklenen 5 deger gelmedi):", e)
    except Exception as e:
        print("Bilinmeyen Hata:", e)

# interval=50 (50 milisaniyede bir günceller)
ani = FuncAnimation(fig, update, interval=50)

# ÇÖZÜM 2: Grafiği ekranda tutmak için block=True kullanmak garanti yöntemdir
plt.show(block=True)