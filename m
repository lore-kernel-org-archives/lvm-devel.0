From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 20 May 2014 19:54:01 +0000 (UTC)
Subject: master - tests: add have_cache and have_raid
Message-ID: <20140520195401.9460D60C83@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=2e9792121fa93e7cb67583cd2757dd52ab2825dc
Commit:        2e9792121fa93e7cb67583cd2757dd52ab2825dc
Parent:        7f92c3a13eeba179872dacd4b632d8bb5188a0ba
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue May 20 19:54:48 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue May 20 21:50:30 2014 +0200

tests: add have_cache and have_raid

Need to be aware of build options, when system would be
configure without raid or cache support
---
 test/Makefile.in                      |    2 ++
 test/lib/aux.sh                       |   14 ++++++++++++--
 test/shell/lvchange-partial-raid10.sh |    2 +-
 test/shell/lvchange-partial.sh        |    2 +-
 test/shell/lvchange-raid.sh           |    6 +++---
 test/shell/lvchange-raid10.sh         |    2 +-
 test/shell/lvchange-raid456.sh        |    2 +-
 test/shell/lvconvert-raid.sh          |    2 +-
 test/shell/lvconvert-raid10.sh        |    2 +-
 test/shell/lvconvert-raid456.sh       |    2 +-
 test/shell/lvconvert-repair-raid.sh   |    2 +-
 test/shell/lvconvert-thin-external.sh |    2 +-
 test/shell/lvcreate-cache.sh          |    2 +-
 test/shell/lvcreate-large-raid.sh     |    2 +-
 test/shell/lvcreate-large-raid10.sh   |    2 +-
 test/shell/lvcreate-raid.sh           |    2 +-
 test/shell/lvcreate-raid10.sh         |    2 +-
 test/shell/lvresize-raid.sh           |    2 +-
 test/shell/lvresize-raid10.sh         |    2 +-
 test/shell/pvmove-cache-segtypes.sh   |    6 +++---
 test/shell/pvmove-raid-segtypes.sh    |    2 +-
 test/shell/pvmove-thin-segtypes.sh    |    4 ++--
 test/shell/pvremove-thin.sh           |    2 +-
 test/shell/vgsplit-raid.sh            |    2 +-
 24 files changed, 41 insertions(+), 29 deletions(-)

diff --git a/test/Makefile.in b/test/Makefile.in
index 33d8ab4..33b7042 100644
--- a/test/Makefile.in
+++ b/test/Makefile.in
@@ -146,6 +146,8 @@ lib/paths: $(srcdir)/Makefile.in .lib-dir-stamp
 	echo 'abs_builddir="$(abs_builddir)"' >> $@-t
 	echo 'export DM_UDEV_SYNCHRONISATION=$(dm_udev_synchronisation)' >> $@-t
 	echo 'export THIN=@THIN@' >> $@-t
+	echo 'export RAID=@RAID@' >> $@-t
+	echo 'export CACHE=@CACHE@' >> $@-t
 	echo 'export LVMETAD_PIDFILE="@LVMETAD_PIDFILE@"' >> $@-t
 	echo 'export DMEVENTD_PIDFILE="@DMEVENTD_PIDFILE@"' >> $@-t
 	echo 'export CLVMD_PIDFILE="@CLVMD_PIDFILE@"' >> $@-t
diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 8b765e9..0832f24 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -770,13 +770,23 @@ target_at_least() {
 }
 
 have_thin() {
-	target_at_least dm-thin-pool "$@" || exit 1
-	test "$THIN" = shared || test "$THIN" = internal || exit 1
+	test "$THIN" = shared -o "$THIN" = internal || return 1
+	target_at_least dm-thin-pool "$@" || return 1
 
 	# disable thin_check if not present in system
 	which thin_check || lvmconf 'global/thin_check_executable = ""'
 }
 
