From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 19 Nov 2012 13:49:10 +0000 (UTC)
Subject: master - test: testing lvconvert
Message-ID: <20121119134910.5A0D01698@hosted02.fedoraproject.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a7893ae8580d344f3f55ddb08892991edf17408f
Commit:        a7893ae8580d344f3f55ddb08892991edf17408f
Parent:        bf1cf1459f414eb1b397c21a0cdbd5acda7540f6
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Nov 19 12:31:11 2012 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Nov 19 14:38:17 2012 +0100

test: testing lvconvert

---
 test/shell/lvconvert-thin.sh |   75 ++++++++++++++++++++++++++++++++++-------
 1 files changed, 62 insertions(+), 13 deletions(-)

diff --git a/test/shell/lvconvert-thin.sh b/test/shell/lvconvert-thin.sh
index 97ccc09..f21453f 100644
--- a/test/shell/lvconvert-thin.sh
+++ b/test/shell/lvconvert-thin.sh
@@ -12,32 +12,81 @@
 
 . lib/test
 
+prepare_lvs()
+{
+	lvremove -f $vg
+	lvcreate -L10M -n $lv1 $vg
+	lvcreate -L8M -n $lv2 $vg
+}
+
 #
 # Main
 #
 aux have_thin 1 0 0 || skip
 
-aux prepare_pvs 4 64
+aux prepare_pvs 4 6400000
 
 vgcreate $vg -s 64K $(cat DEVICES)
 
 # create mirrored LVs for data and metadata volumes
-lvcreate -aey -l8 -m1 --mirrorlog core -n $lv1 $vg
-lvcreate -aey -l4 -m1 --mirrorlog core -n $lv2 $vg
+lvcreate -aey -L10M -m1 --mirrorlog core -n $lv1 $vg
+lvcreate -aey -L8M -m1 --mirrorlog core -n $lv2 $vg
+lvchange -an $vg/$lv1
+
+
+# conversion fails for internal volumes
+not lvconvert --thinpool $vg/${lv1}_mimage_0
+not lvconvert --thinpool $vg/$lv1 --poolmetadata $vg/${lv2}_mimage_0
+# can't use --readahead with --poolmetadata
+not lvconvert --thinpool $vg/$lv1 --poolmetadata $vg/$lv2 --readahead 512
+
+lvconvert --thinpool $vg/$lv1 --poolmetadata $vg/$lv2
+
+prepare_lvs
+lvconvert -c 64 --stripes 2 --thinpool $vg/$lv1 --readahead 48
+
+lvremove -f $vg
+lvcreate -L1T -n $lv1 $vg
+lvconvert -c 8M --thinpool $vg/$lv1
+
+lvremove -f $vg
+# test with bigger sizes
+lvcreate -L1T -n $lv1 $vg
+lvcreate -L8M -n $lv2 $vg
+lvcreate -L1M -n $lv3 $vg
 
-lvconvert -c 64K --thinpool $vg/$lv1 --poolmetadata $vg/$lv2
+# chunk size is bigger then size of thin pool data
+not lvconvert -c 1G --thinpool $vg/$lv3
+# stripes can't be used with poolmetadata
+not lvconvert --stripes 2 --thinpool $vg/$lv1 --poolmetadata $vg/$lv2
+# too small metadata (<2M)
+not lvconvert -c 64 --thinpool $vg/$lv1 --poolmetadata $vg/$lv3
+# too small chunk size fails
+not lvconvert -c 4 --thinpool $vg/$lv1 --poolmetadata $vg/$lv2
+# too big chunk size fails
+not lvconvert -c 2G --thinpool $vg/$lv1 --poolmetadata $vg/$lv2
+# negative chunk size fails
+not lvconvert -c -256 --thinpool $vg/$lv1 --poolmetadata $vg/$lv2
+# non power of 2 fails
+not lvconvert -c 88 --thinpool $vg/$lv1 --poolmetadata $vg/$lv2
 
-lvcreate -V10M -T $vg/$lv1 --name $lv3
+# Warning about smaller then suggested
+lvconvert -c 256 --thinpool $vg/$lv1 --poolmetadata $vg/$lv2 |& tee err
+grep "WARNING: Chunk size is smaller" err
 
-# check lvrename work properly
-lvrename $vg/$lv1  $vg/pool
-check lv_field $vg/pool name "pool"
+lvremove -f $vg
+lvcreate -L1T -n $lv1 $vg
+lvcreate -L32G -n $lv2 $vg
+# Warning about bigger then needed
+lvconvert --thinpool $vg/$lv1 --poolmetadata $vg/$lv2 |& tee err
+grep "WARNING: Maximum size" err
 
-lvrename $vg/$lv3  $vg/$lv4
-check lv_field $vg/$lv4 name "$lv4"
+lvremove -f $vg
+lvcreate -L24T -n $lv1 $vg
+# Warning about bigger then needed (24T data and 16G -> 128K chunk)
+lvconvert -c 64 --thinpool $vg/$lv1 |& tee err
+grep "WARNING: Chunk size is too small" err
 
-# not yet supported conversions
-not lvconvert -m 1 $vg/pool
-not lvconvert -m 1 $vg/$lv3
+#lvs -a -o+chunk_size,stripe_size,seg_pe_ranges
 
 vgremove -ff $vg


