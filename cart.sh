#!/bin/bash

USERID=$(id -u)
LOGS_FOLDER="/var/log/shell-roboshop"
LOGS_FILE="$LOGS_FOLDER/$0.log"
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
SCRIPT_DIR=$PWD
MONGODB_HOST=mongodb.supriya1999.online
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

dnf module disable nodejs -y &>>$LOGS_FILE
VALIDATE $? "Disabling nodejs default version"

dnf module enable nodejs:20 -y &>>$LOGS_FILE
VALIDATE $? "enabling nodejs 20"

dnf install nodejs -y &>>$LOGS_FILE
VALIDATE $? "installing nodejs"

id roboshop &>>$LOGS_FILE
if [ $? -ne 0 ]; then
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOGS_FILE
    VALIDATE $? "creating system user"
else 
    echo -e "Roboshop user already exist ... $Y SKIPPING $N"
fi    

mkdir -p /app 
VALIDATE $? "creating app directory"

curl -o /tmp/cart.zip https://roboshop-artifacts.s3.amazonaws.com/cart-v3.zip &>>$LOGS_FILE
VALIDATE $? "Downloading cart code"

cd /app
VALIDATE $? "Moving to app directory"

rm -rf /app/*
VALIDATE $? "Removing existing code"

unzip /tmp/cart.zip &>>$LOGS_FILE
VALIDATE $? "Uzip cart code"

npm install &>>$LOGS_FILE
VALIDATE $? "installing dependencies"

cp $SCRIPT_DIR/cart.service /etc/systemd/system/cart.service
VALIDATE $? "created systemctl service"

systemctl daemon-reload
systemctl enable cart &>>$LOGS_FILE
systemctl start cart
VALIDATE $? "starting and enabling cart"

