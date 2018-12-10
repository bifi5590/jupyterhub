screen -dmS jupyterhubtest docker run --name jupyterhubtest -p 8000:8000 jupyterhubtest 
sleep 5
sensible-browser http://127.0.0.1:8000/