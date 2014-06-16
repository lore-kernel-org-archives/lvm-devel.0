From: Jonathan Brassow <jbrassow@fedoraproject.org>
Date: Mon, 16 Jun 2014 23:15:52 +0000 (UTC)
Subject: master - cache: Properly rename origin LV tree when adding "_corig"
Message-ID: <20140616231552.BD22E6023A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=962a40b98134417f27e89709625ba2ec662204c2
Commit:        962a40b98134417f27e89709625ba2ec662204c2
Parent:        fea8abe56ae506e8c924a317cd701e159aab824c
Author:        Jonathan Brassow <jbrassow@redhat.com>
AuthorDate:    Mon Jun 16 18:15:39 2014 -0500
Committer:     Jonathan Brassow <jbrassow@redhat.com>
CommitterDate: Mon Jun 16 18:15:39 2014 -0500

cache: Properly rename origin LV tree when adding "_corig"

When creating a cache LV with a RAID origin, we need to ensure that
the sub-LVs of that origin properly change their names to include
the "_corig" extention of the top-level LV.  We do this by first
performing a 'lv_rename_update' before making the call to
'insert_layer_for_lv'.
---
 WHATS_NEW                     |    1 +
 lib/metadata/cache_manip.c    |   19 ++++++++++++++++-
 test/shell/lvconvert-cache.sh |   44 +++++++++++++++++++++++++++++++++++++++++
 test/shell/lvcreate-cache.sh  |   16 ++++++++++----
 4 files changed, 74 insertions(+), 6 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index dcde550..5d83a66 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.107 - 
 ==================================
+  When converting RAID origin to cache LV, properly rename sub-LVs.
   Use RemoveOnStop for lvm2-lvmetad.socket systemd unit.
   Add thin-generic configuration profile for generic thin settings.
   Fix crash when reporting of empty labels on pvs.
diff --git a/lib/metadata/cache_manip.c b/lib/metadata/cache_manip.c
index 0e2569c..456bc86 100644
--- a/lib/metadata/cache_manip.c
+++ b/lib/metadata/cache_manip.c
@@ -91,6 +91,8 @@ struct logical_volume *lv_cache_create(struct logical_volume *pool,
 	struct cmd_context *cmd = pool->vg->cmd;
 	struct logical_volume *cache_lv;
 	struct lv_segment *seg;
+	int origin_name_len = strlen(origin->name);
+	char origin_name[origin_name_len + 7]; /* + "_corig" and NULL */
 
 	if (!lv_is_cache_pool(pool)) {
 		log_error(INTERNAL_ERROR
@@ -122,8 +124,23 @@ struct logical_volume *lv_cache_create(struct logical_volume *pool,
 	if (!(segtype = get_segtype_from_string(cmd, "cache")))
 		return_NULL;
 
+	/*
+	 * insert_layer_for_lv does not rename the sub-LVs when adding
+	 * the suffix.  So, we rename everything here and then change
+	 * only the top-level LV back before adding the layer.
+	 */
+	sprintf(origin_name, "%s_corig", origin->name);
+	if (!lv_rename_update(cmd, origin, origin_name, 0)) {
+		log_error("Failed to rename origin LV, %s", origin->name);
+		return NULL;
+	}
+
+	origin_name[origin_name_len] = '\0';
+	if (!(origin->name = dm_pool_strdup(origin->vg->vgmem, origin_name)))
+		return_0;
+
 	cache_lv = origin;
-	if (!insert_layer_for_lv(cmd, cache_lv, CACHE, "_corig"))
+	if (!(origin = insert_layer_for_lv(cmd, cache_lv, CACHE, "_corig")))
 		return_NULL;
 
 	seg = first_seg(cache_lv);
diff --git a/test/shell/lvconvert-cache.sh b/test/shell/lvconvert-cache.sh
new file mode 100644
index 0000000..79d5fd1
--- /dev/null
+++ b/test/shell/lvconvert-cache.sh
@@ -0,0 +1,44 @@
+#!/bin/sh
+# Copyright (C) 2014 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+. lib/inittest
+
+aux have_cache 1 3 0 || skip
+
+aux prepare_vg 5 80
+
+# lvcreate origin, lvcreate cache-pool, and lvconvert to cache
+lvcreate -l 2 -n $lv1 $vg
+lvcreate --type cache-pool -l 1 -n ${lv1}_cachepool $vg
+lvconvert --type cache --cachepool $vg/${lv1}_cachepool $vg/$lv1
+dmsetup table ${vg}-$lv1 | grep cache  # ensure it is loaded in kernel
+lvremove -ff $vg
+
+# Bug 1095843
+# lvcreate RAID1 origin, lvcreate cache-pool, and lvconvert to cache
+lvcreate --type raid1 -m 1 -l 2 -n $lv1 $vg
+lvcreate --type cache-pool -l 1 -n ${lv1}_cachepool $vg
+lvconvert --type cache --cachepool $vg/${lv1}_cachepool $vg/$lv1
+lvs -a $vg/${lv1}_corig_rimage_0        # ensure images are properly renamed
+dmsetup table ${vg}-$lv1 | grep cache   # ensure it is loaded in kernel
+lvremove -ff $vg
+
+# lvcreate RAID1 origin, lvcreate RAID1 cache-pool, and lvconvert to cache
+lvcreate --type raid1 -m 1 -l 2 -n $lv1 $vg
+lvcreate --type raid1 -m 1 -l 2 -n ${lv1}_cachepool $vg
+lvconvert --type cache-pool --yes $vg/${lv1}_cachepool
+#should lvs -a $vg/${lv1}_cdata_rimage_0  # ensure images are properly renamed
+lvconvert --type cache --cachepool $vg/${lv1}_cachepool $vg/$lv1
+lvs -a $vg/${lv1}_corig_rimage_0        # ensure images are properly renamed
+dmsetup table ${vg}-$lv1 | grep cache   # ensure it is loaded in kernel
+lvremove -ff $vg
+
+vgremove -f $vg
diff --git a/test/shell/lvcreate-cache.sh b/test/shell/lvcreate-cache.sh
index c4b4a75..4274897 100644
--- a/test/shell/lvcreate-cache.sh
+++ b/test/shell/lvcreate-cache.sh
@@ -69,14 +69,20 @@ lvremove -f $vg/cache_pool
 #lvcreate -H -l 2 $vg/cache_pool -n $lv1
 #lvremove -f $vg
 
-if [ 1 -eq 0 ]; then
+# Bug 1110026
 # Create origin, then cache_pool and cache
-# FIXME: This case needs to use lvconvert
 lvcreate -l 2 -n $lv1 $vg
-lvconvert --type cache -l 1 $vg/$lv1 $mode
-dmsetup table ${vg}-$lv1 | grep cache  # ensure it is loaded in kernel
+lvcreate --type cache -l 1 $vg/$lv1
+#should dmsetup table ${vg}-$lv1 | grep cache  # ensure it is loaded in kernel
+lvremove -ff $vg
+
+# Bug 1110026 & Bug 1095843
+# Create RAID1 origin, then cache_pool and cache
+lvcreate -l 2 -n $lv1 $vg
+lvcreate --type cache -l 1 $vg/$lv1
+#should lvs -a $vg/${lv1}_corig_rimage_0        # ensure images are properly renamed
+#should dmsetup table ${vg}-$lv1 | grep cache  # ensure it is loaded in kernel
 lvremove -ff $vg
-fi
 
 # Shorthand CLI (origin exists, create cache_pool and cache)
 #lvcreate -l 1 -n $lv1 $vg


