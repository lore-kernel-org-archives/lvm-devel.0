From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 16 Mar 2012 13:44:52 -0000
Subject: LVM2/test/lib aux.sh
Message-ID: <20120316134452.28653.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-03-16 13:44:52

Modified files:
	test/lib       : aux.sh 

Log message:
	Switch condition for dmeventd check

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/lib/aux.sh.diff?cvsroot=lvm2&r1=1.44&r2=1.45

--- LVM2/test/lib/aux.sh	2012/03/16 12:59:02	1.44
+++ LVM2/test/lib/aux.sh	2012/03/16 13:44:51	1.45
@@ -197,7 +197,7 @@
 
 	echo "ok"
 
-	test -z "$RUNNING_DMEVENTD" && not pgrep dmeventd &>/dev/null
+	test -n "$RUNNING_DMEVENTD" || not pgrep dmeventd &>/dev/null
 }
 
 make_ioerror() {


