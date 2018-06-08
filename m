From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 8 Jun 2018 08:38:58 -0400
Subject: master - cleanup: updates message with dots
Message-ID: <201806081238.w58CcwSW006086@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=8b111f28b0cf75951c18f1b7f100e5aa59d4f659
Commit:        8b111f28b0cf75951c18f1b7f100e5aa59d4f659
Parent:        bc8c8d2f87a93a5f1c77a928e7400d31788fc6fd
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Jun 5 18:47:03 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jun 8 14:37:31 2018 +0200

cleanup: updates message with dots

---
 tools/vgcfgrestore.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/tools/vgcfgrestore.c b/tools/vgcfgrestore.c
index adcd45a..ec2c240 100644
--- a/tools/vgcfgrestore.c
+++ b/tools/vgcfgrestore.c
@@ -25,7 +25,7 @@ int vgcfgrestore(struct cmd_context *cmd, int argc, char **argv)
 	if (argc == 1) {
 		vg_name = skip_dev_dir(cmd, argv[0], NULL);
 		if (!validate_name(vg_name)) {
-			log_error("Volume group name \"%s\" is invalid", vg_name);
+			log_error("Volume group name \"%s\" is invalid.", vg_name);
 			return EINVALID_CMD_LINE;
 		}
 	} else if (!(arg_is_set(cmd, list_ARG) && arg_is_set(cmd, file_ARG))) {
@@ -64,12 +64,12 @@ int vgcfgrestore(struct cmd_context *cmd, int argc, char **argv)
 	}
 
 	if (!lock_vol(cmd, vg_name, LCK_VG_WRITE, NULL)) {
-		log_error("Unable to lock volume group %s", vg_name);
+		log_error("Unable to lock volume group %s.", vg_name);
 		return ECMD_FAILED;
 	}
 
 	if (!lock_vol(cmd, VG_ORPHANS, LCK_VG_WRITE, NULL)) {
-		log_error("Unable to lock orphans");
+		log_error("Unable to lock orphans.");
 		unlock_vg(cmd, NULL, vg_name);
 		return ECMD_FAILED;
 	}
@@ -91,7 +91,7 @@ int vgcfgrestore(struct cmd_context *cmd, int argc, char **argv)
 	}
 
 	ret = ECMD_PROCESSED;
-	log_print_unless_silent("Restored volume group %s", vg_name);
+	log_print_unless_silent("Restored volume group %s.", vg_name);
 
 	unlock_vg(cmd, NULL, VG_ORPHANS);
 	unlock_vg(cmd, NULL, vg_name);


