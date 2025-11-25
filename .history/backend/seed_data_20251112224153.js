const pool = require('./config/database');
const bcrypt = require('bcryptjs');

async function seedData() {
  try {
    console.log('🌱 Örnek veri ekleme başlıyor...\n');

    // 1. Müşteriler ekle
    console.log('👥 Müşteriler ekleniyor...');
    const hashedPassword = await bcrypt.hash('test123', 10);
    
    const customers = [
      ['Ahmet Yılmaz', 'ahmet@test.com', '5551234567', hashedPassword],
      ['Ayşe Demir', 'ayse@test.com', '5551234568', hashedPassword],
      ['Mehmet Kaya', 'mehmet@test.com', '5551234569', hashedPassword],
      ['Fatma Şahin', 'fatma@test.com', '5551234570', hashedPassword],
      ['Ali Öztürk', 'ali@test.com', '5551234571', hashedPassword]
    ];

    for (const customer of customers) {
      await pool.execute(
        'INSERT IGNORE INTO customers (name, email, phone, password) VALUES (?, ?, ?, ?)',
        customer
      );
    }
    console.log('✅ 5 müşteri eklendi\n');

    // 2. İşletmeler ekle
    console.log('🏢 İşletmeler ekleniyor...');
    const businesses = [
      ['Elit Kuaför', 'Mehmet Yılmaz', 'elit@kuafor.com', '5559876543', hashedPassword, 'Atatürk Cad. No:15', 'İstanbul', 'Kadıköy', 'Modern kuaför salonu', '09:00:00', '19:00:00'],
      ['Saç Tasarım Studio', 'Zeynep Kara', 'sac@tasarim.com', '5559876544', hashedPassword, 'Cumhuriyet Mah. 45/2', 'İstanbul', 'Beşiktaş', 'Profesyonel saç tasarım', '10:00:00', '20:00:00'],
      ['Klasik Berber', 'Hasan Demir', 'klasik@berber.com', '5559876545', hashedPassword, 'İstiklal Cad. No:78', 'İstanbul', 'Beyoğlu', 'Geleneksel berber', '08:00:00', '18:00:00']
    ];

    const businessIds = [];
    for (const business of businesses) {
      const [result] = await pool.execute(
        `INSERT INTO businesses (business_name, owner_name, email, phone, password, address, city, district, description, opening_time, closing_time, is_active) 
         VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 1)
         ON DUPLICATE KEY UPDATE id=LAST_INSERT_ID(id)`,
        business
      );
      businessIds.push(result.insertId || result.lastInsertId);
    }
    console.log('✅ 3 işletme eklendi\n');

    // 3. Çalışanlar ekle
    console.log('👨‍💼 Çalışanlar ekleniyor...');
    const employees = [
      [businessIds[0], 'Ahmet Usta', 'ahmet@elit.com', '5551111111', 'Saç Kesimi Uzmanı'],
      [businessIds[0], 'Ayşe Hanım', 'ayse@elit.com', '5551111112', 'Bayan Kuaför'],
      [businessIds[1], 'Zeynep Usta', 'zeynep@tasarim.com', '5551111113', 'Saç Tasarımcısı'],
      [businessIds[1], 'Mehmet Bey', 'mehmet@tasarim.com', '5551111114', 'Renk Uzmanı'],
      [businessIds[2], 'Hasan Usta', 'hasan@berber.com', '5551111115', 'Master Berber']
    ];

    const employeeIds = [];
    for (const employee of employees) {
      const [result] = await pool.execute(
        'INSERT INTO employees (business_id, name, email, phone, specialization, is_active) VALUES (?, ?, ?, ?, ?, 1)',
        employee
      );
      employeeIds.push(result.insertId);
    }
    console.log('✅ 5 çalışan eklendi\n');

    // 3.1. Çalışan çalışma saatleri ekle
    console.log('📅 Çalışan çalışma saatleri ekleniyor...');
    const schedules = [
      // Ahmet Usta (employee_id: 1) - Pazartesi-Cuma 09:00-18:00
      [employeeIds[0], 1, '09:00:00', '18:00:00', 1], // Pazartesi
      [employeeIds[0], 2, '09:00:00', '18:00:00', 1], // Salı
      [employeeIds[0], 3, '09:00:00', '18:00:00', 1], // Çarşamba
      [employeeIds[0], 4, '09:00:00', '18:00:00', 1], // Perşembe
      [employeeIds[0], 5, '09:00:00', '18:00:00', 1], // Cuma
      
      // Ayşe Hanım (employee_id: 2) - Pazartesi-Cumartesi 10:00-19:00
      [employeeIds[1], 1, '10:00:00', '19:00:00', 1], // Pazartesi
      [employeeIds[1], 2, '10:00:00', '19:00:00', 1], // Salı
      [employeeIds[1], 3, '10:00:00', '19:00:00', 1], // Çarşamba
      [employeeIds[1], 4, '10:00:00', '19:00:00', 1], // Perşembe
      [employeeIds[1], 5, '10:00:00', '19:00:00', 1], // Cuma
      [employeeIds[1], 6, '10:00:00', '19:00:00', 1], // Cumartesi
      
      // Zeynep Usta (employee_id: 3) - Salı-Cumartesi 11:00-20:00
      [employeeIds[2], 2, '11:00:00', '20:00:00', 1], // Salı
      [employeeIds[2], 3, '11:00:00', '20:00:00', 1], // Çarşamba
      [employeeIds[2], 4, '11:00:00', '20:00:00', 1], // Perşembe
      [employeeIds[2], 5, '11:00:00', '20:00:00', 1], // Cuma
      [employeeIds[2], 6, '11:00:00', '20:00:00', 1], // Cumartesi
      
      // Mehmet Bey (employee_id: 4) - Pazartesi-Cuma 09:00-17:00
      [employeeIds[3], 1, '09:00:00', '17:00:00', 1], // Pazartesi
      [employeeIds[3], 2, '09:00:00', '17:00:00', 1], // Salı
      [employeeIds[3], 3, '09:00:00', '17:00:00', 1], // Çarşamba
      [employeeIds[3], 4, '09:00:00', '17:00:00', 1], // Perşembe
      [employeeIds[3], 5, '09:00:00', '17:00:00', 1], // Cuma
      
      // Hasan Usta (employee_id: 5) - Pazartesi-Cumartesi 08:00-18:00
      [employeeIds[4], 1, '08:00:00', '18:00:00', 1], // Pazartesi
      [employeeIds[4], 2, '08:00:00', '18:00:00', 1], // Salı
      [employeeIds[4], 3, '08:00:00', '18:00:00', 1], // Çarşamba
      [employeeIds[4], 4, '08:00:00', '18:00:00', 1], // Perşembe
      [employeeIds[4], 5, '08:00:00', '18:00:00', 1], // Cuma
      [employeeIds[4], 6, '08:00:00', '18:00:00', 1], // Cumartesi
    ];

    for (const schedule of schedules) {
      await pool.execute(
        'INSERT IGNORE INTO employee_schedules (employee_id, day_of_week, start_time, end_time, is_available) VALUES (?, ?, ?, ?, ?)',
        schedule
      );
    }
    console.log('✅ Çalışan çalışma saatleri eklendi\n');

    // 4. Hizmetler ekle
    console.log('✂️ Hizmetler ekleniyor...');
    const services = [
      // Elit Kuaför
      [businessIds[0], 'Erkek Saç Kesimi', 'Profesyonel erkek saç kesimi', 30, 150.00],
      [businessIds[0], 'Bayan Saç Kesimi', 'Profesyonel bayan saç kesimi', 45, 250.00],
      [businessIds[0], 'Sakal Traşı', 'Klasik ustura traşı', 20, 80.00],
      [businessIds[0], 'Saç Boyama', 'Profesyonel saç boyama', 90, 400.00],
      
      // Saç Tasarım Studio
      [businessIds[1], 'Saç Kesim & Şekillendirme', 'Modern saç kesimi ve şekillendirme', 60, 300.00],
      [businessIds[1], 'Ombre/Balyaj', 'Özel renk teknikleri', 120, 800.00],
      [businessIds[1], 'Keratin Bakımı', 'Saç düzleştirme ve bakım', 90, 600.00],
      
      // Klasik Berber
      [businessIds[2], 'Klasik Traş', 'Geleneksel ustura traşı', 25, 100.00],
      [businessIds[2], 'Saç + Sakal', 'Komple bakım', 40, 180.00],
      [businessIds[2], 'Çocuk Saç Kesimi', 'Çocuklar için özel', 20, 80.00]
    ];

    const serviceIds = [];
    for (const service of services) {
      const [result] = await pool.execute(
        'INSERT INTO services (business_id, service_name, description, duration, price, is_active) VALUES (?, ?, ?, ?, ?, 1)',
        service
      );
      serviceIds.push(result.insertId);
    }
    console.log('✅ 10 hizmet eklendi\n');

    // 5. Randevular ekle
    console.log('📅 Randevular ekleniyor...');
    const today = new Date();
    const tomorrow = new Date(today);
    tomorrow.setDate(tomorrow.getDate() + 1);
    const nextWeek = new Date(today);
    nextWeek.setDate(nextWeek.getDate() + 7);
    
    const formatDate = (date) => {
      return date.toISOString().split('T')[0];
    };

    const appointments = [
      // Bugünkü randevular (beklemede)
      [1, businessIds[0], 1, serviceIds[0], formatDate(today), '10:00:00', 'pending', 'Saç kısaltma istiyorum'],
      [2, businessIds[0], 2, serviceIds[1], formatDate(today), '14:00:00', 'pending', null],
      [3, businessIds[1], 3, serviceIds[4], formatDate(today), '11:00:00', 'confirmed', 'Özel gün için'],
      
      // Yarınki randevular (onaylanmış)
      [1, businessIds[1], 4, serviceIds[5], formatDate(tomorrow), '15:00:00', 'confirmed', 'Balyaj istiyorum'],
      [4, businessIds[2], 5, serviceIds[7], formatDate(tomorrow), '09:00:00', 'confirmed', null],
      [5, businessIds[0], 1, serviceIds[2], formatDate(tomorrow), '16:00:00', 'pending', null],
      
      // Gelecek hafta (karışık durumlar)
      [2, businessIds[2], 5, serviceIds[8], formatDate(nextWeek), '10:00:00', 'pending', null],
      [3, businessIds[0], 2, serviceIds[3], formatDate(nextWeek), '13:00:00', 'confirmed', 'Koyu kahve renk'],
      [4, businessIds[1], 3, serviceIds[6], formatDate(nextWeek), '11:00:00', 'pending', null],
      [5, businessIds[2], null, serviceIds[9], formatDate(nextWeek), '14:00:00', 'confirmed', 'Çocuğum için'],
      
      // Geçmiş randevular (tamamlanmış/iptal)
      [1, businessIds[0], 1, serviceIds[0], '2025-11-10', '10:00:00', 'completed', null],
      [2, businessIds[1], 3, serviceIds[4], '2025-11-09', '15:00:00', 'completed', null],
      [3, businessIds[2], 5, serviceIds[7], '2025-11-08', '11:00:00', 'cancelled', 'Müşteri iptal etti'],
    ];

    for (const appointment of appointments) {
      await pool.execute(
        `INSERT INTO appointments (customer_id, business_id, employee_id, service_id, appointment_date, appointment_time, status, notes) 
         VALUES (?, ?, ?, ?, ?, ?, ?, ?)`,
        appointment
      );
    }
    console.log('✅ 13 randevu eklendi\n');

    console.log('🎉 Tüm örnek veriler başarıyla eklendi!\n');
    console.log('📊 Özet:');
    console.log('   - 5 Müşteri');
    console.log('   - 3 İşletme');
    console.log('   - 5 Çalışan');
    console.log('   - 10 Hizmet');
    console.log('   - 13 Randevu\n');
    console.log('🔑 Test Bilgileri:');
    console.log('   Admin: admin / admin123');
    console.log('   Müşteriler: *@test.com / test123');
    console.log('   İşletmeler: *@kuafor.com veya *@tasarim.com / test123\n');

  } catch (error) {
    console.error('❌ Hata:', error);
  } finally {
    process.exit(0);
  }
}

seedData();

