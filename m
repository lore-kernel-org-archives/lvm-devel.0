From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 23 Mar 2012 09:41:20 -0000
Subject: LVM2/test/lib aux.sh
Message-ID: <20120323094120.17694.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-03-23 09:41:20

Modified files:
	test/lib       : aux.sh 

Log message:
	Improve teardown_devs
	
	Try to avoid start of dmeventd during vgremove if the code has any bug
	inside.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/lib/aux.sh.diff?cvsroot=lvm2&r1=1.47&r2=1.48

--- LVM2/test/lib/aux.sh	2012/03/20 10:51:57	1.47
+++ LVM2/test/lib/aux.sh	2012/03/23 09:41:20	1.48
@@ -102,11 +102,6 @@
 		fi
 	fi
 
-	if test "$stray" -eq 0; then
-		dmsetup table | not egrep -q "$vg|$vg1|$vg2|$vg3|$vg4" || \
-			vgremove -ff $vg $vg1 $vg2 $vg3 $vg4 &>/dev/null || rm -f debug.log
-	fi
-
 	# Remove devices, start with closed (sorted by open count)
 	local remfail=no
 	local need_udev_wait=0
@@ -166,7 +161,14 @@
 teardown() {
 	echo -n "## teardown..."
 
-	test -f LOCAL_CLVMD && {
+	dmsetup table | not egrep -q "$vg|$vg1|$vg2|$vg3|$vg4" || {
+		# Avoid activation of dmeventd if there is no pid
+		cfg=$(test -s LOCAL_DMEVENTD || echo "--config 'activation { monitoring = 0 }'")
+		vgremove -ff $cfg  \
+			$vg $vg1 $vg2 $vg3 $vg4 &>/dev/null || rm -f debug.log
+	}
+
+	test -s LOCAL_CLVMD && {
 		kill -INT "$(cat LOCAL_CLVMD)"
 		test -z "$LVM_VALGRIND_CLVMD" || sleep 1
 		sleep .1
@@ -176,8 +178,8 @@
 	echo -n .
 
 	pgrep dmeventd || true
-	test -f LOCAL_DMEVENTD && kill -9 $(cat LOCAL_DMEVENTD) || true
-	test -f LOCAL_LVMETAD && kill -9 $(cat LOCAL_LVMETAD) || true
+	test ! -s LOCAL_DMEVENTD || kill -9 "$(cat LOCAL_DMEVENTD)" || true
+	test ! -s LOCAL_LVMETAD || kill -9 "$(cat LOCAL_LVMETAD)" || true
 
 	echo -n .
 


