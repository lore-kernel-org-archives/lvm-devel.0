From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 23 Aug 2012 12:42:52 +0000 (UTC)
Subject: master - check: add internal errors for unexpected paths
Message-ID: <20120823124252.84BDAA0D9A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=fd417db274e9a75f33f661b475aeebfd3d9eae45
Commit:        fd417db274e9a75f33f661b475aeebfd3d9eae45
Parent:        15891d366d34fa6ea7235ec803ee0c5445a17101
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jun 21 12:43:31 2012 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Aug 23 14:37:52 2012 +0200

check: add internal errors for unexpected paths

Adding couple INTERNAL_ERROR reports for unwanted parameters:

Ensure the 'top' metadata node cannot be NULL for lvmetad.

Make obvious vginfo2 cannot be NULL.

Report internal error if handler and vg is undefined.

Check for handle in poll_vg().

Ensure seg is not NULL in dev_manager_transient().

Report missing read_ahead for _lv_read_ahead_single().

Check for report handler in dm_report_object().

Check missing VG in _vgreduce_single().
---
 lib/activate/dev_manager.c |    5 +++++
 lib/cache/lvmcache.c       |   12 +++++++-----
 lib/cache/lvmetad.c        |   11 ++++++++++-
 lib/metadata/metadata.c    |    5 +++++
 libdm/libdm-report.c       |    5 +++++
 tools/polldaemon.c         |    5 +++++
 tools/vgreduce.c           |    5 +++++
 7 files changed, 42 insertions(+), 6 deletions(-)

diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 122741c..43bcd49 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -668,6 +668,11 @@ int dev_manager_transient(struct dev_manager *dm, struct logical_volume *lv)
 		if (!type || !params)
 			continue;
 
+		if (!seg) {
+			log_error(INTERNAL_ERROR "Segment is not selected.");
+			goto out;
+		}
+
 		if (seg->segtype->ops->check_transient_status &&
 		    !seg->segtype->ops->check_transient_status(seg, params))
 			goto_out;
diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index 8936809..6f9cfad 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -1005,12 +1005,14 @@ static int _free_vginfo(struct lvmcache_vginfo *vginfo)
 				  vginfo->vgname);
 			r = 0;
 		}
-	} else do
-		if (vginfo2->next == vginfo) {
-			vginfo2->next = vginfo->next;
-			break;
+	} else
+		while (vginfo2) {
+			if (vginfo2->next == vginfo) {
+				vginfo2->next = vginfo->next;
+				break;
+			}
+			vginfo2 = vginfo2->next;
 		}
- 	while ((vginfo2 = vginfo2->next));
 
 	dm_free(vginfo->vgname);
 	dm_free(vginfo->creation_host);
diff --git a/lib/cache/lvmetad.c b/lib/cache/lvmetad.c
index db092ac..6e1759b 100644
--- a/lib/cache/lvmetad.c
+++ b/lib/cache/lvmetad.c
@@ -199,7 +199,11 @@ struct volume_group *lvmetad_vg_lookup(struct cmd_context *cmd, const char *vgna
 
 	if (!strcmp(daemon_reply_str(reply, "response", ""), "OK")) {
 
-		top = dm_config_find_node(reply.cft->root, "metadata");
+		if (!(top = dm_config_find_node(reply.cft->root, "metadata"))) {
+			log_error(INTERNAL_ERROR "metadata config node not found.");
+			goto out;
+		}
+
 		name = daemon_reply_str(reply, "name", NULL);
 
 		/* fall back to lvm2 if we don't know better */
@@ -593,6 +597,11 @@ int lvmetad_pv_found(struct id pvid, struct device *device, const struct format_
 					   "metadata = %b", strchr(buf, '{'),
 					   NULL);
 	} else {
+		if (handler) {
+			log_error(INTERNAL_ERROR "Handler needs existing VG.");
+			dm_free(pvmeta);
+			return 0;
+		}
 		/* There are no MDAs on this PV. */
 		reply = daemon_send_simple(_lvmetad,
 					   "pv_found",
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index dd029ac..fd13b0a 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -2221,6 +2221,11 @@ static int _lv_read_ahead_single(struct logical_volume *lv, void *data)
 	struct lv_segment *seg = first_seg(lv);
 	uint32_t seg_read_ahead = 0, *read_ahead = data;
 
+	if (!read_ahead) {
+		log_error(INTERNAL_ERROR "Read ahead data missing.");
+		return 0;
+	}
+
 	if (seg && seg->area_count && seg_type(seg, 0) == AREA_PV)
 		dev_get_read_ahead(seg_pv(seg, 0)->dev, &seg_read_ahead);
 
diff --git a/libdm/libdm-report.c b/libdm/libdm-report.c
index 3f86767..0bafa86 100644
--- a/libdm/libdm-report.c
+++ b/libdm/libdm-report.c
@@ -695,6 +695,11 @@ int dm_report_object(struct dm_report *rh, void *object)
 	struct dm_report_field *field;
 	void *data = NULL;
 
+	if (!rh) {
+		log_error(INTERNAL_ERROR "dm_report handler is NULL.");
+		return 0;
+	}
+
 	if (!(row = dm_pool_zalloc(rh->mem, sizeof(*row)))) {
 		log_error("dm_report_object: struct row allocation failed");
 		return 0;
diff --git a/tools/polldaemon.c b/tools/polldaemon.c
index fe55c3b..f57484e 100644
--- a/tools/polldaemon.c
+++ b/tools/polldaemon.c
@@ -261,6 +261,11 @@ static int _poll_vg(struct cmd_context *cmd, const char *vgname,
 	const char *name;
 	int finished;
 
+	if (!parms) {
+		log_error(INTERNAL_ERROR "Handle is undefined.");
+		return ECMD_FAILED;
+	}
+
 	dm_list_iterate_items(lvl, &vg->lvs) {
 		lv = lvl->lv;
 		if (!(lv->status & parms->lv_type))
diff --git a/tools/vgreduce.c b/tools/vgreduce.c
index 9696651..975b9ea 100644
--- a/tools/vgreduce.c
+++ b/tools/vgreduce.c
@@ -124,6 +124,11 @@ static int _vgreduce_single(struct cmd_context *cmd, struct volume_group *vg,
 	int r = ECMD_FAILED;
 	const char *name = pv_dev_name(pv);
 
+	if (!vg) {
+		log_error(INTERNAL_ERROR "VG is NULL.");
+		return ECMD_FAILED;
+	}
+
 	if (pv_pe_alloc_count(pv)) {
 		log_error("Physical volume \"%s\" still in use", name);
 		return ECMD_FAILED;


