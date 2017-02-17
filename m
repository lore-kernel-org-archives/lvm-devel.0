From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 17 Feb 2017 12:25:42 +0000 (UTC)
Subject: master - cleanup: unused uninit vars
Message-ID: <20170217122542.B49DC60E97@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=238a79aac41fcba65e7ac9c75f05275ab5915de6
Commit:        238a79aac41fcba65e7ac9c75f05275ab5915de6
Parent:        995f7aa92fb4a80ccb3bb9f78a396be15932baf3
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Feb 17 13:16:27 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Feb 17 13:20:55 2017 +0100

cleanup: unused uninit vars

---
 tools/command.c |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/tools/command.c b/tools/command.c
index cdea72c..a4139f0 100644
--- a/tools/command.c
+++ b/tools/command.c
@@ -1326,7 +1326,7 @@ static int copy_line(char *line, int max_line, int *position)
 
 int define_commands(char *run_name)
 {
-	struct command *cmd;
+	struct command *cmd = NULL;
 	char line[MAX_LINE];
 	char line_orig[MAX_LINE];
 	char *line_argv[MAX_LINE_ARGC];
@@ -1824,7 +1824,6 @@ static void print_def_man(struct arg_def *def, int usage)
 	int val_enum;
 	int lvt_enum;
 	int sep = 0;
-	int i;
 
 	for (val_enum = 0; val_enum < VAL_COUNT; val_enum++) {
 		if (def->val_bits & val_enum_to_bit(val_enum)) {
@@ -1927,7 +1926,7 @@ void print_man_usage(char *lvmname, struct command *cmd)
 {
 	struct command_name *cname;
 	int onereq = (cmd->cmd_flags & CMD_FLAG_ONE_REQUIRED_OPT) ? 1 : 0;
-	int i, sep, ro, rp, oo, op, opt_enum;
+	int sep, ro, rp, oo, op, opt_enum;
 	int need_ro_indent_end = 0;
 
 	if (!(cname = find_command_name(cmd->name)))


