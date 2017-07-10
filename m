From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 10 Jul 2017 08:33:16 -0400
Subject: master - tests: replace egrep
Message-ID: <201707101233.v6ACXGjm022747@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=7a8f87d28b3ccd3fc4890606c3edf83896d6624e
Commit:        7a8f87d28b3ccd3fc4890606c3edf83896d6624e
Parent:        bdd95051ed6a71e447474e96f770b2d79baf4889
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Jul 3 20:55:11 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jul 10 14:23:53 2017 +0200

tests: replace egrep

---
 test/shell/activate-minor.sh          |    4 ++--
 test/shell/lvconvert-cache-abort.sh   |    2 +-
 test/shell/lvcreate-repair.sh         |    2 +-
 test/shell/profiles-cache.sh          |   16 ++++++++--------
 test/shell/profiles-thin.sh           |    2 +-
 test/shell/pvmove-abort.sh            |    4 ++--
 test/shell/pvmove-resume-1.sh         |   20 ++++++++++----------
 test/shell/pvmove-resume-2.sh         |   10 +++++-----
 test/shell/pvmove-resume-multiseg.sh  |   18 +++++++++---------
 test/shell/unknown-segment.sh         |    4 ++--
 test/shell/vgextend-restoremissing.sh |    2 +-
 11 files changed, 42 insertions(+), 42 deletions(-)

diff --git a/test/shell/activate-minor.sh b/test/shell/activate-minor.sh
index 187a4aa..e2db1c0 100644
--- a/test/shell/activate-minor.sh
+++ b/test/shell/activate-minor.sh
@@ -17,13 +17,13 @@ SKIP_WITH_LVMPOLLD=1
 
 # Just skip this test if minor is already in use...
 dmsetup info | tee info
-egrep "^Major, minor: *[0-9]+, 123" info && skip
+grep -E "^Major, minor: *[0-9]+, 123" info && skip
 
 aux prepare_vg 2
 lvcreate -a n --zero n -l 1 -n foo $vg
 lvchange $vg/foo -My --major=255 --minor=123
 lvchange $vg/foo -a y
 dmsetup info $vg-foo | tee info
-egrep "^Major, minor: *[0-9]+, 123" info
+grep -E "^Major, minor: *[0-9]+, 123" info
 
 vgremove -ff $vg
diff --git a/test/shell/lvconvert-cache-abort.sh b/test/shell/lvconvert-cache-abort.sh
index 18b509e..9cf9410 100644
--- a/test/shell/lvconvert-cache-abort.sh
+++ b/test/shell/lvconvert-cache-abort.sh
@@ -50,7 +50,7 @@ sleep 0.2
 kill -INT $PID_CONVERT
 aux enable_dev "$dev1"
 wait
-egrep "Flushing.*aborted" log
+grep -E "Flushing.*aborted" log
 # check the table got restored
 check grep_dmsetup table $vg-$lv1 "writeback"
 
diff --git a/test/shell/lvcreate-repair.sh b/test/shell/lvcreate-repair.sh
index 456788d..5e02e7f 100644
--- a/test/shell/lvcreate-repair.sh
+++ b/test/shell/lvcreate-repair.sh
@@ -33,7 +33,7 @@ for i in "$dev1" "$dev2" "$dev3" ; do
 		vgreduce --removemissing --force $vg
 
 		# check if reduced device was removed
-		test "$i" = "$dev1" && dm_table | not egrep "$vg-$lv1: *[^ ]+"
+		test "$i" = "$dev1" && dm_table | not grep -E "$vg-$lv1: *[^ ]+"
 
 		lvcreate -l1 -n $lv2 $vg
 
diff --git a/test/shell/profiles-cache.sh b/test/shell/profiles-cache.sh
index 1765150..dd4affb 100644
--- a/test/shell/profiles-cache.sh
+++ b/test/shell/profiles-cache.sh
@@ -25,7 +25,7 @@ PFILE="cache-test"
 
 aux prepare_profiles
 
