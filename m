From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 16 Mar 2012 19:08:10 -0000
Subject: LVM2/test/lib aux.sh
Message-ID: <20120316190810.20982.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-03-16 19:08:09

Modified files:
	test/lib       : aux.sh 

Log message:
	Longer sleep after clvmd start

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/lib/aux.sh.diff?cvsroot=lvm2&r1=1.45&r2=1.46

--- LVM2/test/lib/aux.sh	2012/03/16 13:44:51	1.45
+++ LVM2/test/lib/aux.sh	2012/03/16 19:08:09	1.46
@@ -36,7 +36,7 @@
 	test -z "$LVM_VALGRIND_CLVMD" || run_valgrind="run_valgrind"
 	$run_valgrind lib/clvmd -Isinglenode -d 1 -f &
 	local local_clvmd=$!
-	sleep .1
+	sleep .3
 	# extra sleep for slow valgrind
 	test -z "$LVM_VALGRIND_CLVMD" || sleep 5
 	# check that it is really running now
@@ -176,7 +176,7 @@
 		kill -INT "$(cat LOCAL_CLVMD)"
 		test -z "$LVM_VALGRIND_CLVMD" || sleep 1
 		sleep .1
-		kill -9 "$(cat LOCAL_CLVMD)" || true
+		kill -9 "$(cat LOCAL_CLVMD)" &>/dev/null || true
 	}
 
 	echo -n .
@@ -288,7 +288,7 @@
 }
 
 cleanup_scsi_debug_dev() {
-	aux teardown_devs
+	teardown_devs
 	rm -f SCSI_DEBUG_DEV LOOP
 }
 