+have_raid() {
+	test "$RAID" = shared -o "$RAID" = internal || return 1
+	target_at_least dm-raid "$@"
+}
+
+have_cache() {
+	test "$CACHE" = shared -o "$CACHE" = internal || return 1
+	target_at_least dm-cache "$@"
+}
+
 # check if lvm shell is build-in  (needs readline)
 have_readline() {
 	echo version | lvm &>/dev/null
diff --git a/test/shell/lvchange-partial-raid10.sh b/test/shell/lvchange-partial-raid10.sh
index 3141add..3c112bb 100644
--- a/test/shell/lvchange-partial-raid10.sh
+++ b/test/shell/lvchange-partial-raid10.sh
@@ -11,7 +11,7 @@
 
 . lib/test
 
-aux target_at_least dm-raid 1 3 2 || skip
+aux have_raid 1 3 2 || skip
 
 aux prepare_vg 4
 
diff --git a/test/shell/lvchange-partial.sh b/test/shell/lvchange-partial.sh
index 7483d88..c3d7217 100644
--- a/test/shell/lvchange-partial.sh
+++ b/test/shell/lvchange-partial.sh
@@ -15,7 +15,7 @@
 aux prepare_vg 4
 
 TYPE=raid1
-aux target_at_least dm-raid 1 1 0 || TYPE=mirror
+aux have_raid 1 1 0 || TYPE=mirror
 
 lvcreate -aey --type $TYPE -m 1 -l 2 -n $lv1 $vg
 lvchange -an $vg/$lv1
diff --git a/test/shell/lvchange-raid.sh b/test/shell/lvchange-raid.sh
index 8ef6c33..209e094 100644
--- a/test/shell/lvchange-raid.sh
+++ b/test/shell/lvchange-raid.sh
@@ -17,9 +17,9 @@
 # Proper mismatch count 1.5.2 upstream,1.3.5 < x < 1.4.0 in RHEL6
 #
 # We will simplify and simple test for 1.5.2 and 1.3.5 < x < 1.4.0
-aux target_at_least dm-raid 1 3 5 &&
-  ! aux target_at_least dm-raid 1 4 0 ||
-  aux target_at_least dm-raid 1 5 2 || skip
+aux have_raid 1 3 5 &&
+  ! aux have_raid 1 4 0 ||
+  aux have_raid 1 5 2 || skip
 
 # DEVICE "$dev6" is reserved for non-RAID LVs that
 # will not undergo failure
diff --git a/test/shell/lvchange-raid10.sh b/test/shell/lvchange-raid10.sh
index b31c328..0d17928 100644
--- a/test/shell/lvchange-raid10.sh
+++ b/test/shell/lvchange-raid10.sh
@@ -13,7 +13,7 @@ TEST_RAID=raid10
 
 . shell/lvchange-raid.sh
 
-aux target_at_least dm-raid 1 5 2 || skip
+aux have_raid 1 5 2 || skip
 
 run_types raid10 -m 1 -i 2 "$dev1" "$dev2" "$dev3" "$dev4"
 
diff --git a/test/shell/lvchange-raid456.sh b/test/shell/lvchange-raid456.sh
index 83f82c3..b1dd1db 100644
--- a/test/shell/lvchange-raid456.sh
+++ b/test/shell/lvchange-raid456.sh
@@ -14,7 +14,7 @@ TEST_RAID=raid456
 . shell/lvchange-raid.sh
 
 aux raid456_replace_works || skip
-aux target_at_least dm-raid 1 5 2 || skip
+aux have_raid 1 5 2 || skip
 
 run_types raid4 -i 2 "$dev1" "$dev2" "$dev3" "$dev4"
 run_types raid5 -i 2 "$dev1" "$dev2" "$dev3" "$dev4"
diff --git a/test/shell/lvconvert-raid.sh b/test/shell/lvconvert-raid.sh
index 01118cb..2a498b2 100644
--- a/test/shell/lvconvert-raid.sh
+++ b/test/shell/lvconvert-raid.sh
@@ -22,7 +22,7 @@ get_image_pvs() {
 ########################################################
 # MAIN
 ########################################################
-aux target_at_least dm-raid 1 2 0 || skip
+aux have_raid 1 2 0 || skip
 
 aux prepare_pvs 5
 vgcreate -s 256k $vg $(cat DEVICES)
diff --git a/test/shell/lvconvert-raid10.sh b/test/shell/lvconvert-raid10.sh
index 6297f65..e9b0ef8 100644
--- a/test/shell/lvconvert-raid10.sh
+++ b/test/shell/lvconvert-raid10.sh
@@ -24,7 +24,7 @@ get_image_pvs() {
 ########################################################
 # RAID10: Can replace 'copies - 1' devices from each stripe
 # Tests are run on 2-way mirror, 3-way stripe RAID10
-aux target_at_least dm-raid 1 3 1 || skip
+aux have_raid 1 3 1 || skip
 
 # 9 PVs needed for RAID10 testing (3-stripes/2-mirror - replacing 3 devs)
 aux prepare_pvs 9 80
diff --git a/test/shell/lvconvert-raid456.sh b/test/shell/lvconvert-raid456.sh
index bf9a823..b9386c9 100644
--- a/test/shell/lvconvert-raid456.sh
+++ b/test/shell/lvconvert-raid456.sh
@@ -23,7 +23,7 @@ get_image_pvs() {
 # MAIN
 ########################################################
 aux raid456_replace_works || skip
-aux target_at_least dm-raid 1 2 0 || skip
+aux have_raid 1 2 0 || skip
 
 aux prepare_pvs 6
 vgcreate -s 256k $vg $(cat DEVICES)
diff --git a/test/shell/lvconvert-repair-raid.sh b/test/shell/lvconvert-repair-raid.sh
index bc5483b..7d4ea7e 100644
--- a/test/shell/lvconvert-repair-raid.sh
+++ b/test/shell/lvconvert-repair-raid.sh
@@ -12,7 +12,7 @@
 . lib/test
 
 aux raid456_replace_works || skip
-aux target_at_least dm-raid 1 1 0 || skip
+aux have_raid 1 1 0 || skip
 
 aux lvmconf 'allocation/maximise_cling = 0'
 aux lvmconf 'allocation/mirror_logs_require_separate_pvs = 1'
diff --git a/test/shell/lvconvert-thin-external.sh b/test/shell/lvconvert-thin-external.sh
index 00712bd..5d52e60 100644
--- a/test/shell/lvconvert-thin-external.sh
+++ b/test/shell/lvconvert-thin-external.sh
@@ -157,7 +157,7 @@ lvremove -ff $vg
 # Test conversion to the pool and thin external@the same time (rhbz #1003461)
 lvcreate -l50 -n pool $vg
 lvcreate -l100 -n thin $vg
-lvconvert --thin --thinpool $vg/pool $vg/thin --originname thin-origin
+lvconvert --yes --thin --thinpool $vg/pool $vg/thin --originname thin-origin
 check lv_field $vg/thin segtype thin
 check lv_field $vg/thin-origin segtype linear
 
diff --git a/test/shell/lvcreate-cache.sh b/test/shell/lvcreate-cache.sh
index 302a708..1c438e7 100644
--- a/test/shell/lvcreate-cache.sh
+++ b/test/shell/lvcreate-cache.sh
@@ -11,7 +11,7 @@
 
 . lib/test
 
-aux target_at_least dm-cache 1 3 0 || skip
+aux have_cache 1 3 0 || skip
 
 aux prepare_vg 5 80
 
diff --git a/test/shell/lvcreate-large-raid.sh b/test/shell/lvcreate-large-raid.sh
index 3f06d04..84110ab 100644
--- a/test/shell/lvcreate-large-raid.sh
+++ b/test/shell/lvcreate-large-raid.sh
@@ -16,7 +16,7 @@
 # FIXME  update test to make something useful on <16T
 aux can_use_16T || skip
 
-aux target_at_least dm-raid 1 1 0 || skip
+aux have_raid 1 1 0 || skip
 
 aux prepare_vg 5
 
diff --git a/test/shell/lvcreate-large-raid10.sh b/test/shell/lvcreate-large-raid10.sh
index 635d7a3..5a15ee0 100644
--- a/test/shell/lvcreate-large-raid10.sh
+++ b/test/shell/lvcreate-large-raid10.sh
@@ -16,7 +16,7 @@
 # FIXME  update test to make something useful on <16T
 aux can_use_16T || skip
 
-aux target_at_least dm-raid 1 3 0 || skip
+aux have_raid 1 3 0 || skip
 
 aux prepare_vg 5
 
diff --git a/test/shell/lvcreate-raid.sh b/test/shell/lvcreate-raid.sh
index d0d365f..d9c949a 100644
--- a/test/shell/lvcreate-raid.sh
+++ b/test/shell/lvcreate-raid.sh
@@ -18,7 +18,7 @@ lv_devices() {
 ########################################################
 # MAIN
 ########################################################
-aux target_at_least dm-raid 1 1 0 || skip
+aux have_raid 1 1 0 || skip
 
 aux prepare_pvs 6 20  # 6 devices for RAID10 (2-mirror,3-stripe) test
 vgcreate -s 512k $vg $(cat DEVICES)
diff --git a/test/shell/lvcreate-raid10.sh b/test/shell/lvcreate-raid10.sh
index a521794..ae02ab2 100644
--- a/test/shell/lvcreate-raid10.sh
+++ b/test/shell/lvcreate-raid10.sh
@@ -18,7 +18,7 @@ lv_devices() {
 ########################################################
 # MAIN
 ########################################################
-aux target_at_least dm-raid 1 3 0 || skip
+aux have_raid 1 3 0 || skip
 
 aux prepare_pvs 6 20  # 6 devices for RAID10 (2-mirror,3-stripe) test
 vgcreate -s 512k $vg $(cat DEVICES)
diff --git a/test/shell/lvresize-raid.sh b/test/shell/lvresize-raid.sh
index bc8b36f..e13a08d 100644
--- a/test/shell/lvresize-raid.sh
+++ b/test/shell/lvresize-raid.sh
@@ -11,7 +11,7 @@
 
 . lib/test
 
-aux target_at_least dm-raid 1 1 0 || skip
+aux have_raid 1 1 0 || skip
 
 aux prepare_pvs 6 80
 
diff --git a/test/shell/lvresize-raid10.sh b/test/shell/lvresize-raid10.sh
index 306507f..42cfeb4 100644
--- a/test/shell/lvresize-raid10.sh
+++ b/test/shell/lvresize-raid10.sh
@@ -11,7 +11,7 @@
 
 . lib/test
 
-aux target_at_least dm-raid 1 3 0 || skip
+aux have_raid 1 3 0 || skip
 
 aux prepare_vg 5
 
diff --git a/test/shell/pvmove-cache-segtypes.sh b/test/shell/pvmove-cache-segtypes.sh
index 2b62b1f..db3bde5 100644
--- a/test/shell/pvmove-cache-segtypes.sh
+++ b/test/shell/pvmove-cache-segtypes.sh
@@ -22,10 +22,10 @@ test_description="ensure pvmove works with the cache segment types"
 test -e LOCAL_CLVMD && skip
 which md5sum || skip
 
-aux target_at_least dm-cache 1 3 0 || skip
+aux have_cache 1 3 0 || skip
 # for stacking
-aux target_at_least dm-thin-pool 1 8 0 || skip
-aux target_at_least dm-raid 1 4 2 || skip
+aux have_thin 1 8 0 || skip
+aux have_raid 1 4 2 || skip
 
 aux prepare_vg 5 80
 
diff --git a/test/shell/pvmove-raid-segtypes.sh b/test/shell/pvmove-raid-segtypes.sh
index 1b0f129..f3f5cd5 100644
--- a/test/shell/pvmove-raid-segtypes.sh
+++ b/test/shell/pvmove-raid-segtypes.sh
@@ -16,7 +16,7 @@ test_description="ensure pvmove works with raid segment types"
 test -e LOCAL_CLVMD && skip
 which md5sum || skip
 
-aux target_at_least dm-raid 1 3 5 || skip
+aux have_raid 1 3 5 || skip
 
 aux prepare_pvs 5 20
 vgcreate -c n -s 128k $vg $(cat DEVICES)
diff --git a/test/shell/pvmove-thin-segtypes.sh b/test/shell/pvmove-thin-segtypes.sh
index c514bb5..4bd3b29 100644
--- a/test/shell/pvmove-thin-segtypes.sh
+++ b/test/shell/pvmove-thin-segtypes.sh
@@ -15,9 +15,9 @@ test_description="ensure pvmove works with thin segment types"
 test -e LOCAL_CLVMD && skip
 which md5sum || skip
 
-aux target_at_least dm-thin-pool 1 8 0 || skip
+aux have_thin 1 8 0 || skip
 # for stacking
-aux target_at_least dm-raid 1 3 5 || skip
+aux have_raid 1 3 5 || skip
 
 aux prepare_pvs 5 20
 vgcreate -c n -s 128k $vg $(cat DEVICES)
diff --git a/test/shell/pvremove-thin.sh b/test/shell/pvremove-thin.sh
index 03e6ca3..e8af2af 100644
--- a/test/shell/pvremove-thin.sh
+++ b/test/shell/pvremove-thin.sh
@@ -16,7 +16,7 @@
 
 aux prepare_vg
 
-aux target_at_least dm-thin-pool 1 8 0 || skip
+aux have_thin 1 8 0 || skip
 
 aux extend_filter_LVMTEST
 
diff --git a/test/shell/vgsplit-raid.sh b/test/shell/vgsplit-raid.sh
index 898fc9a..6454556 100644
--- a/test/shell/vgsplit-raid.sh
+++ b/test/shell/vgsplit-raid.sh
@@ -21,7 +21,7 @@ create_vg_() {
 	vgcreate -s 64k "$@"
 }
 
-aux target_at_least dm-raid 1 1 0 || skip
+aux have_raid 1 1 0 || skip
 
 aux prepare_pvs 5 10
 


