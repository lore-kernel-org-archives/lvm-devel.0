From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 19 Jun 2015 14:33:49 +0000 (UTC)
Subject: master - tests: external origin updates
Message-ID: <20150619143349.BED5B60DEA@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b45e9183bc276da207c62072726b973e3d6a429c
Commit:        b45e9183bc276da207c62072726b973e3d6a429c
Parent:        00d028fd7739ea1f4a49f1f3df6ce1dfb7188fe0
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jun 19 16:26:18 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jun 19 16:33:29 2015 +0200

tests: external origin updates

Update test for recent updates to support unalligned sizes
and extension of reduced volume.
---
 test/shell/lvconvert-thin-external.sh       |    2 ++
 test/shell/lvresize-thin-external-origin.sh |   10 +++++++---
 2 files changed, 9 insertions(+), 3 deletions(-)

diff --git a/test/shell/lvconvert-thin-external.sh b/test/shell/lvconvert-thin-external.sh
index eba9e36..479d23c 100644
--- a/test/shell/lvconvert-thin-external.sh
+++ b/test/shell/lvconvert-thin-external.sh
@@ -57,6 +57,8 @@ lvcreate -l10 -T $vg/pool1 -c 192k
 not lvconvert -T --thinpool $vg/pool1 $vg/pool --originname origin
 # Create pool1 chunk_size unaligned LV and check failing conversion
 lvcreate -l2 -n $lv1 $vg
+# Newer thin-pool target (>= 1.13) supports unaligned external origin
+aux lvmconf 'global/thin_disabled_features = [ "external_origin_extend" ]'
 not lvconvert -T --thinpool $vg/pool1 $vg/$lv1
 
 lvremove -f $vg/pool1 $vg/$lv1
diff --git a/test/shell/lvresize-thin-external-origin.sh b/test/shell/lvresize-thin-external-origin.sh
index 66de5f8..090cb06 100644
--- a/test/shell/lvresize-thin-external-origin.sh
+++ b/test/shell/lvresize-thin-external-origin.sh
@@ -20,7 +20,7 @@ test -e LOCAL_LVMPOLLD && skip
 aux have_thin 1 2 0 || skip
 
 # Pretend we miss the external_origin_extend feature
-aux lvmconf "global/thin_disabled_features = [ \"external_origin_extend\" ]"
+aux lvmconf 'global/thin_disabled_features = [ "external_origin_extend" ]'
 
 aux prepare_pvs 2
 
@@ -41,7 +41,11 @@ not lvresize -L+10 $vg/$lv1
 
 # But reduction works
 lvresize -L-5 -f $vg/$lv1
+check lv_field $vg/$lv1 lv_size "5.00" --units m --nosuffix
+
 not lvresize -L+15 -y $vg/$lv1
+check lv_field $vg/$lv1 lv_size "5.00" --units m --nosuffix
+
 # Try to resize again back up to the size of external origin
-# But for now we do not support zeroing for rexetended areas.
-not lvresize -L+5 -f $vg/$lv1
+lvresize -L+5 -f $vg/$lv1
+check lv_field $vg/$lv1 lv_size "10.00" --units m --nosuffix


