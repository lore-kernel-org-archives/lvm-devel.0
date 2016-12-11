From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sun, 11 Dec 2016 22:35:04 +0000 (UTC)
Subject: master - tests: test should clean devices it has created
Message-ID: <20161211223504.52A6F60C86@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=bcf59a1b185c07a3f7e10f9de13e83501f9a852b
Commit:        bcf59a1b185c07a3f7e10f9de13e83501f9a852b
Parent:        198f335139f7a538272c8cb6657ad4f5d58b01db
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Dec 11 10:18:44 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun Dec 11 23:24:19 2016 +0100

tests: test should clean devices it has created

To be able to detect lvm2 command is not leaking some
'unexpected' device - remove all devices before
test exits by its own command so test teardown
now can check what was 'left' unexpectedly.
---
 test/api/lvtest.sh                          |    2 ++
 test/shell/error-usage.sh                   |    2 ++
 test/shell/lvconvert-thin.sh                |    3 +--
 test/shell/lvconvert-twostep.sh             |    3 ++-
 test/shell/lvcreate-small-snap.sh           |    2 ++
 test/shell/lvextend-percent-extents.sh      |    2 ++
 test/shell/lvresize-thin-external-origin.sh |    2 ++
 test/shell/lvs-cache.sh                     |    2 ++
 test/shell/mdata-strings.sh                 |    2 ++
 test/shell/nomda-missing.sh                 |    2 ++
 test/shell/nomda-restoremissing.sh          |    2 ++
 test/shell/profiles-thin.sh                 |    2 ++
 test/shell/profiles.sh                      |    2 ++
 test/shell/pv-range-overflow.sh             |    1 +
 test/shell/select-report.sh                 |    2 ++
 test/shell/vgcfgbackup-lvm1.sh              |    2 +-
 test/shell/zero-usage.sh                    |    2 ++
 17 files changed, 31 insertions(+), 4 deletions(-)

diff --git a/test/api/lvtest.sh b/test/api/lvtest.sh
index f34f0f8..8cba14c 100644
--- a/test/api/lvtest.sh
+++ b/test/api/lvtest.sh
@@ -21,3 +21,5 @@ lvcreate -n test -l 5 $vg
 aux apitest lvtest $vg
 
 check lv_field $vg/test lv_name test
+
+vgremove -ff $vg
diff --git a/test/shell/error-usage.sh b/test/shell/error-usage.sh
index 531dad3..1f03071 100644
--- a/test/shell/error-usage.sh
+++ b/test/shell/error-usage.sh
@@ -32,3 +32,5 @@ check lv_field $vg/$lv1 seg_size_pe "8"   # 8 * 256
 
 # FIXME should we print info we are ignoring stripping?
 lvextend -L+1 -I64 -i2 $vg/$lv1
+
+vgremove -ff $vg
diff --git a/test/shell/lvconvert-thin.sh b/test/shell/lvconvert-thin.sh
index 1999d86..4bd1acd 100644
--- a/test/shell/lvconvert-thin.sh
+++ b/test/shell/lvconvert-thin.sh
@@ -149,6 +149,5 @@ fail lvconvert --yes --type snapshot $vg/$lv1 $vg/$lv2
 fail lvconvert --yes --type snapshot $vg/$lv2 $vg/$lv1
 fail lvconvert --yes --type thin-pool $vg/$lv1
 
-lvremove -f $vg
-
 vgremove -ff $vg
+vgremove -ff $vg1
diff --git a/test/shell/lvconvert-twostep.sh b/test/shell/lvconvert-twostep.sh
index f202ae2..9c54756 100644
--- a/test/shell/lvconvert-twostep.sh
+++ b/test/shell/lvconvert-twostep.sh
@@ -24,9 +24,10 @@ lvconvert --mirrorlog core $vg/mirror
 not lvconvert -m 1 --mirrorlog disk $vg/mirror "$dev3" 2>&1 | tee errs
 grep "two steps" errs
 
-test -e LOCAL_CLVMD && exit 0
+if test ! -e LOCAL_CLVMD ; then
 # FIXME  mirrored unsupported in cluster
 not lvconvert -m 1 --mirrorlog mirrored $vg/mirror "$dev3" "$dev4" 2>&1 | tee errs
 grep "two steps" errs
+fi
 
 vgremove -ff $vg
diff --git a/test/shell/lvcreate-small-snap.sh b/test/shell/lvcreate-small-snap.sh
index 43424de..d7b5104 100644
--- a/test/shell/lvcreate-small-snap.sh
+++ b/test/shell/lvcreate-small-snap.sh
@@ -32,3 +32,5 @@ grep "smaller" lvcreate.out
 not lvcreate -s -l 4 -n snapB $vg/one 2>&1 | tee lvcreate.out
 not grep "suspend origin one" lvcreate.out
 grep "smaller" lvcreate.out
+
+vgremove -ff $vg
diff --git a/test/shell/lvextend-percent-extents.sh b/test/shell/lvextend-percent-extents.sh
index 67c36b2..56932a7 100644
--- a/test/shell/lvextend-percent-extents.sh
+++ b/test/shell/lvextend-percent-extents.sh
@@ -108,3 +108,5 @@ lvremove -f $vg/$lv
 lvcreate -i2 -I 64k -l10 -n $lv $vg
 lvreduce -f -l1 $vg/$lv
 check lv_field $vg/$lv lv_size "8.00m"
+
+vgremove -ff $vg
diff --git a/test/shell/lvresize-thin-external-origin.sh b/test/shell/lvresize-thin-external-origin.sh
index b864b81..c1ebffe 100644
--- a/test/shell/lvresize-thin-external-origin.sh
+++ b/test/shell/lvresize-thin-external-origin.sh
@@ -50,3 +50,5 @@ check lv_field $vg/$lv1 lv_size "5.00" --units m --nosuffix
 # Try to resize again back up to the size of external origin
 lvresize -L+5 -f $vg/$lv1
 check lv_field $vg/$lv1 lv_size "10.00" --units m --nosuffix
