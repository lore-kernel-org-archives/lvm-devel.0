From: David Teigland <teigland@sourceware.org>
Date: Mon, 23 Apr 2018 09:56:51 -0400
Subject: master - clvm: rescan when VG or PV not found
Message-ID: <201804231356.w3NDupk8002500@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=1409c4a1c20319845171b91edb6310e25ae81792
Commit:        1409c4a1c20319845171b91edb6310e25ae81792
Parent:        c42a18d372f314aa51d9d7877342f1d78fd68973
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Apr 20 16:09:49 2018 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Apr 20 16:09:49 2018 -0500

clvm: rescan when VG or PV not found

Rescan devices to update lvmcache content when
clvmd vg_read doesn't find a VG or PV.
---
 lib/metadata/metadata.c |   28 ++++++++++++++++++++++++----
 1 files changed, 24 insertions(+), 4 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 685c589..2df9abe 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -4585,6 +4585,7 @@ static struct volume_group *_vg_read_by_vgid(struct cmd_context *cmd,
 	if (!(vgname = lvmcache_vgname_from_vgid(cmd->mem, vgid))) {
 		log_debug_metadata("Reading VG by vgid %.8s no VG name found, retrying.", vgid);
 		lvmcache_destroy(cmd, 0, 0);
+		label_scan_destroy(cmd);
 		lvmcache_label_scan(cmd);
 	}
 
@@ -4597,14 +4598,33 @@ static struct volume_group *_vg_read_by_vgid(struct cmd_context *cmd,
 
 	label_scan_setup_bcache();
 
-	if ((vg = _vg_read(cmd, vgname, vgid, warn_flags, &consistent, precommitted))) {
-		/* Does it matter if consistent is 0 or 1? */
-		label_scan_destroy(cmd);
-		return vg;
+	if (!(vg = _vg_read(cmd, vgname, vgid, warn_flags, &consistent, precommitted))) {
+		log_error("Rescan devices to look for missing VG.");
+		goto scan;
+	}
+
+	if (vg_missing_pv_count(vg)) {
+		log_error("Rescan devices to look for missing PVs.");
+		release_vg(vg);
+		goto scan;
 	}
 
+	label_scan_destroy(cmd); /* drop bcache to close devs, keep lvmcache */
+	return vg;
+
+ scan:
+	lvmcache_destroy(cmd, 0, 0);
 	label_scan_destroy(cmd);
+	lvmcache_label_scan(cmd);
+
+	if (!(vg = _vg_read(cmd, vgname, vgid, warn_flags, &consistent, precommitted)))
+		goto fail;
+
+	label_scan_destroy(cmd); /* drop bcache to close devs, keep lvmcache */
+	return vg;
 
+ fail:
+	label_scan_destroy(cmd); /* drop bache to close devs, keep lvmcache */
 	log_debug_metadata("Reading VG by vgid %.8s not found.", vgid);
 	return NULL;
 }


