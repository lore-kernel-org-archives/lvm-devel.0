From: Petr Rockai <mornfall@fedoraproject.org>
Date: Tue,  4 Jun 2013 19:25:55 +0000 (UTC)
Subject: dev-mornfall-activate - report: improve reporting of active state
Message-ID: <20130604192555.E7AB66115D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=2d3700ba42e156aa8b6e2819736cab6866ea56ce
Commit:        2d3700ba42e156aa8b6e2819736cab6866ea56ce
Parent:        d2d71330c308230065dbc865e4552a9a62aad269
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu May 2 18:06:50 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri May 3 15:43:52 2013 +0200

report: improve reporting of active state

For reporting stacked or joined devices properly in cluster,
we need to report their activation state according the lock,
which activated this device tree.

This is getting a bit complex - current code tries simple approach -

For snapshot - return status for origin.
For thin pool - return status of the first known active thin volume.
For the rest of them - try to use dependency list of LVs and skip
known execptions.  This should be able to recursively deduce top level
device for given LV.

(in release fix)
---
 lib/metadata/lv.c |   40 +++++++++++++++++++++++++++++++++++++++-
 lib/metadata/lv.h |    1 +
 2 files changed, 40 insertions(+), 1 deletions(-)

diff --git a/lib/metadata/lv.c b/lib/metadata/lv.c
index 41de7a5..283b8c4 100644
--- a/lib/metadata/lv.c
+++ b/lib/metadata/lv.c
@@ -745,6 +745,12 @@ char *lv_active_dup(struct dm_pool *mem, const struct logical_volume *lv)
 {
 	const char *s;
 
+	if (vg_is_clustered(lv->vg)) {
+		//const struct logical_volume *lvo = lv;
+		lv = lv_lock_holder(lv);
+		//log_debug("Holder for %s => %s.", lvo->name, lv->name);
+	}
+
 	if (!lv_is_active(lv))
 		s = ""; /* not active */
 	else if (!vg_is_clustered(lv->vg))
@@ -755,7 +761,39 @@ char *lv_active_dup(struct dm_pool *mem, const struct logical_volume *lv)
 			"local exclusive" : "remote exclusive";
 	else /* locally active */
 		s = lv_is_active_but_not_locally(lv) ?
-		     "remotely" : "locally";
+			"remotely" : "locally";
 
 	return dm_pool_strdup(mem, s);
 }
+
+/* For given LV find recursively the LV which holds lock for it */
+const struct logical_volume *lv_lock_holder(const struct logical_volume *lv)
+{
+	const struct seg_list *sl;
+
+	if (lv_is_cow(lv))
+		return lv_lock_holder(origin_from_cow(lv));
+
+	if (lv_is_thin_pool(lv))
+		/* Find any active LV from the pool */
+		dm_list_iterate_items(sl, &lv->segs_using_this_lv)
+			if (lv_is_active(sl->seg->lv)) {
+				log_debug("Thin volume \"%s\" is active.", sl->seg->lv->name);
+				return sl->seg->lv;
+			}
+
+	/* For other types, by default look for the first user */
+	dm_list_iterate_items(sl, &lv->segs_using_this_lv) {
+		/* FIXME: complete this exception list */
+		if (lv_is_thin_volume(lv) &&
+		    lv_is_thin_volume(sl->seg->lv) &&
+		    first_seg(lv)->pool_lv == sl->seg->pool_lv)
+			continue; /* Skip thin snaphost */
+		if (lv_is_external_origin(lv) &&
+		    lv_is_thin_volume(sl->seg->lv))
+			continue; /* Skip external origin */
+		return lv_lock_holder(sl->seg->lv);
+	}
+
+	return lv;
+}
diff --git a/lib/metadata/lv.h b/lib/metadata/lv.h
index bac8bc2..ed0d745 100644
--- a/lib/metadata/lv.h
+++ b/lib/metadata/lv.h
@@ -90,4 +90,5 @@ const char *lv_layer(const struct logical_volume *lv);
 int lv_active_change(struct cmd_context *cmd, struct logical_volume *lv,
 		     activation_change_t activate);
 char *lv_active_dup(struct dm_pool *mem, const struct logical_volume *lv);
+const struct logical_volume *lv_lock_holder(const struct logical_volume *lv);
 #endif /* _LVM_LV_H */


