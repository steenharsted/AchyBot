# AchyBot Deployment Guide for shinylab.sdu.dk

This guide documents how to deploy the AchyBot Shiny app to SDU's internal Shiny Server at `https://shinylab.sdu.dk/AchyBot`.

---

## ✅ Requirements
- Access to `shinylab.sdu.dk` (web) and `shinylab.srv.sdu.dk` (SSH)
- VPN connection to SDU if off-campus
- Working `ssh` and `scp` tools (Windows users can use PowerShell or Git Bash)
- Shiny app folder containing `app.R` (and optionally a `DESCRIPTION` file)

---

## 🚀 Deployment Steps

### 1. **Prepare App Folder**
Ensure your app is structured like this:
```
AchyBot/
├── app.R
├── DESCRIPTION         # optional but recommended
└── www/ or data/       # any needed resources
```

### 2. **Upload App to Server**
On Windows, first copy the folder to a simple path (to avoid spaces):
```powershell
mkdir C:\temp\AchyBot
Copy-Item -Recurse "C:\Users\sharsted\OneDrive - Syddansk Universitet\R_projects\AchyBot\*" C:\temp\AchyBot
```
Then upload to your home directory on the server:
```powershell
scp -o MACs=hmac-sha2-256 -r "C:/temp/AchyBot" sharsted@shinylab.srv.sdu.dk:~
```

### 3. **Move App into Shiny Server Directory**
SSH into the server:
```bash
ssh -o MACs=hmac-sha2-256 sharsted@shinylab.srv.sdu.dk
```
Then:
```bash
sudo mv ~/AchyBot /srv/shiny-server/
sudo chown -R shiny:shiny /srv/shiny-server/AchyBot
```

### 4. **Install Dependencies from DESCRIPTION**
```bash
sudo su - -c "R"
```
Then in R:
```r
install.packages("devtools")
devtools::install_deps("/srv/shiny-server/AchyBot", dependencies = TRUE)
# Optionally:
remotes::install_github("ellessenne/shinychat")
q()
```

### 5. **Restart Shiny Server**
```bash
sudo systemctl restart shiny-server
```

### 6. **Test in Browser**
Go to:
```
https://shinylab.sdu.dk/AchyBot
```

---

## 🐞 Debugging Tips
- Watch logs live while testing:
```bash
sudo tail -f /var/log/shiny-server/*.log
```
- Typical errors:
  - `there is no package called ...` → install in root R session
  - `app exited during initialization` → syntax/package/file errors

---

## 🎉 Success
Your app is now live and served over HTTPS via SDU's reverse proxy.

Contact: Steen Flammild Harsted

