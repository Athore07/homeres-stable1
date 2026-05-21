// lib/data/seeders/app_seeder.dart
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AppSeeder {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Random _random = Random();

  // Collections
  final String usersCollection = 'users';
  final String techniciansCollection = 'technicians';
  final String servicesCollection = 'services';
  final String bookingsCollection = 'bookings';
  final String chatsCollection = 'chats';
  final String chatMessagesCollection = 'chat_messages';
  final String notificationsCollection = 'notifications';
  final String reviewsCollection = 'reviews';

  // Sample data pools
  final List<String> _firstNames = [
    'John', 'Sarah', 'Michael', 'Emma', 'David', 'Lisa', 'Robert', 'Jennifer',
    'William', 'Maria', 'James', 'Patricia', 'Daniel', 'Linda', 'Richard'
  ];

  final List<String> _lastNames = [
    'Smith', 'Johnson', 'Williams', 'Brown', 'Jones', 'Garcia', 'Miller',
    'Davis', 'Rodriguez', 'Martinez', 'Hernandez', 'Lopez', 'Wilson'
  ];

  final List<String> _streets = [
    'Main Street', 'Oak Avenue', 'Maple Drive', 'Cedar Lane', 'Pine Road',
    'Elm Street', 'Washington Boulevard', 'Park Avenue', 'Lake View Drive',
    'Sunset Boulevard'
  ];

  final List<String> _cities = ['New York', 'Los Angeles', 'Chicago', 'Houston', 'Phoenix'];

  // Electric appliance repair specific services
  final List<Map<String, dynamic>> _serviceTemplates = [
    {
      'name': 'Refrigerator Repair',
      'category': 'Kitchen Appliances',
      'description': 'Diagnosis and repair of refrigerator cooling issues, compressor problems, and temperature control',
      'icon': 'kitchen',
      'basePrice': 89.99,
    },
    {
      'name': 'Washing Machine Repair',
      'category': 'Laundry Appliances',
      'description': 'Fix drainage problems, drum issues, and electronic control malfunctions',
      'icon': 'local_laundry_service',
      'basePrice': 79.99,
    },
    {
      'name': 'Oven & Stove Repair',
      'category': 'Kitchen Appliances',
      'description': 'Heating element replacement, temperature calibration, and ignition repairs',
      'icon': 'outdoor_grill',
      'basePrice': 94.99,
    },
    {
      'name': 'Dishwasher Repair',
      'category': 'Kitchen Appliances',
      'description': 'Water leakage, drainage problems, and cleaning performance issues',
      'icon': 'dishwasher',
      'basePrice': 84.99,
    },
    {
      'name': 'Air Conditioner Service',
      'category': 'HVAC',
      'description': 'AC maintenance, refrigerant recharge, and cooling performance optimization',
      'icon': 'ac_unit',
      'basePrice': 99.99,
    },
    {
      'name': 'Water Heater Repair',
      'category': 'Plumbing & Heating',
      'description': 'Tank and tankless water heater diagnosis and heating element replacement',
      'icon': 'water_heater',
      'basePrice': 109.99,
    },
    {
      'name': 'Microwave Repair',
      'category': 'Kitchen Appliances',
      'description': 'Magnetron replacement, turntable repair, and control panel fixes',
      'icon': 'microwave',
      'basePrice': 69.99,
    },
    {
      'name': 'Dryer Repair',
      'category': 'Laundry Appliances',
      'description': 'No heat issues, drum belt replacement, and vent cleaning',
      'icon': 'dry',
      'basePrice': 74.99,
    },
    {
      'name': 'Electrical Panel Repair',
      'category': 'Electrical Systems',
      'description': 'Circuit breaker replacement, panel upgrades, and safety inspections',
      'icon': 'electric_bolt',
      'basePrice': 129.99,
    },
    {
      'name': 'Wiring & Outlet Installation',
      'category': 'Electrical Systems',
      'description': 'New outlet installation, wiring repairs, and safety grounding',
      'icon': 'electrical_services',
      'basePrice': 59.99,
    },
    {
      'name': 'Ceiling Fan Installation',
      'category': 'Electrical Systems',
      'description': 'Fan mounting, wiring connection, and balance adjustment',
      'icon': 'mode_fan',
      'basePrice': 69.99,
    },
    {
      'name': 'Range Hood Repair',
      'category': 'Kitchen Appliances',
      'description': 'Motor replacement, filter cleaning, and ventilation duct repairs',
      'icon': 'air',
      'basePrice': 79.99,
    },
  ];

  final List<String> _specialties = [
    'Kitchen Appliances',
    'Laundry Appliances',
    'HVAC Systems',
    'Electrical Systems',
    'General Appliance Repair',
    'Plumbing & Heating',
  ];

  final List<String> _skills = [
    'Electrical Diagnosis', 'Circuit Testing', 'Part Replacement',
    'Refrigerant Handling', 'Wiring', 'Soldering', 'Motor Repair',
    'Control Board Repair', 'Safety Inspection', 'Installation',
    'Maintenance', 'Troubleshooting', 'Customer Service', 'Pipe Fitting'
  ];

  final List<String> _bookingDescriptions = [
    'Refrigerator not cooling properly',
    'Washing machine making loud noise',
    'Oven not heating up',
    'AC blowing warm air',
    'Dishwasher not draining',
    'Electrical panel sparking',
    'Dryer not starting',
    'Water heater leaking',
    'Need new outlets installed',
    'Ceiling fan wobbling',
    'Microwave display not working',
    'Range hood motor failure',
    'Circuit breaker keeps tripping',
    'Freezer icing up',
    'Garbage disposal jammed',
  ];

  /// Seed all collections with test data
  Future<void> seedAll() async {
    print('🌱 Starting database seeding...');
    
    try {
      // Clear existing data
      await _clearAllCollections();
      
      // Seed in order due to dependencies
      final serviceIds = await seedServices();
      final userIds = await seedUsers();
      final technicianIds = await seedTechnicians(userIds);
      
      await Future.delayed(const Duration(seconds: 2)); // Allow data propagation
      
      final bookingIds = await seedBookings(userIds, technicianIds, serviceIds);
      final chatIds = await seedChats(userIds);
      await seedChatMessages(chatIds, userIds);
      await seedNotifications(userIds);
      await seedReviews(bookingIds, userIds, technicianIds);
      
      print('✅ Seeding completed successfully!');
      print('📊 Generated:');
      print('   - ${userIds.length} users');
      print('   - ${technicianIds.length} technicians');
      print('   - ${serviceIds.length} services');
      print('   - ${bookingIds.length} bookings');
      print('   - ${chatIds.length} chats');
      print('   - 50+ notifications');
      print('   - 15+ reviews');
    } catch (e) {
      print('❌ Seeding failed: $e');
      rethrow;
    }
  }

  /// Clear all collections
  Future<void> _clearAllCollections() async {
    print('🧹 Clearing existing data...');
    
    final collections = [
      usersCollection,
      techniciansCollection,
      servicesCollection,
      bookingsCollection,
      chatsCollection,
      chatMessagesCollection,
      notificationsCollection,
      reviewsCollection,
    ];

    for (final collection in collections) {
      final snapshot = await _firestore.collection(collection).get();
      for (final doc in snapshot.docs) {
        await doc.reference.delete();
      }
    }
    
    print('✨ All collections cleared');
  }

  /// Seed Services (12 services)
  Future<List<String>> seedServices() async {
    print('🔧 Seeding services...');
    final List<String> serviceIds = [];

    for (final template in _serviceTemplates) {
      final docRef = _firestore.collection(servicesCollection).doc();
      final serviceData = {
        'id': docRef.id,
        'name': template['name'],
        'category': template['category'],
        'description': template['description'],
        'icon': template['icon'],
        'basePrice': template['basePrice'],
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
      };
      
      await docRef.set(serviceData);
      serviceIds.add(docRef.id);
    }

    print('✅ ${serviceIds.length} services created');
    return serviceIds;
  }

  /// Seed Users (15 users: 10 homeowners, 3 technicians, 2 both)
  Future<List<String>> seedUsers() async {
    print('👥 Seeding users...');
    final List<String> userIds = [];

    // Create test accounts (use these for login)
    final testUsers = [
      {
        'email': 'homeownero@test.com',
        'password': 'password123',
        'name': 'John Homeowner',
        'role': 'homeowner',
        'phone': '+1234567890',
      },
      {
        'email': 'techniciano@test.com',
        'password': 'password123',
        'name': 'Mike Technician',
        'role': 'technician',
        'phone': '+1234567891',
      },
      {
        'email': 'admino@test.com',
        'password': 'password123',
        'name': 'Admin User',
        'role': 'admin',
        'phone': '+1234567892',
      },
    ];

    for (final testUser in testUsers) {
      try {
        // Create Firebase Auth user
        UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
          email: testUser['email'] as String,
          password: testUser['password'] as String,
        );

        final userData = {
          'id': userCredential.user!.uid,
          'email': testUser['email'],
          'name': testUser['name'],
          'phone': testUser['phone'],
          'role': testUser['role'],
          'profileImage': null,
          'isVerified': true,
          'createdAt': FieldValue.serverTimestamp(),
        };

        await _firestore
            .collection(usersCollection)
            .doc(userCredential.user!.uid)
            .set(userData);
        
        userIds.add(userCredential.user!.uid);
      } catch (e) {
        // User might already exist
        print('⚠️  Test user ${testUser['email']} may already exist: $e');
      }
    }

    // Generate additional random users
    for (int i = 0; i < 12; i++) {
      final firstName = _firstNames[_random.nextInt(_firstNames.length)];
      final lastName = _lastNames[_random.nextInt(_lastNames.length)];
      final role = i < 7 ? 'homeowner' : 'technician';
      
      final userData = {
        'id': 'user_${i + 1}',
        'email': '${firstName.toLowerCase()}.${lastName.toLowerCase()}@example.com',
        'name': '$firstName $lastName',
        'phone': '+1${_random.nextInt(900) + 100}${_random.nextInt(900) + 100}${_random.nextInt(9000) + 1000}',
        'role': role,
        'profileImage': null,
        'isVerified': _random.nextBool(),
        'createdAt': FieldValue.serverTimestamp(),
      };

      await _firestore
          .collection(usersCollection)
          .doc(userData['id'] as String)
          .set(userData);
      
      userIds.add(userData['id'] as String);
    }

    print('✅ ${userIds.length} users created');
    return userIds;
  }

  /// Seed Technicians (5 technicians)
  Future<List<String>> seedTechnicians(List<String> userIds) async {
    print('👨‍🔧 Seeding technicians...');
    final List<String> technicianIds = [];
    
    final technicianUserIds = userIds
        .where((id) => id.startsWith('user_') && id.endsWith('8') || id.endsWith('9') || id.endsWith('10') || id.endsWith('11') || id.endsWith('12'))
        .toList();

    final technicianNames = [
      'Robert Engineer', 'David Electric', 'James Repairman',
      'William Fixit', 'Daniel Volt',
    ];

    for (int i = 0; i < 5; i++) {
      final technicianId = 'tech_${i + 1}';
      final numSkills = _random.nextInt(4) + 3;
      final skills = List.generate(
        numSkills,
        (_) => _skills[_random.nextInt(_skills.length)],
      ).toSet().toList();

      final numCertifications = _random.nextInt(3) + 1;
      final certifications = List.generate(
        numCertifications,
        (index) => [
          'EPA Certification',
          'NATE Certified',
          'Licensed Electrician',
          'HVAC Excellence',
          'Appliance Repair Certified',
        ][_random.nextInt(5)],
      ).toSet().toList();

      final technicianData = {
        'id': technicianId,
        'userId': i < technicianUserIds.length ? technicianUserIds[i] : technicianId,
        'name': technicianNames[i],
        'email': '${technicianNames[i].split(' ')[0].toLowerCase()}.tech@example.com',
        'phone': '+1${_random.nextInt(900) + 100}${_random.nextInt(900) + 100}${_random.nextInt(9000) + 1000}',
        'specialty': _specialties[i % _specialties.length],
        'skills': skills,
        'certifications': certifications,
        'experience': _random.nextInt(15) + 2,
        'hourlyRate': (_random.nextInt(50) + 35).toDouble(),
        'rating': (_random.nextDouble() * 2 + 3).toDouble(), // 3.0 - 5.0
        'totalJobs': _random.nextInt(200) + 50,
        'isAvailable': _random.nextBool(),
        'verificationStatus': ['verified', 'pending', 'unverified'][_random.nextInt(3)],
        'latitude': 40.7128 + (_random.nextDouble() - 0.5) * 0.1,
        'longitude': -74.0060 + (_random.nextDouble() - 0.5) * 0.1,
        'profileImage': null,
        'createdAt': FieldValue.serverTimestamp(),
      };

      await _firestore
          .collection(techniciansCollection)
          .doc(technicianId)
          .set(technicianData);
      
      technicianIds.add(technicianId);
    }

    print('✅ ${technicianIds.length} technicians created');
    return technicianIds;
  }

  /// Seed Bookings (20 bookings)
  Future<List<String>> seedBookings(
    List<String> userIds,
    List<String> technicianIds,
    List<String> serviceIds,
  ) async {
    print('📅 Seeding bookings...');
    final List<String> bookingIds = [];
    
    final homeownerIds = userIds.where((id) => id.startsWith('user_1') || id.startsWith('user_2') || id.startsWith('user_3') || id.startsWith('user_4') || id.startsWith('user_5') || id.startsWith('user_6') || id.startsWith('user_7')).toList();

    final statuses = ['pending', 'confirmed', 'in_progress', 'completed', 'cancelled'];
    final statusWeights = [0.3, 0.2, 0.15, 0.25, 0.1];

    for (int i = 0; i < 20; i++) {
      final bookingId = 'booking_${i + 1}';
      final service = _serviceTemplates[_random.nextInt(_serviceTemplates.length)];
      final status = _weightedRandom(statuses, statusWeights);
      
      final scheduledHour = _random.nextInt(12) + 8; // 8 AM to 8 PM
      final scheduledDay = DateTime.now().add(Duration(days: _random.nextInt(14) - 7));
      final scheduledTime = DateTime(
        scheduledDay.year,
        scheduledDay.month,
        scheduledDay.day,
        scheduledHour,
        _random.nextInt(4) * 15, // 0, 15, 30, 45 minutes
      );

      final bookingData = {
        'id': bookingId,
        'homeownerId': homeownerIds[_random.nextInt(homeownerIds.length)],
        'technicianId': technicianIds[_random.nextInt(technicianIds.length)],
        'serviceId': serviceIds[_random.nextInt(serviceIds.length)],
        'serviceName': service['name'],
        'scheduledTime': Timestamp.fromDate(scheduledTime),
        'status': status,
        'address': '${_random.nextInt(999) + 1} ${_streets[_random.nextInt(_streets.length)]}',
        'latitude': 40.7128 + (_random.nextDouble() - 0.5) * 0.1,
        'longitude': -74.0060 + (_random.nextDouble() - 0.5) * 0.1,
        'description': _bookingDescriptions[_random.nextInt(_bookingDescriptions.length)],
        'totalPrice': (service['basePrice'] as double) * (_random.nextDouble() * 0.5 + 0.75),
        'createdAt': FieldValue.serverTimestamp(),
        'completedAt': status == 'completed' 
            ? Timestamp.fromDate(scheduledTime.add(const Duration(hours: 2)))
            : null,
      };

      await _firestore
          .collection(bookingsCollection)
          .doc(bookingId)
          .set(bookingData);
      
      bookingIds.add(bookingId);
    }

    print('✅ ${bookingIds.length} bookings created');
    return bookingIds;
  }

  /// Seed Chats (8 chats)
  Future<List<String>> seedChats(List<String> userIds) async {
    print('💬 Seeding chats...');
    final List<String> chatIds = [];

    for (int i = 0; i < 8; i++) {
      final chatId = 'chat_${i + 1}';
      final participant1 = userIds[_random.nextInt(userIds.length)];
      String participant2;
      do {
        participant2 = userIds[_random.nextInt(userIds.length)];
      } while (participant2 == participant1);

      final chatData = {
        'id': chatId,
        'participants': [participant1, participant2],
        'lastMessage': _getRandomMessage(),
        'lastMessageTime': FieldValue.serverTimestamp(),
        'bookingId': _random.nextBool() ? 'booking_${_random.nextInt(20) + 1}' : null,
        'createdAt': FieldValue.serverTimestamp(),
      };

      await _firestore
          .collection(chatsCollection)
          .doc(chatId)
          .set(chatData);
      
      chatIds.add(chatId);
    }

    print('✅ ${chatIds.length} chats created');
    return chatIds;
  }

  /// Seed Chat Messages (random messages for each chat)
  Future<void> seedChatMessages(List<String> chatIds, List<String> userIds) async {
    print('📝 Seeding chat messages...');
    int messageCount = 0;

    for (final chatId in chatIds) {
      final numMessages = _random.nextInt(10) + 5; // 5-15 messages per chat
      
      for (int i = 0; i < numMessages; i++) {
        final messageId = 'msg_${chatId}_${i + 1}';
        final senderId = userIds[_random.nextInt(userIds.length)];
        final sender = ['John', 'Sarah', 'Mike', 'Emma', 'David'][_random.nextInt(5)];

        final messageData = {
          'id': messageId,
          'chatId': chatId,
          'senderId': senderId,
          'senderName': sender,
          'text': _getRandomMessage(),
          'imageUrl': null,
          'isRead': _random.nextBool(),
          'timestamp': Timestamp.fromDate(
            DateTime.now().subtract(Duration(minutes: _random.nextInt(1440)))
          ),
        };

        await _firestore
            .collection(chatMessagesCollection)
            .doc(messageId)
            .set(messageData);
        
        messageCount++;
      }
    }

    print('✅ $messageCount chat messages created');
  }

  /// Seed Notifications (50+ notifications)
  Future<void> seedNotifications(List<String> userIds) async {
    print('🔔 Seeding notifications...');
    
    final notificationTypes = ['booking', 'chat', 'system', 'promotion'];
    final titles = [
      'Booking Confirmed', 'New Message', 'System Update', 'Special Offer',
      'Booking Reminder', 'Technician Assigned', 'Payment Received', 'Review Request',
      'Service Completed', 'Appointment Scheduled',
    ];
    final messages = [
      'Your booking has been confirmed for tomorrow',
      'You have a new message from your technician',
      'App update available with new features',
      'Get 20% off your next repair service!',
      'Your appointment is in 2 hours',
      'A technician has been assigned to your job',
      'Payment of \$95.00 has been processed',
      'How was your experience? Leave a review!',
      'Your appliance repair has been completed',
      'New appointment scheduled for next week',
    ];

    for (int i = 0; i < 50; i++) {
      final notificationId = 'notif_${i + 1}';
      final notificationData = {
        'id': notificationId,
        'userId': userIds[_random.nextInt(userIds.length)],
        'title': titles[_random.nextInt(titles.length)],
        'message': messages[_random.nextInt(messages.length)],
        'type': notificationTypes[_random.nextInt(notificationTypes.length)],
        'referenceId': _random.nextBool() ? 'booking_${_random.nextInt(20) + 1}' : null,
        'isRead': _random.nextBool(),
        'createdAt': Timestamp.fromDate(
          DateTime.now().subtract(Duration(hours: _random.nextInt(168)))
        ),
      };

      await _firestore
          .collection(notificationsCollection)
          .doc(notificationId)
          .set(notificationData);
    }

    print('✅ 50 notifications created');
  }

  /// Seed Reviews (15 reviews)
  Future<void> seedReviews(
    List<String> bookingIds,
    List<String> userIds,
    List<String> technicianIds,
  ) async {
    print('⭐ Seeding reviews...');
    
    final comments = [
      'Excellent service! Fixed my refrigerator quickly.',
      'Very professional and knowledgeable.',
      'Good work but arrived a bit late.',
      'Highly recommended! Great communication.',
      'Fixed the issue on the first visit.',
      'Fair pricing and quality work.',
      'Would definitely use again.',
      'Prompt and efficient service.',
      'Explained the problem clearly before fixing.',
      'Outstanding repair work!',
      'Average experience, could be better.',
      'Saved me from buying a new appliance!',
      'Very courteous and clean work.',
      'The best technician I\'ve ever hired.',
      'Reasonable rates for emergency repair.',
    ];

    for (int i = 0; i < 15; i++) {
      final reviewId = 'review_${i + 1}';
      final bookingId = bookingIds[_random.nextInt(bookingIds.length)];
      
      final reviewData = {
        'id': reviewId,
        'bookingId': bookingId,
        'userId': userIds[_random.nextInt(userIds.length)],
        'technicianId': technicianIds[_random.nextInt(technicianIds.length)],
        'userName': ['John', 'Sarah', 'Michael', 'Emma', 'David'][_random.nextInt(5)],
        'rating': (_random.nextDouble() * 2 + 3), // 3.0 - 5.0
        'comment': comments[i % comments.length],
        'wouldRecommend': _random.nextDouble() > 0.2, // 80% would recommend
        'createdAt': Timestamp.fromDate(
          DateTime.now().subtract(Duration(days: _random.nextInt(30)))
        ),
      };

      await _firestore
          .collection(reviewsCollection)
          .doc(reviewId)
          .set(reviewData);
    }

    print('✅ 15 reviews created');
  }

  // Helper methods
  String _getRandomMessage() {
    final messages = [
      'Hi, when can you come to check my refrigerator?',
      'The washing machine is making a strange noise',
      'Can you come tomorrow morning?',
      'I\'ll be home after 5 PM',
      'Please bring the necessary parts',
      'How much will it cost approximately?',
      'The AC stopped working completely',
      'Is the service covered by warranty?',
      'I need an urgent repair',
      'Thank you for your help!',
      'Can you send me the invoice?',
      'The problem is getting worse',
      'Do you work on weekends?',
      'Please confirm the appointment',
      'I have pictures of the issue',
    ];
    return messages[_random.nextInt(messages.length)];
  }

  String _weightedRandom(List<String> items, List<double> weights) {
    double totalWeight = weights.reduce((a, b) => a + b);
    double random = _random.nextDouble() * totalWeight;
    
    for (int i = 0; i < items.length; i++) {
      random -= weights[i];
      if (random <= 0) return items[i];
    }
    
    return items.last;
  }
}