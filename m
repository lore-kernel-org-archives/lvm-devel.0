From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 11 Jul 2017 11:22:17 -0400
Subject: master - tests: improve test logic
Message-ID: <201707111522.v6BFMHrx015490@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=f11e74ae3d1f5bd5221110fa08d502cc39365955
Commit:        f11e74ae3d1f5bd5221110fa08d502cc39365955
Parent:        2c3d9a07cbaa49275d24c40c6a4fa2480b1ac3d8
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Jul 11 11:16:24 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Jul 11 16:26:12 2017 +0200

tests: improve test logic

Use existing vars.
Reduce extra lvchange -an and use directly activation with lvcreate.
---
 test/shell/lvconvert-mirror-basic.sh |   21 ++++++++++-----------
 1 files changed, 10 insertions(+), 11 deletions(-)

diff --git a/test/shell/lvconvert-mirror-basic.sh b/test/shell/lvconvert-mirror-basic.sh
index 0959af8..06b3450 100644
--- a/test/shell/lvconvert-mirror-basic.sh
+++ b/test/shell/lvconvert-mirror-basic.sh
@@ -49,23 +49,22 @@ test_lvconvert() {
 	local finish_count=$3
 	local finish_count_p1=$(( finish_count + 1 ))
 	local finish_log_type=$4
-	local dev_array=( "$dev1" "$dev2" "$dev3" "$dev4" "$dev5" )
 	local start_log_count
 	local finish_log_count
 	local max_log_count
 	local alloc=""
-	local active=true
+	local active="-aey"
 	local i
 
-	test "$5" = "active" && active=false
+	test "$5" = "active" && active="-an"
 	#test $finish_count -gt $start_count && up=true
 
 	# Do we have enough devices for the mirror images?
-	test $start_count_p1 -gt ${#dev_array[@]} && \
+	test $start_count_p1 -gt ${#DEVICES[@]} && \
 		die "Action requires too many devices"
 
 	# Do we have enough devices for the mirror images?
-	test $finish_count_p1 -gt ${#dev_array[@]} && \
+	test $finish_count_p1 -gt ${#DEVICES[@]} && \
 		die "Action requires too many devices"
 
 	start_log_count=$(log_name_to_count $start_log_type)
@@ -78,23 +77,22 @@ test_lvconvert() {
 
 	if [ $start_count -gt 0 ]; then
 		# Are there extra devices for the log or do we overlap
-		if [ $(( start_count_p1 + start_log_count )) -gt ${#dev_array[@]} ]; then
+		if [ $(( start_count_p1 + start_log_count )) -gt ${#DEVICES[@]} ]; then
 			alloc="--alloc anywhere"
 		fi
 
-		lvcreate -aey -l2 --type mirror -m $start_count --mirrorlog $start_log_type \
+		lvcreate "$active" -Zn -l2 --type mirror -m $start_count --mirrorlog $start_log_type \
 			-n $lv1 $vg $alloc
 		check mirror_legs $vg $lv1 $start_count_p1
 		# FIXME: check mirror log
 	else
-		lvcreate -aey -l2 -n $lv1 $vg
+		lvcreate "$active" -Zn -l2 -n $lv1 $vg
 	fi
 
 	lvs -a -o name,copy_percent,devices $vg
-	test $active || lvchange -an $vg/$lv1
 
 	# Are there extra devices for the log or do we overlap
-	if [ $(( finish_count_p1 +  finish_log_count )) -gt ${#dev_array[@]} ]; then
+	if [ $(( finish_count_p1 +  finish_log_count )) -gt ${#DEVICES[@]} ]; then
 		alloc="--alloc anywhere"
 	fi
 
@@ -109,7 +107,7 @@ test_lvconvert() {
 	lvconvert --type mirror -m $finish_count $mirrorlog $finish_log_type \
 		$vg/$lv1 $alloc
 
-	test $active || lvchange -aey $vg/$lv1
+	test "$active" = "-an" || lvchange "$active" $vg/$lv1
 
 	check mirror_no_temporaries $vg $lv1
 	if [ "$finish_count_p1" -eq 1 ]; then
@@ -125,6 +123,7 @@ test_lvconvert() {
 }
 
 aux prepare_vg 5 5
+get_devs
 
 MIRRORED="mirrored"
 # FIXME: Cluster is not supporting exlusive activation of mirrored log


