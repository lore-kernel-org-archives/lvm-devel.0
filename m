From: David Teigland <teigland@sourceware.org>
Date: Mon, 30 Sep 2019 12:39:41 -0400
Subject: master - metadata: import device name hint from metadata
Message-ID: <201909301639.x8UGdfVY024735@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=3a8e41a67b3f0edb0fcb27302351f7d58b6ef8c5
Commit:        3a8e41a67b3f0edb0fcb27302351f7d58b6ef8c5
Parent:        fcfabb26a535f9b967e96ad44300377598622c0d
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Sep 4 14:13:14 2019 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Sep 30 11:38:10 2019 -0500

metadata: import device name hint from metadata

Start by using it in a comment for a missing PV.
---
 lib/format_text/import_vsn1.c |    6 ++++++
 lib/metadata/metadata.c       |    5 ++++-
 lib/metadata/pv.h             |    1 +
 3 files changed, 11 insertions(+), 1 deletions(-)

diff --git a/lib/format_text/import_vsn1.c b/lib/format_text/import_vsn1.c
index f29abce..2785ab3 100644
--- a/lib/format_text/import_vsn1.c
+++ b/lib/format_text/import_vsn1.c
@@ -184,6 +184,7 @@ static int _read_pv(struct cmd_context *cmd,
 	struct physical_volume *pv;
 	struct pv_list *pvl;
 	const struct dm_config_value *cv;
+	const char *device_hint;
 	uint64_t size, ba_start;
 
 	if (!(pvl = dm_pool_zalloc(mem, sizeof(*pvl))) ||
@@ -228,6 +229,11 @@ static int _read_pv(struct cmd_context *cmd,
 		return 0;
 	}
 
+	if (dm_config_get_str(pvn, "device", &device_hint)) {
+		if (!(pv->device_hint = dm_pool_strdup(mem, device_hint)))
+			log_error("Failed to allocate memory for device hint in read_pv.");
+	}
+
 	if (!_read_uint64(pvn, "pe_start", &pv->pe_start)) {
 		log_error("Couldn't read extent start value (pe_start) "
 			  "for physical volume.");
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index b434967..cf5c563 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -4971,7 +4971,10 @@ struct volume_group *vg_read(struct cmd_context *cmd, const char *vg_name, const
 		if (!pvl->pv->dev) {
 			/* The obvious and common case of a missing device. */
 
-			log_warn("WARNING: VG %s is missing PV %s.", vg_name, uuidstr);
+			if (pvl->pv->device_hint)
+				log_warn("WARNING: VG %s is missing PV %s (last written to %s).", vg_name, uuidstr, pvl->pv->device_hint);
+			else
+				log_warn("WARNING: VG %s is missing PV %s.", vg_name, uuidstr);
 			missing_pv_dev++;
 
 		} else if (pvl->pv->status & MISSING_PV) {
diff --git a/lib/metadata/pv.h b/lib/metadata/pv.h
index 3430c2e..efa13e0 100644
--- a/lib/metadata/pv.h
+++ b/lib/metadata/pv.h
@@ -26,6 +26,7 @@ struct physical_volume {
 	struct id id;
 	struct id old_id;		/* Set during pvchange -u. */
 	struct device *dev;
+	const char *device_hint;	/* primary name last time metadata was written */
 	const struct format_type *fmt;
 	struct format_instance *fid;
 


