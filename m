From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 27 Jun 2017 06:20:18 -0400
Subject: master - coverity: drop unneeded assigns
Message-ID: <201706271020.v5RAKIXA003919@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=0349b6d889551b33d4bf26ffaa71dc6c0eb88198
Commit:        0349b6d889551b33d4bf26ffaa71dc6c0eb88198
Parent:        419e8284c8b918558b20bc1e2194ad2cbdd5d58b
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Jun 27 11:38:56 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Jun 27 12:15:42 2017 +0200

coverity: drop unneeded assigns

---
 tools/command.c  |    2 --
 tools/reporter.c |    2 +-
 tools/toollib.c  |    2 +-
 3 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/tools/command.c b/tools/command.c
index b8b38ad..5c2ec26 100644
--- a/tools/command.c
+++ b/tools/command.c
@@ -1817,8 +1817,6 @@ void print_usage(struct command *cmd, int longhelp, int desc_first)
 	}
 
 	if (!onereq && cmd->ro_count) {
-		first = 1;
-
 		for (ro = 0; ro < cmd->ro_count; ro++) {
 			opt_enum = cmd->required_opt_args[ro].opt;
 
diff --git a/tools/reporter.c b/tools/reporter.c
index b9c4153..ad9d5ee 100644
--- a/tools/reporter.c
+++ b/tools/reporter.c
@@ -1387,7 +1387,7 @@ static int _report(struct cmd_context *cmd, int argc, char **argv, report_type_t
 	struct single_report_args *single_args = &args.single_args[REPORT_IDX_SINGLE];
 	static char report_name[] = "report";
 	struct processing_handle *handle;
-	int r = ECMD_FAILED;
+	int r;
 
 	/*
 	 * Include foreign VGs that contain active LVs.
diff --git a/tools/toollib.c b/tools/toollib.c
index 622dbf3..452c8b0 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -2690,7 +2690,7 @@ static int _lv_props_match(struct cmd_context *cmd, struct logical_volume *lv, u
 
 static int _check_lv_types(struct cmd_context *cmd, struct logical_volume *lv, int pos)
 {
-	int ret = 1;
+	int ret;
 
 	if (!pos)
 		return 1;


