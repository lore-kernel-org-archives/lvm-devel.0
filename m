From: Schneider, Janine <janine.schneider@fau.de>
Date: Sat, 13 Oct 2018 22:44:22 +0200
Subject: LVM2 label and metadata location
Message-ID: <923d72c2593cfbd26d8d2da589698851@fau.de>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hello Sir or Madam,

i am writing to you because i do have a question about the LVM2 label 
and the contained metadata location.
I need to know how the metadata location is encoded because i am 
currently writing my master thesis about the examination of different 
system metadata. If you want to verify this you can contact my 
supervisor and professor Mister Felix Freiling from the 
Friedrich-Alexander-Universit?t Erlangen-N?rnberg.
I would be very grateful if you could tell me where to find the metadata 
location in (for example) a hexdump of the LVM label like this one:

Offset       0  1  2  3  4  5  6  7   8  9 10 11 12 13 14 15

001049088   4C 41 42 45 4C 4F 4E 45  01 00 00 00 00 00 00 00   LABELONE
001049104   7A 46 99 07 20 00 00 00  4C 56 4D 32 20 30 30 31   zF?     
LVM2 001
001049120   74 5A 6D 45 42 50 53 68  56 67 68 69 59 65 55 42   
tZmEBPShVghiYeUB
001049136   78 4A 51 6A 44 55 55 69  38 72 41 31 36 48 67 58   
xJQjDUUi8rA16HgX
001049152   00 00 90 70 74 00 00 00  00 00 10 00 00 00 00 00      pt
001049168   00 00 00 00 00 00 00 00  00 00 00 00 00 00 00 00
001049184   00 00 00 00 00 00 00 00  00 10 00 00 00 00 00 00
001049200   00 F0 0F 00 00 00 00 00  00 00 00 00 00 00 00 00    ?
001049216   00 00 00 00 00 00 00 00  02 00 00 00 01 00 00 00

I did read the LVM2 documentation and i have tried to find the location 
parsing in the LVM2 code but unfortunately I was unable to figure out 
how this has to be done.

Thank you so much for your help.
With best wishes from Bavaria, Germany

Janine Schneider


