# SOP-004: SSL Setup and Validation via PuTTY

**Environment:** Production (`api.flexit.fit`)  
**Category:** DevOps / Platform Team  
**Last updated:** July 2026

## 1. Purpose

This SOP describes the exact process to connect to the infrastructure through a jump host using PuTTY, access the internal application server, validate Nginx SSL configuration, and confirm HTTPS is working for `api.flexit.fit`.

## 2. Security Requirements

- Never share private keys over chat/email in plain text.
- Ensure SSH key file permission is always `chmod 600`.
- Remove temporary key files after work if policy requires it.

## 3. Procedure

### Step A — Connect to Jump Host (PuTTY)
1. Open PuTTY.
2. Host Name: `18.218.246.73`
3. Connection > Data > Auto-login username: `ubuntu`
4. Connection > SSH > Auth > Select your `.ppk` file.
5. Open session.

### Step B — Create Internal SSH Key File on Jump Host
1. Remove any previous temp key file: `rm -f ~/.ssh/key_prod`
2. Start file input: `cat > ~/.ssh/key_prod`
3. Paste full PEM key content (including `BEGIN` and `END` lines).
4. Press `Ctrl + D` to save and exit.

### Step C — Validate Key and Connect to Internal Server
1. Set secure permissions: `chmod 600 ~/.ssh/key_prod`
2. Validate key: `ssh-keygen -y -f ~/.ssh/key_prod >/dev/null && echo KEY_OK`
3. SSH to internal server: `ssh -i ~/.ssh/key_prod ubuntu@3.129.94.50`

### Step D — Validate Nginx Configuration
Run: `sudo nginx -t`

Expected output:
```
nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
nginx: configuration file /etc/nginx/nginx.conf test is successful
```

If a warning appears like `server name "http://api.flexit.fit" has suspicious symbols`, proceed to Step E.

### Step E — Fix server_name Warning
1. Inspect config: `sudo sed -n '1,220p' /etc/nginx/sites-enabled/default`
2. Remove invalid token: `sudo sed -i 's| http://api.flexit.fit||g' /etc/nginx/sites-enabled/default`
3. Re-test and reload:
   ```bash
   sudo nginx -t
   sudo systemctl reload nginx
   sudo nginx -t
   ```

### Step F — Functional HTTPS Validation
From a local browser, open `https://api.flexit.fit`. Ensure a valid HTTPS connection is established and the API response body is returned.

## 4. Troubleshooting

- **Stuck at `>` prompt while pasting key:** Press `Ctrl + C`, restart `cat > ~/.ssh/key_prod`, paste key, press `Ctrl + D`.
- **`ssh-keygen` fails:** Malformed PEM content. Recreate file and paste full key.
- **Permission denied (publickey):** Verify `chmod 600` and confirm correct key corresponds to target host `authorized_keys`. Use `ssh -vvv` for verbose output.
