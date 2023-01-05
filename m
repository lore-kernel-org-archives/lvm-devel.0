From: David Teigland <teigland@sourceware.org>
Date: Thu,  5 Jan 2023 20:48:59 +0000 (GMT)
Subject: main - vgimportclone: fix importing PV without metadata
Message-ID: <20230105204859.391CA3858D35@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=c4b898a53eec39bc28b5451e7fde87945303a644
Commit:        c4b898a53eec39bc28b5451e7fde87945303a644
Parent:        2580f007f0aaa3bf22c43295caa2c60c6142494f
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Jan 5 14:28:31 2023 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Jan 5 14:28:31 2023 -0600

vgimportclone: fix importing PV without metadata

If one of the PVs in the VG does not hold metadata, then the
command would fail, thinking that PV was from a different VG.
Also add missing free on that error path.
---
 tools/vgimportclone.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/tools/vgimportclone.c b/tools/vgimportclone.c
index 60ef20762..93fa3b18d 100644
--- a/tools/vgimportclone.c
+++ b/tools/vgimportclone.c
@@ -203,7 +203,7 @@ int vgimportclone(struct cmd_context *cmd, int argc, char **argv)
 	struct device *dev;
 	struct device_list *devl;
 	struct dm_list other_devs;
-	struct volume_group *vg, *error_vg;
+	struct volume_group *vg, *error_vg = NULL;
 	const char *vgname;
 	char base_vgname[NAME_LEN] = { 0 };
 	char tmp_vgname[NAME_LEN] = { 0 };
@@ -322,7 +322,7 @@ int vgimportclone(struct cmd_context *cmd, int argc, char **argv)
 			goto out;
 		}
 
-		if (!(vgname = lvmcache_vgname_from_info(info))) {
+		if (!(vgname = lvmcache_vgname_from_info(info)) || is_orphan_vg(vgname)) {
 			/* The PV may not have metadata, this will be resolved in
 			   the process_each_vg/vg_read at the end. */
 			continue;
@@ -503,6 +503,8 @@ retry_name:
 	}
 	ret = ECMD_PROCESSED;
 out:
+	if (error_vg)
+		release_vg(error_vg);
 	unlock_devices_file(cmd);
 	return ret;
 }

