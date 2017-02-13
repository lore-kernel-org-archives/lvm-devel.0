From: David Teigland <teigland@fedoraproject.org>
Date: Mon, 13 Feb 2017 18:10:35 +0000 (UTC)
Subject: master - lvm shell: clear argv for each command
Message-ID: <20170213181035.0AC7A6039D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=9a0f0c70bf59a5cd07828ff39e5ff04b4a5411ad
Commit:        9a0f0c70bf59a5cd07828ff39e5ff04b4a5411ad
Parent:        23a1ced4397b699ae572570ec772683d7003de6f
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Jan 13 12:02:06 2017 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Feb 13 08:20:10 2017 -0600

lvm shell: clear argv for each command

---
 tools/lvm.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/tools/lvm.c b/tools/lvm.c
index aae6da0..5fd9918 100644
--- a/tools/lvm.c
+++ b/tools/lvm.c
@@ -210,7 +210,7 @@ int lvm_shell(struct cmd_context *cmd, struct cmdline_context *cmdline)
 {
 	log_report_t saved_log_report_state = log_get_report_state();
 	char *orig_command_log_selection = NULL;
-	int is_lastlog_cmd = 0, argc, ret;
+	int is_lastlog_cmd = 0, argc, ret, i;
 	char *input = NULL, *args[MAX_ARGS], **argv;
 
 	rl_readline_name = "lvm";
@@ -262,6 +262,9 @@ int lvm_shell(struct cmd_context *cmd, struct cmdline_context *cmdline)
 
 		add_history(input);
 
+		for (i = 0; i < MAX_ARGS; i++)
+			args[i] = NULL;
+
 		argv = args;
 
 		if (lvm_split(input, &argc, argv, MAX_ARGS) == MAX_ARGS) {


