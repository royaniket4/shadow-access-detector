#!/usr/bin/env python3
import json
import pwd
import sys
import os

def get_users():
    users = []
    for p in pwd.getpwall():
        if p.pw_uid < 1000 or 'nologin' in p.pw_shell:
            continue

        risk = "Medium"
        if p.pw_name == "aniket":
            risk = "High"
        if p.pw_shell not in ["/bin/bash", "/bin/zsh"]:
            risk = "Critical"

        # Optional auto-revoke logic
        # if p.pw_shell in ["/bin/bash", "/bin/zsh"] and risk == "High":
        #     os.system(f"usermod -s /usr/sbin/nologin {p.pw_name}")

        users.append({
            "user": p.pw_name,
            "uid": p.pw_uid,
            "shell": p.pw_shell,
            "last_login": "Never",
            "risk": risk
        })
    return users

if __name__ == "__main__":
    try:
        print("DEBUG: scanner.py started", file=sys.stderr)
        result = get_users()
        print("DEBUG: Found", len(result), "users", file=sys.stderr)
        print(json.dumps(result), flush=True)
        sys.exit(0)
    except Exception as e:
        print("DEBUG: Exception occurred", file=sys.stderr)
        print(json.dumps({"error": str(e)}), flush=True)
        sys.exit(1)
