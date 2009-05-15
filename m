From: Milan Broz <mbroz@redhat.com>
Date: Fri, 15 May 2009 13:39:29 +0200
Subject: [PATCH] add error message if vgcfg fails because og missing PVs
Message-ID: <4A0D5471.4050307@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

vgcfgrestore should not quietly fail when backup file has missing PVs.

(my previous comment in code is wrong, there are situation when vg_read prints nothing)

Signed-off-by: Milan Broz <mbroz@redhat.com>
---
 lib/format_text/archiver.c |   11 ++++++-----
 1 files changed, 6 insertions(+), 5 deletions(-)

diff --git a/lib/format_text/archiver.c b/lib/format_text/archiver.c
index 5362adb..d80c0ba 100644
--- a/lib/format_text/archiver.c
+++ b/lib/format_text/archiver.c
@@ -335,7 +335,7 @@ int backup_restore_from_file(struct cmd_context *cmd, const char *vg_name,
 			     const char *file)
 {
 	struct volume_group *vg;
-	int r = 0;
+	int missing_pvs, r = 0;
 
 	/*
 	 * Read in the volume group from the text file.
@@ -343,11 +343,12 @@ int backup_restore_from_file(struct cmd_context *cmd, const char *vg_name,
 	if (!(vg = backup_read_vg(cmd, vg_name, file)))
 		return_0;
 
-	/*
-	 * If PV is missing, there is already message from read above
-	 */
-	if (!vg_missing_pv_count(vg))
+	missing_pvs = vg_missing_pv_count(vg);
+	if (missing_pvs == 0)
 		r = backup_restore_vg(cmd, vg);
+	else
+		log_error("Cannot restore Volume Group %s with %i PVs "
+			  "marked as missing.", vg->name, missing_pvs);
 
 	vg_release(vg);
 	return r;



