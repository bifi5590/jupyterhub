#screen -dmS jupyterhubtest docker run --name jupyterhubtest -p 8000:8000 jupyterhubtest 
screen -dmS jupyterhubtest docker run --privileged --name jupyterhubtest -v /sys/fs/cgroup:/sys/fs/cgroup -p 8000:8000 jupyterhubtest:latest 
sleep 5
sensible-browser http://127.0.0.1:8000/