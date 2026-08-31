# Testing Quick Start - 5 Minute Setup

Fast-track guide to test Mangea POS Frontend + Backend.

## Prerequisites (60 seconds)

```bash
# Terminal 1: Backend
cd /home/farhan/mangea-backend
go run ./cmd/api
# Expected: "Starting server on :8080"

# Terminal 2: Frontend
cd /home/farhan/mangea_app
flutter run -d chrome
# App opens in Chrome
```

## Quick Test (5 minutes)

### 1. Create Test Category & Product (Backend)

```bash
# Save these IDs for next steps
CATEGORY=$(curl -s -X POST http://localhost:8080/api/v1/categories \
  -H "Content-Type: application/json" \
  -d '{"name": "Makanan"}' | jq -r '.id')

PRODUCT=$(curl -s -X POST http://localhost:8080/api/v1/products \
  -H "Content-Type: application/json" \
  -d '{
    "category_id": "'$CATEGORY'",
    "name": "Nasi Goreng",
    "price": 25000,
    "stock": 10,
    "is_available": true
  }' | jq -r '.id')

TABLE=$(curl -s -X POST http://localhost:8080/api/v1/tables \
  -H "Content-Type: application/json" \
  -d '{"table_number": "A1", "capacity": 4}' | jq -r '.id')

echo "✓ Category: $CATEGORY"
echo "✓ Product: $PRODUCT"
echo "✓ Table: $TABLE"
```

### 2. Test API Connectivity (Frontend)

In Chrome:
1. Open DevTools (F12)
2. Go to Network tab
3. Refresh page (Cmd/Ctrl + R)
4. Look for network requests to `localhost:8080`
5. Should see successful responses (Status: 200)

✓ **Pass:** Requests to backend endpoint
❌ **Fail:** No requests or errors

### 3. Create Order via Frontend

In Chrome:
1. Navigate to Dashboard (if not already there)
2. Check that it loads (no errors)
3. If UI exists to create orders, do it:
   - Add Nasi Goreng to cart
   - Select table A1
   - Click Create Order

✓ **Pass:** Order appears in Dashboard
❌ **Fail:** Error message or no order appears

### 4. Verify Order Created on Backend

```bash
# Check order exists
curl http://localhost:8080/api/v1/orders | jq '.[] | {customer_name, total_amount, status}'

# Expected output:
# {
#   "customer_name": "...",
#   "total_amount": 25000,
#   "status": "pending"
# }
```

✓ **Pass:** Order exists with correct data
❌ **Fail:** Order missing or data wrong

### 5. Test Status Update

In Frontend:
1. Find order in Dashboard
2. Change status: pending → cooking
3. Watch badge color change

In Backend:
```bash
ORDER_ID="..."  # From previous step
curl http://localhost:8080/api/v1/orders/$ORDER_ID | jq '.status'
# Expected: "cooking"
```

✓ **Pass:** Status updated on both sides
❌ **Fail:** Status mismatch or error

## Common Issues & Fixes

| Problem | Solution |
|---------|----------|
| `Connection refused` | Backend not running: `go run ./cmd/api` |
| `Cannot find mysql` | MySQL not running: start MySQL service |
| `CORS error` | Normal for local testing, ignore |
| `Timeout waiting for debugger` | Flutter build slow, wait 30-60s |
| `Order not appearing` | Refresh dashboard or restart app |
| `Network requests 404` | Check API_CONSTANTS base URL |

## Test Checklist (2 minutes)

- [ ] Backend running on :8080
- [ ] Flutter app running in Chrome
- [ ] Can create order in frontend
- [ ] Order appears on backend
- [ ] Can update order status
- [ ] Status updates on both sides
- [ ] No console errors (F12)
- [ ] No network failures (DevTools)

## Key Files for Reference

| File | Purpose |
|------|---------|
| `FRONTEND_TESTING.md` | 11 comprehensive test scenarios |
| `BACKEND_INTEGRATION_TEST.md` | End-to-end integration tests |
| `/home/farhan/mangea-backend/API_TESTING.md` | Backend curl testing |

## Next Steps

✅ **If tests pass:**
1. Run full test suite (see FRONTEND_TESTING.md)
2. Test edge cases (offline mode, errors)
3. Performance testing

❌ **If tests fail:**
1. Check troubleshooting section above
2. Review detailed guides
3. Check backend logs: `go run ./cmd/api` output
4. Check frontend logs: DevTools Console

## Example Test Script

Save as `test.sh`:

```bash
#!/bin/bash
set -e

echo "🧪 Starting Integration Test..."

# Create category
CATEGORY=$(curl -s -X POST http://localhost:8080/api/v1/categories \
  -H "Content-Type: application/json" \
  -d '{"name": "Test"}' | jq -r '.id')
echo "✓ Created category: $CATEGORY"

# Create product
PRODUCT=$(curl -s -X POST http://localhost:8080/api/v1/products \
  -H "Content-Type: application/json" \
  -d '{
    "category_id": "'$CATEGORY'",
    "name": "Test Product",
    "price": 10000,
    "stock": 5,
    "is_available": true
  }' | jq -r '.id')
echo "✓ Created product: $PRODUCT"

# Create order
ORDER=$(curl -s -X POST http://localhost:8080/api/v1/orders \
  -H "Content-Type: application/json" \
  -d '{
    "customer_name": "Test",
    "table_number": "A1",
    "items": [{
      "product_id": "'$PRODUCT'",
      "product_name": "Test Product",
      "price": 10000,
      "quantity": 1,
      "subtotal": 10000
    }]
  }' | jq -r '.id')
echo "✓ Created order: $ORDER"

# Verify order
STATUS=$(curl -s http://localhost:8080/api/v1/orders/$ORDER | jq -r '.status')
echo "✓ Order status: $STATUS"

# Update status
curl -s -X PATCH http://localhost:8080/api/v1/orders/$ORDER/status \
  -H "Content-Type: application/json" \
  -d '{"status": "cooking"}' > /dev/null
echo "✓ Updated status to cooking"

# Verify update
NEW_STATUS=$(curl -s http://localhost:8080/api/v1/orders/$ORDER | jq -r '.status')
echo "✓ New status: $NEW_STATUS"

if [ "$NEW_STATUS" = "cooking" ]; then
  echo "✅ All tests PASSED!"
  exit 0
else
  echo "❌ Test FAILED: Status not updated"
  exit 1
fi
```

Run with:
```bash
chmod +x test.sh
./test.sh
```

---

## Success = ✅ All Pass

When all quick tests pass, you've verified:
- ✅ Backend is running and accessible
- ✅ Frontend can communicate with backend
- ✅ JSON serialization correct
- ✅ Order CRUD working
- ✅ Status transitions working

**Ready for detailed testing!** 🎉
