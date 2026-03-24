import os
import sys
import time

print("AiClod worker placeholder started", flush=True)
print(f"AI enabled={os.getenv('AI_FEATURES_ENABLED', 'false')}", flush=True)
print(f"Admin enabled={os.getenv('ADMIN_CONSOLE_ENABLED', 'false')}", flush=True)
while True:
    print("worker heartbeat", flush=True)
    time.sleep(30)
