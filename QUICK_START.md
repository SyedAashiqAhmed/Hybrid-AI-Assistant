# 🚀 Quick Start Guide - Hybrid AI Mobile Assistant

## ⚡ 5-Minute Setup

### Step 1: Prerequisites Check ✅

```bash
# Check Flutter installation
flutter --version

# Expected: Flutter 3.10.4 or higher
```

### Step 2: Install Dependencies 📦

```bash
cd e:\hybrid\hybrid_ai_assistant
flutter pub get
```

### Step 3: Run the App 🎯

```bash
# For Android
flutter run

# For specific device
flutter devices
flutter run -d <device-id>
```

---

## 🧪 Testing the App

### Test 1: System Commands (Offline)

Try these commands **without internet**:

```
✅ "Turn on flashlight"
✅ "Turn off flashlight"
✅ "Change to dark mode"
✅ "Change to light mode"
✅ "Switch theme"
```

**Expected**: Instant response, no network needed

---

### Test 2: AI Queries (Online)

Try these with internet connection:

```
✅ "Explain binary search algorithm"
✅ "What is Flutter?"
✅ "Help me with C++ pointers"
✅ "Explain recursion with example"
✅ "What is the difference between Stack and Queue?"
```

**Expected**: AI response in 2-3 seconds

---

### Test 3: URL Opening (Security)

Try these:

```
✅ "Open youtube.com" → Should work (whitelisted)
✅ "Open google.com" → Should work (whitelisted)
❌ "Open randomsite.com" → Should block (not whitelisted)
```

**Expected**: Security warning for non-whitelisted sites

---

### Test 4: Voice Input 🎤

1. Click microphone button
2. Speak: "Turn on flashlight"
3. App should recognize and execute

**Expected**: Voice → Text → Action

---

## 🎨 UI Features to Explore

### Chat Interface
- User messages (blue, right-aligned)
- AI messages (gray, left-aligned)
- System actions (green, left-aligned)
- Timestamps on all messages

### Theme Switching
1. Say "Change to dark mode"
2. App switches to dark theme
3. Theme persists after app restart

### Typing Indicator
- Shows animated dots when AI is processing
- Disappears when response arrives

---

## 🔧 Troubleshooting

### Issue: "Gemini API Error"

**Solution**:
```dart
// Check lib/config/app_config.dart
static const String geminiApiKey = 'YOUR_API_KEY_HERE';
```

### Issue: "Flashlight not working"

**Solution**:
- Use physical Android device (not emulator)
- Grant camera permission when prompted

### Issue: "Voice input not working"

**Solution**:
- Grant microphone permission
- Use physical device
- Check internet connection (for voice recognition)

---

## 📱 Supported Platforms

| Platform | Status | Notes |
|----------|--------|-------|
| Android | ✅ Full Support | All features work |
| iOS | ⚠️ Partial | Flashlight needs testing |
| Web | ❌ Limited | No flashlight/voice |
| Desktop | ❌ Limited | No flashlight |

**Recommended**: Android device for full feature testing

---

## 🎯 Example Conversations

### Conversation 1: Study Help
```
You: "Explain binary search"
AI: [Detailed explanation with example]
You: "Give me a C++ code example"
AI: [C++ code with explanation]
```

### Conversation 2: Device Control
```
You: "Turn on flashlight"
System: 🔦 Flashlight turned ON
You: "Turn it off"
System: 🔦 Flashlight turned OFF
```

### Conversation 3: Mixed Usage
```
You: "Change to dark mode"
System: 🎨 Theme changed to dark mode
You: "Now explain what is Flutter"
AI: [Flutter explanation]
You: "Open flutter.dev"
System: 🌐 Opening flutter.dev in browser...
```

---

## 🔍 Debugging Tips

### Enable Debug Mode

```dart
// In intent_engine.dart, uncomment:
debugPrint('Intent detected: ${_intentEngine.getIntentDescription(intent)}');
```

### Check API Status

Add this in chat_screen.dart:
```dart
@override
void initState() {
  super.initState();
  _testGeminiApi();
}

Future<void> _testGeminiApi() async {
  final status = await _geminiService.getApiStatus();
  print(status);
}
```

### Monitor Network Calls

```bash
# In terminal while app is running
flutter logs
```

---

## 📊 Performance Expectations

| Action | Expected Time |
|--------|---------------|
| Flashlight toggle | < 100ms |
| Theme change | < 200ms |
| Intent detection | < 10ms |
| AI response | 2-3 seconds |
| Voice recognition | 1-2 seconds |

---

## 🎓 For Viva/Demo

### Demo Flow (5 minutes)

1. **Introduction** (30 sec)
   - "This is a Hybrid AI Assistant"
   - "Combines rule-based and AI approaches"

2. **System Commands** (1 min)
   - "Turn on flashlight" → Show instant response
   - "Change theme" → Show theme switch
   - Explain: "These work offline, no AI needed"

3. **AI Features** (2 min)
   - "Explain binary search" → Show AI response
   - "Help with C++ pointers" → Show AI help
   - Explain: "These use Gemini API"

4. **Security** (1 min)
   - "Open youtube.com" → Works
   - "Open randomsite.com" → Blocked
   - Explain: "Whitelist security"

5. **Architecture** (30 sec)
   - Show Intent Engine code
   - Explain hybrid decision flow

### Key Points to Emphasize

1. **Cost Efficiency**: "Zero cost - uses FREE APIs"
2. **Speed**: "System commands are instant"
3. **Offline Support**: "Works without internet for basic commands"
4. **Security**: "URL whitelist prevents malicious sites"
5. **Scalability**: "Easy to add new commands"

---

## 🛠️ Customization Guide

### Add New System Command

1. **Add keywords** in `app_config.dart`:
```dart
static const List<String> volumeUpKeywords = [
  'volume up',
  'increase volume',
  'louder',
];
```

2. **Add intent type** in `intent.dart`:
```dart
enum IntentType {
  // ... existing
  volumeUp,
}
```

3. **Add detection** in `intent_engine.dart`:
```dart
if (_matchesKeywords(input, AppConfig.volumeUpKeywords)) {
  return Intent(type: IntentType.volumeUp, ...);
}
```

4. **Implement action** in `system_actions.dart`:
```dart
case IntentType.volumeUp:
  return await _increaseVolume();
```

### Modify AI Behavior

Edit `app_config.dart`:
```dart
static const String systemPrompt = '''
Your custom instructions here...
''';
```

---

## 📚 Additional Resources

- **Flutter Docs**: https://flutter.dev/docs
- **Gemini API**: https://ai.google.dev/docs
- **Material 3**: https://m3.material.io
- **Dart Packages**: https://pub.dev

---

## ✅ Checklist Before Demo

- [ ] App runs without errors
- [ ] Flashlight works on device
- [ ] Theme switching works
- [ ] AI responses are working
- [ ] Voice input is functional
- [ ] URL opening is tested
- [ ] Offline commands verified
- [ ] Code is well-commented
- [ ] README is updated

---

## 🎉 You're Ready!

Your Hybrid AI Mobile Assistant is now ready to use and demonstrate!

**Next Steps**:
1. Test all features
2. Prepare demo script
3. Review viva points
4. Practice explaining architecture

**Good luck with your project! 🚀**

---

**Need Help?**
- Check TECHNICAL_DOCS.md for detailed implementation
- Check README.md for architecture overview
- Check PROJECT_ABSTRACT.md for presentation points
