From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 12 Jan 2011 16:07:56 -0000
Subject: LVM2/test/lib aux.sh
Message-ID: <20110112160756.8967.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2011-01-12 16:07:56

Modified files:
	test/lib       : aux.sh 

Log message:
	Kill clvmd properly after locking_type 3 tests (using clvmd/singlenode).

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/lib/aux.sh.diff?cvsroot=lvm2&r1=1.5&r2=1.6

--- LVM2/test/lib/aux.sh	2011/01/07 15:04:52	1.5
+++ LVM2/test/lib/aux.sh	2011/01/12 16:07:55	1.6
@@ -32,6 +32,7 @@
 	# check that it is really running now
 	sleep .1
 	ps $LOCAL_CLVMD || skip
+        echo "$LOCAL_CLVMD" > LOCAL_CLVMD
 }
 
 prepare_dmeventd() {
@@ -83,10 +84,10 @@
 teardown() {
     echo -n "## teardown..."
 
-    test -n "$LOCAL_CLVMD" && {
-	kill "$LOCAL_CLVMD"
+    test -f LOCAL_CLVMD && {
+	kill "$(cat LOCAL_CLVMD)"
 	sleep .1
-	kill -9 "$LOCAL_CLVMD" || true
+	kill -9 "$(cat LOCAL_CLVMD)" || true
     }
 
     echo -n .


