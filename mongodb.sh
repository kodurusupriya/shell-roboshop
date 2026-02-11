#!/bin/bash


set -e # this will be checking for errors, if errors it will exit

#!/bin/bash

USERID=$(id -u)
LOGS_FOLDER="/var/log/shell-roboshop"
LOGS_FILE="$LOGS_FOLDER/$0.log"
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[34m"
 
if [ $USERID -ne 0 ]; then
    echo -e "$R please run this script with root user access $N"  | tee -a $LOGS_FILE
    exit 1
fi

mkdir -p $LOGS_FOLDER

#by default shell will not execute,only executed when called
VALIDATE(){

        if [ $1 -ne 0 ]; then 
            echo -e "$2 ... $R failure $N" | tee -a $LOGS_FILE
            exit 1
        else 
            echo -e "$2 ... $G success $N"  | tee -a $LOGS_FILE
        fi     

}
cp mongo.repo /etc/yum.repos.d/mongo.repo
VALIDATE $? "copying mongo repo"

dnf install mongodb-org -y 
VALIDATE $? "installing mongodb server"

systemctl enable mongod 
VALIDATE $? "enable mongodb"

systemctl start mongod 
VALIDATE $? "start mongodb"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf
VALIDATE $? "allowing remote connections"

systemctl restart mongod
VALIDATE $? "restarted mongodb"