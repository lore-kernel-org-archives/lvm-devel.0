From: David Teigland <teigland@sourceware.org>
Date: Thu,  4 Nov 2021 16:37:11 +0000 (GMT)
Subject: main - rename pvscan_cache_single to expect_missing_vg_device in cmd
Message-ID: <20211104163711.D99C6385840F@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=594f6ca97024fa23dfa852b6cc9da272877e1ced
Commit:        594f6ca97024fa23dfa852b6cc9da272877e1ced
Parent:        726dd25969e9e6a3de285a22cea45e9f5f53520f
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Nov 3 09:50:11 2021 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Nov 4 11:08:38 2021 -0500

rename pvscan_cache_single to expect_missing_vg_device in cmd

---
 lib/commands/toolcontext.h | 2 +-
 lib/device/device_id.c     | 5 ++---
 lib/metadata/metadata.c    | 4 ++--
 tools/pvscan.c             | 2 +-
 4 files changed, 6 insertions(+), 7 deletions(-)

diff --git a/lib/commands/toolcontext.h b/lib/commands/toolcontext.h
index e864932f2..0ae45ccc0 100644
--- a/lib/commands/toolcontext.h
+++ b/lib/commands/toolcontext.h
@@ -174,7 +174,7 @@ struct cmd_context {
 	unsigned activate_component:1;		/* command activates component LV */
 	unsigned process_component_lvs:1;	/* command processes also component LVs */
 	unsigned mirror_warn_printed:1;		/* command already printed warning about non-monitored mirrors */
-	unsigned pvscan_cache_single:1;
+	unsigned expect_missing_vg_device:1;	/* when reading a vg it's expected that a dev for a pv isn't found */
 	unsigned can_use_one_scan:1;
 	unsigned is_clvmd:1;
 	unsigned md_component_detection:1;
diff --git a/lib/device/device_id.c b/lib/device/device_id.c
index 167bf661b..18669630c 100644
--- a/lib/device/device_id.c
+++ b/lib/device/device_id.c
@@ -778,9 +778,8 @@ static void _device_ids_update_try(struct cmd_context *cmd)
 {
 	int held = 0;
 
-	/* Defer updates to non-pvscan-cache commands. */
-	if (cmd->pvscan_cache_single) {
-		log_print("pvscan[%d] skip updating devices file.", getpid());
+	if (cmd->expect_missing_vg_device) {
+		log_print("skip updating devices file.");
 		return;
 	}
 
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index c4f65366b..f01a0bea6 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -3558,7 +3558,7 @@ static void _set_pv_device(struct format_instance *fid,
 		if (!id_write_format(&pv->id, buffer, sizeof(buffer)))
 			buffer[0] = '\0';
 
-		if (cmd && !cmd->pvscan_cache_single &&
+		if (cmd && !cmd->expect_missing_vg_device &&
 		    (!vg_is_foreign(vg) && !cmd->include_foreign_vgs))
 			log_warn("WARNING: Couldn't find device with uuid %s.", buffer);
 		else
@@ -5084,7 +5084,7 @@ struct volume_group *vg_read(struct cmd_context *cmd, const char *vg_name, const
 		if (!pvl->pv->dev) {
 			/* The obvious and common case of a missing device. */
 
-			if (vg_is_foreign(vg) && !cmd->include_foreign_vgs)
+			if ((vg_is_foreign(vg) && !cmd->include_foreign_vgs) || cmd->expect_missing_vg_device)
 				log_debug("VG %s is missing PV %s (last written to %s)", vg_name, uuidstr, pvl->pv->device_hint ?: "na");
 			else if (pvl->pv->device_hint)
 				log_warn("WARNING: VG %s is missing PV %s (last written to %s).", vg_name, uuidstr, pvl->pv->device_hint);
diff --git a/tools/pvscan.c b/tools/pvscan.c
index 01f57af0c..4f97e211c 100644
--- a/tools/pvscan.c
+++ b/tools/pvscan.c
@@ -1679,7 +1679,7 @@ static int _pvscan_cache_args(struct cmd_context *cmd, int argc, char **argv,
 	dm_list_init(&pvscan_args);
 	dm_list_init(&pvscan_devs);
 
-	cmd->pvscan_cache_single = 1;
+	cmd->expect_missing_vg_device = 1;
 
 	/*
 	 * Special pvscan-specific setup steps to avoid looking