+
+vgremove -ff $vg
diff --git a/test/shell/lvs-cache.sh b/test/shell/lvs-cache.sh
index 74077ae..f2463b8 100644
--- a/test/shell/lvs-cache.sh
+++ b/test/shell/lvs-cache.sh
@@ -88,3 +88,5 @@ lvremove -f $vg
 
 lvcreate -n foo -l 1 $vg
 lvs -a -S 'cache_policy=undefined' | grep foo
+
+vgremove -ff $vg
diff --git a/test/shell/mdata-strings.sh b/test/shell/mdata-strings.sh
index d3e831f..5d22953 100644
--- a/test/shell/mdata-strings.sh
+++ b/test/shell/mdata-strings.sh
@@ -45,3 +45,5 @@ vgcreate $vg "$created"
 # 'no parse errors and VG really exists'
 vgs $vg 2>err
 not grep "Parse error" err
+
+dmsetup remove "${PREFIX}${pv_ugly}"
diff --git a/test/shell/nomda-missing.sh b/test/shell/nomda-missing.sh
index f9c394e..9fe4bec 100644
--- a/test/shell/nomda-missing.sh
+++ b/test/shell/nomda-missing.sh
@@ -84,3 +84,5 @@ check active $vg linear2
 check active $vg linear12
 check active $vg mirror12
 check active $vg mirror123
+
+vgremove -ff $vg
diff --git a/test/shell/nomda-restoremissing.sh b/test/shell/nomda-restoremissing.sh
index e0d1da0..811637b 100644
--- a/test/shell/nomda-restoremissing.sh
+++ b/test/shell/nomda-restoremissing.sh
@@ -32,3 +32,5 @@ not lvcreate -aey --type mirror -m 1 -l 1 -n mirror $vg # write operations fail
 aux enable_dev "$dev1"
 lvcreate -aey --type mirror -m 1 -l 1 -n mirror $vg # no MDA => automatically restored
 vgck $vg
+
+vgremove -ff $vg
diff --git a/test/shell/profiles-thin.sh b/test/shell/profiles-thin.sh
index 6b8bc6a..d97bf59 100644
--- a/test/shell/profiles-thin.sh
+++ b/test/shell/profiles-thin.sh
@@ -74,3 +74,5 @@ check vg_field $vg profile "thin-performance"
 check lv_field $vg/pool_performance_inherited profile ""
 $SHOULD check lv_field $vg/pool_performance_inherited chunk_size 1.00m
 check lv_field $vg/pool_performance_inherited zero ""
+
+vgremove -ff $vg
diff --git a/test/shell/profiles.sh b/test/shell/profiles.sh
index 562b7b1..508f6db 100644
--- a/test/shell/profiles.sh
+++ b/test/shell/profiles.sh
@@ -131,3 +131,5 @@ lvm dumpconfig --type profilable-command --file etc/profile/generated.profile
 pvs --profile generated &> msg
 not grep "$MSG_NOT_PROFILABLE" msg
 not grep "$MSG_IGNORING_INVALID_CMD_PROFILE" msg
+
+vgremove -ff $vg1
diff --git a/test/shell/pv-range-overflow.sh b/test/shell/pv-range-overflow.sh
index 37fd659..2d80f4e 100644
--- a/test/shell/pv-range-overflow.sh
+++ b/test/shell/pv-range-overflow.sh
@@ -32,3 +32,4 @@ grep "Logical volume bogus not found." err
 # 'run the offending pvmove command'
 not pvmove -v -n$lv "$dev1":4294967296 "$dev2"
 
+vgremove -ff $vg
diff --git a/test/shell/select-report.sh b/test/shell/select-report.sh
index b39ce54..aad3857 100644
--- a/test/shell/select-report.sh
+++ b/test/shell/select-report.sh
@@ -218,3 +218,5 @@ sel lv '(lv_name=vol1 || lv_name=vol2) && lv_size < 8m' vol2
 sel lv '(lv_name=vol1 && lv_size=8m) && vg_tags=vg_tag2' vol1
 # negation of clause grouped by ( )
 sel lv '!(lv_name=vol1 || lv_name=vol2)' abc xyz orig snap
+
+vgremove -ff $vg1 $vg2 $vg3
diff --git a/test/shell/vgcfgbackup-lvm1.sh b/test/shell/vgcfgbackup-lvm1.sh
index 4a7f32a..f3c7ab4 100644
--- a/test/shell/vgcfgbackup-lvm1.sh
+++ b/test/shell/vgcfgbackup-lvm1.sh
@@ -30,7 +30,7 @@ vgcreate -M1 -c n $vg $(cat DEVICES)
 lvcreate -l1 -n $lv1 $vg "$dev1"
 pvremove -ff -y "$dev2"
 not lvcreate -l1 -n $lv1 $vg "$dev3"
+lvchange -an $vg
 vgcfgbackup -f "backup.$$" $vg
 
 fi
-
diff --git a/test/shell/zero-usage.sh b/test/shell/zero-usage.sh
index ee91bda..768df28 100644
--- a/test/shell/zero-usage.sh
+++ b/test/shell/zero-usage.sh
@@ -35,3 +35,5 @@ check lv_field $vg/$lv1 lv_modules "zero"
 check lv_field $vg/$lv1 segtype "zero"
 check lv_field $vg/$lv1 seg_count "1"
 check lv_field $vg/$lv1 seg_size_pe "8"   # 8 * 256
+
+vgremove -ff $vg


