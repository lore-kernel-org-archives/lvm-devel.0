From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 19 Sep 2011 12:49:15 -0000
Subject: LVM2/test t-dmeventd-restart.sh
Message-ID: <20110919124915.7786.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-09-19 12:49:14

Modified files:
	test           : t-dmeventd-restart.sh 

Log message:
	Test speed up
	
	Removing vg  reduces time execution of this test.
	Teardown has some wait states here...

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-dmeventd-restart.sh.diff?cvsroot=lvm2&r1=1.3&r2=1.4

--- LVM2/test/t-dmeventd-restart.sh	2011/03/02 12:49:13	1.3
+++ LVM2/test/t-dmeventd-restart.sh	2011/09/19 12:49:14	1.4
@@ -38,3 +38,5 @@
 sleep 3
 lvchange --monitor y --verbose $vg/3way 2>&1 | tee lvchange.out
 not grep 'already monitored' lvchange.out
+
+vgremove -ff $vg


