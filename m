From: Jonathan Brassow <jbrassow@fedoraproject.org>
Date: Wed,  7 Aug 2013 20:50:53 +0000 (UTC)
Subject: master - TEST: Be explicit about which mirror segment type to use.
Message-ID: <20130807205053.E810760D19@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ea4c0ea34f4c4cba53f4426dbbff39bee475a2f5
Commit:        ea4c0ea34f4c4cba53f4426dbbff39bee475a2f5
Parent:        f50e8fb9b9030c86f3a65f61a4b7f43089a26c60
Author:        Jonathan Brassow <jbrassow@redhat.com>
AuthorDate:    Wed Aug 7 15:48:31 2013 -0500
Committer:     Jonathan Brassow <jbrassow@redhat.com>
CommitterDate: Wed Aug 7 15:48:31 2013 -0500

TEST: Be explicit about which mirror segment type to use.

In those places where mirrors were being created while assuming
a default segment type of "mirror", we include the '--type mirror'
argument to explicitly set the segment type.  This will preserve
the mirror testing that is performed even though the default
mirroring segment type is now "raid1".
---
 test/api/percent.sh                               |    2 +-
 test/shell/activate-missing.sh                    |    4 +-
 test/shell/activate-partial.sh                    |    2 +-
 test/shell/dmeventd-restart.sh                    |    4 +-
 test/shell/inconsistent-metadata.sh               |    2 +-
 test/shell/listings.sh                            |    2 +-
 test/shell/lvchange-mirror.sh                     |    4 +-
 test/shell/lvconvert-mirror-basic.sh              |    2 +-
 test/shell/lvconvert-mirror.sh                    |   50 ++++++++++----------
 test/shell/lvconvert-repair-dmeventd.sh           |    2 +-
 test/shell/lvconvert-repair-policy.sh             |    4 +-
 test/shell/lvconvert-repair-replace.sh            |   12 +++---
 test/shell/lvconvert-repair-snapshot.sh           |    2 +-
 test/shell/lvconvert-repair-transient-dmeventd.sh |    2 +-
 test/shell/lvconvert-repair-transient.sh          |    2 +-
 test/shell/lvconvert-repair.sh                    |   12 +++---
 test/shell/lvconvert-thin.sh                      |    4 +-
 test/shell/lvconvert-twostep.sh                   |    2 +-
 test/shell/lvcreate-mirror.sh                     |    8 ++--
 test/shell/lvcreate-operation.sh                  |    4 +-
 test/shell/lvcreate-pvtags.sh                     |   10 ++--
 test/shell/lvcreate-striped-mirror.sh             |   20 ++++----
 test/shell/lvcreate-thin.sh                       |    2 +-
 test/shell/lvcreate-usage.sh                      |   10 ++--
 test/shell/lvresize-mirror.sh                     |    4 +-
 test/shell/metadata.sh                            |    2 +-
 test/shell/mirror-names.sh                        |    8 ++--
 test/shell/mirror-vgreduce-removemissing.sh       |   32 +++++++-------
 test/shell/nomda-missing.sh                       |    4 +-
 test/shell/nomda-restoremissing.sh                |    6 +-
 test/shell/snapshots-of-mirrors.sh                |    6 +-
 test/shell/unknown-segment.sh                     |    2 +-
 test/shell/unlost-pv.sh                           |    2 +-
 test/shell/vgextend-restoremissing.sh             |    6 +-
 test/shell/vgmerge-operation.sh                   |    2 +-
 test/shell/vgreduce-removemissing-snapshot.sh     |    2 +-
 test/shell/vgreduce-usage.sh                      |    4 +-
 test/shell/vgsplit-operation.sh                   |   14 +++---
 38 files changed, 131 insertions(+), 131 deletions(-)

diff --git a/test/api/percent.sh b/test/api/percent.sh
index 8f7d5da..097cad8 100644
--- a/test/api/percent.sh
+++ b/test/api/percent.sh
@@ -22,7 +22,7 @@ lvcreate -aey -l 5 -n foo $vg
 lvcreate -s -n snap $vg/foo -l 3 -c 4k
 lvcreate -s -n snap2 $vg/foo -l 6 -c 4k
 dd if=/dev/urandom of="$DM_DEV_DIR/$vg/snap2" count=1 bs=1024
-lvcreate -aey -m 1 -n mirr $vg -l 1 --mirrorlog core
+lvcreate -aey --type mirror -m 1 -n mirr $vg -l 1 --mirrorlog core
 lvs $vg
 aux apitest percent $vg
 
diff --git a/test/shell/activate-missing.sh b/test/shell/activate-missing.sh
index 8f5a949..6f7c7a2 100644
--- a/test/shell/activate-missing.sh
+++ b/test/shell/activate-missing.sh
@@ -27,8 +27,8 @@ lvcreate -l2 -n linear12 $vg "$dev1":4 "$dev2":4
 lvcreate -aey -l1 -n origin1 $vg "$dev1"
 lvcreate -s $vg/origin1 -l1 -n s_napshot2 "$dev2"
 
-lvcreate -aey -l1 -m1 -n mirror12 --mirrorlog core $vg "$dev1" "$dev2"
-lvcreate -aey -l1 -m1 -n mirror123 $vg "$dev1" "$dev2" "$dev3"
+lvcreate -aey -l1 --type mirror -m1 -n mirror12 --mirrorlog core $vg "$dev1" "$dev2"
+lvcreate -aey -l1 --type mirror -m1 -n mirror123 $vg "$dev1" "$dev2" "$dev3"
 
 vgchange -a n $vg
 aux disable_dev "$dev1"
diff --git a/test/shell/activate-partial.sh b/test/shell/activate-partial.sh
index bc01f72..757c696 100644
--- a/test/shell/activate-partial.sh
+++ b/test/shell/activate-partial.sh
@@ -13,7 +13,7 @@
 
 aux prepare_vg 3
 
-lvcreate -aey -m 1 -l 1 --nosync -n mirror $vg
+lvcreate -aey --type mirror -m 1 -l 1 --nosync -n mirror $vg
 lvchange -a n $vg/mirror
 aux disable_dev "$dev1"
 
diff --git a/test/shell/dmeventd-restart.sh b/test/shell/dmeventd-restart.sh
index a90b7c7..e27d426 100644
--- a/test/shell/dmeventd-restart.sh
+++ b/test/shell/dmeventd-restart.sh
@@ -15,9 +15,9 @@ aux prepare_dmeventd
 
 aux prepare_vg 5
 
-lvcreate -aey -m 3 --nosync --ignoremonitoring -l1 -n 4way $vg
+lvcreate -aey --type mirror -m 3 --nosync --ignoremonitoring -l1 -n 4way $vg
 lvchange --monitor y $vg/4way
-lvcreate -aey -m 2 --nosync --ignoremonitoring -l1 -n 3way $vg
+lvcreate -aey --type mirror -m 2 --nosync --ignoremonitoring -l1 -n 3way $vg
 lvchange --monitor y $vg/3way
 
 dmeventd -R -f &
diff --git a/test/shell/inconsistent-metadata.sh b/test/shell/inconsistent-metadata.sh
index 7cf177a..699fea7 100644
--- a/test/shell/inconsistent-metadata.sh
+++ b/test/shell/inconsistent-metadata.sh
@@ -13,7 +13,7 @@
 
 aux prepare_vg 3 12
 
-lvcreate -aye -m 1 -l 1 -n mirror $vg
+lvcreate -aye --type mirror -m 1 -l 1 -n mirror $vg
 lvcreate -l 1 -n resized $vg
 lvchange -a n $vg/mirror
 
diff --git a/test/shell/listings.sh b/test/shell/listings.sh
index 8b9d082..30df79f 100644
--- a/test/shell/listings.sh
+++ b/test/shell/listings.sh
@@ -54,7 +54,7 @@ dmsetup ls|grep $PREFIX|grep -v "LVMTEST.*pv."
 lvremove -f $vg/$lv2
 
 #COMM lvs -a displays mirror legs and log
-lvcreate -aey -l4 -m2 -n $lv3 $vg
+lvcreate -aey -l4 --type mirror -m2 -n $lv3 $vg
 test $(lvs --noheadings $vg | wc -l) -eq 2
 test $(lvs -a --noheadings $vg | wc -l) -eq 6
 dmsetup ls|grep $PREFIX|grep -v "LVMTEST.*pv."
diff --git a/test/shell/lvchange-mirror.sh b/test/shell/lvchange-mirror.sh
index 7036210..1a0c06b 100644
--- a/test/shell/lvchange-mirror.sh
+++ b/test/shell/lvchange-mirror.sh
@@ -19,14 +19,14 @@ aux prepare_dmeventd
 aux prepare_vg 3
 
 # force resync 2-way active mirror
-lvcreate -aey -l2 -m1 -n $lv1 $vg "$dev1" "$dev2" "$dev3":0-1
+lvcreate -aey -l2 --type mirror -m1 -n $lv1 $vg "$dev1" "$dev2" "$dev3":0-1
 check mirror $vg $lv1 "$dev3"
 lvchange -y --resync $vg/$lv1
 check mirror $vg $lv1 "$dev3"
 lvremove -ff $vg
 
 # force resync 2-way inactive mirror
-lvcreate -aey -l2 -m1 -n $lv1 $vg "$dev1" "$dev2" "$dev3":0-1
+lvcreate -aey -l2 --type mirror -m1 -n $lv1 $vg "$dev1" "$dev2" "$dev3":0-1
 lvchange -an $vg/$lv1
 check mirror $vg $lv1 "$dev3"
 lvchange --resync $vg/$lv1
