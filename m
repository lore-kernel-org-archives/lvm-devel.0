From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Sat,  6 May 2023 20:46:12 +0000 (GMT)
Subject: main - cov: check syscall result
Message-ID: <20230506204612.08A373858D28@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=58293173cf4d05d3bffa905875442567e5ca4780
Commit:        58293173cf4d05d3bffa905875442567e5ca4780
Parent:        f038fc3b177c43b9bb0929f5dcc834e24574df03
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Apr 26 16:36:42 2023 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat May 6 20:38:57 2023 +0200

cov: check syscall result

---
 tools/vgimportdevices.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/tools/vgimportdevices.c b/tools/vgimportdevices.c
index 07d07402a..bccd94f61 100644
--- a/tools/vgimportdevices.c
+++ b/tools/vgimportdevices.c
@@ -233,7 +233,8 @@ int vgimportdevices(struct cmd_context *cmd, int argc, char **argv)
 	log_print("Added %u devices to devices file.", vp.added_devices);
 out:
 	if ((ret == ECMD_FAILED) && created_file)
-		unlink(cmd->devices_file_path);
+		if (unlink(cmd->devices_file_path) < 0)
+			log_sys_debug("unlink", cmd->devices_file_path);
 	destroy_processing_handle(cmd, handle);
 	return ret;
 }

