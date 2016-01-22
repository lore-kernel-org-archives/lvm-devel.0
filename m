From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri, 22 Jan 2016 13:20:46 +0000 (UTC)
Subject: master - metadata: check PV dev size is not less than PV size
Message-ID: <20160122132046.E3E1560C97@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c0912af3104cb72ea275d90b8b1d68a25a9ca48a
Commit:        c0912af3104cb72ea275d90b8b1d68a25a9ca48a
Parent:        1f5dfb7369600c169ecd2c78e0cd079ad1442548
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Fri Jan 22 11:37:09 2016 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri Jan 22 14:16:00 2016 +0100

metadata: check PV dev size is not less than PV size

---
 WHATS_NEW               |    1 +
 lib/metadata/metadata.c |   34 ++++++++++++++++++++++++++++++++++
 2 files changed, 35 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index f6fd967..ff64846 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.141 - 
 ====================================
+  Warn if device size is less than corresponding PV size in metadata.
   Cache device sizes internally.
   Restore support for command breaking in process_each_lv_in_vg() (2.02.118).
   Use correct mempool when process_each_lv_in_vg() (2.02.118).
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index e733f6e..b9e4121 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -666,6 +666,34 @@ int vg_check_pv_dev_block_sizes(const struct volume_group *vg)
 	return 1;
 }
 
+static int _check_pv_dev_sizes(struct volume_group *vg)
+{
+	struct pv_list *pvl;
+	uint64_t dev_size, size;
+	int r = 1;
+
+	if (is_orphan_vg(vg->name))
+		return 1;
+
+	dm_list_iterate_items(pvl, &vg->pvs) {
+		if (is_missing_pv(pvl->pv))
+			continue;
+
+		dev_size = pv_dev_size(pvl->pv);
+		size = pv_size(pvl->pv);
+
+		if (dev_size < size) {
+			log_warn("Device %s has size of %" PRIu64 " sectors which "
+				 "is smaller than corresponding PV size of %" PRIu64
+				  " sectors. Was device resized?",
+				  pv_dev_name(pvl->pv), dev_size, size);
+			r = 0;
+		}
+	}
+
+	return r;
+}
+
 /*
  * Extend a VG by a single PV / device path
  *
@@ -742,6 +770,8 @@ int vg_extend(struct volume_group *vg, int pv_count, const char *const *pv_names
 		dm_free(pv_name);
 	}
 
+	(void) _check_pv_dev_sizes(vg);
+
 /* FIXME Decide whether to initialise and add new mdahs to format instance */
 
 	return 1;
@@ -4031,6 +4061,10 @@ struct volume_group *vg_read_internal(struct cmd_context *cmd, const char *vgnam
 	if (!(vg = _vg_read(cmd, vgname, vgid, warn_flags, consistent, 0)))
 		goto_out;
 
+	if (!_check_pv_dev_sizes(vg))
+		log_warn("One or more devices used as PVs in VG %s "
+			 "have changed sizes.", vg->name);
+
 	if (!check_pv_segments(vg)) {
 		log_error(INTERNAL_ERROR "PV segments corrupted in %s.",
 			  vg->name);


