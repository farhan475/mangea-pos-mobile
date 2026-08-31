# Frontend Testing Guide - Mangea POS Flutter App

Complete testing guide untuk Flutter frontend Mangea POS.

## Prerequisites

- Flutter 3.19.6+
- Go backend running on `http://localhost:8080/api/v1`
- MySQL with migrations applied
- Browser (Chrome) or Android emulator/device

## Running the App

### Option 1: Web Browser (Easiest for Testing)

```bash
flutter run -d chrome
# Opens http://localhost:port in Chrome
```

### Option 2: Android Emulator

```bash
flutter emulators --launch <emulator-id>
flutter run
```

### Option 3: Linux Desktop

```bash
flutter run -d linux
```

## Test Scenarios

### 1. App Startup & Initialization

**Expected Behavior:**
- App loads without crashes
- Splash screen shows briefly
- Root navigation appears (Sidebar + Main content area)
- No server connection errors in console

**Test:**
```bash
flutter run -d chrome
# Check Chrome DevTools console (F12) for errors
```

**Pass Criteria:**
- ✓ App displays main shell screen
- ✓ No error messages in console
- ✓ Sidebar navigation visible
- ✓ Dashboard content loads

---

### 2. API Connectivity Test

**Test Backend Connection:**

```dart
// In Flutter DevTools console or via logs:
// Monitor DioClient requests in app logs
```

**Expected Behavior:**
- GET `/api/v1/categories` → 200 OK, empty array
- GET `/api/v1/products` → 200 OK, empty array  
- GET `/api/v1/orders` → 200 OK, empty array

**Test:**
1. Open app
2. Open Categories list (or products)
3. Check DevTools Network tab for requests
4. Verify requests go to correct base URL: `http://localhost:8080/api/v1`

**Pass Criteria:**
- ✓ Network requests appear in DevTools
- ✓ Correct endpoints called
- ✓ No CORS errors
- ✓ Response status 200

---

### 3. Navigation & Screen Flow

**Dashboard Screen:**
- [ ] Sidebar visible with menu items
- [ ] Dashboard title and description show
- [ ] Metrics cards display (New Orders, Total Orders, etc)
- [ ] Order List column displays
- [ ] Payment List column displays (tablet mode)
- [ ] Sidebar widgets (Popular Dishes, Out of Stock)

**POS Screen:**
- [ ] Click "Menu/POS" in sidebar
- [ ] Product grid loads
- [ ] Category filters visible
- [ ] Search bar functional
- [ ] Add to cart button works
- [ ] Cart sidebar updates

**Orders Screen:**
- [ ] Click "Orders" in sidebar
- [ ] Order list loads
- [ ] Filter chips show (All, Pending, Cooking, Ready, Completed)
- [ ] Order cards display with status badges
- [ ] Status badge colors correct (Yellow=Cooking, Green=Ready, Blue=Completed)

**Tables Screen:**
- [ ] Click "Tables" in sidebar
- [ ] Table grid/list loads
- [ ] Table cards show number, capacity, status
- [ ] Add table button works (modal opens)

**Test:**
1. Click each sidebar menu item
2. Verify screen transitions smoothly
3. Check data loads (no loading spinner stuck)
4. Verify back/navigation works

**Pass Criteria:**
- ✓ All screens accessible
- ✓ No navigation crashes
- ✓ Data loads properly
- ✓ Responsive layout (check in tablet mode)

---

### 4. Product Management

**Create Product (Manual Backend):**

First, create category + product in backend:

```bash
# Backend: Create category
curl -X POST http://localhost:8080/api/v1/categories \
  -H "Content-Type: application/json" \
  -d '{"name": "Makanan"}'
# Response: {"id": "...", "name": "Makanan", "created_at": "..."}

# Backend: Create product
curl -X POST http://localhost:8080/api/v1/products \
  -H "Content-Type: application/json" \
  -d '{
    "category_id": "[category-id-from-above]",
    "name": "Nasi Goreng",
    "price": 25000.00,
    "stock": 10,
    "is_available": true
  }'
```

**Test in Frontend:**

