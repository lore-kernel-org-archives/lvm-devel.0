From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 19 Mar 2014 00:02:18 +0000 (UTC)
Subject: master - pvscan: cleanup updates
Message-ID: <20140319000218.E30DD60FD8@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=852a2b98be2c83a3ddb31396f49854a3d14cf6ed
Commit:        852a2b98be2c83a3ddb31396f49854a3d14cf6ed
Parent:        3d7eaf9226d6e425721f12da5ff4cd47209324df
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Mar 19 00:19:01 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Mar 19 00:58:02 2014 +0100

pvscan: cleanup updates

Simplify code:
 remove unneeded assignments
 use unsigned values for length
---
 tools/pvscan.c |   30 ++++++++++++------------------
 1 files changed, 12 insertions(+), 18 deletions(-)

diff --git a/tools/pvscan.c b/tools/pvscan.c
index cb2f3f9..6a74ac0 100644
--- a/tools/pvscan.c
+++ b/tools/pvscan.c
@@ -18,8 +18,8 @@
 #include "lvmetad.h"
 #include "lvmcache.h"
 
-int pv_max_name_len = 0;
-int vg_max_name_len = 0;
+unsigned pv_max_name_len = 0;
+unsigned vg_max_name_len = 0;
 
 static void _pvscan_display_single(struct cmd_context *cmd,
 				   struct physical_volume *pv,
@@ -34,7 +34,7 @@ static void _pvscan_display_single(struct cmd_context *cmd,
 
 	/* short listing? */
 	if (arg_count(cmd, short_ARG) > 0) {
-		log_print_unless_silent("%s", pv_dev_name(pv));
+		log_print_unless_silent("%s", pvdevname);
 		return;
 	}
 
@@ -331,10 +331,7 @@ int pvscan(struct cmd_context *cmd, int argc, char **argv)
 
 	uint64_t size_total = 0;
 	uint64_t size_new = 0;
-
-	int len = 0;
-	pv_max_name_len = 0;
-	vg_max_name_len = 0;
+	unsigned len;
 
 	if (arg_count(cmd, cache_ARG))
 		return _pvscan_lvmetad(cmd, argc, argv);
@@ -429,18 +426,15 @@ int pvscan(struct cmd_context *cmd, int argc, char **argv)
 		free_pv_fid(pvl->pv);
 	}
 
-	if (!pvs_found) {
+	if (!pvs_found)
 		log_print_unless_silent("No matching physical volumes found");
-		unlock_vg(cmd, VG_GLOBAL);
-		return ECMD_PROCESSED;
-	}
-
-	log_print_unless_silent("Total: %d [%s] / in use: %d [%s] / in no VG: %d [%s]",
-				pvs_found,
-				display_size(cmd, size_total),
-				pvs_found - new_pvs_found,
-				display_size(cmd, (size_total - size_new)),
-				new_pvs_found, display_size(cmd, size_new));
+	else
+		log_print_unless_silent("Total: %d [%s] / in use: %d [%s] / in no VG: %d [%s]",
+					pvs_found,
+					display_size(cmd, size_total),
+					pvs_found - new_pvs_found,
+					display_size(cmd, (size_total - size_new)),
+					new_pvs_found, display_size(cmd, size_new));
 
 	unlock_vg(cmd, VG_GLOBAL);
 


