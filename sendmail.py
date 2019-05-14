
#coding: utf-8
import smtplib
from email.mime.text import MIMEText
from email.header import Header
from email.MIMEMultipart import MIMEMultipart



sender = 'haolanboo@163.com'
receiver = 'haolxl2012@163.com'
subject = '放假通知'
smtpserver = 'smtp.163.com'
username = 'haolanboo@163.com'
password = 'haolxl2012'
msg = MIMEMultipart()

body = "你好世界！iddddddddddddddddddddddddddddddddddd！"


msg.attach(MIMEText(body, 'plain','utf-8'))

#msg = MIMEText('大家关好窗户','plain','utf-8')#中文需参数‘utf-8'，单字节字符不需要
msg['Subject'] = Header(subject, 'utf-8')
msg['From'] = 'haolanboo@163.com'
msg['To'] = "haolxl2012@163.com"
smtp = smtplib.SMTP()
smtp.connect('smtp.163.com')
smtp.login(username, password)
smtp.sendmail(sender, receiver, msg.as_string())
smtp.quit()