1. Open POS screen
2. Navigate to products tab
3. Look for "Nasi Goreng" in product grid
4. Verify price displays as "25000" or "Rp 25.000"
5. Click product → add to cart

**Pass Criteria:**
- ✓ Product appears in grid after creation
- ✓ Product details display correctly
- ✓ Add to cart works
- ✓ Cart updates with item

---

### 5. Order Creation Flow

**Complete Order Workflow:**

1. **Create test data (Backend):**
   ```bash
   # Create table
   curl -X POST http://localhost:8080/api/v1/tables \
     -H "Content-Type: application/json" \
     -d '{"table_number": "A1", "capacity": 4}'
   ```

2. **In Frontend - POS Screen:**
   - [ ] Search/find "Nasi Goreng" product
   - [ ] Click add to cart
   - [ ] Set quantity to 2
   - [ ] Verify subtotal calculated (25000 × 2 = 50000)
   - [ ] Click "Checkout" or "Create Order"
   - [ ] Modal appears to select table
   - [ ] Select table "A1"
   - [ ] Optionally enter customer name
   - [ ] Click "Submit Order"

3. **Verification:**
   - [ ] Order created successfully (no error toast)
   - [ ] App navigates back to dashboard
   - [ ] New order appears in Dashboard order list
   - [ ] Order shows correct:
     - Table number: "A1"
     - Item count: "1 item" (Nasi Goreng × 2)
     - Total: "50000"
     - Status badge: "Pending" (gray)

**Pass Criteria:**
- ✓ Order POST request succeeds (DevTools shows 201)
- ✓ Order appears in Dashboard immediately
- ✓ All order details correct
- ✓ No duplicate orders created
- ✓ Total amount calculated server-side (trust backend calculation)

---

### 6. Order Status Transitions

**Start with pending order from previous test.**

**Status Flow: Pending → Cooking**
1. In Dashboard, find your order
2. Click on order card
3. Click "Mark as Cooking" or status button
4. Verify:
   - [ ] Order status updates to "Cooking"
   - [ ] Badge color changes to Yellow
   - [ ] Network request shows PATCH /orders/:id/status

**Status Flow: Cooking → Ready**
1. Click order again
2. Change status to "Ready"
3. Verify:
   - [ ] Badge changes to Green
   - [ ] Order moves to payment section (if visible)

**Status Flow: Ready → Paid**
1. Click order
2. Change to "Paid"
3. Verify:
   - [ ] Badge changes to Blue (if implemented)
   - [ ] Order removed from order list
   - [ ] Table "A1" status changes back to available

**Error Case: Invalid Transition**
1. Create new order (status = pending)
2. Try to change status directly to "paid" (skip cooking/ready)
3. Verify:
   - [ ] Backend returns 422 error
   - [ ] Frontend shows error toast: "Cannot transition from pending to paid"
   - [ ] Order status unchanged

**Pass Criteria:**
- ✓ Valid transitions succeed
- ✓ Invalid transitions rejected with error
- ✓ Status badge colors update
- ✓ UI reflects server state correctly
- ✓ No race conditions (rapid clicks handled gracefully)

---

### 7. Offline-First Sync

**Test Offline Order Creation:**

1. **Disable Network:**
   - Browser DevTools → Network tab → Offline checkbox
   - Or disconnect WiFi/network

2. **Create Order:**
   - Go to POS, add product to cart
   - Select table, create order
   - Verify:
     - [ ] Order created locally (no network error)
     - [ ] "Pending Sync" badge appears on order
     - [ ] Order stored in Hive local DB

3. **Re-enable Network:**
   - Browser DevTools → uncheck Offline
   - Or reconnect network

4. **Verify Sync:**
   - [ ] SyncManager triggers automatically (or manual sync button)
   - [ ] Network tab shows POST /sync/orders request
   - [ ] Request includes offline order with items
   - [ ] Response returns synced orders with sync_status="synced"
   - [ ] UI updates: "Pending Sync" badge disappears
   - [ ] Order now appears on backend

5. **Resend Sync (Idempotency Test):**
   - Manually trigger sync again (force sync or restart app)
   - Verify:
     - [ ] No duplicate orders created
     - [ ] Order still shows as synced
     - [ ] Idempotent behavior works

