From: David Teigland <teigland@sourceware.org>
Date: Wed, 25 Apr 2018 17:51:14 -0400
Subject: master - clvmd: skip dev rescan after full scan
Message-ID: <201804252151.w3PLpEw7017662@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=47bfac21cab25b104170bf31e4fec84096bf90a5
Commit:        47bfac21cab25b104170bf31e4fec84096bf90a5
Parent:        1fec86571ff9133c0a24a794d1221a0fefde7670
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Apr 24 14:48:30 2018 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Apr 25 16:39:43 2018 -0500

clvmd: skip dev rescan after full scan

When clvmd does a full label scan just prior to
calling _vg_read(), pass a new flag into _vg_read
to indicate that the normal rescan of VG devs is
not needed.
---
 lib/metadata/metadata-exported.h |    1 +
 lib/metadata/metadata.c          |    8 ++++++++
 2 files changed, 9 insertions(+), 0 deletions(-)

diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 73041cf..e8ecfd6 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -645,6 +645,7 @@ void pvcreate_params_set_defaults(struct pvcreate_params *pp);
  */ 
 #define WARN_PV_READ      0x00000001
 #define WARN_INCONSISTENT 0x00000002
+#define SKIP_RESCAN       0x00000004
 
 /*
 * Utility functions
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index a908658..3c1d8a4 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -3864,6 +3864,10 @@ static struct volume_group *_vg_read(struct cmd_context *cmd,
 	 * we can also skip the rescan in that case.
 	 */
 	if (!cmd->can_use_one_scan || lvmcache_scan_mismatch(cmd, vgname, vgid)) {
+		/* the skip rescan special case is for clvmd vg_read_by_vgid */
+		/* FIXME: this is not a warn flag, pass this differently */
+		if (warn_flags & SKIP_RESCAN)
+			goto find_vg;
 		skipped_rescan = 0;
 		log_debug_metadata("Rescanning devices for for %s", vgname);
 		lvmcache_label_rescan_vg(cmd, vgname, vgid);
@@ -3872,6 +3876,8 @@ static struct volume_group *_vg_read(struct cmd_context *cmd,
 		skipped_rescan = 1;
 	}
 
+ find_vg:
+
 	if (!(fmt = lvmcache_fmt_from_vgname(cmd, vgname, vgid, 0))) {
 		log_debug_metadata("Cache did not find fmt for vgname %s", vgname);
 		return_NULL;
@@ -4593,6 +4599,7 @@ struct volume_group *vg_read_by_vgid(struct cmd_context *cmd,
 		lvmcache_destroy(cmd, 0, 0);
 		label_scan_destroy(cmd);
 		lvmcache_label_scan(cmd);
+		warn_flags |= SKIP_RESCAN;
 	}
 
 	if (!(vgname = lvmcache_vgname_from_vgid(cmd->mem, vgid))) {
@@ -4623,6 +4630,7 @@ struct volume_group *vg_read_by_vgid(struct cmd_context *cmd,
 	lvmcache_destroy(cmd, 0, 0);
 	label_scan_destroy(cmd);
 	lvmcache_label_scan(cmd);
+	warn_flags |= SKIP_RESCAN;
 
 	if (!(vg = _vg_read(cmd, vgname, vgid, warn_flags, &consistent, precommitted)))
 		goto fail;


