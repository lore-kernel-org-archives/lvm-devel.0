From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 23 Apr 2021 21:06:03 +0000 (GMT)
Subject: main - clang: ensure vg is defined
Message-ID: <20210423210603.1E2313B08C2B@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=49caa9f3b1950ffd2ca9aa990e8bf0b480b62b87
Commit:        49caa9f3b1950ffd2ca9aa990e8bf0b480b62b87
Parent:        51fd232b8eb2613a198b049d44688ea2422b248a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Apr 22 22:42:54 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Apr 23 23:00:55 2021 +0200

clang: ensure vg is defined

---
 tools/pvchange.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/tools/pvchange.c b/tools/pvchange.c
index b0bc83ed5..d6e35d66f 100644
--- a/tools/pvchange.c
+++ b/tools/pvchange.c
@@ -54,7 +54,7 @@ static int _pvchange_single(struct cmd_context *cmd, struct volume_group *vg,
 	}
 
 	/* If in a VG, must change using volume group. */
-	if (!is_orphan(pv)) {
+	if (vg && !is_orphan(pv)) {
 		if (tagargs && !(vg->fid->fmt->features & FMT_TAGS)) {
 			log_error("Volume group containing %s does not "
 				  "support tags", pv_name);
@@ -134,7 +134,7 @@ static int _pvchange_single(struct cmd_context *cmd, struct volume_group *vg,
 	}
 
 	if (arg_is_set(cmd, metadataignore_ARG)) {
-		if ((vg_mda_copies(vg) != VGMETADATACOPIES_UNMANAGED) &&
+		if (vg && (vg_mda_copies(vg) != VGMETADATACOPIES_UNMANAGED) &&
 		    (arg_count(cmd, force_ARG) == PROMPT) &&
 		    yes_no_prompt("Override preferred number of copies "
 				  "of VG %s metadata? [y/n]: ",
@@ -175,7 +175,7 @@ static int _pvchange_single(struct cmd_context *cmd, struct volume_group *vg,
 	}
 
 	log_verbose("Updating physical volume \"%s\"", pv_name);
-	if (!is_orphan(pv)) {
+	if (vg && !is_orphan(pv)) {
 		if (!vg_write(vg) || !vg_commit(vg)) {
 			log_error("Failed to store physical volume \"%s\" in "
 				  "volume group \"%s\"", pv_name, vg->name);


