From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 10 Mar 2014 11:27:34 +0000 (UTC)
Subject: master - tests: aux adds kill_sleep_kill_
Message-ID: <20140310112734.028BB6039D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c7262d5b383091e874d5a00ac266819b5eda649b
Commit:        c7262d5b383091e874d5a00ac266819b5eda649b
Parent:        1c18fc42ecd2f33794fd552f1539d76867420cf5
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Mar 9 22:55:11 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Mar 10 12:24:11 2014 +0100

tests: aux adds kill_sleep_kill_

Move common code to subfunction
---
 test/lib/aux.sh |   21 ++++++++++++---------
 1 files changed, 12 insertions(+), 9 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 2cb3dc9..4b4662c 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -192,11 +192,19 @@ teardown_devs() {
 	}
 }
 
+kill_sleep_kill_() {
+	if test -s "$1" ; then
+		if kill -TERM "$(cat $1)" ; then
+			if test "$2" -eq 0 ; then sleep .1 ; else sleep 1 ; fi
+			kill -KILL "$(cat $1)" 2>/dev/null || true
+		fi
+	fi
+}
+
 teardown() {
 	echo -n "## teardown..."
-	test ! -s LOCAL_LVMETAD || \
-	    (kill -TERM "$(cat LOCAL_LVMETAD)" && sleep 1 &&
-	     kill -KILL "$(cat LOCAL_LVMETAD)" 2> /dev/null) || true
+
+	kill_sleep_kill_ LOCAL_LVMETAD ${LVM_VALGRIND_LVMETAD:-0}
 
 	dm_table | not egrep -q "$vg|$vg1|$vg2|$vg3|$vg4" || {
 		# Avoid activation of dmeventd if there is no pid
@@ -205,12 +213,7 @@ teardown() {
 			$vg $vg1 $vg2 $vg3 $vg4 &>/dev/null || rm -f debug.log
 	}
 
-	test -s LOCAL_CLVMD && {
-		kill -INT "$(cat LOCAL_CLVMD)"
-		test -z "$LVM_VALGRIND_CLVMD" || sleep 1
-		sleep .1
-		kill -9 "$(cat LOCAL_CLVMD)" &>/dev/null || true
-	}
+	kill_sleep_kill_ LOCAL_CLVMD ${LVM_VALGRIND_CLVMD:-0}
 
 	echo -n .
 


