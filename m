From: Alasdair Kergon <agk@fedoraproject.org>
Date: Wed,  4 Mar 2015 01:01:49 +0000 (UTC)
Subject: master - systemid: Init and merge lvm2 and lvm1 fields.
Message-ID: <20150304010149.B46826111C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=3562b5ab39b32bd27c81f57185e397facb7690f5
Commit:        3562b5ab39b32bd27c81f57185e397facb7690f5
Parent:        dcba4781eaa5545981a831c3c27374d3fce085fe
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Wed Mar 4 01:00:51 2015 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Wed Mar 4 01:00:51 2015 +0000

systemid: Init and merge lvm2 and lvm1 fields.

Use system_id field in preference to lvm1_system_id.
Initialise both for now.
---
 lib/display/display.c         |    2 +-
 lib/format1/import-export.c   |    4 +++-
 lib/format_text/export.c      |    4 +++-
 lib/format_text/import_vsn1.c |    2 --
 lib/metadata/vg.c             |    5 +++++
 lib/report/report.c           |    2 +-
 tools/toollib.c               |    5 +++--
 tools/vgchange.c              |    3 +++
 8 files changed, 19 insertions(+), 8 deletions(-)

diff --git a/lib/display/display.c b/lib/display/display.c
index b511b8e..cf3c7f6 100644
--- a/lib/display/display.c
+++ b/lib/display/display.c
@@ -695,7 +695,7 @@ void vgdisplay_full(const struct volume_group *vg)
 
 	log_print("--- Volume group ---");
 	log_print("VG Name               %s", vg->name);
-	log_print("System ID             %s", vg->system_id);
+	log_print("System ID             %s", (vg->system_id && *vg->system_id) ? vg->system_id : vg->lvm1_system_id ? : "");
 	log_print("Format                %s", vg->fid->fmt->name);
 	if (vg->fid->fmt->features & FMT_MDAS) {
 		log_print("Metadata Areas        %d",
diff --git a/lib/format1/import-export.c b/lib/format1/import-export.c
index 8155b04..9b387e2 100644
--- a/lib/format1/import-export.c
+++ b/lib/format1/import-export.c
@@ -156,8 +156,10 @@ int export_pv(struct cmd_context *cmd, struct dm_pool *mem __attribute__((unused
 	}
 
 	/* Preserve existing system_id if it exists */
-	if (vg && *vg->lvm1_system_id)
+	if (vg && vg->lvm1_system_id && *vg->lvm1_system_id)
 		strncpy((char *)pvd->system_id, vg->lvm1_system_id, sizeof(pvd->system_id));
+	else if (vg && vg->system_id && *vg->system_id)
+		strncpy((char *)pvd->system_id, vg->system_id, sizeof(pvd->system_id));
 
 	/* Is VG already exported or being exported? */
 	if (vg && vg_is_exported(vg)) {
diff --git a/lib/format_text/export.c b/lib/format_text/export.c
index ddaaebb..8232e2f 100644
--- a/lib/format_text/export.c
+++ b/lib/format_text/export.c
@@ -414,9 +414,11 @@ static int _print_vg(struct formatter *f, struct volume_group *vg)
 
 	if (!_out_tags(f, &vg->tags))
 		return_0;
-
+ 
 	if (vg->system_id && *vg->system_id)
 		outf(f, "system_id = \"%s\"", vg->system_id);
+	else if (vg->lvm1_system_id && *vg->lvm1_system_id)
+		outf(f, "system_id = \"%s\"", vg->lvm1_system_id);
 
 	outsize(f, (uint64_t) vg->extent_size, "extent_size = %u",
 		vg->extent_size);
diff --git a/lib/format_text/import_vsn1.c b/lib/format_text/import_vsn1.c
index 366e61c..64c08a0 100644
--- a/lib/format_text/import_vsn1.c
+++ b/lib/format_text/import_vsn1.c
@@ -883,8 +883,6 @@ static struct volume_group *_read_vg(struct format_instance *fid,
 	dm_hash_destroy(pv_hash);
 	dm_hash_destroy(lv_hash);
 
-	/* FIXME Determine format type from file contents */
-	/* eg Set to instance of fmt1 here if reading a format1 backup? */
 	vg_set_fid(vg, fid);
 
 	/*
diff --git a/lib/metadata/vg.c b/lib/metadata/vg.c
index 2bed1ad..404cc6f 100644
--- a/lib/metadata/vg.c
+++ b/lib/metadata/vg.c
@@ -47,6 +47,8 @@ struct volume_group *alloc_vg(const char *pool_name, struct cmd_context *cmd,
 		return NULL;
 	}
 
+	vg->system_id = "";
+
 	vg->cmd = cmd;
 	vg->vgmem = vgmem;
 	vg->alloc = ALLOC_NORMAL;
@@ -627,6 +629,9 @@ int vg_set_system_id(struct volume_group *vg, const char *system_id)
 		return 0;
 	}
 
+	if (vg->lvm1_system_id)
+		*vg->lvm1_system_id = '\0';
+
 	return 1;
 }
 
diff --git a/lib/report/report.c b/lib/report/report.c
index b5418e5..75928c0 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -989,7 +989,7 @@ static int _vgsystemid_disp(struct dm_report *rh, struct dm_pool *mem,
 			    const void *data, void *private)
 {
 	const struct volume_group *vg = (const struct volume_group *) data;
-	const char *repstr = vg->system_id ? : vg->lvm1_system_id ? : "";
+	const char *repstr = (vg->system_id && *vg->system_id) ? vg->system_id : vg->lvm1_system_id ? : "";
 
 	return _string_disp(rh, mem, field, &repstr, private);
 }
diff --git a/tools/toollib.c b/tools/toollib.c
index 19c23fe..12fe1e2 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -200,8 +200,9 @@ static int _ignore_vg(struct volume_group *vg, const char *vg_name,
 	 */
 	if (read_error & FAILED_SYSTEMID) {
 		if (arg_vgnames && str_list_match_item(arg_vgnames, vg->name)) {
-			log_error("Cannot access VG %s with system ID %s with local system ID %s.",
-				  vg->name, vg->system_id, vg->cmd->system_id);
+			log_error("Cannot access VG %s with system ID %s with %slocal system ID%s%s.",
+				  vg->name, vg->system_id, vg->cmd->system_id ? "" : "unknown ",
+				  vg->cmd->system_id ? " " : "", vg->cmd->system_id ? vg->cmd->system_id : "");
 			return 1;
 		} else {
 			read_error &= ~FAILED_SYSTEMID; /* Check for other errors */
diff --git a/tools/vgchange.c b/tools/vgchange.c
index 3f97722..36b44a9 100644
--- a/tools/vgchange.c
+++ b/tools/vgchange.c
@@ -575,6 +575,9 @@ static int _vgchange_system_id(struct cmd_context *cmd, struct volume_group *vg)
 		    vg->name, vg->system_id, system_id);
 
 	vg->system_id = system_id;
+	
+	if (vg->lvm1_system_id)
+		*vg->lvm1_system_id = '\0';
 
 	return 1;
 }


