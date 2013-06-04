From: Petr Rockai <mornfall@fedoraproject.org>
Date: Tue,  4 Jun 2013 19:24:51 +0000 (UTC)
Subject: dev-mornfall-activate - cleanup: explicit check for nonnull pointer
Message-ID: <20130604192451.3854760F3D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=dfca5dac9ca3ed0ca186b9d79d6b2cacedc4ea37
Commit:        dfca5dac9ca3ed0ca186b9d79d6b2cacedc4ea37
Parent:        dd4fdce16c82225f7b8fce0b5ce294d8f3d2e4d6
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Apr 19 21:10:19 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun Apr 21 23:14:05 2013 +0200

cleanup: explicit check for nonnull pointer

Since execvp requires nonnull args - add explicit check.
---
 lib/misc/lvm-exec.c |    4 ++--
 tools/lvmcmdline.c  |    2 +-
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/lib/misc/lvm-exec.c b/lib/misc/lvm-exec.c
index 4b74a41..1b69635 100644
--- a/lib/misc/lvm-exec.c
+++ b/lib/misc/lvm-exec.c
@@ -54,7 +54,6 @@ int exec_cmd(struct cmd_context *cmd, const char *const argv[],
 	int status;
 	char buf[PATH_MAX * 2];
 
-
 	if (rstatus)
 		*rstatus = -1;
 
@@ -76,7 +75,8 @@ int exec_cmd(struct cmd_context *cmd, const char *const argv[],
 		/* FIXME Fix effect of reset_locking on cache then include this */
 		/* destroy_toolcontext(cmd); */
 		/* FIXME Use execve directly */
-		execvp(argv[0], (char **) argv);
+		if (argv[0])
+			execvp(argv[0], (char **) argv);
 		log_sys_error("execvp", argv[0]);
 		_exit(errno);
 	}
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index c69d20d..60aa4d9 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -1499,7 +1499,7 @@ int lvm2_main(int argc, char **argv)
 		return -1;
 
 	if (is_static() && strcmp(base, "lvm.static") &&
-	    path_exists(LVM_SHARED_PATH) &&
+	    path_exists(LVM_SHARED_PATH) && argv &&
 	    !getenv("LVM_DID_EXEC")) {
 		if (setenv("LVM_DID_EXEC", base, 1))
 			log_sys_error("setenv", "LVM_DID_EXEC");


