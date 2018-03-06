From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 6 Mar 2018 09:46:09 -0500
Subject: master - activation: add base lv component function
Message-ID: <201803061446.w26Ek9LR026737@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=ca9cbd92c40affa5ea5597de2d0ebd18382d9dab
Commit:        ca9cbd92c40affa5ea5597de2d0ebd18382d9dab
Parent:        6481471c9d74038da457b74ef1f2b0c15931bfa8
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Feb 27 14:13:00 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Mar 6 15:42:05 2018 +0100

activation: add base lv component function

Introduce:

lv_is_component() check is LV is actually a component device.

lv_component_is_active() checking if any component device is active.

lv_holder_is_active() is any component holding device is active.
---
 WHATS_NEW                        |    1 +
 lib/activate/activate.c          |  111 +++++++++++++++++++++++++++++++++++++-
 lib/activate/activate.h          |    7 ++-
 lib/activate/dev_manager.c       |    2 +-
 lib/metadata/metadata-exported.h |   11 ++++
 5 files changed, 129 insertions(+), 3 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index b282caa..9656da7 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.178 - 
 =====================================
+  Extend internal library to recognize and work with component LV.
   Skip duplicate check for active LV when prompting for its removal.
   Activate correct lock holding LV when it is cached.
   Do not modify archived metadata when removing striped raid.
diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index f5e9ef9..aa230fe 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2017 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2018 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -2860,3 +2860,112 @@ void activation_exit(void)
 	dev_manager_exit();
 }
 #endif
+
+static int _component_cb(struct logical_volume *lv, void *data)
+{
+	struct logical_volume **component_lv = (struct logical_volume **) data;
+
+	if (lv_is_locked(lv) || lv_is_pvmove(lv) ||/* ignoring */
+	    /* thin-pool is special and it's using layered device */
+	    (lv_is_thin_pool(lv) && pool_is_active(lv)))
+		return -1;
+
+	if (lv_is_active(lv)) {
+		if (!lv_is_component(lv) || lv_is_visible(lv))
+			return -1;	/* skip whole subtree */
+
+		log_debug_activation("Found active component LV %s.", display_lvname(lv));
+		*component_lv = lv;
+		return 0;	/* break any further processing */
+	}
+
+	return 1;
+}
+
+/*
+ * Finds out for any LV if any of its component LVs are active.
+ * Function first checks if an existing LV is visible and active eventually
+ * it's lock holding LV is already active. In such case sub LV cannot be
+ * actived alone and no further checking is needed.
+ *
+ * Returns active component LV if there is such.
+ */
+const struct logical_volume *lv_component_is_active(const struct logical_volume *lv)
+{
+	const struct logical_volume *component_lv = NULL;
+	const struct logical_volume *holder_lv = lv_lock_holder(lv);
+
+	if ((holder_lv != lv) && lv_is_active(holder_lv))
+                return NULL; /* Lock holding LV is active, do not check components */
+
+	if (_component_cb((struct logical_volume *) lv, &holder_lv) == 1)
+		(void) for_each_sub_lv((struct logical_volume *) lv, _component_cb,
+				       (void*) &component_lv);
+
+	return component_lv;
+}
+
+/*
+ * Finds out if any LV above is active, as stacked device tree can be composed of
+ * chained set of LVs.
+ *
+ * Returns active holder LV if there is such.
+ */
+const struct logical_volume *lv_holder_is_active(const struct logical_volume *lv)
+{
+	const struct logical_volume *holder;
+	const struct seg_list *sl;
+
+	if (lv_is_locked(lv) || lv_is_pvmove(lv))
+		return NULL; /* Skip pvmove/locked LV tracking */
+
+	dm_list_iterate_items(sl, &lv->segs_using_this_lv) {
+		/* Recursive call for upper-stack holder */
+		if ((holder = lv_holder_is_active(sl->seg->lv)))
+			return holder;
+
+		if (lv_is_active(sl->seg->lv)) {
+			log_debug_activation("Found active holder LV %s.", display_lvname(sl->seg->lv));
+			return sl->seg->lv;
+		}
+	}
+
+	return NULL;
+}
+
+static int _deactivate_sub_lv_cb(struct logical_volume *lv, void *data)
+{
+	struct logical_volume **slv = data;
+
+	if (lv_is_thin_pool(lv) || lv_is_external_origin(lv))
+		return -1;
+
+	if (!deactivate_lv(lv->vg->cmd, lv)) {
+		*slv = lv;
+		return 0;
+	}
+
+	return 1;
+}
+
+/*
+ * Deactivates LV toghether with explicit deactivation call made also for all its component LVs.
+ */
+int deactivate_lv_with_sub_lv(const struct logical_volume *lv)
+{
+	struct logical_volume *flv;
+
+	if (!deactivate_lv(lv->vg->cmd, lv)) {
+		log_error("Cannot deactivate logical volume %s.",
+			  display_lvname(lv));
+		return 0;
+	}
+
+	if (!for_each_sub_lv((struct logical_volume *)lv, _deactivate_sub_lv_cb, &flv)) {
+		log_error("Cannot deactivate subvolume %s of logical volume %s.",
+			  display_lvname(flv), display_lvname(lv));
+		return 0;
+	}
+
+	return 1;
+}
diff --git a/lib/activate/activate.h b/lib/activate/activate.h
index 8d06867..dc4d3cd 100644
--- a/lib/activate/activate.h
+++ b/lib/activate/activate.h
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.  
- * Copyright (C) 2004-2016 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2018 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -198,6 +198,11 @@ int lv_is_active_exclusive(const struct logical_volume *lv);
 int lv_is_active_exclusive_locally(const struct logical_volume *lv);
 int lv_is_active_exclusive_remotely(const struct logical_volume *lv);
 
+/* Check is any component LV is active */
+const struct logical_volume *lv_component_is_active(const struct logical_volume *lv);
+const struct logical_volume *lv_holder_is_active(const struct logical_volume *lv);
+int deactivate_lv_with_sub_lv(const struct logical_volume *lv);
+
 int lv_has_target_type(struct dm_pool *mem, const struct logical_volume *lv,
 		       const char *layer, const char *target_type);
 
diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 2faf1cc..8bf0e47 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2002-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2017 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2018 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 71df955..cd7ff8a 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -253,6 +253,17 @@
 
 #define lv_is_removed(lv)	(((lv)->status & LV_REMOVED) ? 1 : 0)
 
+/* Recognize component LV (matching lib/misc/lvm-string.c _lvname_has_reserved_component_string()) */
+#define lv_is_component(lv) (lv_is_cache_origin(lv) || ((lv)->status & (\
+	CACHE_POOL_DATA |\
+	CACHE_POOL_METADATA |\
+	MIRROR_IMAGE |\
+	MIRROR_LOG |\
+	RAID_IMAGE |\
+	RAID_META |\
+	THIN_POOL_DATA |\
+	THIN_POOL_METADATA)) ? 1 : 0)
+
 int lv_layout_and_role(struct dm_pool *mem, const struct logical_volume *lv,
 		       struct dm_list **layout, struct dm_list **role);
 


