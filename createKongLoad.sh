for ((i=1;i<=600;i++));
do
   sleep 1;
   http --proxy http://localhost:8000/ http://myfrontend.com/foo apikey:JoePassword
done
