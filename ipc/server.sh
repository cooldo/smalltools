#rm -rf fifo;touch fifo
rm -rf fifo; mkfifo fifo
#printf '%s\n' {1..100} > fifo &
#exit
for i in {1..1000}
do
    #echo "12345"  > fifo &
    #./writefile.sh &
    ./writefile.sh &
    #flock -xw 5 /tmp/file.lock ./writefile.sh &
    #flock -xn  /tmp/file.lock ./writefile.sh
    #echo -e "0\n1\n2\n3\n4\n5\n6\n7\n8\n9" > fifo &
    #printf '\n' > fifo &
done
