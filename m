From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 10 Jul 2017 08:33:51 -0400
Subject: master - tests: correcting usage of '==' in bash
Message-ID: <201707101233.v6ACXpfX022853@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=5ca4fd0478f239cc04233612bdf52019733b6bef
Commit:        5ca4fd0478f239cc04233612bdf52019733b6bef
Parent:        d12c0ae16315680efcd2306f8f657d45e7c4aca6
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Jul 2 20:25:20 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jul 10 14:23:53 2017 +0200

tests: correcting usage of '==' in bash

---
 test/shell/lvchange-raid.sh                    |   10 +++++-----
 test/shell/lvconvert-raid-status-validation.sh |   24 ++++++++++++------------
 test/shell/process-each-duplicate-pvs.sh       |    2 +-
 3 files changed, 18 insertions(+), 18 deletions(-)

diff --git a/test/shell/lvchange-raid.sh b/test/shell/lvchange-raid.sh
index 7418cd5..ac885be 100644
--- a/test/shell/lvchange-raid.sh
+++ b/test/shell/lvchange-raid.sh
@@ -261,17 +261,17 @@ run_recovery_rate_check() {
 run_checks() {
 	THIN_POSTFIX=""
 
-	if [ -z $3 ]; then
+	if [ -z "$3" ]; then
 		printf "#\n#\n# run_checks: Too few arguments\n#\n#\n"
 		return 1
-	elif [ '-' == $3 ]; then
+	elif [ '-' = "$3" ]; then
 		printf "#\n#\n# run_checks: Simple check\n#\n#\n"
 
 		run_writemostly_check $1 $2
 		run_syncaction_check $1 $2
 		run_refresh_check $1 $2
 		run_recovery_rate_check $1 $2
-	elif [ 'thinpool_data' == $3 ]; then
+	elif [ "thinpool_data" = "$3" ]; then
 		printf "#\n#\n# run_checks: RAID as thinpool data\n#\n#\n"
 
 # Hey, specifying devices for thin allocation doesn't work
@@ -285,7 +285,7 @@ run_checks() {
 		run_syncaction_check $1 $2
 		run_refresh_check $1 $2
 		run_recovery_rate_check $1 $2
-	elif [ 'thinpool_meta' == $3 ]; then
+	elif [ "thinpool_meta" = "$3" ]; then
 		printf "#\n#\n# run_checks: RAID as thinpool metadata\n#\n#\n"
 
 		lvrename $1/$2 ${2}_meta
@@ -298,7 +298,7 @@ run_checks() {
 		run_syncaction_check $1 $2
 		run_refresh_check $1 $2
 		run_recovery_rate_check $1 $2
-	elif [ 'snapshot' == $3 ]; then
+	elif [ "snapshot" = "$3" ]; then
 		printf "#\n#\n# run_checks: RAID under snapshot\n#\n#\n"
 		lvcreate -aey -s $1/$2 -l 4 -n snap "$dev6"
 
diff --git a/test/shell/lvconvert-raid-status-validation.sh b/test/shell/lvconvert-raid-status-validation.sh
index d705cc2..bc9654c 100644
--- a/test/shell/lvconvert-raid-status-validation.sh
+++ b/test/shell/lvconvert-raid-status-validation.sh
@@ -55,16 +55,16 @@ while true; do
 	if [ ${b[0]} -ne ${b[1]} ]; then
 		# If the sync operation ("recover" in this case) is not
 		# finished, then it better be as follows:
-		[ ${a[5]} == "Aa" ]
-		[ ${a[7]} == "recover" ]
+		[ ${a[5]} = "Aa" ]
+		[ ${a[7]} = "recover" ]
 	else
 		# Tough to tell the INVALID case,
 		#   Before starting sync thread: "Aa X/X recover"
 		# from the valid case,
 		#   Just finished sync thread: "Aa X/X recover"
 		# We'll just put "should" for now
-		should [ ${a[5]} == "AA" ]
-		should [ ${a[7]} == "idle" ]
+		should [ ${a[5]} = "AA" ]
+		should [ ${a[7]} = "idle" ]
 		break
 	fi
         sleep .1
@@ -84,16 +84,16 @@ while true; do
 	if [ ${b[0]} -ne ${b[1]} ]; then
 		# If the sync operation ("recover" in this case) is not
 		# finished, then it better be as follows:
-		[ ${a[5]} == "AAa" ]
-		[ ${a[7]} == "recover" ]
+		[ ${a[5]} = "AAa" ]
+		[ ${a[7]} = "recover" ]
 	else
 		# Tough to tell the INVALID case,
 		#   Before starting sync thread: "Aa X/X recover"
 		# from the valid case,
 		#   Just finished sync thread: "Aa X/X recover"
 		# We'll just put "should" for now
-		should [ ${a[5]} == "AAA" ]
-		should [ ${a[7]} == "idle" ]
+		should [ ${a[5]} = "AAA" ]
+		should [ ${a[7]} = "idle" ]
 		break
 	fi
         sleep .1
@@ -112,11 +112,11 @@ while true; do
 	if [ ${b[0]} -ne ${b[1]} ]; then
 		# If the sync operation ("resync" in this case) is not
 		# finished, then it better be as follows:
-		[ ${a[5]} == "aa" ]
-		[ ${a[7]} == "resync" ]
+		[ ${a[5]} = "aa" ]
+		[ ${a[7]} = "resync" ]
 	else
-		should [ ${a[5]} == "AA" ]
-		should [ ${a[7]} == "idle" ]
+		should [ ${a[5]} = "AA" ]
+		should [ ${a[7]} = "idle" ]
 		break
 	fi
         sleep .1
diff --git a/test/shell/process-each-duplicate-pvs.sh b/test/shell/process-each-duplicate-pvs.sh
index 270fc52..542ee53 100644
--- a/test/shell/process-each-duplicate-pvs.sh
+++ b/test/shell/process-each-duplicate-pvs.sh
@@ -76,7 +76,7 @@ grep "prefers device" warn
 
 # Find which is the preferred dev and which is the duplicate.
 PV=$(pvs --noheadings -o name -S uuid=$UUID1)
-if [ $PV == "$dev1" ]; then
+if [ "$PV" = "$dev1" ]; then
 	DUP=$dev2
 else
 	DUP=$dev1


