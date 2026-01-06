import 'package:flutter/material.dart' hide Intent;
import 'package:flutter/services.dart';
import 'package:torch_light/torch_light.dart';
import 'package:url_launcher/url_launcher.dart';
// import 'package:flutter_tts/flutter_tts.dart'; // Temporarily disabled
import 'package:shared_preferences/shared_preferences.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart' as permission_handler;
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'dart:async';
import '../models/intent.dart';
import '../config/app_config.dart';

/// System Actions Service
/// Executes all LOCAL device/system commands
/// 
/// PRINCIPLE: These actions NEVER go to AI - they are executed directly
class SystemActions {
  // final FlutterTts _tts = FlutterTts(); // Temporarily disabled
  bool _isFlashlightOn = false;
  
  // Timer and Alarm management
  Timer? _activeTimer;
  int? _timerDuration;
  final FlutterLocalNotificationsPlugin _notificationsPlugin = 
      FlutterLocalNotificationsPlugin();
  final List<Map<String, dynamic>> _alarms = [];
  
  // Audio player for alarm sound
  final AudioPlayer _alarmAudioPlayer = AudioPlayer();
  Timer? _alarmStopTimer;
  
  // Reminder management
  final List<Map<String, dynamic>> _reminders = [];
  
  // Scheduled call management
  final List<Map<String, dynamic>> _scheduledCalls = [];


  SystemActions() {
    // _initializeTts(); // Temporarily disabled
    _initializeNotifications();
    _initializeAlarmManager();
  }
  
  /// Initialize alarm manager
  Future<void> _initializeAlarmManager() async {
    await AndroidAlarmManager.initialize();
  }
  
