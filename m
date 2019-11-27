From: David Teigland <teigland@sourceware.org>
Date: Wed, 27 Nov 2019 10:27:34 -0500
Subject: master - scanning: use bool type for _scan_text_mismatch
Message-ID: <49365.119112710273000513@us-mta-235.us.mimecast.lan>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=98a8099da9e43561a1fe981bbf2866e373f0d07a
Commit:        98a8099da9e43561a1fe981bbf2866e373f0d07a
Parent:        b400353c71397954a7cc4c4b52b9570715104773
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Nov 27 09:26:04 2019 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Nov 27 09:26:49 2019 -0600

scanning: use bool type for _scan_text_mismatch

---
 lib/metadata/metadata.c |   20 +++++++-------------
 1 files changed, 7 insertions(+), 13 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 1ac5445..b12db60 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -4577,7 +4577,7 @@ void vg_write_commit_bad_mdas(struct cmd_context *cmd, struct volume_group *vg)
  * reread metadata.
  */
 
-static int _scan_text_mismatch(struct cmd_context *cmd, const char *vgname, const char *vgid)
+static bool _scan_text_mismatch(struct cmd_context *cmd, const char *vgname, const char *vgid)
 {
 	struct dm_list mda_list;
 	struct mda_list *mdal, *safe;
@@ -4588,7 +4588,7 @@ static int _scan_text_mismatch(struct cmd_context *cmd, const char *vgname, cons
 	struct raw_locn *rlocn;
 	struct device *dev;
 	uint32_t bad_fields;
-	int ret = 1;
+	bool ret = true;
 
 	/*
 	 * if cmd->can_use_one_scan, check one mda_header is unchanged,
@@ -4610,7 +4610,6 @@ static int _scan_text_mismatch(struct cmd_context *cmd, const char *vgname, cons
 
 		if (!(dev = mda_get_device(mda))) {
 			log_debug("rescan for text mismatch - no mda dev");
-			ret = 1;
 			goto out;
 		}
 
@@ -4624,13 +4623,11 @@ static int _scan_text_mismatch(struct cmd_context *cmd, const char *vgname, cons
 		 */
 		if (!dev_invalidate_bytes(dev, 4096, 512)) {
 			log_debug("rescan for text mismatch - cannot invalidate");
-			ret = 1;
 			goto out;
 		}
 
 		if (!(mdah = raw_read_mda_header(cmd->fmt, area, 1, 0, &bad_fields))) {
 			log_debug("rescan for text mismatch - no mda header");
-			ret = 1;
 			goto out;
 		}
 
@@ -4638,18 +4635,16 @@ static int _scan_text_mismatch(struct cmd_context *cmd, const char *vgname, cons
 
 		if (bad_fields) {
 			log_debug("rescan for text mismatch - bad_fields");
-			ret = 1;
 		} else if (rlocn->checksum != mda->scan_text_checksum) {
 			log_debug("rescan for text checksum mismatch - now %x prev %x",
 				  rlocn->checksum, mda->scan_text_checksum);
-			ret = 1;
 		} else if (rlocn->offset != mda->scan_text_offset) {
 			log_debug("rescan for text offset mismatch - now %llu prev %llu",
 				  (unsigned long long)rlocn->offset,
 				  (unsigned long long)mda->scan_text_offset);
-			ret = 1;
 		} else {
-			ret = 0;
+			/* the common case where fields match and no rescan needed */
+			ret = false;
 		}
 
 		dm_pool_free(cmd->mem, mdah);
@@ -4668,12 +4663,11 @@ static int _scan_text_mismatch(struct cmd_context *cmd, const char *vgname, cons
 		log_debug("rescan for text mismatch - no mdas");
 		goto out;
 	}
-
-	ret = 0;
-
 out:
 	if (!ret)
-		log_debug("rescan skipped - text offset and checksum unchanged");
+		log_debug("rescan skipped - unchanged offset %llu checksum %x",
+			  (unsigned long long)mda->scan_text_offset,
+			  mda->scan_text_checksum);
 
 	dm_list_iterate_items_safe(mdal, safe, &mda_list) {
 		dm_list_del(&mdal->list);



