From: David Teigland <teigland@fedoraproject.org>
Date: Tue, 14 Feb 2017 16:29:11 +0000 (UTC)
Subject: master - man-generator: fix compiler warnings
Message-ID: <20170214162911.2B370611BD@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=1236e0ed293d13bff1205dbd2ac31877278b7a90
Commit:        1236e0ed293d13bff1205dbd2ac31877278b7a90
Parent:        1dddb068c90d553957dd8668b76c3eb9734b2e95
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Feb 14 10:28:52 2017 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Feb 14 10:28:52 2017 -0600

man-generator: fix compiler warnings

---
 tools/command.c |    7 +++----
 1 files changed, 3 insertions(+), 4 deletions(-)

diff --git a/tools/command.c b/tools/command.c
index b655abe..aa33d5c 100644
--- a/tools/command.c
+++ b/tools/command.c
@@ -2181,7 +2181,7 @@ void print_man_usage(char *lvmname, struct command *cmd)
 void print_man_usage_common(struct command *cmd)
 {
 	struct command_name *cname;
-	int i, sep, ro, rp, oo, op, opt_enum;
+	int i, sep, rp, oo, op, opt_enum;
 
 	if (!(cname = find_command_name(cmd->name)))
 		return;
@@ -2569,7 +2569,7 @@ static void include_description_file(char *name, char *des_file)
 	if (fd < 0)
 		return;
 
-	read(fd, buf, sizeof(buf));
+	(void)read(fd, buf, sizeof(buf));
 
 	buf[MAX_MAN_DESC-1] = '\0';
 
@@ -2584,8 +2584,7 @@ void print_man(char *name, char *des_file, int include_primary, int include_seco
 	struct command_name *cname;
 	struct command *cmd, *prev_cmd = NULL;
 	char *lvmname = name;
-	const char *desc;
-	int i, j, ro, rp, oo, op;
+	int i;
 
 	if (!strncmp(name, "lvm-", 4))
 		name += 4;


