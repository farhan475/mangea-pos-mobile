# Frontend-Backend Integration Testing Guide

Complete guide untuk testing Flutter frontend dengan Go backend.

## Prerequisites

### Backend Setup
- ✅ Go backend compiled: `bin/api`
- ✅ MySQL running with migrations applied
- ✅ Backend running on `http://localhost:8080/api/v1`
- ✅ All 22 API endpoints implemented

### Frontend Setup  
- ✅ Flutter app built
- ✅ Dependencies installed via `flutter pub get`
- ✅ DioClient configured to `http://localhost:8080/api/v1`
- ✅ App running on Chrome/emulator

## Integration Test Matrix

| Feature | Frontend | Backend | Status |
|---------|----------|---------|--------|
| List Categories | ✅ | ✅ | Ready |
| List Products | ✅ | ✅ | Ready |
| Create Product | ✅ | ✅ | Ready |
| Create Table | ✅ | ✅ | Ready |
| Create Order | ✅ | ✅ | Ready |
| Update Order Status | ✅ | ✅ | Ready |
| Update Full Order | ✅ | ✅ | **FIXED** |
| Sync Orders | ✅ | ✅ | Ready |
| Dashboard Metrics | ✅ | ✅ | Ready |
| Popular Dishes | ✅ | ✅ | Ready |
| Out of Stock | ✅ | ✅ | Ready |

## End-to-End Test Flow

### Step 1: Setup Test Environment

```bash
# Terminal 1: Ensure MySQL running
mysql -u root -p

# Terminal 2: Start backend
cd /home/farhan/mangea-backend
go run ./cmd/api
# Output: "Starting server on :8080"

# Terminal 3: Start Flutter app
cd /home/farhan/mangea_app
flutter run -d chrome
# App opens in Chrome at http://localhost:<port>
```

### Step 2: Create Test Data

**Via Backend (curl):**

```bash
# 1. Create category
CATEGORY_RESPONSE=$(curl -s -X POST http://localhost:8080/api/v1/categories \
  -H "Content-Type: application/json" \
  -d '{"name": "Makanan"}')
CATEGORY_ID=$(echo $CATEGORY_RESPONSE | jq -r '.id')
echo "Created category: $CATEGORY_ID"

# 2. Create product
PRODUCT_RESPONSE=$(curl -s -X POST http://localhost:8080/api/v1/products \
  -H "Content-Type: application/json" \
  -d '{
    "category_id": "'$CATEGORY_ID'",
    "name": "Nasi Goreng",
    "price": 25000.00,
    "stock": 10,
    "is_available": true
  }')
PRODUCT_ID=$(echo $PRODUCT_RESPONSE | jq -r '.id')
echo "Created product: $PRODUCT_ID"

# 3. Create table
TABLE_RESPONSE=$(curl -s -X POST http://localhost:8080/api/v1/tables \
  -H "Content-Type: application/json" \
  -d '{"table_number": "A1", "capacity": 4}')
TABLE_ID=$(echo $TABLE_RESPONSE | jq -r '.id')
echo "Created table: $TABLE_ID"
```

**Or Via Frontend (Manual):**
- No UI yet for creating categories/products/tables
- Use backend curl instead (automated setup faster)

### Step 3: Test Complete Order Workflow

#### In Frontend UI:

1. **Open Dashboard**
   - Should see empty order list
   - Metrics show: 0 new orders, 0 total today

2. **Open POS/Menu Screen**
   - Should see "Nasi Goreng" product
   - Price displays: 25,000

3. **Create Order**
   - Click "Nasi Goreng"
   - Set quantity: 2
   - Cart shows: Nasi Goreng × 2, subtotal = 50,000
   - Click "Checkout"
   - Select table: A1
   - Enter customer name: "Test Customer"
   - Click "Create Order"

4. **Verify Order Created**
   - Navigate to Dashboard
   - New order appears with:
     - Table: A1
     - Customer: Test Customer
     - Items: 1 (Nasi Goreng)
     - Total: 50,000
     - Status badge: Pending (gray)
   - Metrics updated: New Orders = 1, Total = 1

#### Verify in Backend (curl):

```bash
# Get all orders
curl http://localhost:8080/api/v1/orders | jq '.[] | {id, customer_name, status, total_amount}'
# Should see your order with status="pending", total_amount=50000

# Get order details with items
ORDER_ID="<order-id-from-above>"
curl http://localhost:8080/api/v1/orders/$ORDER_ID | jq '.'
# Should include nested items array with Nasi Goreng × 2
```

### Step 4: Test Order Status Transitions

#### In Frontend:

1. Find pending order in Dashboard
2. Click on order card
3. Change status to "Cooking"
   - Badge changes color (yellow)
   - Order moves up in list (if sorted by status)
4. Change status to "Ready"
   - Badge changes color (green)
