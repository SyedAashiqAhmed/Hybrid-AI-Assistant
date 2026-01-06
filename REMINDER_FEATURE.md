# Reminder Feature Documentation

## Overview
The reminder feature allows users to set custom reminders with specific messages that trigger after a specified duration. Unlike timers (which just show a generic completion message), reminders display the custom message you set.

## What Was Fixed
**Before:** "Remind me" commands were treated as simple timers without storing the reminder message.  
**After:** Full reminder functionality with custom messages and proper notification display.

---

## Usage Examples

### Setting Reminders
```
"Remind me to call mom in 30 minutes"
"Remind me to take medicine in 1 hour"
"Remind me buy groceries in 2 hours"
"Remind me to check the oven in 15 minutes"
"Set reminder to water plants in 45 minutes"
```

### Viewing Reminders
```
"Show reminders"
"List reminders"
"My reminders"
"Check reminders"
```

---

## How It Works

### 1. **Setting a Reminder**
When you say: `"Remind me to call mom in 30 minutes"`

The system:
1. Extracts the message: "call mom"
2. Extracts the duration: 30 minutes (1800 seconds)
3. Stores the reminder with timestamp
4. Schedules a notification
5. Confirms: "⏰ Reminder set for 30 minutes: 'call mom'"

### 2. **Reminder Triggers**
After the specified time:
- Shows notification with title: "⏰ Reminder!"
- Displays your custom message: "call mom"
- Plays notification sound
- Vibrates device
- Removes from active reminders list

### 3. **Viewing Active Reminders**
Shows all pending reminders with:
- Custom message
- Time remaining (e.g., "in 15m 30s")

---

## Technical Implementation

### Files Modified

#### 1. **`lib/models/intent.dart`**
Added new intent types:
- `IntentType.setReminder` - For setting reminders
- `IntentType.showReminders` - For viewing active reminders

#### 2. **`lib/config/app_config.dart`**
Added keyword lists:
```dart
setReminderKeywords = ['remind me', 'reminder', 'set reminder', 'create reminder']
showRemindersKeywords = ['show reminders', 'list reminders', 'my reminders', 'check reminders']
```

#### 3. **`lib/services/intent_engine.dart`**
Added:
- `_detectReminderIntent()` - Detects reminder commands
- `_extractReminderMessage()` - Extracts custom message from input
- Intent description for debugging

**Message Extraction Patterns:**
- "remind me to [message] in [duration]"
- "remind me [message] in [duration]"
- "reminder to [message] in [duration]"
- "reminder [message]"

#### 4. **`lib/services/system_actions.dart`**
Added:
- `_reminders` list - Stores active reminders
- `_setReminder()` - Creates and schedules reminder
- `_showReminderNotification()` - Displays reminder notification
- `_showReminders()` - Lists all active reminders
- Reminder notification channel setup

---

## Features

### ✅ Custom Messages
- Store and display personalized reminder messages
- Support for any text message

### ✅ Time-Based Triggers
- Supports minutes, hours, and seconds
- Examples: "in 5 minutes", "in 1 hour", "in 30 seconds"

### ✅ Multiple Reminders
- Set multiple reminders simultaneously
- Each tracked independently

### ✅ Active Reminder List
- View all pending reminders
- Shows time remaining for each
- Displays custom messages

### ✅ Notifications
- Dedicated reminder notification channel
- Custom message in notification body
- Sound and vibration alerts
- High priority notifications

---

## Differences: Timer vs Reminder vs Alarm

| Feature | Timer | Reminder | Alarm |
|---------|-------|----------|-------|
| **Purpose** | Countdown | Task reminder | Wake up / specific time |
| **Trigger** | After duration | After duration | At specific time |
| **Message** | Generic "Timer Complete" | Custom message | Generic "Alarm!" |
| **Use Case** | "Set timer for 5 minutes" | "Remind me to call mom in 30 minutes" | "Set alarm for 7 AM" |
| **Sound** | Brief notification | Notification sound | Continuous alarm (60s) |

---

## Examples

### Example 1: Simple Reminder
**Input:** "Remind me to take medicine in 30 minutes"
- **Duration:** 30 minutes (1800 seconds)
- **Message:** "take medicine"
- **Response:** "⏰ Reminder set for 30 minutes: 'take medicine'"
- **Notification (after 30 min):** "⏰ Reminder! - take medicine"

### Example 2: Short Duration
**Input:** "Remind me to check the oven in 5 minutes"
- **Duration:** 5 minutes (300 seconds)
- **Message:** "check the oven"
- **Response:** "⏰ Reminder set for 5 minutes: 'check the oven'"

### Example 3: Multiple Reminders
```
User: "Remind me to call John in 15 minutes"
App: "⏰ Reminder set for 15 minutes: 'call John'"

User: "Remind me to water plants in 1 hour"
App: "⏰ Reminder set for 1 hour: 'water plants'"

User: "Show reminders"
App: "⏰ Your reminders:
     • 'call John' (in 12m 30s)
     • 'water plants' (in 57m 15s)"
```

---

## Testing

### Manual Test Cases

1. **Basic Reminder**
   - Say: "Remind me to test in 1 minute"
   - Wait 1 minute
   - Verify notification shows "test"

2. **Multiple Reminders**
   - Set 3 different reminders
   - Say: "Show reminders"
   - Verify all 3 are listed with correct times

3. **Edge Cases**
   - "Remind me" (no message) → Should show error
   - "Remind me to call" (no duration) → Should show error
   - "Remind me to call in 0 minutes" → Should show error

4. **Message Extraction**
   - "Remind me to buy milk in 30 minutes" → "buy milk"
   - "Remind me call mom in 1 hour" → "call mom"
   - "Reminder to check email in 15 minutes" → "check email"

---

## Future Enhancements

Potential improvements:
- [ ] Persistent reminders (survive app restart)
- [ ] Recurring reminders (daily, weekly)
- [ ] Snooze functionality
- [ ] Edit/delete specific reminders
- [ ] Location-based reminders
- [ ] Priority levels for reminders
- [ ] Reminder categories/tags

---

## Troubleshooting

### Reminder not triggering?
- Check notification permissions are granted
- Ensure app is not force-stopped
- Verify battery optimization is disabled for the app

### Message not showing correctly?
- Check the message extraction patterns
- Ensure proper format: "remind me to [message] in [duration]"

### Can't see active reminders?
- Use "show reminders" or "list reminders"
- Reminders are removed after they trigger
