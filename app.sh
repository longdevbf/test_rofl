#!/bin/sh
set -x
CONTRACT_ADDRESS=0x9f9b5a50587f5fe1E0b34c65e578f080CE884002
TICKER=ROSEUSDT

echo "[INFO] Socket OK. Starting price oracle..."

while true; do
    # Fetch price from Binance
    price=$(curl -s "https://www.binance.com/api/v3/ticker/price?symbol=${TICKER}" \
        | jq '(.price | tonumber) * 1000000 | trunc')

    if [ -z "$price" ] || [ "$price" = "null" ]; then
        echo "[ERROR] Không lấy được giá từ Binance cho ${TICKER}"
        sleep 15
        continue
    fi

    printf "[INFO] Contract: %s\n" "${CONTRACT_ADDRESS}"
    printf "[INFO] Ticker: %s, Price: %s\n" "${TICKER}" "$price"

    # Format calldata
    price_u128=$(printf '%064x' ${price})
    method="dae1ee1f" # submitObservation(uint128)
    data="${method}${price_u128}"
    
    echo "[INFO] Calldata: $data"

    # Test socket connectivity trước
    socket_test=$(curl -s \
      --json '{"method": "health"}' \
      --unix-socket /run/rofl-appd.sock \
      http://localhost/health 2>/dev/null || echo "socket_error")

    if [ "$socket_test" = "socket_error" ]; then
        echo "[ERROR] Không thể kết nối tới rofl-appd.sock"
        sleep 30
        continue
    fi

    # Submit transaction
    response=$(curl -s \
      --json '{"tx": {"kind": "eth", "data": {"gas_limit": 300000, "to": "'${CONTRACT_ADDRESS}'", "value": 0, "data": "'${data}'"}}}' \
      --unix-socket /run/rofl-appd.sock \
      http://localhost/rofl/v1/tx/sign-submit)

    echo "[DEBUG] Full Response: $response"

    # Parse response
    success=$(echo "$response" | jq -r '.success // false' 2>/dev/null)
    error_msg=$(echo "$response" | jq -r '.error // empty' 2>/dev/null)
    tx_hash=$(echo "$response" | jq -r '.tx_hash // empty' 2>/dev/null)

    if [ "$success" = "true" ] && [ -n "$tx_hash" ] && [ "$tx_hash" != "empty" ]; then
        echo "[✅] Transaction thành công!"
        echo "    TxHash: $tx_hash"
        echo "    Explorer: https://explorer.oasis.io/testnet/sapphire/tx/$tx_hash"
    else
        echo "[❌] Transaction thất bại!"
        [ -n "$error_msg" ] && echo "    Error: $error_msg"
        echo "    Raw response: $response"
    fi

    sleep 60
done