  /// Initialize notifications
  Future<void> _initializeNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);
    await _notificationsPlugin.initialize(initSettings);
    
    // Create notification channels with sound
    await _createNotificationChannels();
    
    // Request notification permission for Android 13+
    await _requestNotificationPermission();
  }
  
  /// Create notification channels
  Future<void> _createNotificationChannels() async {
    // Timer channel
    const timerChannel = AndroidNotificationChannel(
      'timer_channel',
      'Timer',
      description: 'Timer notifications',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
      showBadge: true,
    );
    
    // Alarm channel
    const alarmChannel = AndroidNotificationChannel(
      'alarm_channel',
      'Alarms',
      description: 'Alarm notifications',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
      showBadge: true,
    );
    
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(timerChannel);
    
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(alarmChannel);
    
    // Reminder channel
    const reminderChannel = AndroidNotificationChannel(
      'reminder_channel',
      'Reminders',
      description: 'Reminder notifications',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
      showBadge: true,
    );
    
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(reminderChannel);
    
    // Phone Call channel
    const phoneCallChannel = AndroidNotificationChannel(
      'phone_call_channel',
      'Scheduled Calls',
      description: 'Scheduled phone call notifications',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
      showBadge: true,
    );
    
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(phoneCallChannel);
  }
  
  /// Request notification permission
  Future<void> _requestNotificationPermission() async {
    final androidInfo = await permission_handler.Permission.notification.request();
    if (!androidInfo.isGranted) {
      debugPrint('Notification permission not granted');
    }
  }

  /// Initialize Text-to-Speech
  // Future<void> _initializeTts() async {
  //   await _tts.setVolume(AppConfig.ttsDefaultVolume);
  //   await _tts.setSpeechRate(AppConfig.ttsDefaultRate);
  //   await _tts.setPitch(AppConfig.ttsDefaultPitch);
  // }

  /// Execute system action based on intent
  Future<IntentResult> executeAction(Intent intent, BuildContext? context) async {
    switch (intent.type) {
      case IntentType.flashlightOn:
        return await _turnFlashlightOn();
      
      case IntentType.flashlightOff:
        return await _turnFlashlightOff();
      
      case IntentType.themeChange:
        return await _changeTheme(intent, context);
      
      case IntentType.openUrl:
        return await _openUrl(intent);
      
      case IntentType.readAloud:
        return await _readAloud(intent.originalInput);
      
      case IntentType.setTimer:
        return await _setTimer(intent);
      
      case IntentType.cancelTimer:
        return await _cancelTimer();
      
      case IntentType.setAlarm:
        return await _setAlarm(intent);
      
      case IntentType.showAlarms:
        return await _showAlarms();
      
      case IntentType.setReminder:
        return await _setReminder(intent);
      
      case IntentType.showReminders:
        return await _showReminders();
      
      case IntentType.makeCall:
        return await _makeCall(intent);
      
      case IntentType.scheduleCall:
        return await _scheduleCall(intent);
      
      case IntentType.showScheduledCalls:
        return await _showScheduledCalls();
      
      case IntentType.cancelScheduledCall:
        return await _cancelScheduledCall();
      
      default:
        return IntentResult.failure('Unknown system action');
    }
  }

  /// Turn flashlight ON
  Future<IntentResult> _turnFlashlightOn() async {
    try {
      // Check if flashlight is available
      final hasFlashlight = await TorchLight.isTorchAvailable();
      
      if (!hasFlashlight) {
        return IntentResult.failure(
          '❌ Flashlight not available on this device'
        );
      }

      // Turn on flashlight
      await TorchLight.enableTorch();
      _isFlashlightOn = true;

      return IntentResult.success(
        '🔦 Flashlight turned ON',
        data: {'flashlightState': true},
      );
    } catch (e) {
      return IntentResult.failure(
        '❌ Failed to turn on flashlight: ${e.toString()}'
      );
    }
  }

  /// Turn flashlight OFF
  Future<IntentResult> _turnFlashlightOff() async {
    try {
      await TorchLight.disableTorch();
      _isFlashlightOn = false;

      return IntentResult.success(
        '🔦 Flashlight turned OFF',
        data: {'flashlightState': false},
      );
    } catch (e) {
      return IntentResult.failure(
        '❌ Failed to turn off flashlight: ${e.toString()}'
      );
    }
  }

  /// Change app theme
  Future<IntentResult> _changeTheme(Intent intent, BuildContext? context) async {
    try {
      final themePreference = intent.parameters['theme'];
      final prefs = await SharedPreferences.getInstance();

      String newTheme;
      if (themePreference == 'dark') {
        newTheme = 'dark';
      } else if (themePreference == 'light') {
        newTheme = 'light';
      } else {
        // Toggle theme
        final currentTheme = prefs.getString('theme') ?? 'light';
        newTheme = currentTheme == 'light' ? 'dark' : 'light';
      }

      // Save theme preference
      await prefs.setString('theme', newTheme);

      return IntentResult.success(
        '🎨 Theme changed to $newTheme mode',
        data: {'theme': newTheme},
      );
    } catch (e) {
      return IntentResult.failure(
        '❌ Failed to change theme: ${e.toString()}'
      );
    }
  }

  /// Open URL in external browser
  Future<IntentResult> _openUrl(Intent intent) async {
    try {
      final urlString = intent.parameters['url'] as String;
      final isWhitelisted = intent.parameters['isWhitelisted'] as bool;

      // Security check
      if (!isWhitelisted) {
        return IntentResult.failure(
          '⚠️ Security Warning: "$urlString" is not in the whitelist.\n'
          'For safety, only whitelisted domains can be opened.'
        );
      }

      // Ensure URL has protocol
      String fullUrl = urlString;
      if (!urlString.startsWith('http://') && !urlString.startsWith('https://')) {
        fullUrl = 'https://$urlString';
      }

      final uri = Uri.parse(fullUrl);

      // Try to launch URL
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        return IntentResult.success(
          '🌐 Opening $urlString in browser...',
          data: {'url': fullUrl},
        );
      } else {
        return IntentResult.failure(
          '❌ Cannot open URL: $urlString'
        );
      }
    } catch (e) {
      return IntentResult.failure(
        '❌ Failed to open URL: ${e.toString()}'
      );
    }
  }

  /// Read text aloud using TTS
  Future<IntentResult> _readAloud(String text) async {
    return IntentResult.failure('❌ TTS temporarily disabled');
  }

  /// Stop TTS
  // Future<void> stopSpeaking() async {
  //   await _tts.stop();
  // }

  /// Speak AI response
  // Future<void> speakResponse(String text) async {
  //   try {
  //     await _tts.speak(text);
  //   } catch (e) {
  //     debugPrint('TTS Error: $e');
  //   }
  // }

  /// Set a timer
  Future<IntentResult> _setTimer(Intent intent) async {
    try {
      final duration = intent.parameters['duration'] as int;
      
      if (duration <= 0) {
        return IntentResult.failure('❌ Please specify a valid duration');
      }
      
      // Cancel existing timer if any
      _activeTimer?.cancel();
      
      // Store duration
      _timerDuration = duration;
      
      // Start new timer
      _activeTimer = Timer(Duration(seconds: duration), () {
        _showTimerNotification();
      });
      
      // Format duration for display
      final minutes = duration ~/ 60;
      final seconds = duration % 60;
      String durationText;
      if (minutes > 0) {
        durationText = '$minutes minute${minutes > 1 ? 's' : ''}';
        if (seconds > 0) {
          durationText += ' $seconds second${seconds > 1 ? 's' : ''}';
        }
      } else {
        durationText = '$seconds second${seconds > 1 ? 's' : ''}';
      }
      
      return IntentResult.success(
        '⏲️ Timer set for $durationText',
        data: {'duration': duration},
      );
    } catch (e) {
      return IntentResult.failure('❌ Failed to set timer: ${e.toString()}');
    }
  }

  /// Cancel active timer
  Future<IntentResult> _cancelTimer() async {
    if (_activeTimer != null && _activeTimer!.isActive) {
      _activeTimer!.cancel();
      _activeTimer = null;
      _timerDuration = null;
      return IntentResult.success('⏲️ Timer cancelled');
    } else {
      return IntentResult.failure('❌ No active timer to cancel');
    }
  }

  /// Show timer notification
  Future<void> _showTimerNotification() async {
    const androidDetails = AndroidNotificationDetails(
      'timer_channel',
      'Timer',
      channelDescription: 'Timer notifications',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      channelShowBadge: true,
      ticker: 'Timer Complete',
      styleInformation: BigTextStyleInformation('Your timer has finished'),
    );
    const notificationDetails = NotificationDetails(android: androidDetails);
    
    await _notificationsPlugin.show(
      0,
      '⏲️ Timer Complete!',
      'Your timer has finished',
      notificationDetails,
    );
  }

  /// Set an alarm
  Future<IntentResult> _setAlarm(Intent intent) async {
    try {
      final timeString = intent.parameters['time'] as String;
      
      if (timeString.isEmpty) {
        return IntentResult.failure('❌ Please specify a time (e.g., "7 AM" or "19:30")');
      }
      
      // Parse time
      final timeParts = timeString.split(':');
      if (timeParts.length != 2) {
        return IntentResult.failure('❌ Invalid time format');
      }
      
      final hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);
      
      // Create alarm time
      final now = DateTime.now();
      var alarmTime = DateTime(now.year, now.month, now.day, hour, minute);
      
      // If time has passed today, set for tomorrow
      if (alarmTime.isBefore(now)) {
        alarmTime = alarmTime.add(const Duration(days: 1));
      }
      
      // Store alarm
      _alarms.add({
        'time': timeString,
        'dateTime': alarmTime,
        'id': _alarms.length,
      });
      
      // Schedule notification
      await _scheduleAlarmNotification(alarmTime, _alarms.length - 1);
      
      // Format time for display
      final period = hour >= 12 ? 'PM' : 'AM';
      final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
      final displayTime = '$displayHour:${minute.toString().padLeft(2, '0')} $period';
      
      return IntentResult.success(
        '⏰ Alarm set for $displayTime',
        data: {'time': timeString, 'alarmTime': alarmTime},
      );
    } catch (e) {
      return IntentResult.failure('❌ Failed to set alarm: ${e.toString()}');
    }
  }

  /// Schedule alarm notification
  Future<void> _scheduleAlarmNotification(DateTime alarmTime, int id) async {
    const androidDetails = AndroidNotificationDetails(
      'alarm_channel',
      'Alarms',
      channelDescription: 'Alarm notifications',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true, // Enable sound in notification
      enableVibration: true,
      fullScreenIntent: true,
      channelShowBadge: true,
      autoCancel: false,
      ongoing: true,
      ticker: 'Alarm Ringing',
      styleInformation: BigTextStyleInformation('Your alarm is ringing'),
    );
    const notificationDetails = NotificationDetails(android: androidDetails);
    
    // Calculate delay until alarm time
    final delay = alarmTime.difference(DateTime.now());
    
    // Schedule notification and alarm sound
    Future.delayed(delay, () async {
      // Show notification
      await _notificationsPlugin.show(
        id,
        '⏰ Alarm!',
        'Your alarm is ringing',
        notificationDetails,
      );
      
      // Play alarm sound
      await _playAlarmSound();
    });
  }

  /// Show all alarms
  Future<IntentResult> _showAlarms() async {
    if (_alarms.isEmpty) {
      return IntentResult.success('⏰ No alarms set');
    }
    
    final alarmList = _alarms.map((alarm) {
      final time = alarm['time'] as String;
      return '• $time';
    }).join('\n');
    
    return IntentResult.success(
      '⏰ Your alarms:\n$alarmList',
      data: {'alarms': _alarms},
    );
  }

  /// Get flashlight state
  bool get isFlashlightOn => _isFlashlightOn;

  /// Play alarm sound (loops for configured duration)
  Future<void> _playAlarmSound() async {
    if (!AppConfig.alarmSoundEnabled) return;
    
    try {
      // Stop any currently playing alarm
      await _stopAlarmSound();
      
      // Instead of using audioplayers (which has URI issues),
      // we'll use repeated notifications with sound
      // This is more reliable across different Android versions
      
      int soundCount = 0;
      const maxSounds = 12; // Play sound 12 times (every 5 seconds for 60 seconds)
      
      // Play notification sound repeatedly
      Timer.periodic(const Duration(seconds: 5), (timer) {
        soundCount++;
        if (soundCount >= maxSounds) {
          timer.cancel();
          _notificationsPlugin.cancelAll();
        } else {
          // Update notification to trigger sound again
          _showAlarmSoundNotification(soundCount);
        }
      });
      
      // Auto-stop after configured duration
      _alarmStopTimer = Timer(
        Duration(seconds: AppConfig.alarmDurationSeconds),
        () async {
          await _stopAlarmSound();
          await _notificationsPlugin.cancelAll();
        },
      );
    } catch (e) {
      debugPrint('Error playing alarm sound: $e');
    }
  }
  
  /// Show alarm sound notification (for repeated sound)
  Future<void> _showAlarmSoundNotification(int count) async {
    const androidDetails = AndroidNotificationDetails(
      'alarm_channel',
      'Alarms',
      channelDescription: 'Alarm notifications',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      fullScreenIntent: true,
      channelShowBadge: true,
      autoCancel: false,
      ongoing: true,
      ticker: 'Alarm Ringing',
      styleInformation: BigTextStyleInformation('Tap to dismiss'),
    );
    const notificationDetails = NotificationDetails(android: androidDetails);
    
    await _notificationsPlugin.show(
      999, // Fixed ID for alarm sound notifications
      '⏰ Alarm Ringing!',
      'Tap to dismiss',
      notificationDetails,
    );
  }
  
  /// Stop alarm sound
  Future<void> _stopAlarmSound() async {
    try {
      await _alarmAudioPlayer.stop();
      _alarmStopTimer?.cancel();
      _alarmStopTimer = null;
    } catch (e) {
      debugPrint('Error stopping alarm sound: $e');
    }
  }


  /// Set a reminder
  Future<IntentResult> _setReminder(Intent intent) async {
    try {
      final duration = intent.parameters['duration'] as int;
      final message = intent.parameters['message'] as String;
      
      if (duration <= 0) {
        return IntentResult.failure('❌ Please specify a valid duration');
      }
      
      if (message.isEmpty) {
        return IntentResult.failure('❌ Please specify what to remind you about');
      }
      
      // Store reminder
      final reminderId = _reminders.length;
      _reminders.add({
        'id': reminderId,
        'message': message,
        'duration': duration,
        'createdAt': DateTime.now(),
      });
      
      // Schedule reminder notification
      Timer(Duration(seconds: duration), () {
        _showReminderNotification(message, reminderId);
      });
      
      // Format duration for display
      final minutes = duration ~/ 60;
      final seconds = duration % 60;
      String durationText;
      if (minutes > 0) {
        durationText = '$minutes minute${minutes > 1 ? 's' : ''}';
        if (seconds > 0) {
          durationText += ' $seconds second${seconds > 1 ? 's' : ''}';
        }
      } else {
        durationText = '$seconds second${seconds > 1 ? 's' : ''}';
      }
      
      return IntentResult.success(
        '⏰ Reminder set for $durationText: "$message"',
        data: {'duration': duration, 'message': message},
      );
    } catch (e) {
      return IntentResult.failure('❌ Failed to set reminder: ${e.toString()}');
    }
  }

  /// Show reminder notification
  Future<void> _showReminderNotification(String message, int id) async {
    const androidDetails = AndroidNotificationDetails(
      'reminder_channel',
      'Reminders',
      channelDescription: 'Reminder notifications',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      channelShowBadge: true,
      ticker: 'Reminder',
      styleInformation: BigTextStyleInformation(''),
    );
    const notificationDetails = NotificationDetails(android: androidDetails);
    
    await _notificationsPlugin.show(
      100 + id, // Use different ID range for reminders
      '⏰ Reminder!',
      message,
      notificationDetails,
    );
    
    // Remove from active reminders
    _reminders.removeWhere((r) => r['id'] == id);
  }

  /// Show all reminders
  Future<IntentResult> _showReminders() async {
    if (_reminders.isEmpty) {
      return IntentResult.success('⏰ No active reminders');
    }
    
    final reminderList = _reminders.map((reminder) {
      final message = reminder['message'] as String;
      final createdAt = reminder['createdAt'] as DateTime;
      final duration = reminder['duration'] as int;
      final triggerTime = createdAt.add(Duration(seconds: duration));
      final remaining = triggerTime.difference(DateTime.now());
      
      if (remaining.isNegative) {
        return '• "$message" (triggering soon...)';
      }
      
      final mins = remaining.inMinutes;
      final secs = remaining.inSeconds % 60;
      return '• "$message" (in ${mins}m ${secs}s)';
    }).join('\n');
    
    return IntentResult.success(
      '⏰ Your reminders:\n$reminderList',
      data: {'reminders': _reminders},
    );
  }


  /// Make an immediate phone call
  Future<IntentResult> _makeCall(Intent intent) async {
    try {
      final phoneNumber = intent.parameters['phoneNumber'] as String;
      
      debugPrint('🔵 _makeCall called with number: $phoneNumber');
      
      if (phoneNumber.isEmpty) {
        return IntentResult.failure('❌ Please specify a phone number');
      }
      
      // Request phone permission
      debugPrint('🔵 Requesting phone permission...');
      final phonePermission = await permission_handler.Permission.phone.request();
      if (!phonePermission.isGranted) {
        debugPrint('🔴 Phone permission denied');
        return IntentResult.failure('❌ Phone permission is required to make calls');
      }
      debugPrint('🟢 Phone permission granted');
      
      // Use flutter_phone_direct_caller to make direct call
      try {
        debugPrint('🔵 Calling FlutterPhoneDirectCaller.callNumber($phoneNumber)');
        await FlutterPhoneDirectCaller.callNumber(phoneNumber);
        debugPrint('🟢 Call initiated successfully');
        
        return IntentResult.success(
          '📞 Calling $phoneNumber...',
          data: {'phoneNumber': phoneNumber},
        );
      } catch (e) {
        debugPrint('🔴 Direct caller error: ${e.toString()}');
        return IntentResult.failure('❌ Failed to make call: ${e.toString()}');
      }
    } catch (e) {
      debugPrint('🔴 General error: ${e.toString()}');
      return IntentResult.failure('❌ Failed to make call: ${e.toString()}');
    }
  }

  /// Schedule a phone call
  Future<IntentResult> _scheduleCall(Intent intent) async {
    try {
      final phoneNumber = intent.parameters['phoneNumber'] as String;
      final duration = intent.parameters['duration'] as int;
      
      if (phoneNumber.isEmpty) {
        return IntentResult.failure('❌ Please specify a phone number');
      }
      
      if (duration <= 0) {
        return IntentResult.failure('❌ Please specify a valid delay time');
      }
      
      // Request phone permission
      final phonePermission = await permission_handler.Permission.phone.request();
      if (!phonePermission.isGranted) {
        return IntentResult.failure('❌ Phone permission is required to make calls');
      }
      
      // Store scheduled call
      final callId = _scheduledCalls.length;
      final scheduledTime = DateTime.now().add(Duration(seconds: duration));
      
      _scheduledCalls.add({
        'id': callId,
        'phoneNumber': phoneNumber,
        'duration': duration,
        'scheduledTime': scheduledTime,
        'createdAt': DateTime.now(),
      });
      
      // Schedule the call
      Timer(Duration(seconds: duration), () async {
        // Show notification before making call
        await _showCallNotification(phoneNumber, callId);
        
        // Wait 2 seconds to show notification, then initiate call
        await Future.delayed(const Duration(seconds: 2));
        
        // Initiate the call
        await _initiateCall(phoneNumber, callId);
      });
      
      // Format duration for display
      final minutes = duration ~/ 60;
      final seconds = duration % 60;
      String durationText;
      if (minutes > 0) {
        durationText = '$minutes minute${minutes > 1 ? 's' : ''}';
        if (seconds > 0) {
          durationText += ' $seconds second${seconds > 1 ? 's' : ''}';
        }
      } else {
        durationText = '$seconds second${seconds > 1 ? 's' : ''}';
      }
      
      return IntentResult.success(
        '📞 Call to $phoneNumber scheduled in $durationText',
        data: {'phoneNumber': phoneNumber, 'duration': duration},
      );
    } catch (e) {
      return IntentResult.failure('❌ Failed to schedule call: ${e.toString()}');
    }
  }

  /// Show call notification
  Future<void> _showCallNotification(String phoneNumber, int id) async {
    const androidDetails = AndroidNotificationDetails(
      'phone_call_channel',
      'Scheduled Calls',
      channelDescription: 'Scheduled phone call notifications',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      channelShowBadge: true,
      ticker: 'Scheduled Call',
      styleInformation: BigTextStyleInformation('Initiating call...'),
    );
    const notificationDetails = NotificationDetails(android: androidDetails);
    
    await _notificationsPlugin.show(
      200 + id, // Use different ID range for calls
      '📞 Scheduled Call',
      'Calling $phoneNumber...',
      notificationDetails,
    );
  }

  /// Initiate phone call
  Future<void> _initiateCall(String phoneNumber, int id) async {
    try {
      debugPrint('🔵 Initiating scheduled call to: $phoneNumber');
      
      // Use flutter_phone_direct_caller for direct calling
      await FlutterPhoneDirectCaller.callNumber(phoneNumber);
      
      debugPrint('🟢 Scheduled call initiated successfully');
      
      // Remove from scheduled calls list
      _scheduledCalls.removeWhere((call) => call['id'] == id);
    } catch (e) {
      debugPrint('🔴 Error initiating scheduled call: $e');
    }
  }

  /// Show all scheduled calls
  Future<IntentResult> _showScheduledCalls() async {
    if (_scheduledCalls.isEmpty) {
      return IntentResult.success('📞 No scheduled calls');
    }
    
    final callList = _scheduledCalls.map((call) {
      final phoneNumber = call['phoneNumber'] as String;
      final scheduledTime = call['scheduledTime'] as DateTime;
      final remaining = scheduledTime.difference(DateTime.now());
      
      if (remaining.isNegative) {
        return '• $phoneNumber (calling soon...)';
      }
      
      final mins = remaining.inMinutes;
      final secs = remaining.inSeconds % 60;
      return '• $phoneNumber (in ${mins}m ${secs}s)';
    }).join('\n');
    
    return IntentResult.success(
      '📞 Your scheduled calls:\n$callList',
      data: {'scheduledCalls': _scheduledCalls},
    );
  }

  /// Cancel scheduled call
  Future<IntentResult> _cancelScheduledCall() async {
    if (_scheduledCalls.isEmpty) {
      return IntentResult.failure('❌ No scheduled calls to cancel');
    }
    
    // Cancel the most recent scheduled call
    final lastCall = _scheduledCalls.removeLast();
    final phoneNumber = lastCall['phoneNumber'] as String;
    
    return IntentResult.success(
      '📞 Cancelled scheduled call to $phoneNumber',
      data: {'cancelledCall': lastCall},
    );
  }

  /// Cleanup
  void dispose() {
    // _tts.stop(); // Temporarily disabled
    _activeTimer?.cancel();
    _alarmStopTimer?.cancel();
    _alarmAudioPlayer.dispose();
  }
}
