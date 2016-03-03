From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu,  3 Mar 2016 13:19:35 +0000 (UTC)
Subject: master - metadata: create historical LVs when LVs are removed and interconnect with live LVs
Message-ID: <20160303131935.5571F61B8D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=790b2e874822767808f3c5bcc4ce1499944969ff
Commit:        790b2e874822767808f3c5bcc4ce1499944969ff
Parent:        eeaa5a4481e04c0131152fd88e6ea2651949ae35
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Mar 1 15:20:09 2016 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Mar 3 11:26:51 2016 +0100

metadata: create historical LVs when LVs are removed and interconnect with live LVs

When an LV is being removed, we create an instance of
"struct historical_logical_volume" wrapped up in
"struct generic_logical_volume".

All instances of "struct historical_logical_volume" are then recorded in
"historical_lvs" list which is part of "struct volume_group".

The "historical LV" is then interconnected with "live LVs" to
connect a history chain for the live LV.
---
 lib/metadata/metadata.c   |   25 ++++++++++
 lib/metadata/pool_manip.c |  118 +++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 143 insertions(+), 0 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 5e84e96..0d2211a 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -32,6 +32,7 @@
 #include "archiver.h"
 #include "defaults.h"
 #include "lvmlockd.h"
+#include "time.h"
 
 #include <math.h>
 #include <sys/param.h>
@@ -3182,6 +3183,25 @@ static int _check_old_pv_ext_for_vg(struct volume_group *vg)
 	return 1;
 }
 
