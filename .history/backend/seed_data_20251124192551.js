const pool = require('./config/database');
const bcrypt = require('bcryptjs');

async function seedData() {
  try {
    console.log('🌱 Örnek veri yenileniyor...\n');

    // Verileri temizle
    console.log('🧹 Mevcut veriler temizleniyor...');
    await pool.query('SET FOREIGN_KEY_CHECKS=0');
    const tables = [
      'appointments',
      'employee_schedules',
      'services',
      'employees',
      'businesses',
      'customers'
    ];

    for (const table of tables) {
      await pool.query(`TRUNCATE TABLE ${table}`);
    }
    await pool.query('SET FOREIGN_KEY_CHECKS=1');
    console.log('✅ Tablolar temizlendi\n');

    // Yeni müşteriler
    const customersData = [
      {
        name: 'Ece Nur Demir',
        email: 'ece@beautyhub.com',
        phone: '5552103344',
        password: 'Ece2025!'
      },
      {
        name: 'Mert Yaman',
        email: 'mert@freshfade.com',
        phone: '5554189922',
        password: 'Mert2025!'
      },
      {
        name: 'Selin Akay',
        email: 'selin@glowlab.com',
        phone: '5557923410',
        password: 'Selin2025!'
      },
      {
        name: 'Kerem Altun',
        email: 'kerem@metrocut.com',
        phone: '5556281144',
        password: 'Kerem2025!'
      }
    ];

    console.log('👥 Müşteriler ekleniyor...');
    const customerIds = [];
    for (const customer of customersData) {
      const hashedPassword = await bcrypt.hash(customer.password, 10);
      const [result] = await pool.execute(
        `INSERT INTO customers (name, email, phone, password) VALUES (?, ?, ?, ?)`,
        [customer.name, customer.email, customer.phone, hashedPassword]
      );
      customerIds.push(result.insertId);
    }
    console.log(`✅ ${customerIds.length} müşteri eklendi\n`);

    // Yeni işletmeler ve ilgili veriler
    const businessesData = [
      {
        info: {
          business_name: 'Luxe Studio',
          owner_name: 'Selçuk Aydın',
          email: 'hello@luxestudio.com',
          phone: '5559001122',
          password: 'Luxe2025!',
          address: 'Bağdat Cad. No:45',
          city: 'İstanbul',
          district: 'Kadıköy',
          description: 'Premium kuaför & güzellik stüdyosu',
          opening_time: '09:00:00',
          closing_time: '20:00:00'
        },
        employees: [
          {
            name: 'Defne Koral',
            email: 'defne@luxestudio.com',
            phone: '5559002101',
            specialization: 'Bayan Saç Stilisti',
            schedule: [
              { day: 1, start: '09:30:00', end: '18:30:00' },
              { day: 2, start: '09:30:00', end: '18:30:00' },
              { day: 3, start: '09:30:00', end: '18:30:00' },
              { day: 4, start: '09:30:00', end: '18:30:00' },
              { day: 5, start: '09:30:00', end: '18:30:00' },
              { day: 6, start: '10:00:00', end: '17:00:00' }
            ]
          },
          {
            name: 'Tolga Rüzgar',
            email: 'tolga@luxestudio.com',
            phone: '5559002102',
            specialization: 'Renk Uzmanı',
            schedule: [
              { day: 2, start: '10:00:00', end: '19:00:00' },
              { day: 3, start: '10:00:00', end: '19:00:00' },
              { day: 4, start: '10:00:00', end: '19:00:00' },
              { day: 5, start: '11:00:00', end: '20:00:00' },
              { day: 6, start: '11:00:00', end: '20:00:00' }
            ]
          },
          {
            name: 'Melike Aras',
            email: 'melike@luxestudio.com',
            phone: '5559002103',
            specialization: 'Bakım Uzmanı',
            schedule: [
              { day: 1, start: '11:00:00', end: '20:00:00' },
              { day: 2, start: '11:00:00', end: '20:00:00' },
              { day: 3, start: '11:00:00', end: '20:00:00' },
              { day: 4, start: '12:00:00', end: '20:30:00' },
              { day: 5, start: '12:00:00', end: '20:30:00' }
            ]
          }
        ],
        services: [
          {
            service_name: 'Signature Kesim',
            description: 'Kişiye özel stil danışmanlığı ile saç kesimi',
            duration: 45,
            price: 350.0
          },
          {
            service_name: 'Luxe Renk Dönüşümü',
            description: 'Profesyonel renk uygulaması ve bakım',
            duration: 120,
            price: 950.0
          },
          {
            service_name: 'Botoks Bakım',
            description: 'Saç yenileyici botoks bakım paketi',
            duration: 75,
            price: 650.0
          },
          {
            service_name: 'Keratin Spa',
            description: 'Keratin destekli parlaklık terapisi',
            duration: 90,
            price: 720.0
          }
        ]
      },
      {
        info: {
          business_name: 'Urban Fade Lounge',
          owner_name: 'Eren Aksoy',
          email: 'contact@urbanfade.com',
          phone: '5558447733',
          password: 'Urban2025!',
          address: 'Maslak Mah. No:12',
          city: 'İstanbul',
          district: 'Sarıyer',
          description: 'Modern erkek bakım ve stil merkezi',
          opening_time: '10:00:00',
          closing_time: '22:00:00'
        },
        employees: [
          {
            name: 'Caner Yıldız',
            email: 'caner@urbanfade.com',
            phone: '5558447701',
            specialization: 'Erkek Saç Tasarımcısı',
            schedule: [
              { day: 1, start: '10:00:00', end: '21:00:00' },
              { day: 2, start: '10:00:00', end: '21:00:00' },
              { day: 3, start: '10:00:00', end: '21:00:00' },
              { day: 4, start: '10:00:00', end: '21:00:00' },
              { day: 5, start: '11:00:00', end: '22:00:00' },
              { day: 6, start: '11:00:00', end: '22:00:00' }
            ]
          },
          {
            name: 'Burak Deniz',
            email: 'burak@urbanfade.com',
            phone: '5558447702',
            specialization: 'Sakal & Traş Uzmanı',
            schedule: [
              { day: 1, start: '11:00:00', end: '22:00:00' },
              { day: 2, start: '11:00:00', end: '22:00:00' },
              { day: 3, start: '11:00:00', end: '22:00:00' },
              { day: 4, start: '12:00:00', end: '22:30:00' },
              { day: 5, start: '12:00:00', end: '22:30:00' },
              { day: 6, start: '12:00:00', end: '22:30:00' }
            ]
          },
          {
            name: 'Arda Tez',
            email: 'arda@urbanfade.com',
            phone: '5558447703',
            specialization: 'Bakım Koçu',
            schedule: [
              { day: 2, start: '12:00:00', end: '21:00:00' },
              { day: 3, start: '12:00:00', end: '21:00:00' },
              { day: 4, start: '12:00:00', end: '21:00:00' },
              { day: 5, start: '13:00:00', end: '22:00:00' },
              { day: 6, start: '13:00:00', end: '22:00:00' },
              { day: 0, start: '12:00:00', end: '20:00:00' }
            ]
          }
        ],
        services: [
          {
            service_name: 'Urban Fade Kesim',
            description: 'Keskin hatlı modern fade saç kesimi',
            duration: 35,
            price: 220.0
          },
          {
            service_name: 'Deluxe Sakal Bakım',
            description: 'Sıcak havlu ile premium sakal bakımı',
            duration: 25,
            price: 160.0
          },
          {
            service_name: 'VIP Paket',
            description: 'Saç + sakal + yüz bakımı kombini',
            duration: 60,
            price: 450.0
          },
          {
            service_name: 'Relax Masaj',
            description: 'Omuz ve boyun rahatlatıcı masaj',
            duration: 30,
            price: 200.0
          }
        ]
      },
      {
        info: {
          business_name: 'Glow & Go Beauty Bar',
          owner_name: 'Melisa Yurt',
          email: 'info@glowngo.com',
          phone: '5557305588',
          password: 'Glow2025!',
          address: 'Atakule AVM Kat:2',
          city: 'Ankara',
          district: 'Çankaya',
          description: 'Hızlı lüks güzellik ve bakım barı',
          opening_time: '08:30:00',
          closing_time: '21:00:00'
        },
        employees: [
          {
            name: 'Selma Işık',
            email: 'selma@glowngo.com',
            phone: '5557305501',
            specialization: 'Cilt Bakımı Uzmanı',
            schedule: [
              { day: 1, start: '08:30:00', end: '18:00:00' },
              { day: 2, start: '08:30:00', end: '18:00:00' },
              { day: 3, start: '08:30:00', end: '18:00:00' },
              { day: 4, start: '09:00:00', end: '19:00:00' },
              { day: 5, start: '09:00:00', end: '19:00:00' },
              { day: 6, start: '09:00:00', end: '17:00:00' }
            ]
          },
          {
            name: 'Aylin Kaptan',
            email: 'aylin@glowngo.com',
            phone: '5557305502',
            specialization: 'Makyaj Artist',
            schedule: [
              { day: 1, start: '10:00:00', end: '20:00:00' },
              { day: 2, start: '10:00:00', end: '20:00:00' },
              { day: 3, start: '10:00:00', end: '20:00:00' },
              { day: 4, start: '10:00:00', end: '20:00:00' },
              { day: 5, start: '10:00:00', end: '20:00:00' },
              { day: 6, start: '10:00:00', end: '20:00:00' },
              { day: 0, start: '11:00:00', end: '19:00:00' }
            ]
          },
          {
            name: 'Beren Ulu',
            email: 'beren@glowngo.com',
            phone: '5557305503',
            specialization: 'Kaş & Kirpik Uzmanı',
            schedule: [
              { day: 3, start: '12:00:00', end: '21:00:00' },
              { day: 4, start: '12:00:00', end: '21:00:00' },
              { day: 5, start: '12:00:00', end: '21:00:00' },
              { day: 6, start: '11:00:00', end: '19:00:00' },
              { day: 0, start: '12:00:00', end: '19:00:00' }
            ]
          }
        ],
        services: [
          {
            service_name: 'Express Cilt Yenileme',
            description: 'Hızlı parlaklık veren cilt bakımı',
            duration: 40,
            price: 380.0
          },
          {
            service_name: 'Işıltı Makyaj',
            description: 'Profesyonel günlük ve gece makyajı',
            duration: 50,
            price: 520.0
          },
          {
            service_name: 'Kaş Tasarımı',
            description: 'Kaş haritalama ve şekillendirme',
            duration: 25,
            price: 180.0
          },
          {
            service_name: 'Lash Lift',
            description: 'Kirpik lifting ve keratin bakımı',
            duration: 55,
            price: 420.0
          }
        ]
      }
    ];

    console.log('🏢 İşletmeler ekleniyor...');
    const businessIds = [];
    const employeeIdsByBusiness = [];
    const serviceIdsByBusiness = [];

    for (const business of businessesData) {
      const hashedPassword = await bcrypt.hash(business.info.password, 10);
      const [result] = await pool.execute(
        `INSERT INTO businesses 
         (business_name, owner_name, email, phone, password, address, city, district, description, opening_time, closing_time, is_active) 
         VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 1)`,
        [
          business.info.business_name,
          business.info.owner_name,
          business.info.email,
          business.info.phone,
          hashedPassword,
          business.info.address,
          business.info.city,
          business.info.district,
          business.info.description,
          business.info.opening_time,
          business.info.closing_time
        ]
      );

      const businessId = result.insertId;
      businessIds.push(businessId);

      const employeeIds = [];
      for (const employee of business.employees) {
        const [employeeResult] = await pool.execute(
          `INSERT INTO employees (business_id, name, email, phone, specialization, is_active) 
           VALUES (?, ?, ?, ?, ?, 1)`,
          [
            businessId,
            employee.name,
            employee.email,
            employee.phone,
            employee.specialization
          ]
        );

        const employeeId = employeeResult.insertId;
        employeeIds.push(employeeId);

        if (employee.schedule && employee.schedule.length > 0) {
          for (const slot of employee.schedule) {
      await pool.execute(
              `INSERT INTO employee_schedules (employee_id, day_of_week, start_time, end_time, is_available) 
               VALUES (?, ?, ?, ?, 1)`,
              [employeeId, slot.day, slot.start, slot.end]
            );
          }
        }
      }
      employeeIdsByBusiness.push(employeeIds);

    const serviceIds = [];
      for (const service of business.services) {
        const [serviceResult] = await pool.execute(
          `INSERT INTO services (business_id, service_name, description, duration, price, is_active) 
           VALUES (?, ?, ?, ?, ?, 1)`,
          [
            businessId,
            service.service_name,
            service.description,
            service.duration,
            service.price
          ]
      );
        serviceIds.push(serviceResult.insertId);
      }
      serviceIdsByBusiness.push(serviceIds);
    }
    console.log(`✅ ${businessIds.length} işletme, ${employeeIdsByBusiness.flat().length} çalışan, ${serviceIdsByBusiness.flat().length} hizmet eklendi\n`);

    // Randevular
    console.log('📅 Randevular ekleniyor...');
    const today = new Date();
    const formatDate = (offset) => {
      const date = new Date(today);
      date.setDate(date.getDate() + offset);
      return date.toISOString().split('T')[0];
    };

    const appointmentsData = [
      {
        customerIndex: 0,
        businessIndex: 0,
        employeeIndex: 0,
        serviceIndex: 0,
        dateOffset: 0,
        time: '11:00:00',
        status: 'confirmed',
        notes: 'Özel gün hazırlığı'
      },
      {
        customerIndex: 1,
        businessIndex: 1,
        employeeIndex: 0,
        serviceIndex: 2,
        dateOffset: 1,
        time: '16:30:00',
        status: 'pending',
        notes: 'VIP paket rezervasyonu'
      },
      {
        customerIndex: 2,
        businessIndex: 2,
        employeeIndex: 0,
        serviceIndex: 0,
        dateOffset: 2,
        time: '13:00:00',
        status: 'pending',
        notes: 'Cilt yenileme seansı'
      },
      {
        customerIndex: 0,
        businessIndex: 2,
        employeeIndex: 1,
        serviceIndex: 1,
        dateOffset: -2,
        time: '15:00:00',
        status: 'completed',
        notes: 'Düğün makyaj provası'
      },
      {
        customerIndex: 3,
        businessIndex: 1,
        employeeIndex: 1,
        serviceIndex: 1,
        dateOffset: -1,
        time: '18:30:00',
        status: 'completed',
        notes: 'Sakal bakımı sonrası ürün önerisi'
      },
      {
        customerIndex: 1,
        businessIndex: 0,
        employeeIndex: 1,
        serviceIndex: 3,
        dateOffset: 7,
        time: '17:30:00',
        status: 'pending',
        notes: 'Keratin spa rezervasyonu'
      },
      {
        customerIndex: 2,
        businessIndex: 0,
        employeeIndex: 2,
        serviceIndex: 2,
        dateOffset: 5,
        time: '12:00:00',
        status: 'confirmed',
        notes: 'Botoks bakım tekrar seansı'
      },
      {
        customerIndex: 3,
        businessIndex: 2,
        employeeIndex: 2,
        serviceIndex: 3,
        dateOffset: 0,
        time: '19:00:00',
        status: 'pending',
        notes: 'Akşam etkinliği öncesi'
      },
      {
        customerIndex: 0,
        businessIndex: 1,
        employeeIndex: 2,
        serviceIndex: 3,
        dateOffset: 3,
        time: '14:30:00',
        status: 'confirmed',
        notes: 'Masaj için kısa mola'
      },
      {
        customerIndex: 1,
        businessIndex: 2,
        employeeIndex: 0,
        serviceIndex: 2,
        dateOffset: -5,
        time: '10:30:00',
        status: 'cancelled',
        notes: 'Müşteri tarafından iptal edildi'
      }
    ];

    for (const appointment of appointmentsData) {
      const customerId = customerIds[appointment.customerIndex];
      const businessId = businessIds[appointment.businessIndex];
      const employeeId =
        typeof appointment.employeeIndex === 'number'
          ? employeeIdsByBusiness[appointment.businessIndex][appointment.employeeIndex]
          : null;
      const serviceId =
        serviceIdsByBusiness[appointment.businessIndex][appointment.serviceIndex];

      await pool.execute(
        `INSERT INTO appointments 
         (customer_id, business_id, employee_id, service_id, appointment_date, appointment_time, status, notes)
         VALUES (?, ?, ?, ?, ?, ?, ?, ?)`,
        [
          customerId,
          businessId,
          employeeId,
          serviceId,
          formatDate(appointment.dateOffset),
          appointment.time,
          appointment.status,
          appointment.notes ?? null
        ]
      );
    }
    console.log(`✅ ${appointmentsData.length} randevu eklendi\n`);

    console.log('🎉 Veritabanı modern verilerle güncellendi!\n');
    console.log('📊 Özet:');
    console.log(`   - ${customerIds.length} Müşteri`);
    console.log(`   - ${businessIds.length} İşletme`);
    console.log(`   - ${employeeIdsByBusiness.flat().length} Çalışan`);
    console.log(`   - ${serviceIdsByBusiness.flat().length} Hizmet`);
    console.log(`   - ${appointmentsData.length} Randevu\n`);

    console.log('🔑 Giriş Bilgileri:');
    console.log('   • Admin: admin / admin123');
    console.log('   • İşletmeler:');
    for (let i = 0; i < businessesData.length; i++) {
      const business = businessesData[i];
      console.log(
        `     - ${business.info.business_name}: ${business.info.email} / ${business.info.password}`
      );
    }
    console.log('   • Müşteriler:');
    for (let i = 0; i < customersData.length; i++) {
      const customer = customersData[i];
      console.log(`     - ${customer.name}: ${customer.email} / ${customer.password}`);
    }
    console.log('');
  } catch (error) {
    console.error('❌ Hata:', error);
  } finally {
    process.exit(0);
  }
}

seedData();

