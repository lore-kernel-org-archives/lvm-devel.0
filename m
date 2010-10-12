From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 12 Oct 2010 16:13:44 -0000
Subject: LVM2/test test-utils.sh
Message-ID: <20101012161344.25125.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2010-10-12 16:13:43

Modified files:
	test           : test-utils.sh 

Log message:
	test-utils: Fix a slight bug in the dmeventd-already-running error message.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/test-utils.sh.diff?cvsroot=lvm2&r1=1.50&r2=1.51

--- LVM2/test/test-utils.sh	2010/08/27 08:52:54	1.50
+++ LVM2/test/test-utils.sh	2010/10/12 16:13:43	1.51
@@ -81,7 +81,7 @@
 
 prepare_dmeventd() {
 	if pgrep dmeventd ; then
-		echo "Cannot test dmeventd with real dmeventd ($(pgrep clvmd)) running."
+		echo "Cannot test dmeventd with real dmeventd ($(pgrep dmeventd)) running."
 		exit 200
 	fi
 


