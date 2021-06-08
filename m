From: David Teigland <teigland@sourceware.org>
Date: Tue,  8 Jun 2021 19:08:07 +0000 (GMT)
Subject: main - man/help: fix common option listing
Message-ID: <20210608190807.9A368398301F@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=df27392c8c9ec5d1efd92c2214805471473f2a06
Commit:        df27392c8c9ec5d1efd92c2214805471473f2a06
Parent:        ca930bd936de2e7d4a83fa64add800baf6cfd116
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Jun 8 14:07:39 2021 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Jun 8 14:07:39 2021 -0500

man/help: fix common option listing

---
 tools/command.c | 28 +++++++++++++++++++++++++++-
 1 file changed, 27 insertions(+), 1 deletion(-)

diff --git a/tools/command.c b/tools/command.c
index 1de739aaa..7205969e1 100644
--- a/tools/command.c
+++ b/tools/command.c
@@ -2146,6 +2146,7 @@ void print_usage_common_lvm(struct command_name *cname, struct command *cmd)
 void print_usage_common_cmd(struct command_name *cname, struct command *cmd)
 {
 	int oo, opt_enum;
+	int found_common_command = 0;
 
 	/*
 	 * when there's more than one variant, options that
@@ -2155,6 +2156,18 @@ void print_usage_common_cmd(struct command_name *cname, struct command *cmd)
 	if (cname->variants < 2)
 		return;
 
+	for (opt_enum = 0; opt_enum < ARG_COUNT; opt_enum++) {
+		if (!cname->common_options[opt_enum])
+			continue;
+		if (_is_lvm_all_opt(opt_enum))
+			continue;
+		found_common_command = 1;
+		break;
+	}
+
+	if (!found_common_command)
+		return;
+
 	printf("  Common options for command:");
 
 	/* print options with short opts */
@@ -2213,7 +2226,7 @@ void print_usage_common_cmd(struct command_name *cname, struct command *cmd)
 		printf(" ]");
 	}
 
-	printf(".P\n");
+	printf("\n\n");
 }
 
 void print_usage_notes(struct command_name *cname)
@@ -2994,6 +3007,7 @@ static void _print_man_usage_common_cmd(struct command *cmd)
 {
 	struct command_name *cname;
 	int i, sep, oo, opt_enum;
+	int found_common_command = 0;
 
 	if (!(cname = _find_command_name(cmd->name)))
 		return;
@@ -3001,6 +3015,18 @@ static void _print_man_usage_common_cmd(struct command *cmd)
 	if (cname->variants < 2)
 		return;
 
+	for (opt_enum = 0; opt_enum < ARG_COUNT; opt_enum++) {
+		if (!cname->common_options[opt_enum])
+			continue;
+		if (_is_lvm_all_opt(opt_enum))
+			continue;
+		found_common_command = 1;
+		break;
+	}
+
+	if (!found_common_command)
+		return;
+
 	printf("Common options for command:\n");
 	printf(".\n");
 


