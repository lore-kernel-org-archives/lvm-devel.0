From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 4 Mar 2011 14:19:18 -0000
Subject: LVM2/test/lib aux.sh
Message-ID: <20110304141918.23560.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2011-03-04 14:19:18

Modified files:
	test/lib       : aux.sh 

Log message:
	Wait until dmeventd properly starts in test.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/lib/aux.sh.diff?cvsroot=lvm2&r1=1.10&r2=1.11

--- LVM2/test/lib/aux.sh	2011/03/01 23:44:07	1.10
+++ LVM2/test/lib/aux.sh	2011/03/04 14:19:18	1.11
@@ -55,6 +55,9 @@
 
 	dmeventd -f "$@" &
 	echo "$!" > LOCAL_DMEVENTD
+
+	# FIXME wait for pipe in /var/run instead
+	sleep 1
 }
 
 teardown_devs() {


