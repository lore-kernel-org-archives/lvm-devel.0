From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 12 Feb 2018 16:20:34 -0500
Subject: master - vgimportclone: add some dm_snprintf checks
Message-ID: <201802122120.w1CLKYYi023670@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=d94036f8ed412457f2044f0b36aebe24f7fcc707
Commit:        d94036f8ed412457f2044f0b36aebe24f7fcc707
Parent:        60b61f2db3d6e98329213e11b65581ea1ee080a5
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Feb 9 17:06:30 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Feb 12 22:14:22 2018 +0100

vgimportclone: add some dm_snprintf checks

Check if the generated vg name still fits the buffer.
So too long strings are rejected.
Drop -1  from size passed to snprintf - as the \0 is already included.
---
 WHATS_NEW             |    1 +
 tools/vgimportclone.c |   23 ++++++++++++++++++-----
 2 files changed, 19 insertions(+), 5 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 74f9616..1ffa3db 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.178 - 
 =====================================
+  Improve validation of created strings in vgimportclone.
   Add missing initialisation of mem pool in systemd generator.
   Do not reopen output streams for multithreaded users of liblvm.
   Use versionsort to fix archive file expiry beyond 100000 files.
diff --git a/tools/vgimportclone.c b/tools/vgimportclone.c
index 1f86ad6..146d3b4 100644
--- a/tools/vgimportclone.c
+++ b/tools/vgimportclone.c
@@ -283,12 +283,22 @@ int vgimportclone(struct cmd_context *cmd, int argc, char **argv)
 	 */
 
 	if (arg_is_set(cmd, basevgname_ARG)) {
-		snprintf(base_vgname, sizeof(base_vgname) - 1, "%s", arg_str_value(cmd, basevgname_ARG, ""));
-		memcpy(tmp_vgname, base_vgname, NAME_LEN);
+		vgname = arg_str_value(cmd, basevgname_ARG, "");
+		if (dm_snprintf(base_vgname, sizeof(base_vgname), "%s", vgname) < 0) {
+			log_error("Base vg name %s is too long.", vgname);
+			goto out;
+		}
+		(void) dm_strncpy(tmp_vgname, base_vgname, NAME_LEN);
 		vgname_count = 0;
 	} else {
-		snprintf(base_vgname, sizeof(base_vgname) - 1, "%s", vp.old_vgname);
-		snprintf(tmp_vgname, sizeof(tmp_vgname) - 1, "%s1", vp.old_vgname);
+		if (dm_snprintf(base_vgname, sizeof(base_vgname), "%s", vp.old_vgname) < 0) {
+			log_error(INTERNAL_ERROR "Old vg name %s is too long.", vp.old_vgname);
+			goto out;
+		}
+		if (dm_snprintf(tmp_vgname, sizeof(tmp_vgname), "%s1", vp.old_vgname) < 0) {
+			log_error("Temporary vg name %s1 is too long.", vp.old_vgname);
+			goto out;
+		}
 		vgname_count = 1;
 	}
 
@@ -299,7 +309,10 @@ retry_name:
 	dm_list_iterate_items(vgnl, &vgnameids_on_system) {
 		if (!strcmp(vgnl->vg_name, tmp_vgname)) {
 			vgname_count++;
-			snprintf(tmp_vgname, sizeof(tmp_vgname) - 1, "%s%u", base_vgname, vgname_count);
+			if (dm_snprintf(tmp_vgname, sizeof(tmp_vgname), "%s%u", base_vgname, vgname_count) < 0) {
+				log_error("Failed to generated temporary vg name, %s%u is too long.", base_vgname, vgname_count);
+				goto out;
+			}
 			goto retry_name;
 		}
 	}


