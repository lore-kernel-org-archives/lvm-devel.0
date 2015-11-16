From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 16 Nov 2015 00:16:53 +0000 (UTC)
Subject: master - cache: handle older metadata format
Message-ID: <20151116001653.8FF086063F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e31f4b76f470c7da7328d16551cfaba9cae4674a
Commit:        e31f4b76f470c7da7328d16551cfaba9cae4674a
Parent:        d9295410e98e32636d3bf03ee375c5739bd44b23
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Nov 15 20:03:08 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Nov 16 01:12:57 2015 +0100

cache: handle older metadata format

When reading older lvm2 metadata for cache-pool - we now handle more
extended syntax - basically we want to enter most setting when
actually creating cached LV.

For this new validation code has been added. However older metadata
without new settings set is now found as invalid.

Fix it by adding default settings for  cache policy  mq
and cache mode  writethrough.
---
 WHATS_NEW                        |    1 +
 lib/cache_segtype/cache.c        |   34 +++++++++++++++++++++++++++++++
 test/shell/lvchange-cache-old.sh |   41 ++++++++++++++++++++++++++++++++++++++
 3 files changed, 76 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 2dea99c..d5a4a3b 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.135 - 
 ====================================
+  Fix reading of old metadata with missing cache policy or mode settings.
   Issue error if external_device_info_source=udev and udev db record incomplete.
   Fix passing of 32bit values through daemons (mostly lvmlockd).
   Use local memory pool for whole alloc_handle manipulation.
diff --git a/lib/cache_segtype/cache.c b/lib/cache_segtype/cache.c
index 733c330..033cabe 100644
--- a/lib/cache_segtype/cache.c
+++ b/lib/cache_segtype/cache.c
@@ -34,6 +34,32 @@ static unsigned _feature_mask;
         log_error(t " segment %s of logical volume %s.", ## p,	\
                   dm_config_parent_name(sn), seg->lv->name), 0;
 
+/*
+ * When older metadata are loaded without newer settings,
+ * set then to default settings (the one that could have been
+ * used implicitely at that time).
+ *
+ * Needs both segments cache and cache_pool to be loaded.
+ */
+static int _fix_missing_defaults(struct lv_segment *cpool_seg)
+{
+	if (!cpool_seg->policy_name) {
+		cpool_seg->policy_name = "mq";
+		log_verbose("Cache is missing cache policy, using %s.",
+			    cpool_seg->policy_name);
+	}
+
+	if (!cache_mode_is_set(cpool_seg)) {
+		if (!cache_set_mode(cpool_seg, "writethrough")) {
+			log_error(INTERNAL_ERROR "Failed to writethrough cache mode.");
+			return 0;
+		}
+		log_verbose("Cache is missing cache mode, using %s.",
+			    get_cache_mode_name(cpool_seg));
+	}
+
+	return 1;
+}
 
 static int _cache_pool_text_import(struct lv_segment *seg,
 				   const struct dm_config_node *sn,
@@ -115,6 +141,10 @@ static int _cache_pool_text_import(struct lv_segment *seg,
 	if (!attach_pool_metadata_lv(seg, meta_lv))
 		return_0;
 
+	if (!dm_list_empty(&seg->lv->segs_using_this_lv) &&
+	    !_fix_missing_defaults(seg))
+		return_0;
+
 	return 1;
 }
 
@@ -319,6 +349,10 @@ static int _cache_text_import(struct lv_segment *seg,
 	if (!attach_pool_lv(seg, pool_lv, NULL, NULL))
 		return_0;
 
+	if (!dm_list_empty(&pool_lv->segments) &&
+	    !_fix_missing_defaults(first_seg(pool_lv)))
+		return_0;
+
 	return 1;
 }
 
diff --git a/test/shell/lvchange-cache-old.sh b/test/shell/lvchange-cache-old.sh
new file mode 100644
index 0000000..0b6ef7c
--- /dev/null
+++ b/test/shell/lvchange-cache-old.sh
@@ -0,0 +1,41 @@
+#!/bin/sh
+# Copyright (C) 2015 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+# Exercise usage of older metadata which are missing some new settings
+
+SKIP_WITH_LVMPOLLD=1
+
+. lib/inittest
+
+aux have_cache 1 3 0 || skip
+
+# FIXME: parallel cache metadata allocator is crashing when used value 8000!
+aux prepare_vg 5 80
+
+
+lvcreate -l 10 --type cache-pool $vg/cpool
+lvcreate -l 20 -H -n $lv1 $vg/cpool
+
+vgcfgbackup -f backup $vg
+
+# check metadata without cache policy
+lvchange -an $vg
+grep -v "policy =" backup >backup_1
+vgcfgrestore -f backup_1 $vg
+lvchange -ay $vg
+
+# check metadata without cache mode
+lvchange -an $vg
+grep -v "cache_mode =" backup >backup_2
+vgcfgrestore -f backup_2 $vg
+lvchange -ay $vg
+
+vgremove -ff $vg


