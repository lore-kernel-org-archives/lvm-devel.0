From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 26 Apr 2016 21:31:26 +0000 (UTC)
Subject: master - modprobe: check /sys/module entry first
Message-ID: <20160426213126.1101E60663@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=aa91fe3d3c3e6c2d8d96f5c0766b58375a44daa9
Commit:        aa91fe3d3c3e6c2d8d96f5c0766b58375a44daa9
Parent:        ecae76c713bd4fa6c9d8f2a2c990625e4f38b504
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Apr 26 21:41:04 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Apr 26 23:23:03 2016 +0200

modprobe: check /sys/module entry first

Before executing modprobe for given module name, just check
if the module is not already present in /sys/module.

Useful when checking dm-cache-policy modules as we do not
having matching interface like for targets.
---
 WHATS_NEW               |    1 +
 lib/activate/activate.c |   17 +++++++++++++++++
 2 files changed, 18 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 1aa335e..2a4fdd5 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.152 - 
 ==================================
+  Check first /sys/module/dm_* dir existance before using modprobe.
   Remove mpath from 10-dm.rules, superseded by 11-dm-mpath.rules (mpath>=0.6.0).
 
 Version 2.02.151 - 23rd April 2016
diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index 76afc3d..f554f19 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -603,7 +603,24 @@ int module_present(struct cmd_context *cmd, const char *target_name)
 #ifdef MODPROBE_CMD
 	char module[128];
 	const char *argv[] = { MODPROBE_CMD, module, NULL };
+#endif
+	struct stat st;
+	char path[PATH_MAX];
+	int i = dm_snprintf(path, (sizeof(path) - 1), "%smodule/dm_%s",
+			    dm_sysfs_dir(), target_name);
+
+	if (i > 0) {
+		while (path[--i] != '/')  /* stop on dm_ */
+			if (path[i] == '-')
+				path[i] = '_'; /* replace '-' with '_' */
+
+		if ((lstat(path, &st) == 0) && S_ISDIR(st.st_mode)) {
+			log_debug("Module directory %s exists.", path);
+			return 1;
+		}
+	}
 
+#ifdef MODPROBE_CMD
 	if (dm_snprintf(module, sizeof(module), "dm-%s", target_name) < 0) {
 		log_error("module_present module name too long: %s",
 			  target_name);


