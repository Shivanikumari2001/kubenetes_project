#!/bin/bash

# Usage: ./kill-port.sh <port>
PORT=$1

if [ -z "$PORT" ]; then
  echo "❌ Usage: ./kill-port.sh <port>"
  exit 1
fi

PID=$(lsof -ti:$PORT)

if [ -z "$PID" ]; then
  echo "✅ No process found running on port $PORT"
else
  echo "⚙️  Killing process on port $PORT (PID: $PID)"
  kill -9 $PID
  echo "✅ Port $PORT is now free"
fi
