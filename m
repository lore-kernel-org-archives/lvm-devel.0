From: David Teigland <teigland@sourceware.org>
Date: Fri, 18 May 2018 14:43:05 -0400
Subject: master - fix id_write_format on non-uuid string
Message-ID: <201805181843.w4IIh59l019690@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=0253f5a21dc0b9ee8641228739d3d1036212ba80
Commit:        0253f5a21dc0b9ee8641228739d3d1036212ba80
Parent:        b2574c2f3a4a35b7ea3f51dc776cc64ebbe88ba8
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri May 18 13:41:20 2018 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri May 18 13:41:20 2018 -0500

fix id_write_format on non-uuid string

orphan vgs using the vgname "#orphans" as the vgid,
and valgrind complains about calling id_write_format
on that invalid uuid.
---
 lib/metadata/metadata.c |   14 ++++++++------
 1 files changed, 8 insertions(+), 6 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 2f84d5f..3f6c2e4 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -3765,13 +3765,9 @@ static struct volume_group *_vg_read(struct cmd_context *cmd,
 	struct cached_vg_fmtdata *vg_fmtdata = NULL;	/* Additional format-specific data about the vg */
 	unsigned use_previous_vg;
 
-	uuid[0] = '\0';
-	if (vgid && !id_write_format((const struct id*)vgid, uuid, sizeof(uuid)))
-		stack;
-
-	log_very_verbose("Reading VG %s %s", vgname ?: "<no name>", vgid ? uuid : "<no vgid>");
-
 	if (is_orphan_vg(vgname)) {
+		log_very_verbose("Reading VG %s", vgname);
+
 		if (use_precommitted) {
 			log_error(INTERNAL_ERROR "vg_read_internal requires vgname "
 				  "with pre-commit.");
@@ -3780,6 +3776,12 @@ static struct volume_group *_vg_read(struct cmd_context *cmd,
 		return _vg_read_orphans(cmd, warn_flags, vgname, consistent);
 	}
 
+	uuid[0] = '\0';
+	if (vgid && !id_write_format((const struct id*)vgid, uuid, sizeof(uuid)))
+		stack;
+
+	log_very_verbose("Reading VG %s %s", vgname ?: "<no name>", vgid ? uuid : "<no vgid>");
+
 	if (lvmetad_used() && !use_precommitted) {
 		if ((correct_vg = lvmetad_vg_lookup(cmd, vgname, vgid))) {
 			dm_list_iterate_items(pvl, &correct_vg->pvs)