-cat <<EOF > $PDIR/${PFILE}.profile
+cat <<EOF > "$PDIR/${PFILE}.profile"
 allocation {
 	cache_pool_chunk_size = 128
 	cache_mode = "writeback"
@@ -47,7 +47,7 @@ allocation {
 }
 EOF
 
-cat <<EOF > $PDIR/${PFILE}1.profile
+cat <<EOF > "$PDIR/${PFILE}1.profile"
 allocation {
 	cache_pool_chunk_size = 512
 	cache_mode = "passthrough"
@@ -88,14 +88,14 @@ check lv_field $vg/cpool cachesettings ""
 
 
 lvcreate -L10 -n $lv1 $vg
-lvconvert --metadataprofile ${PFILE}1 -y -H --cachepool $vg/cpool $vg/$lv1
+lvconvert --metadataprofile "${PFILE}1" -y -H --cachepool $vg/cpool $vg/$lv1
 # chunk size 128k is replace with 512k from PFILE1
 check lv_field $vg/$lv1 chunksize "512.00k"
 # cachemode is from PFILE1
 check lv_field $vg/$lv1 cachemode "passthrough"
 lvremove -f $vg
 
-lvcreate -L1G --metadataprofile $PFILE --type cache-pool $vg/cpool
+lvcreate -L1G --metadataprofile "$PFILE" --type cache-pool $vg/cpool
 lvcreate -H -L10 -n $lv1 --cachepool $vg/cpool
 # profile name is stored with cache
 check lv_field $vg/$lv1 profile "$PFILE"
@@ -114,7 +114,7 @@ lvremove -f $vg
 
 #####
 
-lvcreate -L1G --metadataprofile $PFILE --type cache-pool $vg/cpool
+lvcreate -L1G --metadataprofile "$PFILE" --type cache-pool $vg/cpool
 lvcreate --cachesettings 'sequential_threshold=300'  -H -L10 -n $lv1 --cachepool $vg/cpool
 check lv_field $vg/$lv1 profile "$PFILE"
 check lv_field $vg/$lv1 cachesettings "sequential_threshold=300"
@@ -122,7 +122,7 @@ lvremove -f $vg
 
 #####
 
-lvcreate -L1G --metadataprofile $PFILE --type cache-pool $vg/cpool
+lvcreate -L1G --metadataprofile "$PFILE" --type cache-pool $vg/cpool
 lvcreate --chunksize 256    -H -L10 -n $lv1 --cachepool $vg/cpool
 check lv_field $vg/$lv1 cachemode "writeback"
 check lv_field $vg/$lv1 chunksize "256.00k"
@@ -131,8 +131,8 @@ lvremove -f $vg
 
 #####
 
-lvcreate -L1G --metadataprofile $PFILE --type cache-pool $vg/cpool
-lvcreate --metadataprofile ${PFILE}1   -H -L10 -n $lv1 --cachepool $vg/cpool
+lvcreate -L1G --metadataprofile "$PFILE" --type cache-pool $vg/cpool
+lvcreate --metadataprofile "${PFILE}1"   -H -L10 -n $lv1 --cachepool $vg/cpool
 check lv_field $vg/$lv1 chunksize "512.00k"
 check lv_field $vg/$lv1 cachemode "passthrough"
 lvremove -f $vg
diff --git a/test/shell/profiles-thin.sh b/test/shell/profiles-thin.sh
index a3a8b05..81ac90b 100644
--- a/test/shell/profiles-thin.sh
+++ b/test/shell/profiles-thin.sh
@@ -31,7 +31,7 @@ aux prepare_profiles "thin-performance"
 aux prepare_scsi_debug_dev $DEV_SIZE sector_size=4096 opt_blks=256 || skip
 EXPECT=1048576
 check sysfs "$(< SCSI_DEBUG_DEV)" queue/optimal_io_size "$EXPECT"
-aux prepare_pvs 1 $DEV_SIZE
+aux prepare_pvs 1 "$DEV_SIZE"
 
 # Check we are not running on buggy kernel (broken lcm())
 # If so, turn chunk_size test into  'should'
diff --git a/test/shell/pvmove-abort.sh b/test/shell/pvmove-abort.sh
index 218864c..0b8960b 100644
--- a/test/shell/pvmove-abort.sh
+++ b/test/shell/pvmove-abort.sh
@@ -54,8 +54,8 @@ pvmove --abort "$dev1"
 
 # check if proper pvmove was canceled
 get lv_field $vg name -a | tee out
-not egrep "^\[?pvmove0" out
-egrep "^\[?pvmove1" out
+not grep -E "^\[?pvmove0" out
+grep -E "^\[?pvmove1" out
 
 fi
 
diff --git a/test/shell/pvmove-resume-1.sh b/test/shell/pvmove-resume-1.sh
index 1f797d4..ff10199 100644
--- a/test/shell/pvmove-resume-1.sh
+++ b/test/shell/pvmove-resume-1.sh
@@ -90,13 +90,13 @@ test_pvmove_resume() {
 	aux enable_dev "$dev4"
 
 	i=0
-	while get lv_field $vg name -a | egrep "^\[?pvmove"; do
+	while get lv_field $vg name -a | grep -E "^\[?pvmove"; do
 		# wait for 30 secs at max
 		test $i -ge 300 && die "Pvmove is too slow or does not progress."
 		sleep .1
 		i=$((i + 1))
 	done
-	while get lv_field $vg1 name -a | egrep "^\[?pvmove"; do
+	while get lv_field $vg1 name -a | grep -E "^\[?pvmove"; do
 		# wait for 30 secs at max
 		test $i -ge 300 && die "Pvmove is too slow or does not progress."
 		sleep .1
@@ -172,8 +172,8 @@ pvmove_fg() {
 	fi
 
 	# ...thus finish polling
-	get lv_field $vg name -a | egrep "^\[?pvmove0"
-	get lv_field $vg1 name -a | egrep "^\[?pvmove0"
+	get lv_field $vg name -a | grep -E "^\[?pvmove0"
+	get lv_field $vg1 name -a | grep -E "^\[?pvmove0"
 
 	# disable delay device
 	# fg pvmove would take ages to complete otherwise
@@ -197,8 +197,8 @@ pvmove_bg() {
 	fi
 
 	# ...thus finish polling
-	get lv_field $vg name -a | egrep "^\[?pvmove0"
-	get lv_field $vg1 name -a | egrep "^\[?pvmove0"
+	get lv_field $vg name -a | grep -E "^\[?pvmove0"
+	get lv_field $vg1 name -a | grep -E "^\[?pvmove0"
 
 	LVM_TEST_TAG="kill_me_$PREFIX" pvmove -b -i0
 }
@@ -217,8 +217,8 @@ pvmove_fg_single() {
 	fi
 
 	# ...thus finish polling
-	get lv_field $vg name -a | egrep "^\[?pvmove0"
-	get lv_field $vg1 name -a | egrep "^\[?pvmove0"
+	get lv_field $vg name -a | grep -E "^\[?pvmove0"
+	get lv_field $vg1 name -a | grep -E "^\[?pvmove0"
 
 	# disable delay device
 	# fg pvmove would take ages to complete otherwise
@@ -243,8 +243,8 @@ pvmove_bg_single() {
 	fi
 
 	# ...thus finish polling
-	get lv_field $vg name -a | egrep "^\[?pvmove0"
-	get lv_field $vg1 name -a | egrep "^\[?pvmove0"
+	get lv_field $vg name -a | grep -E "^\[?pvmove0"
+	get lv_field $vg1 name -a | grep -E "^\[?pvmove0"
 
 	LVM_TEST_TAG="kill_me_$PREFIX" pvmove -b "$dev1"
 	LVM_TEST_TAG="kill_me_$PREFIX" pvmove -b "$dev2"
diff --git a/test/shell/pvmove-resume-2.sh b/test/shell/pvmove-resume-2.sh
index 73c42c8..50c4233 100644
--- a/test/shell/pvmove-resume-2.sh
+++ b/test/shell/pvmove-resume-2.sh
@@ -77,7 +77,7 @@ test_pvmove_resume() {
 	aux enable_dev "$dev2"
 
 	i=0
-	while get lv_field $vg name -a | egrep "^\[?pvmove"; do
+	while get lv_field $vg name -a | grep -E "^\[?pvmove"; do
 		# wait for 30 secs at max
 		test $i -ge 300 && die "Pvmove is too slow or does not progress."
 		sleep .1
@@ -130,7 +130,7 @@ pvmove_fg() {
 	fi
 
 	# ...thus finish polling
-	get lv_field $vg name -a | egrep "^\[?pvmove0"
+	get lv_field $vg name -a | grep -E "^\[?pvmove0"
 
 	aux enable_dev "$dev2"
 
@@ -150,7 +150,7 @@ pvmove_bg() {
 	fi
 
 	# ...thus finish polling
-	get lv_field $vg name -a | egrep "^\[?pvmove0"
+	get lv_field $vg name -a | grep -E "^\[?pvmove0"
 
 	LVM_TEST_TAG="kill_me_$PREFIX" pvmove -b
 }
@@ -168,7 +168,7 @@ pvmove_fg_single() {
 	fi
 
 	# ...thus finish polling
-	get lv_field $vg name -a | egrep "^\[?pvmove0"
+	get lv_field $vg name -a | grep -E "^\[?pvmove0"
 
 	aux enable_dev "$dev2"
 
@@ -188,7 +188,7 @@ pvmove_bg_single() {
 	fi
 
 	# ...thus finish polling
-	get lv_field $vg name -a | egrep "^\[?pvmove0"
+	get lv_field $vg name -a | grep -E "^\[?pvmove0"
 
 	LVM_TEST_TAG="kill_me_$PREFIX" pvmove -b "$dev1"
 }
diff --git a/test/shell/pvmove-resume-multiseg.sh b/test/shell/pvmove-resume-multiseg.sh
index 2737939..ce54061 100644
--- a/test/shell/pvmove-resume-multiseg.sh
+++ b/test/shell/pvmove-resume-multiseg.sh
@@ -90,7 +90,7 @@ test_pvmove_resume() {
 	aux enable_dev "$dev5"
 
 	i=0
-	while get lv_field $vg name -a | egrep "^\[?pvmove"; do
+	while get lv_field $vg name -a | grep -E "^\[?pvmove"; do
 		# wait for 30 secs@max
 		test $i -ge 300 && die "Pvmove is too slow or does not progress."
 		sleep .1
@@ -148,8 +148,8 @@ pvmove_fg() {
 	fi
 
 	# ...thus finish polling
-	get lv_field $vg name -a | egrep "^\[?pvmove0"
-	get lv_field $vg name -a | egrep "^\[?pvmove1"
+	get lv_field $vg name -a | grep -E "^\[?pvmove0"
+	get lv_field $vg name -a | grep -E "^\[?pvmove1"
 
 	# disable delay device
 	# fg pvmove would take ages to complete otherwise
@@ -173,8 +173,8 @@ pvmove_bg() {
 	fi
 
 	# ...thus finish polling
-	get lv_field $vg name -a | egrep "^\[?pvmove0"
-	get lv_field $vg name -a | egrep "^\[?pvmove1"
+	get lv_field $vg name -a | grep -E "^\[?pvmove0"
+	get lv_field $vg name -a | grep -E "^\[?pvmove1"
 
 	LVM_TEST_TAG="kill_me_$PREFIX" pvmove -b
 }
@@ -193,8 +193,8 @@ pvmove_fg_single() {
 	fi
 
 	# ...thus finish polling
-	get lv_field $vg name -a | egrep "^\[?pvmove0"
-	get lv_field $vg name -a | egrep "^\[?pvmove1"
+	get lv_field $vg name -a | grep -E "^\[?pvmove0"
+	get lv_field $vg name -a | grep -E "^\[?pvmove1"
 
 	# disable delay device
 	# fg pvmove would take ages to complete otherwise
@@ -219,8 +219,8 @@ pvmove_bg_single() {
 	fi
 
 	# ...thus finish polling
-	get lv_field $vg name -a | egrep "^\[?pvmove0"
-	get lv_field $vg name -a | egrep "^\[?pvmove1"
+	get lv_field $vg name -a | grep -E "^\[?pvmove0"
+	get lv_field $vg name -a | grep -E "^\[?pvmove1"
 
 	LVM_TEST_TAG="kill_me_$PREFIX" pvmove -b "$dev1"
 	LVM_TEST_TAG="kill_me_$PREFIX" pvmove -b "$dev3"
diff --git a/test/shell/unknown-segment.sh b/test/shell/unknown-segment.sh
index cadbe19..42f1fd3 100644
--- a/test/shell/unknown-segment.sh
+++ b/test/shell/unknown-segment.sh
@@ -40,8 +40,8 @@ sed -e 's,unstriped,striped,;s,unmirror,mirror,;s,zero+NEWFLAG,zero,' -i.orig ba
 vgcfgrestore -f bak1 $vg
 vgcfgbackup -f bak2 $vg
 
-egrep -v 'description|seqno|creation_time|Generated' < bak0.orig > a
-egrep -v 'description|seqno|creation_time|Generated' < bak2 > b
+grep -v -E 'description|seqno|creation_time|Generated' < bak0.orig > a
+grep -v -E 'description|seqno|creation_time|Generated' < bak2 > b
 diff -u a b
 
 vgremove -ff $vg
diff --git a/test/shell/vgextend-restoremissing.sh b/test/shell/vgextend-restoremissing.sh
index 196d82f..969140a 100644
--- a/test/shell/vgextend-restoremissing.sh
+++ b/test/shell/vgextend-restoremissing.sh
@@ -25,7 +25,7 @@ invalid vgextend
 # --metadatacopies => use --pvmetadatacopies
 invalid vgextend --metadatacopies 3 $vg "$dev1" 2>&1 | tee out
 #grep -- "use --pvmetadatacopies" out
-egrep -- "unrecognized option.*--metadatacopies" out
+grep -E -- "unrecognized option.*--metadatacopies" out
 
 # VG name should exist
 fail vgextend --restoremissing $vg-invalid "$dev1"


