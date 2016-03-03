From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu,  3 Mar 2016 13:20:37 +0000 (UTC)
Subject: master - metadata: automatically remove invalid (dangling) historical LVs
Message-ID: <20160303132037.BE5B560310@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=8a601454e178c72b39be66365eaa153d69d4ed40
Commit:        8a601454e178c72b39be66365eaa153d69d4ed40
Parent:        1297b0c8bef38a9269186ca26d6827560ce0fddf
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Mar 2 12:19:07 2016 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Mar 3 13:50:59 2016 +0100

metadata: automatically remove invalid (dangling) historical LVs

Historical LV is valid as long as there is at least one live LV among
its ancestors. If we find any invalid (dangling) historical LVs, remove
them automatically.
---
 lib/metadata/lv.h       |    2 ++
 lib/metadata/metadata.c |   47 ++++++++++++++++++++++++++++++++++++++++++++++-
 2 files changed, 48 insertions(+), 1 deletions(-)

diff --git a/lib/metadata/lv.h b/lib/metadata/lv.h
index f9f5b4e..da81419 100644
--- a/lib/metadata/lv.h
+++ b/lib/metadata/lv.h
@@ -94,6 +94,8 @@ struct historical_logical_volume {
 	uint64_t timestamp_removed;
 	struct generic_logical_volume *indirect_origin;
 	struct dm_list indirect_glvs; /* list of struct generic_logical_volume */
+	int checked:1; /* set if this historical LV has been checked for validity */
+	int valid:1;   /* historical LV is valid if there's at least one live LV among ancestors */
 };
 
 struct generic_logical_volume {
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 4951d71..9700e73 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -3319,15 +3319,45 @@ static int _check_old_pv_ext_for_vg(struct volume_group *vg)
 	return 1;
 }
 
-static int _handle_historical_lvs(struct volume_group *vg)
+static int _check_historical_lv_is_valid(struct historical_logical_volume *hlv)
 {
 	struct glv_list *glvl;
+
+	if (hlv->checked)
+		return hlv->valid;
+
+	/*
+	 * Historical LV is valid if there is
+	 * at least one live LV among ancestors.
+	 */
+	hlv->valid = 0;
+	dm_list_iterate_items(glvl, &hlv->indirect_glvs) {
+		if (!glvl->glv->is_historical ||
+		    _check_historical_lv_is_valid(glvl->glv->historical)) {
+			hlv->valid = 1;
+			break;
+		}
+	}
+
+	hlv->checked = 1;
+	return hlv->valid;
+}
+
+static int _handle_historical_lvs(struct volume_group *vg)
+{
+	struct glv_list *glvl, *tglvl;
 	time_t current_timestamp = 0;
 	struct historical_logical_volume *hlv;
+	int valid = 1;
+
+	dm_list_iterate_items(glvl, &vg->historical_lvs)
+		glvl->glv->historical->checked = 0;
 
 	dm_list_iterate_items(glvl, &vg->historical_lvs) {
 		hlv = glvl->glv->historical;
 
+		valid &= _check_historical_lv_is_valid(hlv);
+
 		if (!hlv->timestamp_removed) {
 			if (!current_timestamp)
 				current_timestamp = time(NULL);
@@ -3335,6 +3365,21 @@ static int _handle_historical_lvs(struct volume_group *vg)
 		}
 	}
 
+	if (valid)
+		return 1;
+
+	dm_list_iterate_items_safe(glvl, tglvl, &vg->historical_lvs) {
+		hlv = glvl->glv->historical;
+		if (hlv->checked && hlv->valid)
+			continue;
+
+		log_print_unless_silent("Automatically removing historical "
+					"logical volume %s/%s%s.",
+					 vg->name, HISTORICAL_LV_PREFIX, hlv->name);
+		if (!historical_glv_remove(glvl->glv))
+			return_0;
+	}
+
 	return 1;
 }
 


