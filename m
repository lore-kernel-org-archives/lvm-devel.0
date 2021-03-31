From: David Teigland <teigland@sourceware.org>
Date: Wed, 31 Mar 2021 21:48:32 +0000 (GMT)
Subject: dev-next - gcc: declaration of tmpfile shadows a global
Message-ID: <20210331214832.092C43858C27@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=09621725d0ea2a27e462f44139a54096ccadeb19
Commit:        09621725d0ea2a27e462f44139a54096ccadeb19
Parent:        b6cff47bdeef4906d675dad71277a706db0b9127
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Mar 21 23:32:12 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Mar 22 22:35:56 2021 +0100

gcc: declaration of tmpfile shadows a global

Rename tmpfile to tmppath to avoid declaration shadowing of:

/usr/include/stdio.h:174: warning: shadowed declaration is here
---
 lib/device/device_id.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/lib/device/device_id.c b/lib/device/device_id.c
index 2de8b0a14..cf5867dab 100644
--- a/lib/device/device_id.c
+++ b/lib/device/device_id.c
@@ -604,7 +604,7 @@ out:
 int device_ids_write(struct cmd_context *cmd)
 {
 	char dirpath[PATH_MAX];
-	char tmpfile[PATH_MAX];
+	char tmppath[PATH_MAX];
 	char version_buf[VERSION_LINE_MAX] = {0};
 	FILE *fp;
 	int dir_fd;
@@ -674,14 +674,14 @@ int device_ids_write(struct cmd_context *cmd)
 		goto out;
 	}
 
-	if (dm_snprintf(tmpfile, sizeof(tmpfile), "%s_new", cmd->devices_file_path) < 0) {
+	if (dm_snprintf(tmppath, sizeof(tmppath), "%s_new", cmd->devices_file_path) < 0) {
 		ret = 0;
 		goto out;
 	}
 
-	unlink(tmpfile); /* in case a previous file was left */
+	unlink(tmppath); /* in case a previous file was left */
 
-	if (!(fp = fopen(tmpfile, "w+"))) {
+	if (!(fp = fopen(tmppath, "w+"))) {
 		log_warn("Cannot open tmp devices_file to write.");
 		ret = 0;
 		goto out;
@@ -689,7 +689,7 @@ int device_ids_write(struct cmd_context *cmd)
 
 	if ((dir_fd = open(dirpath, O_RDONLY)) < 0) {
 		if (fclose(fp))
-                        log_sys_debug("fclose", tmpfile);
+                        log_sys_debug("fclose", tmppath);
 		ret = 0;
 		goto out;
 	}
@@ -744,7 +744,7 @@ int device_ids_write(struct cmd_context *cmd)
 	if (fclose(fp))
 		stack;
 
-	if (rename(tmpfile, cmd->devices_file_path) < 0) {
+	if (rename(tmppath, cmd->devices_file_path) < 0) {
 		log_error("Failed to replace devices file errno %d", errno);
 		ret = 0;
 	}