diff --git a/test/shell/lvconvert-mirror-basic.sh b/test/shell/lvconvert-mirror-basic.sh
index ed9a17e..caee9db 100644
--- a/test/shell/lvconvert-mirror-basic.sh
+++ b/test/shell/lvconvert-mirror-basic.sh
@@ -76,7 +76,7 @@ test_lvconvert() {
 			alloc="--alloc anywhere"
 		fi
 
-		lvcreate -aey -l2 -m $start_count --mirrorlog $start_log_type \
+		lvcreate -aey -l2 --type mirror -m $start_count --mirrorlog $start_log_type \
 			-n $lv1 $vg $alloc
 		check mirror_legs $vg $lv1 $start_count_p1
 		# FIXME: check mirror log
diff --git a/test/shell/lvconvert-mirror.sh b/test/shell/lvconvert-mirror.sh
index e3c01fa..600bbec 100644
--- a/test/shell/lvconvert-mirror.sh
+++ b/test/shell/lvconvert-mirror.sh
@@ -25,42 +25,42 @@ lvremove -ff $vg
 
 # convert from linear to 2-way mirror (override "raid1" default type)
 lvcreate -aey -l2 -n $lv1 $vg "$dev1"
-lvconvert --type mirror -i1 -m+1 $vg/$lv1 "$dev2" "$dev3:0-1" \
+lvconvert -i1 --type mirror -m+1 $vg/$lv1 "$dev2" "$dev3:0-1" \
 	--config 'global { mirror_segtype_default = "raid1" }'
 check mirror $vg $lv1 "$dev3"
 lvremove -ff $vg
 
 # convert from linear to 2-way mirror - with tags and volume_list (bz683270)
 lvcreate -aey -l2 -n $lv1 $vg --addtag hello
-lvconvert -i1 -m+1 $vg/$lv1 \
+lvconvert -i1 --type mirror -m+1 $vg/$lv1 \
     --config 'activation { volume_list = [ "@hello" ] }'
 lvremove -ff $vg
 
 # convert from 2-way to 3-way mirror - with tags and volume_list (bz683270)
-lvcreate -aey -l2 -m1 -n $lv1 $vg --addtag hello
+lvcreate -aey -l2 --type mirror -m1 -n $lv1 $vg --addtag hello
 lvconvert -i1 -m+1 $vg/$lv1 \
     --config 'activation { volume_list = [ "@hello" ] }'
 lvremove -ff $vg
 
 # convert from 2-way mirror to linear
-lvcreate -aey -l2 -m1 -n $lv1 $vg "$dev1" "$dev2" "$dev3:0-1"
+lvcreate -aey -l2 --type mirror -m1 -n $lv1 $vg "$dev1" "$dev2" "$dev3:0-1"
 lvconvert -m-1 $vg/$lv1
 check linear $vg $lv1
 lvremove -ff $vg
 # and now try removing a specific leg (bz453643)
-lvcreate -aey -l2 -m1 -n $lv1 $vg "$dev1" "$dev2" "$dev3:0-1"
+lvcreate -aey -l2 --type mirror -m1 -n $lv1 $vg "$dev1" "$dev2" "$dev3:0-1"
 lvconvert -m0 $vg/$lv1 "$dev2"
 check lv_on $vg $lv1 "$dev1"
 lvremove -ff $vg
 
 # convert from disklog to corelog, active
-lvcreate -aey -l2 -m1 -n $lv1 $vg "$dev1" "$dev2" "$dev3:0-1"
+lvcreate -aey -l2 --type mirror -m1 -n $lv1 $vg "$dev1" "$dev2" "$dev3:0-1"
 lvconvert -f --mirrorlog core $vg/$lv1
 check mirror $vg $lv1 core
 lvremove -ff $vg
 
 # convert from corelog to disklog, active
-lvcreate -aey -l2 -m1 --mirrorlog core -n $lv1 $vg "$dev1" "$dev2"
+lvcreate -aey -l2 --type mirror -m1 --mirrorlog core -n $lv1 $vg "$dev1" "$dev2"
 lvconvert --mirrorlog disk $vg/$lv1 "$dev3:0-1"
 check mirror $vg $lv1 "$dev3"
 lvremove -ff $vg
@@ -74,7 +74,7 @@ lvremove -ff $vg
 # Test pulling primary image before mirror in-sync (should fail)
 # Test pulling primary image after mirror in-sync (should work)
 # Test that the correct devices remain in the mirror
-lvcreate -aey -l2 -m2 -n $lv1 $vg "$dev1" "$dev2" "$dev4" "$dev3:$DEVRANGE"
+lvcreate -aey -l2 --type mirror -m2 -n $lv1 $vg "$dev1" "$dev2" "$dev4" "$dev3:$DEVRANGE"
 # FIXME:
 #  This is somewhat timing dependent - sync /could/ finish before
 #  we get a chance to have this command fail
@@ -93,7 +93,7 @@ lvremove -ff $vg
 
 # No parallel lvconverts on a single LV please
 
-lvcreate -aey -l5 -m1 -n $lv1 $vg "$dev1" "$dev2" "$dev3:0"
+lvcreate -aey -l5 --type mirror -m1 -n $lv1 $vg "$dev1" "$dev2" "$dev3:0"
 check mirror $vg $lv1
 check mirror_legs $vg $lv1 2
 lvconvert -m+1 -b $vg/$lv1 "$dev4"
@@ -110,7 +110,7 @@ lvremove -ff $vg
 
 # add 1 mirror to core log mirror, but
 #  implicitly keep log as 'core'
-lvcreate -aey -l2 -m1 --mirrorlog core -n $lv1 $vg "$dev1" "$dev2"
+lvcreate -aey -l2 --type mirror -m1 --mirrorlog core -n $lv1 $vg "$dev1" "$dev2"
 lvconvert -m +1 -i1 $vg/$lv1
 
 check mirror $vg $lv1 core
@@ -119,7 +119,7 @@ check mirror_legs $vg $lv1 3
 lvremove -ff $vg
 
 # remove 1 mirror from corelog'ed mirror; should retain 'core' log type
-lvcreate -aey -l2 -m2 --corelog -n $lv1 $vg
+lvcreate -aey -l2 --type mirror -m2 --corelog -n $lv1 $vg
 lvconvert -m -1 -i1 $vg/$lv1
 
 check mirror $vg $lv1 core
@@ -129,7 +129,7 @@ lvremove -ff $vg
 
 # add 1 mirror then add 1 more mirror during conversion
 # FIXME this has been explicitly forbidden?
-#lvcreate -l2 -m1 -n $lv1 $vg "$dev1" "$dev2" "$dev3":0
+#lvcreate -l2 --type mirror -m1 -n $lv1 $vg "$dev1" "$dev2" "$dev3":0
 #lvconvert -m+1 -b $vg/$lv1 "$dev4"
 #lvconvert -m+1 $vg/$lv1 "$dev5"
 #
@@ -139,7 +139,7 @@ lvremove -ff $vg
 #lvremove -ff $vg
 
 # convert inactive mirror and start polling
-lvcreate -aey -l2 -m1 -n $lv1 $vg "$dev1" "$dev2" "$dev3:$DEVRANGE"
+lvcreate -aey -l2 --type mirror -m1 -n $lv1 $vg "$dev1" "$dev2" "$dev3:$DEVRANGE"
 lvchange -an $vg/$lv1
 lvconvert -m+1 $vg/$lv1 "$dev4"
 lvchange -aey $vg/$lv1
@@ -152,7 +152,7 @@ lvremove -ff $vg
 # removal during conversion
 
 # "remove newly added mirror"
-lvcreate -aey -l2 -m1 -n $lv1 $vg "$dev1" "$dev2" "$dev3:$DEVRANGE"
+lvcreate -aey -l2 --type mirror -m1 -n $lv1 $vg "$dev1" "$dev2" "$dev3:$DEVRANGE"
 lvconvert -m+1 -b $vg/$lv1 "$dev4"
 lvconvert -m-1 $vg/$lv1 "$dev4"
 lvconvert $vg/$lv1 # wait
@@ -163,7 +163,7 @@ check mirror_legs $vg $lv1 2
 lvremove -ff $vg
 
 # "remove one of newly added mirrors"
-lvcreate -aey -l2 -m1 -n $lv1 $vg "$dev1" "$dev2" "$dev3:$DEVRANGE"
+lvcreate -aey -l2 --type mirror -m1 -n $lv1 $vg "$dev1" "$dev2" "$dev3:$DEVRANGE"
 lvconvert -m+2 -b $vg/$lv1 "$dev4" "$dev5"
 lvconvert -m-1 $vg/$lv1 "$dev4"
 lvconvert $vg/$lv1 # wait
@@ -174,7 +174,7 @@ check mirror_legs $vg $lv1 3
 lvremove -ff $vg
 
 # "remove from original mirror (the original is still mirror)"
-lvcreate -aey -l2 -m2 -n $lv1 $vg "$dev1" "$dev2" "$dev5" "$dev3:$DEVRANGE"
+lvcreate -aey -l2 --type mirror -m2 -n $lv1 $vg "$dev1" "$dev2" "$dev5" "$dev3:$DEVRANGE"
 lvconvert -m+1 -b $vg/$lv1 "$dev4"
 lvconvert -m-1 $vg/$lv1 "$dev2"
 lvconvert $vg/$lv1
@@ -185,7 +185,7 @@ check mirror_legs $vg $lv1 3
 lvremove -ff $vg
 
 # "remove from original mirror (the original becomes linear)"
-lvcreate -aey -l2 -m1 -n $lv1 $vg "$dev1" "$dev2" "$dev3:$DEVRANGE"
+lvcreate -aey -l2 --type mirror -m1 -n $lv1 $vg "$dev1" "$dev2" "$dev3:$DEVRANGE"
 lvconvert -m+1 -b $vg/$lv1 "$dev4"
 lvconvert -m-1 $vg/$lv1 "$dev2"
 lvconvert $vg/$lv1
@@ -198,14 +198,14 @@ lvremove -ff $vg
 # ---------------------------------------------------------------------
 
 # "rhbz440405: lvconvert -m0 incorrectly fails if all PEs allocated"
-lvcreate -aey -l$(pvs --noheadings -ope_count "$dev1") -m1 -n $lv1 $vg "$dev1" "$dev2" "$dev3:$DEVRANGE"
+lvcreate -aey -l$(pvs --noheadings -ope_count "$dev1") --type mirror -m1 -n $lv1 $vg "$dev1" "$dev2" "$dev3:$DEVRANGE"
 aux wait_for_sync $vg $lv1
 lvconvert -m0 $vg/$lv1 "$dev1"
 check linear $vg $lv1
 lvremove -ff $vg
 
 # "rhbz264241: lvm mirror doesn't lose it's "M" --nosync attribute after being down and the up converted"
-lvcreate -aey -l2 -m1 -n $lv1 --nosync $vg
+lvcreate -aey -l2 --type mirror -m1 -n $lv1 --nosync $vg
 lvconvert -m0 $vg/$lv1
 lvconvert -m1 $vg/$lv1
 lvs --noheadings -o attr $vg/$lv1 | grep '^ *m'
@@ -220,7 +220,7 @@ check mirror_legs $vg $lv1 2
 lvremove -ff $vg
 
 # BZ 463272: disk log mirror convert option is lost if downconvert option is also given
-lvcreate -aey -l1 -m2 --corelog -n $lv1 $vg "$dev1" "$dev2" "$dev3"
+lvcreate -aey -l1 --type mirror -m2 --corelog -n $lv1 $vg "$dev1" "$dev2" "$dev3"
 aux wait_for_sync $vg $lv1
 lvconvert -m1 --mirrorlog disk $vg/$lv1
 check mirror $vg $lv1
@@ -231,7 +231,7 @@ lvremove -ff $vg
 # add mirror and disk log
 
 # "add 1 mirror and disk log"
-lvcreate -aey -l2 -m1 --mirrorlog core -n $lv1 $vg "$dev1" "$dev2"
+lvcreate -aey -l2 --type mirror -m1 --mirrorlog core -n $lv1 $vg "$dev1" "$dev2"
 
 # FIXME on next line, specifying $dev3:0 $dev4 (i.e log device first) fails (!)
 lvconvert -m+1 --mirrorlog disk -i1 $vg/$lv1 "$dev4" "$dev3:$DEVRANGE"
@@ -264,13 +264,13 @@ lvremove -ff $vg
 
 # Should not be able to add images to --nosync mirror
 # but should be able to after 'lvchange --resync'
-lvcreate -aey -m 1 -l1 -n $lv1 $vg --nosync
+lvcreate -aey --type mirror -m 1 -l1 -n $lv1 $vg --nosync
 not lvconvert -m +1 $vg/$lv1
 lvchange -aey --resync -y $vg/$lv1
 lvconvert -m +1 $vg/$lv1
 lvremove -ff $vg
 
-lvcreate -aey -m 1 --corelog -l1 -n $lv1 $vg --nosync
+lvcreate -aey --type mirror -m 1 --corelog -l1 -n $lv1 $vg --nosync
 not lvconvert -m +1 $vg/$lv1
 lvchange -aey --resync -y $vg/$lv1
 lvconvert -m +1 $vg/$lv1
@@ -288,14 +288,14 @@ lvremove -ff $vg
 
 # bz192865: lvconvert log of an inactive mirror lv
 # convert from disklog to corelog, inactive
-lvcreate -aey -l2 -m1 -n $lv1 $vg "$dev1" "$dev2" "$dev3:0-1"
+lvcreate -aey -l2 --type mirror -m1 -n $lv1 $vg "$dev1" "$dev2" "$dev3:0-1"
 lvchange -an $vg/$lv1
 lvconvert -y -f --mirrorlog core $vg/$lv1
 check mirror $vg $lv1 core
 lvremove -ff $vg
 
 # convert from corelog to disklog, inactive
-lvcreate -aey -l2 -m1 --mirrorlog core -n $lv1 $vg "$dev1" "$dev2"
+lvcreate -aey -l2 --type mirror -m1 --mirrorlog core -n $lv1 $vg "$dev1" "$dev2"
 lvchange -an $vg/$lv1
 lvconvert --mirrorlog disk $vg/$lv1 "$dev3:0-1"
 check mirror $vg $lv1 "$dev3"
diff --git a/test/shell/lvconvert-repair-dmeventd.sh b/test/shell/lvconvert-repair-dmeventd.sh
index bde30d7..b3ccca5 100644
--- a/test/shell/lvconvert-repair-dmeventd.sh
+++ b/test/shell/lvconvert-repair-dmeventd.sh
@@ -16,7 +16,7 @@ which mkfs.ext2 || skip
 aux prepare_vg 5
 aux prepare_dmeventd
 
-lvcreate -aey -m 3 --ignoremonitoring -L 1 -n 4way $vg
+lvcreate -aey --type mirror -m 3 --ignoremonitoring -L 1 -n 4way $vg
 lvchange --monitor y $vg/4way
 aux disable_dev "$dev2" "$dev4"
 mkfs.ext2 $DM_DEV_DIR/$vg/4way
diff --git a/test/shell/lvconvert-repair-policy.sh b/test/shell/lvconvert-repair-policy.sh
index 695c27d..49afb7b 100644
--- a/test/shell/lvconvert-repair-policy.sh
+++ b/test/shell/lvconvert-repair-policy.sh
@@ -23,14 +23,14 @@ cleanup() {
 	for d in "$@"; do aux enable_dev "$d"; done
 	for d in "$@"; do vgextend $vg "$d"; done
 	lvremove -ff $vg/mirror
-	lvcreate -aey -m 1 --ignoremonitoring -l 2 -n mirror $vg "$dev1" "$dev2" "$dev3":0
+	lvcreate -aey --type mirror -m 1 --ignoremonitoring -l 2 -n mirror $vg "$dev1" "$dev2" "$dev3":0
 }
 
 repair() {
 	lvconvert --repair --use-policies --config "$1" $vg/mirror
 }
 
-lvcreate -aey -m 1 -L 1 -n mirror $vg
+lvcreate -aey --type mirror -m 1 -L 1 -n mirror $vg
 lvchange -a n $vg/mirror
 
 # Fail a leg of a mirror.
diff --git a/test/shell/lvconvert-repair-replace.sh b/test/shell/lvconvert-repair-replace.sh
index 1666b78..53c0938 100644
--- a/test/shell/lvconvert-repair-replace.sh
+++ b/test/shell/lvconvert-repair-replace.sh
@@ -17,7 +17,7 @@ aux lvmconf 'allocation/mirror_logs_require_separate_pvs = 1'
 
 # 3-way, disk log
 # multiple failures, full replace
-lvcreate -aey --mirrorlog disk -m 2 --ignoremonitoring --nosync -L 1 -n 3way $vg "$dev1" "$dev2" "$dev3" "$dev4":0-1
+lvcreate -aey --mirrorlog disk --type mirror -m 2 --ignoremonitoring --nosync -L 1 -n 3way $vg "$dev1" "$dev2" "$dev3" "$dev4":0-1
 aux disable_dev "$dev1" "$dev2"
 lvconvert -y --repair $vg/3way 2>&1 | tee 3way.out
 lvs -a -o +devices $vg | not grep unknown
@@ -30,7 +30,7 @@ vgremove -ff $vg
 # 3-way, disk log
 # multiple failures, partial replace
 vgcreate $vg "$dev1" "$dev2" "$dev3" "$dev4" "$dev5"
-lvcreate -aey --mirrorlog disk -m 2 --ignoremonitoring --nosync -L 1 -n 3way $vg "$dev1" "$dev2" "$dev3" "$dev4"
+lvcreate -aey --mirrorlog disk --type mirror -m 2 --ignoremonitoring --nosync -L 1 -n 3way $vg "$dev1" "$dev2" "$dev3" "$dev4"
 aux disable_dev "$dev1" "$dev2"
 lvconvert -y --repair $vg/3way 2>&1 | tee 3way.out
 grep "WARNING: Failed" 3way.out
@@ -41,7 +41,7 @@ aux enable_dev "$dev1" "$dev2"
 vgremove -ff $vg
 
 vgcreate $vg "$dev1" "$dev2" "$dev3"
-lvcreate -aey --mirrorlog disk -m 1 --ignoremonitoring --nosync -l 1 -n 2way $vg "$dev1" "$dev2" "$dev3"
+lvcreate -aey --mirrorlog disk --type mirror -m 1 --ignoremonitoring --nosync -l 1 -n 2way $vg "$dev1" "$dev2" "$dev3"
 aux disable_dev "$dev1"
 lvconvert -y --repair $vg/2way 2>&1 | tee 2way.out
 grep "WARNING: Failed" 2way.out
@@ -54,7 +54,7 @@ vgremove -ff $vg
 # Test repair of inactive mirror with log failure
 #  Replacement should fail, but convert should succeed (switch to corelog)
 vgcreate $vg "$dev1" "$dev2" "$dev3" "$dev4"
-lvcreate -aey -m 2 --ignoremonitoring --nosync -l 2 -n mirror2 $vg "$dev1" "$dev2" "$dev3" "$dev4":0
+lvcreate -aey --type mirror -m 2 --ignoremonitoring --nosync -l 2 -n mirror2 $vg "$dev1" "$dev2" "$dev3" "$dev4":0
 vgchange -a n $vg
 pvremove -ff -y "$dev4"
 lvconvert -y --repair $vg/mirror2
@@ -69,7 +69,7 @@ if kernel_at_least 3 0 0; then
 	# 2-way, mirrored log
 	# Double log failure, full replace
 	vgcreate $vg "$dev1" "$dev2" "$dev3" "$dev4" "$dev5" "$dev6"
-	lvcreate -aey --mirrorlog mirrored -m 1 --ignoremonitoring --nosync -L 1 -n 2way $vg \
+	lvcreate -aey --mirrorlog mirrored --type mirror -m 1 --ignoremonitoring --nosync -L 1 -n 2way $vg \
 	    "$dev1" "$dev2" "$dev3":0 "$dev4":0
 	aux disable_dev "$dev3" "$dev4"
 	lvconvert -y --repair $vg/2way 2>&1 | tee 2way.out
@@ -84,7 +84,7 @@ fi
 # 3-way, mirrored log
 # Single log failure, replace
 vgcreate $vg "$dev1" "$dev2" "$dev3" "$dev4" "$dev5" "$dev6"
-lvcreate -aey --mirrorlog mirrored -m 2 --ignoremonitoring --nosync -L 1 -n 3way $vg \
+lvcreate -aey --mirrorlog mirrored --type mirror -m 2 --ignoremonitoring --nosync -L 1 -n 3way $vg \
     "$dev1" "$dev2" "$dev3" "$dev4":0 "$dev5":0
 aux disable_dev "$dev4"
 lvconvert -y --repair $vg/3way 2>&1 | tee 3way.out
diff --git a/test/shell/lvconvert-repair-snapshot.sh b/test/shell/lvconvert-repair-snapshot.sh
index 218ec0b..29576bb 100644
--- a/test/shell/lvconvert-repair-snapshot.sh
+++ b/test/shell/lvconvert-repair-snapshot.sh
@@ -15,7 +15,7 @@ aux prepare_vg 5
 aux lvmconf 'allocation/maximise_cling = 0'
 aux lvmconf 'allocation/mirror_logs_require_separate_pvs = 1'
 
-lvcreate -aey -m 3 --ignoremonitoring -L 2M -n 4way $vg "$dev1" "$dev2" "$dev3" "$dev4" "$dev5":0
+lvcreate -aey --type mirror -m 3 --ignoremonitoring -L 2M -n 4way $vg "$dev1" "$dev2" "$dev3" "$dev4" "$dev5":0
 lvcreate -s $vg/4way -L 2M -n snap
 
 aux disable_dev "$dev2" "$dev4"
diff --git a/test/shell/lvconvert-repair-transient-dmeventd.sh b/test/shell/lvconvert-repair-transient-dmeventd.sh
index 835c6b4..51c95e1 100644
--- a/test/shell/lvconvert-repair-transient-dmeventd.sh
+++ b/test/shell/lvconvert-repair-transient-dmeventd.sh
@@ -14,7 +14,7 @@
 aux prepare_vg 5
 aux prepare_dmeventd
 
-lvcreate -aey -m 3 --ignoremonitoring -L 1 -n 4way $vg
+lvcreate -aey --type mirror -m 3 --ignoremonitoring -L 1 -n 4way $vg
 lvchange --monitor y $vg/4way
 aux disable_dev "$dev2" "$dev4"
 mkfs.ext3 $DM_DEV_DIR/$vg/4way
diff --git a/test/shell/lvconvert-repair-transient.sh b/test/shell/lvconvert-repair-transient.sh
index a87bdb3..93eb803 100644
--- a/test/shell/lvconvert-repair-transient.sh
+++ b/test/shell/lvconvert-repair-transient.sh
@@ -13,7 +13,7 @@
 
 aux prepare_vg 5
 
-lvcreate -aey -m 3 --ignoremonitoring -L 1 -n 4way $vg
+lvcreate -aey --type mirror -m 3 --ignoremonitoring -L 1 -n 4way $vg
 aux disable_dev "$dev2" "$dev4"
 mkfs.ext3 $DM_DEV_DIR/$vg/4way &
 sleep 1
diff --git a/test/shell/lvconvert-repair.sh b/test/shell/lvconvert-repair.sh
index 0113ec4..a3c46b1 100644
--- a/test/shell/lvconvert-repair.sh
+++ b/test/shell/lvconvert-repair.sh
@@ -33,7 +33,7 @@ aux lvmconf 'allocation/mirror_logs_require_separate_pvs = 1'
 
 # 4-way, disk log => 2-way, disk log
 aux prepare_vg 8
-lvcreate -aey -m 3 --ignoremonitoring -L 1 -n 4way $vg "$dev1" "$dev2" "$dev3" "$dev4" "$dev5":0
+lvcreate -aey --type mirror -m 3 --ignoremonitoring -L 1 -n 4way $vg "$dev1" "$dev2" "$dev3" "$dev4" "$dev5":0
 aux disable_dev "$dev2" "$dev4"
 echo n | lvconvert --repair $vg/4way 2>&1 | tee 4way.out
 lvs -a -o +devices $vg | not grep unknown
@@ -43,7 +43,7 @@ check mirror $vg 4way "$dev5"
 
 # 3-way, disk log => linear
 recreate_vg_
-lvcreate -aey -m 2 --ignoremonitoring -L 1 -n 3way $vg
+lvcreate -aey --type mirror -m 2 --ignoremonitoring -L 1 -n 3way $vg
 aux disable_dev "$dev1" "$dev2"
 echo n | lvconvert --repair $vg/3way
 check linear $vg 3way
@@ -56,7 +56,7 @@ check linear $vg 3way
 
 # 3-way, disk log => 3-way, core log
 recreate_vg_
-lvcreate -aey -m 2 --ignoremonitoring -L 1 -n 3way $vg "$dev1" "$dev2" "$dev3" "$dev4":0
+lvcreate -aey --type mirror -m 2 --ignoremonitoring -L 1 -n 3way $vg "$dev1" "$dev2" "$dev3" "$dev4":0
 aux disable_dev "$dev4"
 echo n | lvconvert --repair $vg/3way
 check mirror $vg 3way core
@@ -66,7 +66,7 @@ aux enable_dev "$dev4"
 
 # 3-way, mirrored log => 3-way, core log
 recreate_vg_ -c n
-lvcreate -aey -m 2 --mirrorlog mirrored --ignoremonitoring -L 1 -n 3way $vg \
+lvcreate -aey --type mirror -m 2 --mirrorlog mirrored --ignoremonitoring -L 1 -n 3way $vg \
     "$dev1" "$dev2" "$dev3" "$dev4":0 "$dev5":0
 aux disable_dev "$dev4" "$dev5"
 echo n | lvconvert --repair $vg/3way
@@ -77,7 +77,7 @@ aux enable_dev "$dev4" "$dev5"
 
 # 2-way, disk log => 2-way, core log
 recreate_vg_
-lvcreate -aey -m 1 --ignoremonitoring -L 1 -n 2way $vg "$dev1" "$dev2" "$dev3":0
+lvcreate -aey --type mirror -m 1 --ignoremonitoring -L 1 -n 2way $vg "$dev1" "$dev2" "$dev3":0
 aux disable_dev "$dev3"
 echo n | lvconvert --repair $vg/2way
 check mirror $vg 2way core
@@ -90,7 +90,7 @@ aux enable_dev "$dev3"
 recreate_vg_
 vgreduce $vg "$dev4"
 
-lvcreate -aey -m 1 --ignoremonitoring -L 1 -n mirror $vg
+lvcreate -aey --type mirror -m 1 --ignoremonitoring -L 1 -n mirror $vg
 lvchange -a n $vg/mirror
 vgextend $vg "$dev4"
 aux disable_dev "$dev1"
diff --git a/test/shell/lvconvert-thin.sh b/test/shell/lvconvert-thin.sh
index 3cbfd2c..f1e2176 100644
--- a/test/shell/lvconvert-thin.sh
+++ b/test/shell/lvconvert-thin.sh
@@ -35,8 +35,8 @@ pvcreate "$DM_DEV_DIR/$vg1/$lv"
 vgcreate $vg -s 64K $(cut -d ' ' -f 4 DEVICES) "$DM_DEV_DIR/$vg1/$lv"
 
 # create mirrored LVs for data and metadata volumes
-lvcreate -aey -L10M -m1 --mirrorlog core -n $lv1 $vg
-lvcreate -aey -L8M -m1 --mirrorlog core -n $lv2 $vg
+lvcreate -aey -L10M --type mirror -m1 --mirrorlog core -n $lv1 $vg
+lvcreate -aey -L8M --type mirror -m1 --mirrorlog core -n $lv2 $vg
 lvchange -an $vg/$lv1
 
 
diff --git a/test/shell/lvconvert-twostep.sh b/test/shell/lvconvert-twostep.sh
index e785a22..8417e6a 100644
--- a/test/shell/lvconvert-twostep.sh
+++ b/test/shell/lvconvert-twostep.sh
@@ -13,7 +13,7 @@
 
 aux prepare_vg 4
 
-lvcreate -aey -m 1 --mirrorlog disk --ignoremonitoring -L 1 -n mirror $vg
+lvcreate -aey --type mirror -m 1 --mirrorlog disk --ignoremonitoring -L 1 -n mirror $vg
 not lvconvert -m 2 --mirrorlog core $vg/mirror "$dev3" 2>&1 | tee errs
 grep "two steps" errs
 
diff --git a/test/shell/lvcreate-mirror.sh b/test/shell/lvcreate-mirror.sh
index c286445..7826800 100644
--- a/test/shell/lvcreate-mirror.sh
+++ b/test/shell/lvcreate-mirror.sh
@@ -15,22 +15,22 @@ aux lvmconf 'allocation/maximise_cling = 0'
 aux lvmconf 'allocation/mirror_logs_require_separate_pvs = 1'
 
 # 2-way mirror with corelog, 2 PVs
-lvcreate -aey -l2 -m1 --mirrorlog core -n $lv1 $vg "$dev1" "$dev2"
+lvcreate -aey -l2 --type mirror -m1 --mirrorlog core -n $lv1 $vg "$dev1" "$dev2"
 check mirror_images_redundant $vg $lv1
 
 # 2-way mirror with disklog, 3 PVs
 # lvcreate --nosync is in 100% sync after creation (bz429342)
-lvcreate -aey -l2 -m1 --nosync -n $lv2 $vg "$dev1" "$dev2" "$dev3":0-1 2>&1 | tee out
+lvcreate -aey -l2 --type mirror -m1 --nosync -n $lv2 $vg "$dev1" "$dev2" "$dev3":0-1 2>&1 | tee out
 grep "New mirror won't be synchronised." out
 check lv_field $vg/$lv2 copy_percent "100.00"
 check mirror_images_redundant $vg $lv2
 check mirror_log_on $vg $lv2 "$dev3"
 
 # 3-way mirror with disklog, 4 PVs
-lvcreate -aey -l2 -m2 --nosync --mirrorlog disk -n $lv3 $vg "$dev1" "$dev2" "$dev4" "$dev3":0-1
+lvcreate -aey -l2 --type mirror -m2 --nosync --mirrorlog disk -n $lv3 $vg "$dev1" "$dev2" "$dev4" "$dev3":0-1
 check mirror_images_redundant $vg $lv3
 check mirror_log_on $vg $lv3 "$dev3"
 lvremove -ff $vg
 
 # creating 2-way mirror with disklog from 2 PVs fails
-not lvcreate -aey -l2 -m1 -n $lv1 $vg "$dev1" "$dev2"
+not lvcreate -aey -l2 --type mirror -m1 -n $lv1 $vg "$dev1" "$dev2"
diff --git a/test/shell/lvcreate-operation.sh b/test/shell/lvcreate-operation.sh
index fa02cd5..6fc20b6 100644
--- a/test/shell/lvcreate-operation.sh
+++ b/test/shell/lvcreate-operation.sh
@@ -35,10 +35,10 @@ test -e LOCAL_CLVMD && exit 0
 
 # ---
 # Create mirror on two devices with mirrored log using --alloc anywhere
-lvcreate -m 1 -l4 -n $lv1 --mirrorlog mirrored $vg --alloc anywhere "$dev1" "$dev2"
+lvcreate --type mirror -m 1 -l4 -n $lv1 --mirrorlog mirrored $vg --alloc anywhere "$dev1" "$dev2"
 cleanup_lvs
 
 # --
 # Create mirror on one dev with mirrored log using --alloc anywhere, should fail
-not lvcreate -m 1 -l4 -n $lv1 --mirrorlog mirrored $vg --alloc anywhere "$dev1"
+not lvcreate --type mirror -m 1 -l4 -n $lv1 --mirrorlog mirrored $vg --alloc anywhere "$dev1"
 cleanup_lvs
diff --git a/test/shell/lvcreate-pvtags.sh b/test/shell/lvcreate-pvtags.sh
index 6daf794..20a241c 100644
--- a/test/shell/lvcreate-pvtags.sh
+++ b/test/shell/lvcreate-pvtags.sh
@@ -31,18 +31,18 @@ not lvcreate -l4 -i4 $vg @fast
 not lvcreate -l2 -i2 $vg $DM_DEV_DIR/mapper/pv1
 
 # lvcreate mirror
-lvcreate -aey -l1 -m1 $vg @fast
+lvcreate -aey -l1 --type mirror -m1 $vg @fast
 
 # lvcreate mirror w/corelog
-lvcreate -aey -l1 -m2 --corelog $vg @fast
+lvcreate -aey -l1 --type mirror -m2 --corelog $vg @fast
 
 # lvcreate mirror w/no free PVs
-not lvcreate -aey -l1 -m2 $vg @fast
+not lvcreate -aey -l1 --type mirror -m2 $vg @fast
 
 # lvcreate mirror (corelog, w/no free PVs)
-not lvcreate -aey -l1 -m3 --corelog $vg @fast
+not lvcreate -aey -l1 --type mirror -m3 --corelog $vg @fast
 
 # lvcreate mirror with a single PV arg
-not lvcreate -aey -l1 -m1 --corelog $vg "$dev1"
+not lvcreate -aey -l1 --type mirror -m1 --corelog $vg "$dev1"
 
 vgremove -ff $vg
diff --git a/test/shell/lvcreate-striped-mirror.sh b/test/shell/lvcreate-striped-mirror.sh
index 16ea465..f02c658 100644
--- a/test/shell/lvcreate-striped-mirror.sh
+++ b/test/shell/lvcreate-striped-mirror.sh
@@ -13,43 +13,43 @@
 
 aux prepare_vg 9
 
-lvcreate -aey --nosync -i2 -l2 -m1 --mirrorlog core -n $lv1 $vg 2>&1 | tee log
+lvcreate -aey --nosync -i2 -l2 --type mirror -m1 --mirrorlog core -n $lv1 $vg 2>&1 | tee log
 not grep "Rounding" log
 check mirror_images_redundant $vg $lv1
 
-lvcreate -aey --nosync -i2 -l4 -m1 --mirrorlog core -n $lv2 $vg 2>&1 | tee log
+lvcreate -aey --nosync -i2 -l4 --type mirror -m1 --mirrorlog core -n $lv2 $vg 2>&1 | tee log
 not grep "Rounding" log
 check mirror_images_redundant $vg $lv2
 
-lvcreate -aey --nosync -i3 -l3 -m1 --mirrorlog core -n $lv3 $vg 2>&1 | tee log
+lvcreate -aey --nosync -i3 -l3 --type mirror -m1 --mirrorlog core -n $lv3 $vg 2>&1 | tee log
 not grep "Rounding" log
 check mirror_images_redundant $vg $lv3
 
-lvcreate -aey --nosync -i4 -l4 -m1 --mirrorlog core -n $lv4 $vg 2>&1 | tee log
+lvcreate -aey --nosync -i4 -l4 --type mirror -m1 --mirrorlog core -n $lv4 $vg 2>&1 | tee log
 not grep "Rounding" log
 check mirror_images_redundant $vg $lv4
 
-lvcreate -aey --nosync -i2 -l2 -m2 --mirrorlog core -n $lv5 $vg 2>&1 | tee log
+lvcreate -aey --nosync -i2 -l2 --type mirror -m2 --mirrorlog core -n $lv5 $vg 2>&1 | tee log
 not grep "Rounding" log
 check mirror_images_redundant $vg $lv5
 
-lvcreate -aey --nosync -i3 -l3 -m2 --mirrorlog core -n $lv6 $vg 2>&1 | tee log
+lvcreate -aey --nosync -i3 -l3 --type mirror -m2 --mirrorlog core -n $lv6 $vg 2>&1 | tee log
 not grep "Rounding" log
 check mirror_images_redundant $vg $lv6
 
-lvcreate -aey --nosync -i2 -l2 -m3 --mirrorlog core -n $lv7 $vg 2>&1 | tee log
+lvcreate -aey --nosync -i2 -l2 --type mirror -m3 --mirrorlog core -n $lv7 $vg 2>&1 | tee log
 not grep "Rounding" log
 check mirror_images_redundant $vg $lv7
 
 lvremove -ff $vg
 
-lvcreate -aey --nosync -i3 -l4 -m1 --mirrorlog core -n $lv1 $vg 2>&1 | tee log
+lvcreate -aey --nosync -i3 -l4 --type mirror -m1 --mirrorlog core -n $lv1 $vg 2>&1 | tee log
 grep "Rounding size (4 extents) up to .* (6 extents)" log
 
-lvcreate -aey --nosync -i3 -l4 -m2 --mirrorlog core -n $lv2 $vg 2>&1 | tee log
+lvcreate -aey --nosync -i3 -l4 --type mirror -m2 --mirrorlog core -n $lv2 $vg 2>&1 | tee log
 grep "Rounding size (4 extents) up to .* (6 extents)" log
 
-lvcreate -aey --nosync -i3 -l2 -m2 --mirrorlog core -n $lv3 $vg 2>&1 | tee log
+lvcreate -aey --nosync -i3 -l2 --type mirror -m2 --mirrorlog core -n $lv3 $vg 2>&1 | tee log
 grep "Rounding size (2 extents) up to .* (3 extents)" log
 
 lvremove -ff $vg
diff --git a/test/shell/lvcreate-thin.sh b/test/shell/lvcreate-thin.sh
index 2ae02ab..743da3b 100644
--- a/test/shell/lvcreate-thin.sh
+++ b/test/shell/lvcreate-thin.sh
@@ -176,7 +176,7 @@ lvcreate -L4M -V2G --name lv1 -T $vg/pool1
 # Origin name is not accepted
 not lvcreate -s $vg/lv1 -L4M -V2G --name $vg/lv4
 
-# Check we cannot create mirror and thin or thinpool together
+# Check we cannot create mirror/raid1 and thin or thinpool together
 not lvcreate -T mirpool -L4M --alloc anywhere -m1 $vg
 not lvcreate --thinpool mirpool -L4M --alloc anywhere -m1 $vg
 
diff --git a/test/shell/lvcreate-usage.sh b/test/shell/lvcreate-usage.sh
index c9c906a..68a15a9 100644
--- a/test/shell/lvcreate-usage.sh
+++ b/test/shell/lvcreate-usage.sh
@@ -68,13 +68,13 @@ lvremove -ff $vg/$lv3
 lvchange -an $vg/$lv1
 lvcreate -l1 -s -n $lv3 $vg/$lv1
 not lvcreate -l1 -n $lv4 $vg
-not lvcreate -l1 -m1 -n $lv4 $vg
+not lvcreate -l1 --type mirror -m1 -n $lv4 $vg
 
 lvremove -ff $vg/$lv3
-lvcreate -l1 -m1 -n $lv3 $vg
+lvcreate -l1 --type mirror -m1 -n $lv3 $vg
 vgs -o +max_lv $vg
 not lvcreate -l1 -n $lv4 $vg
-not lvcreate -l1 -m1 -n $lv4 $vg
+not lvcreate -l1 --type mirror -m1 -n $lv4 $vg
 
 lvconvert -m0 $vg/$lv3
 lvconvert -m2 -i 1 $vg/$lv3
@@ -111,10 +111,10 @@ not lvcreate -L 32m -n $lv -R0 $vg 2>err
 grep "Non-zero region size must be supplied." err
 not lvcreate -L 32m -n $lv -R 11k $vg
 not lvcreate -L 32m -n $lv -R 1k $vg
-lvcreate -L 32m -n $lv --regionsize 128m  -m 1 $vg
+lvcreate -L 32m -n $lv --regionsize 128m  --type mirror -m 1 $vg
 check lv_field $vg/$lv regionsize "32.00m"
 lvremove -ff $vg
-lvcreate -L 32m -n $lv --regionsize 4m -m 1 $vg
+lvcreate -L 32m -n $lv --regionsize 4m --type mirror -m 1 $vg
 check lv_field $vg/$lv regionsize "4.00m"
 lvremove -ff $vg
 
diff --git a/test/shell/lvresize-mirror.sh b/test/shell/lvresize-mirror.sh
index 1aeb4b8..68f0ff8 100644
--- a/test/shell/lvresize-mirror.sh
+++ b/test/shell/lvresize-mirror.sh
@@ -16,7 +16,7 @@ aux prepare_vg 5
 for deactivate in true false; do
 
 # extend 2-way mirror
-	lvcreate -aye -l2 -m1 -n $lv1 $vg "$dev1" "$dev2" "$dev3":0-1
+	lvcreate -aye -l2 --type mirror -m1 -n $lv1 $vg "$dev1" "$dev2" "$dev3":0-1
 
 	test $deactivate && lvchange -an $vg/$lv1
 
@@ -29,7 +29,7 @@ for deactivate in true false; do
 	check mirror $vg $lv1 "$dev3"
 
 # extend 2-way mirror (cling if not contiguous)
-	lvcreate -aye -l2 -m1 -n $lv2 $vg "$dev1" "$dev2" "$dev3":0-1
+	lvcreate -aye -l2 --type mirror -m1 -n $lv2 $vg "$dev1" "$dev2" "$dev3":0-1
 	lvcreate -l1 -n $lv3 $vg "$dev1"
 	lvcreate -l1 -n $lv4 $vg "$dev2"
 
diff --git a/test/shell/metadata.sh b/test/shell/metadata.sh
index 5109bf3..b02e74a 100644
--- a/test/shell/metadata.sh
+++ b/test/shell/metadata.sh
@@ -35,7 +35,7 @@ for mdacp in 1 0; do
 	pvcreate "$dev1"
 	vgcreate $vg $(cat DEVICES)
 	lvcreate -n $lv1 -l 2 -i5 -I256 $vg
-	lvcreate -aey -n $lv2 -m2 -l 2  $vg
+	lvcreate -aey -n $lv2 --type mirror -m2 -l 2  $vg
 	lvchange -an $vg/$lv1 $vg/$lv2
 	vgchange -aey $vg
 	lvchange -an $vg/$lv1 $vg/$lv2
diff --git a/test/shell/mirror-names.sh b/test/shell/mirror-names.sh
index d8f711f..de70f43 100644
--- a/test/shell/mirror-names.sh
+++ b/test/shell/mirror-names.sh
@@ -63,7 +63,7 @@ check_and_cleanup_lvs_
 #COMM "init: lvcreate"
 
 #COMM "mirror images are ${lv1}_mimage_x"
-lvcreate -an -Zn -l2 -m1 -n $lv1 $vg
+lvcreate -an -Zn -l2 --type mirror -m1 -n $lv1 $vg
 lv_devices_ $vg/$lv1 ${lv1}_mimage_0 ${lv1}_mimage_1
 
 #COMM "mirror log is ${lv1}_mlog"
@@ -74,7 +74,7 @@ check_and_cleanup_lvs_
 
 #COMM "mirror with name longer than 22 characters (bz221322)"
 name="LVwithanamelogerthan22characters_butidontwonttocounthem"
-lvcreate -an -Zn -m1 -l2 -n $name $vg
+lvcreate -an -Zn --type mirror -m1 -l2 -n $name $vg
 lvs $vg/$name
 check_and_cleanup_lvs_
 
@@ -84,7 +84,7 @@ check_and_cleanup_lvs_
 #COMM "init: lvrename"
 
 #COMM "renamed mirror names: $lv1 to $lv2"
-lvcreate -an -Zn -l2 -m1 -n $lv1 $vg
+lvcreate -an -Zn -l2 --type mirror -m1 -n $lv1 $vg
 lvrename $vg/$lv1 $vg/$lv2
 lv_devices_ $vg/$lv2 ${lv2}_mimage_0 ${lv2}_mimage_1
 lv_mirror_log_ $vg/$lv2 ${lv2}_mlog
@@ -98,7 +98,7 @@ check_and_cleanup_lvs_
 #COMM "init: lvconvert"
 
 #COMM "converting mirror names is ${lv1}_mimagetmp_2"
-lvcreate -aey -l2 -m1 -n $lv1 $vg
+lvcreate -aey -l2 --type mirror -m1 -n $lv1 $vg
 lvconvert -m+1 -i+40 -b $vg/$lv1
 convlv=$(lv_convert_lv_ $vg/$lv1)
 test $convlv = ${lv1}_mimagetmp_2
diff --git a/test/shell/mirror-vgreduce-removemissing.sh b/test/shell/mirror-vgreduce-removemissing.sh
index 02d6c1c..05a8acd 100644
--- a/test/shell/mirror-vgreduce-removemissing.sh
+++ b/test/shell/mirror-vgreduce-removemissing.sh
@@ -125,7 +125,7 @@ check_and_cleanup_lvs_
 
 #COMM "basic: fail the 2nd mirror image of 2-way mirrored LV"
 prepare_lvs_
-lvcreate -an -Zn -l2 -m1 --nosync -n $lv1 $vg "$dev1" "$dev2" "$dev3":$BLOCKS
+lvcreate -an -Zn -l2 --type mirror -m1 --nosync -n $lv1 $vg "$dev1" "$dev2" "$dev3":$BLOCKS
 mimages_are_on_ $lv1 $dev1 $dev2
 mirrorlog_is_on_ $lv1 $dev3
 aux disable_dev "$dev2"
@@ -145,7 +145,7 @@ test_3way_mirror_fail_1_()
 {
 	local index=$1
 
-	lvcreate -an -Zn -l2 -m2 --nosync -n $lv1 $vg "$dev1" "$dev2" "$dev3" "$dev4":$BLOCKS
+	lvcreate -an -Zn -l2 --type mirror -m2 --nosync -n $lv1 $vg "$dev1" "$dev2" "$dev3" "$dev4":$BLOCKS
 	mimages_are_on_ $lv1 "$dev1" "$dev2" "$dev3"
 	mirrorlog_is_on_ $lv1 "$dev4"
 	eval aux disable_dev \$dev$index
@@ -170,7 +170,7 @@ test_3way_mirror_fail_2_()
 {
 	local index=$1
 
-	lvcreate -an -Zn -l2 -m2 --nosync -n $lv1 $vg "$dev1" "$dev2" "$dev3" "$dev4":$BLOCKS
+	lvcreate -an -Zn -l2 --type mirror -m2 --nosync -n $lv1 $vg "$dev1" "$dev2" "$dev3" "$dev4":$BLOCKS
 	mimages_are_on_ $lv1 "$dev1" "$dev2" "$dev3"
 	mirrorlog_is_on_ $lv1 "$dev4"
 	rest_pvs_ $index 3
@@ -196,7 +196,7 @@ test_3way_mirror_plus_1_fail_1_()
 {
 	local index=$1
 
-	lvcreate -an -Zn -l2 -m2 -n $lv1 $vg "$dev1" "$dev2" "$dev3" "$dev5":$BLOCKS
+	lvcreate -an -Zn -l2 --type mirror -m2 -n $lv1 $vg "$dev1" "$dev2" "$dev3" "$dev5":$BLOCKS
 	lvconvert -m+1 $vg/$lv1 "$dev4"
 	check mirror_images_on $vg $lv1 "$dev1" "$dev2" "$dev3" "$dev4"
 	check mirror_log_on $vg $lv1 "$dev5"
@@ -224,7 +224,7 @@ test_3way_mirror_plus_1_fail_3_()
 {
 	local index=$1
 
-	lvcreate -an -Zn -l2 -m2 -n $lv1 $vg "$dev1" "$dev2" "$dev3" "$dev5":$BLOCKS
+	lvcreate -an -Zn -l2 --type mirror -m2 -n $lv1 $vg "$dev1" "$dev2" "$dev3" "$dev5":$BLOCKS
 	lvconvert -m+1 $vg/$lv1 "$dev4"
 	check mirror_images_on $vg $lv1 "$dev1" "$dev2" "$dev3" "$dev4"
 	check mirror_log_on $vg $lv1 "$dev5"
@@ -253,7 +253,7 @@ test_2way_mirror_plus_2_fail_1_()
 {
 	local index=$1
 
-	lvcreate -an -Zn -l2 -m1 -n $lv1 $vg "$dev1" "$dev2" "$dev5":$BLOCKS
+	lvcreate -an -Zn -l2 --type mirror -m1 -n $lv1 $vg "$dev1" "$dev2" "$dev5":$BLOCKS
 	lvconvert -m+2 $vg/$lv1 "$dev3" "$dev4"
 	mimages_are_on_ $lv1 "$dev1" "$dev2" "$dev3" "$dev4"
 	mirrorlog_is_on_ $lv1 "$dev5"
@@ -279,7 +279,7 @@ test_2way_mirror_plus_2_fail_3_()
 {
 	local index=$1
 
-	lvcreate -an -Zn -l2 -m1 -n $lv1 $vg "$dev1" "$dev2" "$dev5":$BLOCKS
+	lvcreate -an -Zn -l2 --type mirror -m1 -n $lv1 $vg "$dev1" "$dev2" "$dev5":$BLOCKS
 	lvconvert -m+2 $vg/$lv1 "$dev3" "$dev4"
 	mimages_are_on_ $lv1 "$dev1" "$dev2" "$dev3" "$dev4"
 	mirrorlog_is_on_ $lv1 "$dev5"
@@ -303,7 +303,7 @@ done
 
 #COMM "fail mirror log of 2-way mirrored LV"
 prepare_lvs_
-lvcreate -aey -l2 -m1 -n $lv1 $vg "$dev1" "$dev2" "$dev5":$BLOCKS
+lvcreate -aey -l2 --type mirror -m1 -n $lv1 $vg "$dev1" "$dev2" "$dev5":$BLOCKS
 mimages_are_on_ $lv1 "$dev1" "$dev2"
 mirrorlog_is_on_ $lv1 "$dev5"
 aux disable_dev "$dev5"
@@ -314,7 +314,7 @@ recover_vg_ "$dev5"
 
 #COMM "fail mirror log of 3-way (1 converting) mirrored LV"
 prepare_lvs_
-lvcreate -aey -l2 -m1 -n $lv1 $vg "$dev1" "$dev2" "$dev5":$BLOCKS
+lvcreate -aey -l2 --type mirror -m1 -n $lv1 $vg "$dev1" "$dev2" "$dev5":$BLOCKS
 lvconvert -m+1 $vg/$lv1 "$dev3"
 mimages_are_on_ $lv1 "$dev1" "$dev2" "$dev3"
 mirrorlog_is_on_ $lv1 "$dev5"
@@ -329,7 +329,7 @@ recover_vg_ "$dev5"
 
 #COMM "fail all mirror images of 2-way mirrored LV"
 prepare_lvs_
-lvcreate -an -Zn -l2 -m1 --nosync -n $lv1 $vg "$dev1" "$dev2" "$dev5":$BLOCKS
+lvcreate -an -Zn -l2 --type mirror -m1 --nosync -n $lv1 $vg "$dev1" "$dev2" "$dev5":$BLOCKS
 mimages_are_on_ $lv1 "$dev1" "$dev2"
 mirrorlog_is_on_ $lv1 "$dev5"
 aux disable_dev "$dev1" "$dev2"
@@ -339,7 +339,7 @@ recover_vg_ "$dev1" "$dev2"
 
 #COMM "fail all mirror images of 3-way (1 converting) mirrored LV"
 prepare_lvs_
-lvcreate -an -Zn -l2 -m1 -n $lv1 $vg "$dev1" "$dev2" "$dev5":$BLOCKS
+lvcreate -an -Zn -l2 --type mirror -m1 -n $lv1 $vg "$dev1" "$dev2" "$dev5":$BLOCKS
 lvconvert -m+1 $vg/$lv1 "$dev3"
 mimages_are_on_ $lv1 "$dev1" "$dev2" "$dev3"
 mirrorlog_is_on_ $lv1 "$dev5"
@@ -353,8 +353,8 @@ recover_vg_ "$dev1" "$dev2" "$dev3"
 
 #COMM "fail a mirror image of one of mirrored LV"
 prepare_lvs_
-lvcreate -an -Zn -l2 -m1 --nosync -n $lv1 $vg "$dev1" "$dev2" "$dev5":$BLOCKS
-lvcreate -an -Zn -l2 -m1 --nosync -n $lv2 $vg "$dev3" "$dev4" "$dev5":$BLOCKS1
+lvcreate -an -Zn -l2 --type mirror -m1 --nosync -n $lv1 $vg "$dev1" "$dev2" "$dev5":$BLOCKS
+lvcreate -an -Zn -l2 --type mirror -m1 --nosync -n $lv2 $vg "$dev3" "$dev4" "$dev5":$BLOCKS1
 mimages_are_on_ $lv1 "$dev1" "$dev2"
 mimages_are_on_ $lv2 "$dev3" "$dev4"
 mirrorlog_is_on_ $lv1 "$dev5"
@@ -369,8 +369,8 @@ recover_vg_ "$dev2"
 
 #COMM "fail mirror images, one for each mirrored LV"
 prepare_lvs_
-lvcreate -an -Zn -l2 -m1 --nosync -n $lv1 $vg "$dev1" "$dev2" "$dev5":$BLOCKS
-lvcreate -an -Zn -l2 -m1 --nosync -n $lv2 $vg "$dev3" "$dev4" "$dev5":$BLOCKS1
+lvcreate -an -Zn -l2 --type mirror -m1 --nosync -n $lv1 $vg "$dev1" "$dev2" "$dev5":$BLOCKS
+lvcreate -an -Zn -l2 --type mirror -m1 --nosync -n $lv2 $vg "$dev3" "$dev4" "$dev5":$BLOCKS1
 mimages_are_on_ $lv1 "$dev1" "$dev2"
 mimages_are_on_ $lv2 "$dev3" "$dev4"
 mirrorlog_is_on_ $lv1 "$dev5"
@@ -389,7 +389,7 @@ recover_vg_ "$dev2" "$dev4"
 
 #COMM "no failures"
 prepare_lvs_
-lvcreate -an -Zn -l2 -m1 --nosync -n $lv1 $vg "$dev1" "$dev2" "$dev5":$BLOCKS
+lvcreate -an -Zn -l2 --type mirror -m1 --nosync -n $lv1 $vg "$dev1" "$dev2" "$dev5":$BLOCKS
 mimages_are_on_ $lv1 "$dev1" "$dev2"
 mirrorlog_is_on_ $lv1 "$dev5"
 vgreduce --removemissing --force $vg
diff --git a/test/shell/nomda-missing.sh b/test/shell/nomda-missing.sh
index 4fc91c7..946eecd 100644
--- a/test/shell/nomda-missing.sh
+++ b/test/shell/nomda-missing.sh
@@ -24,8 +24,8 @@ lvcreate -l2 -n linear12 $vg "$dev1":4 "$dev2":4
 lvcreate -aey -l1 -n origin1 $vg "$dev1"
 lvcreate -s $vg/origin1 -l1 -n s_napshot2 "$dev2"
 
-lvcreate -aey -l1 -m1 -n mirror12 --mirrorlog core $vg "$dev1" "$dev2"
-lvcreate -aey -l1 -m1 -n mirror123 $vg "$dev1" "$dev2" "$dev3"
+lvcreate -aey -l1 --type mirror -m1 -n mirror12 --mirrorlog core $vg "$dev1" "$dev2"
+lvcreate -aey -l1 --type mirror -m1 -n mirror123 $vg "$dev1" "$dev2" "$dev3"
 
 vgchange -a n $vg
 aux disable_dev "$dev1"
diff --git a/test/shell/nomda-restoremissing.sh b/test/shell/nomda-restoremissing.sh
index 98c5df9..eb2e624 100644
--- a/test/shell/nomda-restoremissing.sh
+++ b/test/shell/nomda-restoremissing.sh
@@ -15,7 +15,7 @@ aux prepare_vg 3
 
 pvchange --metadataignore y $dev1
 
-lvcreate -aey -m 1 -l 1 -n mirror $vg
+lvcreate -aey --type mirror -m 1 -l 1 -n mirror $vg
 lvchange -a n $vg/mirror
 lvcreate -l 1 -n lv1 $vg "$dev1"
 
@@ -25,7 +25,7 @@ aux disable_dev "$dev1"
 lvremove $vg/mirror
 not vgck $vg 2>&1 | tee log
 grep "missing 1 physical volume" log
-not lvcreate -aey -m 1 -l 1 -n mirror $vg # write operations fail
+not lvcreate -aey --type mirror -m 1 -l 1 -n mirror $vg # write operations fail
 aux enable_dev "$dev1"
-lvcreate -aey -m 1 -l 1 -n mirror $vg # no MDA => automatically restored
+lvcreate -aey --type mirror -m 1 -l 1 -n mirror $vg # no MDA => automatically restored
 vgck $vg
diff --git a/test/shell/snapshots-of-mirrors.sh b/test/shell/snapshots-of-mirrors.sh
index 3bc72bd..cfb0792 100644
--- a/test/shell/snapshots-of-mirrors.sh
+++ b/test/shell/snapshots-of-mirrors.sh
@@ -14,7 +14,7 @@
 aux prepare_vg 4
 
 # Attempt to create snapshot of a mirror origin - should fail
-lvcreate -aey -m 1 -L 10M -n lv $vg
+lvcreate -aey --type mirror -m 1 -L 10M -n lv $vg
 
 lvcreate -s $vg/lv -L 10M -n snap
 
@@ -22,10 +22,10 @@ lvcreate -s $vg/lv -L 10M -n snap
 lvconvert -m0 $vg/lv
 
 # Up-convert (linear -> mirror)
-lvconvert -m2 $vg/lv
+lvconvert --type mirror -m2 $vg/lv
 
 # Down-convert (mirror -> mirror)
-lvconvert -m1 $vg/lv
+lvconvert -m 1 $vg/lv
 
 # Up-convert (mirror -> mirror) -- Not supported!
 not lvconvert -m2 $vg/lv
diff --git a/test/shell/unknown-segment.sh b/test/shell/unknown-segment.sh
index 070c9ff..c3bba0a 100644
--- a/test/shell/unknown-segment.sh
+++ b/test/shell/unknown-segment.sh
@@ -14,7 +14,7 @@
 aux prepare_vg 4
 
 lvcreate -an -Zn -l 1 -n $lv1 $vg
-lvcreate -an -Zn -l 2 -m 1 -n $lv2 $vg
+lvcreate -an -Zn -l 2 --type mirror -m 1 -n $lv2 $vg
 
 vgcfgbackup -f bak0 $vg
 sed -e 's,striped,unstriped,;s,mirror,unmirror,' -i.orig bak0
diff --git a/test/shell/unlost-pv.sh b/test/shell/unlost-pv.sh
index 73d817c..3e74e0e 100644
--- a/test/shell/unlost-pv.sh
+++ b/test/shell/unlost-pv.sh
@@ -20,7 +20,7 @@ check_() {
 
 aux prepare_vg 3
 
-lvcreate -an -Zn -m 1 -l 1 -n mirror $vg
+lvcreate -an -Zn --type mirror -m 1 -l 1 -n mirror $vg
 #lvchange -a n $vg
 
 # try orphaning a missing PV (bz45867)
diff --git a/test/shell/vgextend-restoremissing.sh b/test/shell/vgextend-restoremissing.sh
index 1a16d45..29273ed 100644
--- a/test/shell/vgextend-restoremissing.sh
+++ b/test/shell/vgextend-restoremissing.sh
@@ -13,7 +13,7 @@
 
 aux prepare_vg 3
 
-lvcreate -an -Zn -m 1 -l 1 -n mirror $vg
+lvcreate -an -Zn --type mirror -m 1 -l 1 -n mirror $vg
 lvcreate -l 1 -n lv1 $vg "$dev1"
 
 # try to just change metadata; we expect the new version (with MISSING_PV set
@@ -23,7 +23,7 @@ lvremove $vg/mirror
 aux enable_dev "$dev1"
 not vgck $vg 2>&1 | tee log
 grep "missing 1 physical volume" log
-not lvcreate -aey -m 1 -l 1 -n mirror $vg # write operations fail
+not lvcreate -aey --type mirror -m 1 -l 1 -n mirror $vg # write operations fail
 vgextend --restore $vg "$dev1" # restore the missing device
 vgck $vg
-lvcreate -an -Zn -m 1 -l 1 -n mirror $vg
+lvcreate -an -Zn --type mirror -m 1 -l 1 -n mirror $vg
diff --git a/test/shell/vgmerge-operation.sh b/test/shell/vgmerge-operation.sh
index 4303aff..0c0517c 100644
--- a/test/shell/vgmerge-operation.sh
+++ b/test/shell/vgmerge-operation.sh
@@ -55,7 +55,7 @@ vgremove -f $vg2
 # 'vgmerge succeeds with mirrored LV in source VG'
 vgcreate $vg1 "$dev1" "$dev2" "$dev3"
 vgcreate $vg2 "$dev4"
-lvcreate -aey -l 4 -n $lv1 -m1 $vg1
+lvcreate -aey -l 4 -n $lv1 --type mirror -m1 $vg1
 vgchange -an $vg1
 check pvlv_counts $vg1 3 1 0
 check pvlv_counts $vg2 1 0 0
diff --git a/test/shell/vgreduce-removemissing-snapshot.sh b/test/shell/vgreduce-removemissing-snapshot.sh
index 488d8fe..3f24c7f 100644
--- a/test/shell/vgreduce-removemissing-snapshot.sh
+++ b/test/shell/vgreduce-removemissing-snapshot.sh
@@ -21,7 +21,7 @@ exit 0
 
 aux prepare_vg 5
 
-lvcreate -m 3 --ig -L 2M -n 4way $vg "$dev1" "$dev2" "$dev3" "$dev4" "$dev5":0
+lvcreate --type mirror -m 3 --ig -L 2M -n 4way $vg "$dev1" "$dev2" "$dev3" "$dev4" "$dev5":0
 lvcreate -s $vg/4way -L 2M -n snap
 lvcreate -i 2 -L 2M $vg "$dev1" "$dev2" -n stripe
 
diff --git a/test/shell/vgreduce-usage.sh b/test/shell/vgreduce-usage.sh
index 350e169..29475b2 100644
--- a/test/shell/vgreduce-usage.sh
+++ b/test/shell/vgreduce-usage.sh
@@ -51,7 +51,7 @@ vgremove -f $vg1
 #COMM "(lvm$mdatype) vgreduce --removemissing --force repares to linear (bz221921)"
 # (lvm$mdatype) setup: create mirror & damage one pv
 vgcreate -M$mdatype $vg1 "$dev1" "$dev2" "$dev3"
-lvcreate -aey -n $lv1 -m1 -l 4 $vg1
+lvcreate -aey -n $lv1 --type mirror -m1 -l 4 $vg1
 lvcreate -n $lv2  -l 4 $vg1 "$dev2"
 lvcreate -n $lv3 -l 4 $vg1 "$dev3"
 vgchange -an $vg1
@@ -70,7 +70,7 @@ not vgs $vg1 # just double-check it's really gone
 # (lvm$mdatype) setup: create mirror + linear lvs
 vgcreate -M$mdatype $vg1 $(cat DEVICES)
 lvcreate -n $lv2 -l 4 $vg1
-lvcreate -aey -m1 -n $lv1 -l 4 $vg1 "$dev1" "$dev2" "$dev3"
+lvcreate -aey --type mirror -m1 -n $lv1 -l 4 $vg1 "$dev1" "$dev2" "$dev3"
 lvcreate -n $lv3 -l 4 $vg1 "$dev3"
 pvs --segments -o +lv_name $(cat DEVICES) # for record only
 # (lvm$mdatype) setup: damage one pv
diff --git a/test/shell/vgsplit-operation.sh b/test/shell/vgsplit-operation.sh
index 01a8aa8..4c9e6f1 100644
--- a/test/shell/vgsplit-operation.sh
+++ b/test/shell/vgsplit-operation.sh
@@ -77,7 +77,7 @@ COMM "vgsplit correctly splits mirror LV into $i VG ($j args)"
 		create_vg_ $vg1 "$dev1" "$dev2" "$dev3"
 		test $i = existing && create_vg_ $vg2 "$dev4"
 
-		lvcreate -an -Zn -l 64 -m1 -n $lv1 $vg1 "$dev1" "$dev2" "$dev3"
+		lvcreate -an -Zn -l 64 --type mirror -m1 -n $lv1 $vg1 "$dev1" "$dev2" "$dev3"
 		if [ $j = PV ]; then
 		  vgsplit $vg1 $vg2 "$dev1" "$dev2" "$dev3"
 		else
@@ -96,7 +96,7 @@ COMM "vgsplit correctly splits mirror LV with mirrored log into $i VG ($j args)"
 		create_vg_ -c n $vg1 "$dev1" "$dev2" "$dev3" "$dev4"
 		test $i = existing && create_vg_ -c n $vg2 "$dev5"
 
-		lvcreate -an -Zn -l 64 --mirrorlog mirrored -m1 -n $lv1 $vg1 \
+		lvcreate -an -Zn -l 64 --mirrorlog mirrored --type mirror -m1 -n $lv1 $vg1 \
 		    "$dev1" "$dev2" "$dev3" "$dev4"
 
 		if [ $j = PV ]; then
@@ -163,7 +163,7 @@ COMM "vgsplit correctly splits linear LV but not mirror LV into $i VG ($j args)"
 		create_vg_ $vg1 "$dev1" "$dev2" "$dev3"
 		test $i = existing && create_vg_ $vg2 "$dev5"
 
-		lvcreate -an -Zn -l 64 -m1 -n $lv1 $vg1 "$dev1" "$dev2" "$dev3"
+		lvcreate -an -Zn -l 64 --type mirror -m1 -n $lv1 $vg1 "$dev1" "$dev2" "$dev3"
 		vgextend $vg1 "$dev4"
 		lvcreate -an -Zn -l 64 -n $lv2 $vg1 "$dev4"
 		if [ $j = PV ]; then
@@ -221,14 +221,14 @@ vgremove -f $vg1
 
 COMM "vgsplit fails splitting one mirror LV, only one PV specified"
 create_vg_ $vg1 "$dev1" "$dev2" "$dev3" "$dev4"
-lvcreate -an -Zn -l 16 -n $lv1 -m1 $vg1 "$dev1" "$dev2" "$dev3"
+lvcreate -an -Zn -l 16 -n $lv1 --type mirror -m1 $vg1 "$dev1" "$dev2" "$dev3"
 check pvlv_counts $vg1 4 1 0
 not vgsplit $vg1 $vg2 "$dev2"
 vgremove -ff $vg1
 
 COMM "vgsplit fails splitting 1 mirror + 1 striped LV, only striped LV specified"
 create_vg_ $vg1 "$dev1" "$dev2" "$dev3" "$dev4"
-lvcreate -an -Zn -l 16 -n $lv1 -m1 $vg1 "$dev1" "$dev2" "$dev3"
+lvcreate -an -Zn -l 16 -n $lv1 --type mirror -m1 $vg1 "$dev1" "$dev2" "$dev3"
 lvcreate -an -Zn -l 16 -n $lv2 -i 2 $vg1 "$dev3" "$dev4"
 check pvlv_counts $vg1 4 2 0
 not vgsplit -n $lv2 $vg1 $vg2 2>err
@@ -239,7 +239,7 @@ vgremove -f $vg1
 #
 COMM "vgsplit fails, active mirror involved in split"
 create_vg_ $vg1 "$dev1" "$dev2" "$dev3" "$dev4"
-lvcreate -aey -l 16 -n $lv1 -m1 $vg1 "$dev1" "$dev2" "$dev3"
+lvcreate -aey -l 16 -n $lv1 --type mirror -m1 $vg1 "$dev1" "$dev2" "$dev3"
 lvcreate -l 16 -n $lv2 $vg1 "$dev4"
 lvchange -an $vg1/$lv2
 check pvlv_counts $vg1 4 2 0
@@ -249,7 +249,7 @@ vgremove -f $vg1
 
 COMM "vgsplit succeeds, active mirror not involved in split"
 create_vg_ $vg1 "$dev1" "$dev2" "$dev3" "$dev4"
-lvcreate -aey -l 16 -n $lv1 -m1 $vg1 "$dev1" "$dev2" "$dev3"
+lvcreate -aey -l 16 -n $lv1 --type mirror -m1 $vg1 "$dev1" "$dev2" "$dev3"
 lvcreate -l 16 -n $lv2 $vg1 "$dev4"
 lvchange -an $vg1/$lv2
 check pvlv_counts $vg1 4 2 0


