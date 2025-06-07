
#1. Prepare your updated app locally

#2. In powershell

scp -o MACs=hmac-sha2-256 -r "C:/temp/AchyBot" sharsted@shinylab.srv.sdu.dk:~

ssh -o MACs=hmac-sha2-256 sharsted@shinylab.srv.sdu.dk

sudo rm -rf /srv/shiny-server/AchyBot
sudo mv ~/AchyBot /srv/shiny-server/
sudo chown -R shiny:shiny /srv/shiny-server/AchyBot

# Install dependencies
# Start R
sudo su - -c "R"

# R code
devtools::install_deps("/srv/shiny-server/AchyBot", dependencies = TRUE)
q()

# Restart shiny server
sudo systemctl restart shiny-server

