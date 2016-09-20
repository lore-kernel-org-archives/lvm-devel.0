From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 20 Sep 2016 12:34:29 +0000 (UTC)
Subject: master - cache: restore reported origin field
Message-ID: <20160920123429.51C7860DAE@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=67d4b3b7f2be1e15af2d05faa97e8b56ddc9d668
Commit:        67d4b3b7f2be1e15af2d05faa97e8b56ddc9d668
Parent:        414d39085c3f248601bec4cea6ce508acfa59283
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Sep 20 14:26:11 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Sep 20 14:26:11 2016 +0200

cache: restore reported origin field

Commit 199697accff0658a11420e263c1f85fb74cd39d3 rerouted funtion
for priting cache volume origin to lvm2app app function - which
however had a bug.  So restore the original functionality
and print correct LV as cache origin LV.
---
 WHATS_NEW                    |    1 +
 lib/metadata/lv.c            |    4 ++--
 test/shell/lvcreate-cache.sh |    1 +
 3 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 924d7c5..faddb9f 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.166 - 
 =====================================
+  Fix reported origin lv field for cache volumes. (2.02.133)
   Always specify snapshot cow LV for monitoring not internal LV. (2.02.165)
   Fix lvchange --discard|--zero for active thin-pool.
   Enforce 4MiB or 25% metadata free space for thin pool operations.
diff --git a/lib/metadata/lv.c b/lib/metadata/lv.c
index 188a255..53a1044 100644
--- a/lib/metadata/lv.c
+++ b/lib/metadata/lv.c
@@ -537,8 +537,8 @@ struct logical_volume *lv_origin_lv(const struct logical_volume *lv)
 
 	if (lv_is_cow(lv))
 		origin = origin_from_cow(lv);
-	else if (lv_is_cache(lv) && first_seg(lv)->origin)
-		origin = first_seg(lv)->origin;
+	else if (lv_is_cache(lv) && !lv_is_pending_delete(lv))
+		origin = seg_lv(first_seg(lv), 0);
 	else if (lv_is_thin_volume(lv) && first_seg(lv)->origin)
 		origin = first_seg(lv)->origin;
 	else if (lv_is_thin_volume(lv) && first_seg(lv)->external_lv)
diff --git a/test/shell/lvcreate-cache.sh b/test/shell/lvcreate-cache.sh
index bed3ec2..c38549f 100644
--- a/test/shell/lvcreate-cache.sh
+++ b/test/shell/lvcreate-cache.sh
@@ -85,6 +85,7 @@ lvremove -f $vg
 lvcreate --type cache-pool  -L1 $vg/cpool
 lvcreate -H -L4 -n $lv1 $vg/cpool
 
+check lv_field $vg/$lv1 origin "[${lv1}_corig]"
 check lv_field $vg/$lv1 copy_percent "0.00"
 # there should be something present (value differs per policy version)
 test -n "$(get lv_field $vg/$lv1 data_percent)"


