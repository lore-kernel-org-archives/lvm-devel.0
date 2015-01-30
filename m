From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 30 Jan 2015 11:35:13 +0000 (UTC)
Subject: master - lv_manip: add for_each_sub_lv_except_pools()
Message-ID: <20150130113513.29800611CC@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=2e35c681222c18980ea818951bf41199f895ccda
Commit:        2e35c681222c18980ea818951bf41199f895ccda
Parent:        c35503e0f74968224e71d79b4359d32af5bdea93
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jan 30 12:27:49 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jan 30 12:33:52 2015 +0100

lv_manip: add for_each_sub_lv_except_pools()

for_each_sub_lv() now scans in depth also pools, however for
rename we actually do want to skip pools.

So add a new for_each_sub_lv_except_pools() to be used by rename,
every other user of for_each_sub_lv() scans every sub LV with pools
included.

This is i.e. necessary for properly working preload of pools
that are using raid arrays.
---
 WHATS_NEW               |    1 +
 lib/metadata/lv_manip.c |   29 +++++++++++++++++++++++++----
 lib/metadata/metadata.h |    3 +++
 3 files changed, 29 insertions(+), 4 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 474cd24..401c8b9 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.116 - 
 ====================================
+  Scan pools in for_each_sub_lv() and add for_each_sub_lv_except_pools().
   Fix lvm2app lvm_lv_get_property return value for fields with info/status ioctl.
   Fix lvm2app regression in lvm_lv_get_attr causing unknown values (2.02.115).
   Set default cache_mode to writehrough when missing in metadata.
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 8a3b779..0fcf7c2 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -3883,9 +3883,9 @@ static int _rename_cb(struct logical_volume *lv, void *data)
  * Loop down sub LVs and call fn for each.
  * fn is responsible to log necessary information on failure.
  */
-int for_each_sub_lv(struct logical_volume *lv,
-		    int (*fn)(struct logical_volume *lv, void *data),
-		    void *data)
+static int _for_each_sub_lv(struct logical_volume *lv, int skip_pools,
+			    int (*fn)(struct logical_volume *lv, void *data),
+			    void *data)
 {
 	struct logical_volume *org;
 	struct lv_segment *seg;
@@ -3913,6 +3913,13 @@ int for_each_sub_lv(struct logical_volume *lv,
 				return_0;
 		}
 
+		if (seg->pool_lv && !skip_pools) {
+			if (!fn(seg->pool_lv, data))
+				return_0;
+			if (!for_each_sub_lv(seg->pool_lv, fn, data))
+				return_0;
+		}
+
 		for (s = 0; s < seg->area_count; s++) {
 			if (seg_type(seg, s) != AREA_LV)
 				continue;
@@ -3939,6 +3946,20 @@ int for_each_sub_lv(struct logical_volume *lv,
 	return 1;
 }
 
+int for_each_sub_lv(struct logical_volume *lv,
+		    int (*fn)(struct logical_volume *lv, void *data),
+		    void *data)
+{
+	return _for_each_sub_lv(lv, 0, fn, data);
+}
+
+int for_each_sub_lv_except_pools(struct logical_volume *lv,
+				 int (*fn)(struct logical_volume *lv, void *data),
+				 void *data)
+{
+	return _for_each_sub_lv(lv, 1, fn, data);
+}
+
 /*
  * Core of LV renaming routine.
  * VG must be locked by caller.
@@ -3975,7 +3996,7 @@ int lv_rename_update(struct cmd_context *cmd, struct logical_volume *lv,
 	}
 
 	/* rename sub LVs */
-	if (!for_each_sub_lv(lv, _rename_cb, (void *) &lv_names))
+	if (!for_each_sub_lv_except_pools(lv, _rename_cb, (void *) &lv_names))
 		return_0;
 
 	/* rename main LV */
diff --git a/lib/metadata/metadata.h b/lib/metadata/metadata.h
index 48c1b3c..f8a11c9 100644
--- a/lib/metadata/metadata.h
+++ b/lib/metadata/metadata.h
@@ -430,6 +430,9 @@ int lv_split_segment(struct logical_volume *lv, uint32_t le);
 int add_seg_to_segs_using_this_lv(struct logical_volume *lv, struct lv_segment *seg);
 int remove_seg_from_segs_using_this_lv(struct logical_volume *lv, struct lv_segment *seg);
 
+int for_each_sub_lv_except_pools(struct logical_volume *lv,
+				 int (*fn)(struct logical_volume *lv, void *data),
+				 void *data);
 int for_each_sub_lv(struct logical_volume *lv,
                     int (*fn)(struct logical_volume *lv, void *data),
                     void *data);


