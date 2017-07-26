From: Alasdair Kergon <agk@sourceware.org>
Date: Wed, 26 Jul 2017 19:46:10 -0400
Subject: master - tools: Introduce exit code EINIT_FAILED.
Message-ID: <201707262346.v6QNkAOL017442@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=54f5bc01b9509f80b3e8fe16f8bb1bc0228265ab
Commit:        54f5bc01b9509f80b3e8fe16f8bb1bc0228265ab
Parent:        f9f75de3da98e0f6f43d46539e4c17781d209478
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Wed Jul 26 23:18:03 2017 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Wed Jul 26 23:18:03 2017 +0100

tools: Introduce exit code EINIT_FAILED.

Replace -1 (reported as 255) by 4.
---
 WHATS_NEW          |    1 +
 tools/errors.h     |    1 +
 tools/lvm2cmd.h    |    1 +
 tools/lvmcmdline.c |   14 +++++++-------
 4 files changed, 10 insertions(+), 7 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index a9b3a08..20da268 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.174 - 
 =================================
+  Introduce exit code 4 EINIT_FAILED to replace -1 when initialisation fails.
   Add synchronization points with udev during reshape of raid LVs.
 
 Version 2.02.173 - 20th July 2017
diff --git a/tools/errors.h b/tools/errors.h
index bfc0461..3d87a48 100644
--- a/tools/errors.h
+++ b/tools/errors.h
@@ -19,6 +19,7 @@
 #define ECMD_PROCESSED		1
 #define ENO_SUCH_CMD		2
 #define EINVALID_CMD_LINE	3
+#define EINIT_FAILED		4
 #define ECMD_FAILED		5
 
 /* FIXME Also returned by cmdlib. */
diff --git a/tools/lvm2cmd.h b/tools/lvm2cmd.h
index 2966ec9..cd2e0ec 100644
--- a/tools/lvm2cmd.h
+++ b/tools/lvm2cmd.h
@@ -40,6 +40,7 @@ typedef void (*lvm2_log_fn_t) (int level, const char *file, int line,
 #define LVM2_COMMAND_SUCCEEDED	1	/* ECMD_PROCESSED */
 #define LVM2_NO_SUCH_COMMAND	2	/* ENO_SUCH_CMD */
 #define LVM2_INVALID_PARAMETERS	3	/* EINVALID_CMD_LINE */
+#define LVM2_INIT_FAILED	4	/* EINIT_FAILED */
 #define LVM2_PROCESSING_FAILED	5	/* ECMD_FAILED */
 
 /*
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index ae55e12..81cc5e0 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -3420,7 +3420,7 @@ int lvm2_main(int argc, char **argv)
 	const char *run_command_name = NULL;
 
 	if (!argv)
-		return -1;
+		return EINIT_FAILED;
 
 	base = last_path_component(argv[0]);
 	if (strcmp(base, "lvm") && strcmp(base, "lvm.static") &&
@@ -3428,16 +3428,16 @@ int lvm2_main(int argc, char **argv)
 		alias = 1;
 
 	if (!_check_standard_fds())
-		return -1;
+		return EINIT_FAILED;
 
 	if (!_get_custom_fds(&custom_fds))
-		return -1;
+		return EINIT_FAILED;
 
 	if (!_close_stray_fds(base, &custom_fds))
-		return -1;
+		return EINIT_FAILED;
 
 	if (!init_custom_log_streams(&custom_fds))
-		return -1;
+		return EINIT_FAILED;
 
 	if (is_static() && strcmp(base, "lvm.static") &&
 	    path_exists(LVM_PATH) &&
@@ -3461,12 +3461,12 @@ int lvm2_main(int argc, char **argv)
 
 		if (*argv[1] == '-') {
 			log_error("Specify options after a command: lvm [command] [options].");
-			return -1;
+			return EINVALID_CMD_LINE;
 		}
 	}
 
 	if (!(cmd = init_lvm(0, 0)))
-		return -1;
+		return EINIT_FAILED;
 
 	/* Store original argv location so we may customise it if we become a daemon */
 	cmd->argv = argv;


