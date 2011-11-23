From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 23 Nov 2011 15:27:14 -0000
Subject: LVM2/test/shell lvextend-snapshot-dmeventd.sh
Message-ID: <20111123152714.24905.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-11-23 15:27:14

Modified files:
	test/shell     : lvextend-snapshot-dmeventd.sh 

Log message:
	Try longer sleep
	
	Seems like testing machine could be busy - so 10s might not be enough
	for rechecking status.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/lvextend-snapshot-dmeventd.sh.diff?cvsroot=lvm2&r1=1.2&r2=1.3

--- LVM2/test/shell/lvextend-snapshot-dmeventd.sh	2011/11/21 12:31:21	1.2
+++ LVM2/test/shell/lvextend-snapshot-dmeventd.sh	2011/11/23 15:27:14	1.3
@@ -40,14 +40,14 @@
 
 write 1 4096
 pre=`percent`
-sleep 10 # dmeventd only checks every 10 seconds :(
+sleep 15 # dmeventd only checks every 10 seconds :(
 post=`percent`
 
 test $pre = $post
 
 write 2 5000
 pre=`percent`
-sleep 10 # dmeventd only checks every 10 seconds :(
+sleep 15 # dmeventd only checks every 10 seconds :(
 post=`percent`
 test $pre -gt $post
 
@@ -57,6 +57,6 @@
 
 write 3 5000
 pre=`percent`
-sleep 10 # dmeventd only checks every 10 seconds :(
+sleep 15 # dmeventd only checks every 10 seconds :(
 post=`percent`
 test $pre -gt $post