**Pass Criteria:**
- ✓ Orders created offline successfully
- ✓ "Pending Sync" badge shows
- ✓ Automatic sync on reconnection
- ✓ Backend receives complete order with items
- ✓ Idempotent (resending doesn't duplicate)

---

### 8. Dashboard Metrics

**After creating multiple orders:**

1. Go to Dashboard
2. Check metrics cards:
   - **New Orders:** Count of pending orders in last 1 hour
   - **Total Orders:** Count of non-cancelled orders today
   - **Waiting List:** Count of occupied tables with orders not ready/paid
   - **Growth %:** (today - yesterday) / yesterday × 100 (or null if first day)

3. **Populate Data:**
   - Create 3 orders, transition them to different states
   - Backend should calculate metrics automatically

4. **Verify:**
   - [ ] Metrics update after each order change
   - [ ] Numbers match backend calculations
   - [ ] Percentages format correctly

**Manual Verification:**
```bash
curl http://localhost:8080/api/v1/dashboard/metrics
# Response: {"new_orders_count": X, "total_orders_today": Y, ...}
```

**Pass Criteria:**
- ✓ Metrics display correct values
- ✓ Metrics update on order changes (may require refresh)
- ✓ No calculation errors

---

### 9. UI Responsiveness

**Tablet Mode:**
1. Open app in browser
2. DevTools → Toggle device toolbar
3. Set to tablet size (e.g., iPad: 768×1024)
4. Verify:
   - [ ] Dashboard 3-column layout shows (Order List, Payment, Sidebar)
   - [ ] Content doesn't overflow
   - [ ] Buttons clickable
   - [ ] Spacing appropriate

**Mobile Mode:**
1. Set device to mobile (e.g., iPhone: 375×667)
2. Verify:
   - [ ] Sidebar collapses (hamburger menu or side drawer)
   - [ ] Content stacks vertically
   - [ ] Touch targets sufficient (44px minimum)
   - [ ] No horizontal scrolling

**Desktop Mode:**
1. Full screen browser
2. Verify:
   - [ ] Sidebar permanent
   - [ ] Multi-column layout optimal

**Pass Criteria:**
- ✓ App responsive across screen sizes
- ✓ No layout breaks or overflow
- ✓ All elements clickable/accessible
- ✓ Touch targets appropriate for mobile

---

### 10. Error Handling

**Test Network Errors:**

1. **Timeout:**
   - Slow down network (DevTools → Network tab → Slow 3G)
   - Try to fetch data
   - Verify:
     - [ ] Loading spinner shows
     - [ ] Timeout error appears after 30s
     - [ ] User can retry

2. **Server Error (500):**
   - Backend offline or returns 500
   - Try any operation
   - Verify:
     - [ ] Error toast appears
     - [ ] User can retry
     - [ ] No app crash

3. **Not Found (404):**
   - Try to fetch non-existent order
   - Verify:
     - [ ] "Not found" error shown
     - [ ] Graceful handling

4. **Validation Error (400):**
   - Try to create order with missing fields
   - Verify:
     - [ ] Validation error shown
     - [ ] Clear error message

**Pass Criteria:**
- ✓ All errors handled gracefully
- ✓ No unhandled exceptions
- ✓ User can retry failed operations
- ✓ Error messages helpful

---

### 11. Data Format Verification

**JSON Serialization:**

1. Open DevTools Network tab
2. Perform operations (create order, etc)
3. Inspect request/response payloads

**Check Format:**
- [ ] Field names are snake_case (user_id, product_name, etc)
- [ ] Timestamps are ISO8601: `2024-08-30T14:40:00Z`
- [ ] Numbers are numeric (not quoted strings)
- [ ] Nulls represented as `null` (not empty strings)
- [ ] Arrays properly formatted

**Example Order Response:**
```json
{
  "id": "550e8400-e29b-41d4-a716-446655440001",
  "user_id": null,
  "customer_name": "John Doe",
  "table_number": "A1",
  "total_amount": 50000.00,
  "status": "pending",
  "sync_status": "synced",
  "created_at": "2024-08-30T14:40:00Z",
  "items": [
    {
      "id": "550e8400-e29b-41d4-a716-446655440002",
      "order_id": "550e8400-e29b-41d4-a716-446655440001",
      "product_id": "550e8400-e29b-41d4-a716-446655440000",
      "product_name": "Nasi Goreng",
      "price": 25000.00,
      "quantity": 2,
      "subtotal": 50000.00
    }
  ]
}
```

**Pass Criteria:**
- ✓ All field names match backend contract
- ✓ Data types correct
- ✓ DateTime parsing works (no "Invalid date" errors)
- ✓ Null handling correct

---

## Automated Testing (Unit/Widget Tests)

### Run Tests

```bash
flutter test
```

### Test Coverage

Current tests cover:
- [ ] Model serialization/deserialization
- [ ] BLoC state management
- [ ] Widget rendering
- [ ] Navigation
- [ ] API service mocking

### Add Tests

Example test file:

```dart
// test/features/dashboard/presentation/bloc/order_bloc_test.dart
void main() {
  group('OrderBloc', () {
    late OrderBloc orderBloc;
    late MockOrderRepository mockOrderRepository;

    setUp(() {
      mockOrderRepository = MockOrderRepository();
      orderBloc = OrderBloc(mockOrderRepository);
    });

    test('Initial state is OrderInitial', () {
      expect(orderBloc.state, equals(OrderInitial()));
    });

    test('LoadTodayOrders emits [OrderLoading, OrderLoaded] on success', () async {
      // Mock successful API response
      when(mockOrderRepository.getOrders(...))
          .thenAnswer((_) async => [...]);

      expectLater(
        orderBloc.stream,
        emitsInOrder([
          isA<OrderLoading>(),
          isA<OrderLoaded>(),
        ]),
      );

      orderBloc.add(LoadTodayOrders());
    });
  });
}
```

---

## Performance Testing

### Metrics to Monitor

- **App Load Time:** < 3 seconds
- **Screen Transition:** < 500ms
- **API Response:** < 1 second (network dependent)
- **Order List Scroll:** 60 FPS
- **Memory:** < 200 MB

### Test Commands

```bash
# Profile app performance
flutter run --profile

# Track memory usage
# Use Android Studio Profiler or similar

# Check frame rate
# DevTools → Performance tab
```

---

## Device Testing

### Android
```bash
flutter run
```

### iOS
```bash
flutter run -d iphone
```

### Web
```bash
flutter run -d chrome
# or
flutter run -d firefox
```

---

## Test Data Cleanup

After testing, clean up:

```bash
# Clear local Hive DB (on device/emulator)
# Usually done via Settings or app reset

# Backend cleanup:
# DELETE all orders, products, tables
# Or restore from backup
```

---

## Success Criteria Summary

- [ ] App builds without errors
- [ ] All screens accessible and render correctly
- [ ] CRUD operations work (Create order, read order, update status)
- [ ] Order status transitions validated (no invalid transitions)
- [ ] Offline mode works (create locally, sync online)
- [ ] Dashboard metrics accurate
- [ ] JSON serialization correct (snake_case, ISO8601, nulls)
- [ ] Error handling graceful (no crashes)
- [ ] UI responsive (tablet, mobile, desktop)
- [ ] Network requests use correct endpoints and methods
- [ ] No unhandled exceptions or console errors

---

## Debugging Tips

### Enable Verbose Logging

```bash
flutter run -v
```

### Inspect Hive Database (Local)

```dart
// In your app code, debug print:
var box = await Hive.openBox('orders');
print(box.values.toList()); // Print all local orders
```

### Monitor Network Requests

**Browser DevTools:**
- F12 → Network tab
- Filter by XHR/Fetch
- Inspect request/response

**Flutter DevTools:**
```bash
flutter pub global activate devtools
devtools
```

### Check Console Logs

```dart
// Add debug prints in code:
log('Order created: $order'); // Uses dart:developer
```

Grep logs:
```bash
flutter run | grep "Order created"
```

---

**Test Checklist Complete!** Once all items pass, frontend is ready for UAT. 🎉
