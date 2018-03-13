From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 13 Mar 2018 08:13:07 -0400
Subject: master - cleanup: use path on stack
Message-ID: <201803131213.w2DCD79O004731@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=e095586d9e280877be336ed312368e657114ce14
Commit:        e095586d9e280877be336ed312368e657114ce14
Parent:        0edd89fadc3725080136e3d5a638d7df4abe9b95
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Mar 9 12:59:13 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Mar 13 12:57:08 2018 +0100

cleanup: use path on stack

---
 lib/metadata/mirror.c |   16 +++++-----------
 1 files changed, 5 insertions(+), 11 deletions(-)

diff --git a/lib/metadata/mirror.c b/lib/metadata/mirror.c
index 4a0e99f..6419b5c 100644
--- a/lib/metadata/mirror.c
+++ b/lib/metadata/mirror.c
@@ -270,7 +270,7 @@ int shift_mirror_images(struct lv_segment *mirrored_seg, unsigned mimage)
 static int _write_log_header(struct cmd_context *cmd, struct logical_volume *lv)
 {
 	struct device *dev;
-	char *name;
+	char name[PATH_MAX];
 	struct { /* The mirror log header */
 		uint32_t magic;
 		uint32_t version;
@@ -281,20 +281,14 @@ static int _write_log_header(struct cmd_context *cmd, struct logical_volume *lv)
 	log_header.version = xlate32(MIRROR_DISK_VERSION);
 	log_header.nr_regions = xlate64((uint64_t)-1);
 
-	if (!(name = dm_pool_alloc(cmd->mem, PATH_MAX))) {
-		log_error("Name allocation failed - log header not written (%s).",
+	if (dm_snprintf(name, sizeof(name), "%s%s/%s", cmd->dev_dir,
+			lv->vg->name, lv->name) < 0) {
+		log_error("Device path name too long - log header not written (%s).",
 			  display_lvname(lv));
 		return 0;
 	}
 
-	if (dm_snprintf(name, PATH_MAX, "%s%s/%s", cmd->dev_dir,
-			 lv->vg->name, lv->name) < 0) {
-		log_error("Name too long - log header not written (%s).",
-			  display_lvname(lv));
-		return 0;
-	}
-
-	log_verbose("Writing log header to device %s.", display_lvname(lv));
+	log_verbose("Writing log header for LV %s to device %s.", display_lvname(lv), name);
 
 	if (!(dev = dev_cache_get(name, NULL))) {
 		log_error("%s: not found: log header not written.", name);


