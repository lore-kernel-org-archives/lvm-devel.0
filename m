From: David Teigland <teigland@fedoraproject.org>
Date: Tue, 21 Jun 2016 16:43:06 +0000 (UTC)
Subject: master - vgcfgrestore: rescan to reenable lvmetad on error path
Message-ID: <20160621164306.A4FE46114C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6c269e639a121329fc035685f944816a763b23cf
Commit:        6c269e639a121329fc035685f944816a763b23cf
Parent:        f96de674905cd9f109cd19e03ba5e92ac84104b8
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Jun 21 11:40:42 2016 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Jun 21 11:40:42 2016 -0500

vgcfgrestore: rescan to reenable lvmetad on error path

In commit 6ae22125, vgcfgrestore began disabling lvmetad
while running, and rescanned to enable it again at the end,
but missed the rescanning/enabling in the error case.
---
 tools/vgcfgrestore.c |   11 ++++++++---
 1 files changed, 8 insertions(+), 3 deletions(-)

diff --git a/tools/vgcfgrestore.c b/tools/vgcfgrestore.c
index 54e382c..77c007c 100644
--- a/tools/vgcfgrestore.c
+++ b/tools/vgcfgrestore.c
@@ -20,6 +20,7 @@ int vgcfgrestore(struct cmd_context *cmd, int argc, char **argv)
 {
 	const char *vg_name = NULL;
 	int lvmetad_rescan = 0;
+	int ret;
 
 	if (argc == 1) {
 		vg_name = skip_dev_dir(cmd, argv[0], NULL);
@@ -83,20 +84,24 @@ int vgcfgrestore(struct cmd_context *cmd, int argc, char **argv)
 		unlock_vg(cmd, VG_ORPHANS);
 		unlock_vg(cmd, vg_name);
 		log_error("Restore failed.");
-		return ECMD_FAILED;
+		ret = ECMD_FAILED;
+		goto rescan;
 	}
 
+	ret = ECMD_PROCESSED;
 	log_print_unless_silent("Restored volume group %s", vg_name);
 
 	unlock_vg(cmd, VG_ORPHANS);
 	unlock_vg(cmd, vg_name);
-
+rescan:
 	if (lvmetad_rescan) {
 		if (!lvmetad_connect(cmd)) {
 			log_warn("WARNING: Failed to connect to lvmetad.");
 			log_warn("WARNING: Update lvmetad with pvscan --cache.");
 			goto out;
 		}
+		if (!refresh_filters(cmd))
+			stack;
 		if (!lvmetad_pvscan_all_devs(cmd, 1)) {
 			log_warn("WARNING: Failed to scan devices.");
 			log_warn("WARNING: Update lvmetad with pvscan --cache.");
@@ -104,5 +109,5 @@ int vgcfgrestore(struct cmd_context *cmd, int argc, char **argv)
 		}
 	}
 out:
-	return ECMD_PROCESSED;
+	return ret;
 }


