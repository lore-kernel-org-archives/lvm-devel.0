From: Dave Wysochanski <dwysocha@redhat.com>
Date: Fri, 10 Jul 2009 11:38:55 -0400
Subject: [PATCH 5/5] Change lock ordering of vgcfgrestore to be consistent with other tools.
In-Reply-To: <1247240335-18769-5-git-send-email-dwysocha@redhat.com>
References: <1247240335-18769-1-git-send-email-dwysocha@redhat.com>
	<1247240335-18769-2-git-send-email-dwysocha@redhat.com>
	<1247240335-18769-3-git-send-email-dwysocha@redhat.com>
	<1247240335-18769-4-git-send-email-dwysocha@redhat.com>
	<1247240335-18769-5-git-send-email-dwysocha@redhat.com>
Message-ID: <1247240335-18769-6-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Orphan lock is now obtained second and released first.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 tools/vgcfgrestore.c |   12 ++++++------
 1 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/tools/vgcfgrestore.c b/tools/vgcfgrestore.c
index 6ec20d1..e1d6bb4 100644
--- a/tools/vgcfgrestore.c
+++ b/tools/vgcfgrestore.c
@@ -43,17 +43,17 @@ int vgcfgrestore(struct cmd_context *cmd, int argc, char **argv)
 		return ECMD_PROCESSED;
 	}
 
-	if (!lock_vol(cmd, VG_ORPHANS, LCK_VG_WRITE)) {
-		log_error("Unable to lock orphans");
-		return ECMD_FAILED;
-	}
-
 	if (!lock_vol(cmd, vg_name, LCK_VG_WRITE)) {
 		log_error("Unable to lock volume group %s", vg_name);
 		unlock_vg(cmd, VG_ORPHANS);
 		return ECMD_FAILED;
 	}
 
+	if (!lock_vol(cmd, VG_ORPHANS, LCK_VG_WRITE)) {
+		log_error("Unable to lock orphans");
+		return ECMD_FAILED;
+	}
+
 	if (!(arg_count(cmd, file_ARG) ?
 	      backup_restore_from_file(cmd, vg_name,
 				       arg_str_value(cmd, file_ARG, "")) :
@@ -66,7 +66,7 @@ int vgcfgrestore(struct cmd_context *cmd, int argc, char **argv)
 
 	log_print("Restored volume group %s", vg_name);
 
-	unlock_vg(cmd, vg_name);
 	unlock_vg(cmd, VG_ORPHANS);
+	unlock_vg(cmd, vg_name);
 	return ECMD_PROCESSED;
 }
-- 
1.6.0.6


