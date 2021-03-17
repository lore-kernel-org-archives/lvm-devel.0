From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 17 Mar 2021 00:00:41 +0000 (GMT)
Subject: main - debug: start with upper case
Message-ID: <20210317000041.44E47385043E@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=8b2cdd8d3a8ad0b3048f38580a0dc20f6e1e492d
Commit:        8b2cdd8d3a8ad0b3048f38580a0dc20f6e1e492d
Parent:        94701b700b83971a49c242e070070526d4eb42dd
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Mar 16 14:16:36 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Mar 17 00:50:40 2021 +0100

debug: start with upper case

Use upper case letter to start sentence.
Also drop unneded check for vg as it's already non-null.
---
 lib/metadata/metadata.c | 18 +++++++++---------
 1 file changed, 9 insertions(+), 9 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 47d3d8b3e..4471f7c86 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -4557,7 +4557,7 @@ static bool _scan_text_mismatch(struct cmd_context *cmd, const char *vgname, con
 			continue;
 
 		if (!(dev = mda_get_device(mda))) {
-			log_debug("rescan for text mismatch - no mda dev");
+			log_debug("Rescan for text mismatch - no mda dev.");
 			goto out;
 		}
 
@@ -4570,24 +4570,24 @@ static bool _scan_text_mismatch(struct cmd_context *cmd, const char *vgname, con
 		 * Invalidate mda_header in bcache so it will be reread from disk.
 		 */
 		if (!dev_invalidate_bytes(dev, 4096, 512)) {
-			log_debug("rescan for text mismatch - cannot invalidate");
+			log_debug("Rescan for text mismatch - cannot invalidate.");
 			goto out;
 		}
 
 		if (!(mdah = raw_read_mda_header(cmd->fmt, area, 1, 0, &bad_fields))) {
-			log_debug("rescan for text mismatch - no mda header");
+			log_debug("Rescan for text mismatch - no mda header.");
 			goto out;
 		}
 
 		rlocn = mdah->raw_locns;
 
 		if (bad_fields) {
-			log_debug("rescan for text mismatch - bad_fields");
+			log_debug("Rescan for text mismatch - bad_fields.");
 		} else if (rlocn->checksum != mda->scan_text_checksum) {
-			log_debug("rescan for text checksum mismatch - now %x prev %x",
+			log_debug("Rescan for text checksum mismatch - now %x prev %x.",
 				  rlocn->checksum, mda->scan_text_checksum);
 		} else if (rlocn->offset != mda->scan_text_offset) {
-			log_debug("rescan for text offset mismatch - now %llu prev %llu",
+			log_debug("Rescan for text offset mismatch - now %llu prev %llu.",
 				  (unsigned long long)rlocn->offset,
 				  (unsigned long long)mda->scan_text_offset);
 		} else {
@@ -4608,12 +4608,12 @@ static bool _scan_text_mismatch(struct cmd_context *cmd, const char *vgname, con
 
 	if (ret) {
 		/* shouldn't happen */
-		log_debug("rescan for text mismatch - no mdas");
+		log_debug("Rescan for text mismatch - no mdas.");
 		goto out;
 	}
 out:
 	if (!ret)
-		log_debug("rescan skipped - unchanged offset %llu checksum %x",
+		log_debug("Rescan skipped - unchanged offset %llu checksum %x.",
 			  (unsigned long long)mda->scan_text_offset,
 			  mda->scan_text_checksum);
 
@@ -4809,7 +4809,7 @@ static struct volume_group *_vg_read(struct cmd_context *cmd,
 		if (!vg)
 			continue;
 
-		if (vg && !vg_ret) {
+		if (!vg_ret) {
 			vg_ret = vg;
 			dev_ret = mda_dev;
 			continue;