5. Change status to "Paid"
   - Badge updates
   - Order moves to payment section (if implemented)
   - Table "A1" should show as available

#### Verify in Backend:

```bash
# Check order after each transition
curl http://localhost:8080/api/v1/orders/$ORDER_ID | jq '.status'
# pending → cooking → ready → paid

# Check table status after paid
curl http://localhost:8080/api/v1/tables | jq '.[] | {table_number, status}'
# A1 should be "available" after order paid
```

### Step 5: Test Invalid Transition (Error Handling)

**In Frontend:**

1. Create new order (status = pending)
2. Try to change status directly to "paid" (skip cooking/ready)
3. Verify error message appears: "Cannot transition from pending to paid"
4. Order status remains "pending"

**Backend Verification:**

```bash
# Try invalid transition via curl
curl -X PATCH http://localhost:8080/api/v1/orders/$ORDER_ID/status \
  -H "Content-Type: application/json" \
  -d '{"status": "paid"}'
# Response: 422 Unprocessable Entity
# {"error": "cannot transition from pending to paid"}
```

### Step 6: Test Offline Sync

**Prerequisites:**
- Order with sync_status = "pending" in local Hive DB
- Network disconnected

#### In Frontend:

1. **Disable Network:**
   - Browser DevTools → Network → Offline checkbox
   - Or: Disconnect WiFi/network

2. **Create Order:**
   - Add product to cart
   - Create order (normally)
   - Should NOT see network error
   - Order saved locally
   - "Pending Sync" badge appears

3. **Re-enable Network:**
   - Browser DevTools → Uncheck Offline
   - Reconnect network

4. **Auto Sync:**
   - SyncManager detects connectivity change
   - POST /sync/orders sent automatically
   - Order synced, badge disappears

#### Backend Verification:

```bash
# After sync, order should exist on backend
curl http://localhost:8080/api/v1/orders | jq '.[] | select(.customer_name == "Offline Customer")'
# Should show the offline-created order

# Verify items also synced
curl http://localhost:8080/api/v1/orders/$OFFLINE_ORDER_ID | jq '.items'
# Should show all items from offline creation
```

#### Idempotency Test:

```bash
# Get pending orders from local DB (simulated)
# Trigger sync again (force or restart app)
# Verify NO duplicate orders created
curl http://localhost:8080/api/v1/orders | wc -l
# Count should stay same (1 order, not 2)
```

### Step 7: Test Dashboard Metrics

**Create multiple orders with different statuses:**

```bash
# Via curl, create 3 orders with different statuses
ORDER1=$(curl -s -X POST http://localhost:8080/api/v1/orders ...)
ORDER2=$(curl -s -X POST http://localhost:8080/api/v1/orders ...)
ORDER3=$(curl -s -X POST http://localhost:8080/api/v1/orders ...)

# Transition them to different states
curl -X PATCH http://localhost:8080/api/v1/orders/$ORDER1/status \
  -d '{"status": "cooking"}'
curl -X PATCH http://localhost:8080/api/v1/orders/$ORDER2/status \
  -d '{"status": "ready"}'
curl -X PATCH http://localhost:8080/api/v1/orders/$ORDER3/status \
  -d '{"status": "paid"}'
```

**In Frontend:**
1. Go to Dashboard
2. Check metrics:
   - **New Orders:** Should be 0 (all moved past pending) or 1 (if one still pending)
   - **Total Orders:** Should be 3 (all non-cancelled)
   - **Growth %:** null (first day) or percentage
   - **Waiting List:** Should be 1 (ready order waiting payment)

**Backend Verification:**

```bash
curl http://localhost:8080/api/v1/dashboard/metrics
# Response:
# {
#   "new_orders_count": 0,
#   "total_orders_today": 3,
#   "orders_growth_percent": null,
#   "waiting_list_count": 1
# }
```

### Step 8: Test Popular Dishes & Out of Stock

**Create multiple orders with same products:**

```bash
# Create orders with Nasi Goreng (quantity 2, 3, 1)
# Total sold: 6 items
# Create orders with other products

# Create product with stock=0
curl -X POST http://localhost:8080/api/v1/products \
  -d '{
    "category_id": "'$CATEGORY_ID'",
    "name": "Rendang",
    "price": 30000,
    "stock": 0,
    "is_available": false
  }'
```

**In Frontend:**
1. Go to Dashboard
2. Check Popular Dishes widget:
   - Should show Nasi Goreng with sold_count=6
   - Sorted by quantity descending
3. Check Out of Stock widget:
   - Should show Rendang
   - Availability note: "Out of stock"

**Backend Verification:**

```bash
curl http://localhost:8080/api/v1/dashboard/popular-dishes?limit=5
# Should show products with total quantity sold

curl http://localhost:8080/api/v1/dashboard/out-of-stock
# Should show Rendang and other unavailable products
```

### Step 9: Test PUT /orders/:id (Full Update)

