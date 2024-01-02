password="progettoreti1"
pass=$(perl -e 'print crypt($ARGV[0], "salt")' $password)
echo "$pass"