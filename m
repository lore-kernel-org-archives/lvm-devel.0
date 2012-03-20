From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 20 Mar 2012 13:35:47 -0000
Subject: LVM2/test/shell dmeventd-restart.sh
Message-ID: <20120320133547.16384.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-03-20 13:35:46

Modified files:
	test/shell     : dmeventd-restart.sh 

Log message:
	Sleep longer in the test so it really dies properly
	
	and check for right exit code from pgrep

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/dmeventd-restart.sh.diff?cvsroot=lvm2&r1=1.4&r2=1.5

--- LVM2/test/shell/dmeventd-restart.sh	2012/03/20 10:48:59	1.4
+++ LVM2/test/shell/dmeventd-restart.sh	2012/03/20 13:35:46	1.5
@@ -31,10 +31,15 @@
 
 # now try what happens if no dmeventd is running
 kill -9 $(cat LOCAL_DMEVENTD)
+rm LOCAL_DMEVENTD
+
 dmeventd -R -f &
-sleep 1
+echo $! >LOCAL_DMEVENTD
+
+# wait longer as tries to communicate with killed daemon
+sleep 7
 # now dmeventd should not be running
-pgrep dmeventd
+not pgrep dmeventd
 rm LOCAL_DMEVENTD
 
 # set dmeventd path