**Scenario:** Update customer name and payment method

```bash
# Via curl (testing the fix):
curl -X PUT http://localhost:8080/api/v1/orders/$ORDER_ID \
  -H "Content-Type: application/json" \
  -d '{
    "customer_name": "Updated Name",
    "table_number": "A1",
    "total_amount": 50000,
    "status": "cooking",
    "payment_method": "cash"
  }'
# Response: 200 OK with updated order
```

**In Frontend (if UI exists):**
- Edit order
- Change customer name
- Change payment method
- Submit
- Order updates on backend

## Test Automation Scripts

### One-Command Setup

```bash
#!/bin/bash
# setup-test-env.sh

# Create category
CATEGORY=$(curl -s -X POST http://localhost:8080/api/v1/categories \
  -H "Content-Type: application/json" \
  -d '{"name": "Makanan"}' | jq -r '.id')

# Create products
NASI=$(curl -s -X POST http://localhost:8080/api/v1/products \
  -H "Content-Type: application/json" \
  -d '{
    "category_id": "'$CATEGORY'",
    "name": "Nasi Goreng",
    "price": 25000,
    "stock": 10,
    "is_available": true
  }' | jq -r '.id')

# Create tables
curl -s -X POST http://localhost:8080/api/v1/tables \
  -H "Content-Type: application/json" \
  -d '{"table_number": "A1", "capacity": 4}'

echo "Test data created!"
echo "Category: $CATEGORY"
echo "Product (Nasi Goreng): $NASI"
```

### Quick Test Commands

```bash
# List all orders with their status
curl http://localhost:8080/api/v1/orders | jq '.[] | {id, customer_name, status, total_amount}'

# Get dashboard metrics
curl http://localhost:8080/api/v1/dashboard/metrics | jq '.'

# Get popular dishes
curl http://localhost:8080/api/v1/dashboard/popular-dishes | jq '.[] | {name, sold_count}'

# Sync pending orders (simulate offline sync)
curl -X POST http://localhost:8080/api/v1/sync/orders \
  -H "Content-Type: application/json" \
  -d '[{...order data...}]'
```

## Troubleshooting Integration Issues

### Frontend Cannot Connect to Backend

**Symptoms:**
- Network request fails
- CORS error in console
- "Could not connect to server"

**Solutions:**
1. Verify backend running: `curl http://localhost:8080/api/v1/categories`
2. Check frontend base URL: `lib/core/constants/api_constants.dart`
3. If using emulator: check if can reach host machine IP
4. Check firewall: `sudo iptables -L` or disable temporarily for testing

### Order Creation Fails

**Symptoms:**
- POST /orders returns error
- "Failed to create order"

**Solutions:**
1. Verify product exists: `curl http://localhost:8080/api/v1/products`
2. Check item structure matches backend expectation
3. Verify total_amount calculation
4. Check backend logs for validation errors

### Data Format Mismatch

**Symptoms:**
- "JSON parsing error"
- Null fields where values expected
- Datetime parsing issues

**Solutions:**
1. Check DevTools Network tab → inspect actual JSON
2. Compare with backend response format
3. Verify field names are snake_case
4. Check datetime format (should be ISO8601: "2024-08-30T...")
5. Ensure Hive entities match backend response

### Offline Sync Not Working

**Symptoms:**
- Orders not syncing when reconnected
- "Pending Sync" badge stays

**Solutions:**
1. Check Hive local DB has pending orders
2. Verify network connectivity detected
3. Check SyncManager logs
4. Manually trigger sync (if button exists)
5. Restart app to trigger sync

## Success Criteria

✅ **All the following must pass:**

- [ ] App builds without errors (`flutter run -d chrome`)
- [ ] Backend running and responding to requests
- [ ] All 22 API endpoints accessible
- [ ] Create order → appears in dashboard immediately
- [ ] Order status transitions work (pending → cooking → ready → paid)
- [ ] Invalid transitions rejected (422 error)
- [ ] Table status updates when order status changes
- [ ] Offline orders sync when reconnected (no duplicates)
- [ ] Dashboard metrics accurate
- [ ] Popular dishes aggregated correctly
- [ ] Out of stock items listed
- [ ] JSON serialization correct (snake_case, ISO8601)
- [ ] All network requests logged correctly
- [ ] No unhandled exceptions or crashes
- [ ] Error messages clear and actionable

---

## Sign-Off

When all tests pass:

```
✅ Frontend-Backend Integration Verified
✅ Ready for User Acceptance Testing (UAT)
✅ Ready for Production Deployment
```

Date: _________  
Tester: _________  
Status: ✅ PASSED / ❌ FAILED

---

**Next Steps:**
1. Run through complete test flow (Step 1-9)
2. Document any failures
3. Fix issues in frontend/backend
4. Re-test until all pass
5. Get sign-off from team lead
