From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon, 15 Feb 2016 12:08:55 +0000 (UTC)
Subject: master - vg: automatically update to newest PV ext version during vg_write
Message-ID: <20160215120855.4D0E360DDE@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=2f00d57e6f7e1066448f93af0b67a378da29a4d0
Commit:        2f00d57e6f7e1066448f93af0b67a378da29a4d0
Parent:        9b9f1ae7726c2ee0e7eda76cd519f7d4921a12d9
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Fri Feb 12 14:22:02 2016 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Feb 15 12:44:46 2016 +0100

vg: automatically update to newest PV ext version during vg_write

---
 lib/metadata/metadata.c |   58 +++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 58 insertions(+), 0 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index a08cfc3..eb50c0a 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -3073,6 +3073,59 @@ out:
 	return r;
 }
 
+static int _pv_in_pvs_to_write_list(struct physical_volume *pv, struct volume_group *vg)
+{
+	struct pv_to_write *pvw;
+
+	dm_list_iterate_items(pvw, &vg->pvs_to_write) {
+		if (pvw->pv == pv)
+			return 1;
+	}
+
+	return 0;
+}
+
+/*
+ * Check if any of the PVs in VG still contain old PV headers
+ * and if yes, schedule them for PV header update.
+ */
+static int _check_old_pv_ext_for_vg(struct volume_group *vg)
+{
+	struct pv_list *pvl;
+	struct pv_to_write *pvw;
+	int pv_needs_rewrite;
+
+	if (!(vg->fid->fmt->features & FMT_PV_FLAGS))
+		return 1;
+
+	dm_list_iterate_items(pvl, &vg->pvs) {
+		if (is_missing_pv(pvl->pv) ||
+		    !pvl->pv->fmt->ops->pv_needs_rewrite)
+			continue;
+
+		if (!pvl->pv->fmt->ops->pv_needs_rewrite(pvl->pv->fmt, pvl->pv,
+							 &pv_needs_rewrite))
+			return_0;
+
+		if (pv_needs_rewrite) {
+			/*
+			 * Schedule PV for writing only once!
+			 */
+			if (_pv_in_pvs_to_write_list(pvl->pv, vg))
+				continue;
+
+			if (!(pvw = dm_pool_zalloc(vg->vgmem, sizeof(*pvw)))) {
+				log_error("pv_to_write allocation for '%s' failed", pv_dev_name(pvl->pv));
+				return 0;
+			}
+			pvw->pv = pvl->pv;
+			dm_list_add(&vg->pvs_to_write, &pvw->list);
+		}
+	}
+
+	return 1;
+}
+
 /*
  * After vg_write() returns success,
  * caller MUST call either vg_commit() or vg_revert()
@@ -3123,6 +3176,11 @@ int vg_write(struct volume_group *vg)
 		return 0;
 	}
 
+	if (!(_check_old_pv_ext_for_vg(vg))) {
+		log_error("Failed to schedule physical volume header update.");
+		return 0;
+	}
+
 	if (!drop_cached_metadata(vg)) {
 		log_error("Unable to drop cached metadata for VG %s.", vg->name);
 		return 0;