+static int _handle_historical_lvs(struct volume_group *vg)
+{
+	struct glv_list *glvl;
+	time_t current_timestamp = 0;
+	struct historical_logical_volume *hlv;
+
+	dm_list_iterate_items(glvl, &vg->historical_lvs) {
+		hlv = glvl->glv->historical;
+
+		if (!hlv->timestamp_removed) {
+			if (!current_timestamp)
+				current_timestamp = time(NULL);
+			hlv->timestamp_removed = (uint64_t) current_timestamp;
+		}
+	}
+
+	return 1;
+}
+
 /*
  * After vg_write() returns success,
  * caller MUST call either vg_commit() or vg_revert()
@@ -3205,6 +3225,11 @@ int vg_write(struct volume_group *vg)
 		}
 	}
 
+	if (!_handle_historical_lvs(vg)) {
+		log_error("Failed to handle historical LVs in VG %s.", vg->name);
+		return 0;
+	}
+
 	if (!vg_validate(vg))
 		return_0;
 
diff --git a/lib/metadata/pool_manip.c b/lib/metadata/pool_manip.c
index cb12aaa..20bb756 100644
--- a/lib/metadata/pool_manip.c
+++ b/lib/metadata/pool_manip.c
@@ -26,6 +26,7 @@
 #include "dev-type.h"
 #include "display.h"
 #include "toolcontext.h"
+#include <stddef.h>
 
 int attach_pool_metadata_lv(struct lv_segment *pool_seg,
 			    struct logical_volume *metadata_lv)
@@ -123,8 +124,98 @@ int attach_pool_lv(struct lv_segment *seg,
 	return 1;
 }
 
+static struct glv_list *_init_historical_glvl(struct dm_pool *mem, struct lv_segment *seg)
+{
+	struct glv_list *glvl;
+	struct historical_logical_volume *hlv;
+
+	if (!(glvl = dm_pool_zalloc(mem, sizeof(struct glv_list))))
+		goto_bad;
+
+	if (!(glvl->glv = dm_pool_zalloc(mem, sizeof(struct generic_logical_volume))))
+		goto_bad;
+
+	if (!(hlv = dm_pool_zalloc(mem, sizeof(struct historical_logical_volume))))
+		goto_bad;
+
+	hlv->lvid = seg->lv->lvid;
+	hlv->name = seg->lv->name;
+	hlv->vg = seg->lv->vg;
+	hlv->timestamp = seg->lv->timestamp;
+	dm_list_init(&hlv->indirect_glvs);
+
+	glvl->glv->is_historical = 1;
+	glvl->glv->historical = hlv;
+
+	return glvl;
+bad:
+	log_error("Initialization of historical LV representation for removed logical "
+		  "volume %s/%s failed.", seg->lv->vg->name, seg->lv->name);
+	if (glvl)
+		dm_pool_free(mem, glvl);
+	return NULL;
+}
+
+static struct generic_logical_volume *_create_historical_glv(struct lv_segment *seg_to_remove)
+{
+	struct dm_pool *mem = seg_to_remove->lv->vg->vgmem;
+	struct generic_logical_volume *historical_glv, *origin_glv = NULL;
+	struct glv_list *historical_glvl;
+	int origin_glv_created = 0;
+
+	if (!(historical_glvl = _init_historical_glvl(mem, seg_to_remove)))
+		goto_bad;
+	historical_glv = historical_glvl->glv;
+
+	if (seg_to_remove->origin) {
+		if (!(origin_glv = get_or_create_glv(mem, seg_to_remove->origin, &origin_glv_created)))
+			goto_bad;
+
+		if (!add_glv_to_indirect_glvs(mem, origin_glv, historical_glv))
+			goto_bad;
+	} else if (seg_to_remove->indirect_origin) {
+		origin_glv = seg_to_remove->indirect_origin;
+
+		if (!remove_glv_from_indirect_glvs(origin_glv, seg_to_remove->lv->this_glv))
+			goto_bad;
+
+		if (!add_glv_to_indirect_glvs(mem, origin_glv, historical_glv))
+			goto_bad;
+	}
+
+	dm_list_add(&seg_to_remove->lv->vg->historical_lvs, &historical_glvl->list);
+	return historical_glvl->glv;
+bad:
+	log_error("Failed to create historical LV representation for removed logical "
+		  "volume %s/%s.", seg_to_remove->lv->vg->name, seg_to_remove->lv->name);
+	if (origin_glv_created)
+		seg_to_remove->origin->this_glv = NULL;
+	if (historical_glvl)
+		dm_pool_free(mem, historical_glvl);
+	return NULL;
+}
+
+static int _set_up_historical_lv(struct lv_segment *seg_to_remove,
+				 struct generic_logical_volume **previous_glv)
+{
+	struct generic_logical_volume *glv = NULL;
+
+	if (seg_to_remove->origin || seg_to_remove->indirect_origin ||
+	    dm_list_size(&seg_to_remove->lv->segs_using_this_lv) ||
+	    dm_list_size(&seg_to_remove->lv->indirect_glvs)) {
+		if (!(glv = _create_historical_glv(seg_to_remove)))
+			return_0;
+	}
+
+	*previous_glv = glv;
+	return 1;
+}
+
+
 int detach_pool_lv(struct lv_segment *seg)
 {
+	struct generic_logical_volume *previous_glv = NULL, *glv, *user_glv;
+	struct glv_list *user_glvl, *tglvl;
 	struct lv_thin_message *tmsg, *tmp;
 	struct seg_list *sl, *tsl;
 	int no_update = 0;
@@ -177,6 +268,9 @@ int detach_pool_lv(struct lv_segment *seg)
 		}
 	}
 
+	if (!_set_up_historical_lv(seg, &previous_glv))
+		return_0;
+
 	if (!detach_thin_external_origin(seg))
 		return_0;
 
@@ -202,15 +296,39 @@ int detach_pool_lv(struct lv_segment *seg)
 		    (seg->lv != sl->seg->origin))
 			continue;
 
+		if (previous_glv) {
+			if (!(user_glv = get_or_create_glv(seg->lv->vg->vgmem, sl->seg->lv, NULL)))
+				return_0;
+
+			if (!add_glv_to_indirect_glvs(seg->lv->vg->vgmem, previous_glv, user_glv))
+				return_0;
+		}
+
 		if (!remove_seg_from_segs_using_this_lv(seg->lv, sl->seg))
 			return_0;
 		/* Thin snapshot is now regular thin volume */
 		sl->seg->origin = NULL;
 	}
 
+	dm_list_iterate_items_safe(user_glvl, tglvl, &seg->lv->indirect_glvs) {
+		user_glv = user_glvl->glv;
+
+		if (!(glv = get_or_create_glv(seg->lv->vg->vgmem, seg->lv, NULL)))
+			return_0;
+
+		if (!remove_glv_from_indirect_glvs(glv, user_glv))
+			return_0;
+
+		if (previous_glv) {
+			if (!add_glv_to_indirect_glvs(seg->lv->vg->vgmem, previous_glv, user_glv))
+				return_0;
+		}
+	}
+
 	seg->lv->status &= ~THIN_VOLUME;
 	seg->pool_lv = NULL;
 	seg->origin = NULL;
+	seg->indirect_origin = NULL;
 
 	return 1;
 }


