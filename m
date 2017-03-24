From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Fri, 24 Mar 2017 09:28:30 -0400
Subject: master - man-generator: cleanup escape '-'
Message-ID: <201703241328.v2ODSUqF004090@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=9354ce6045fa968fc23b310397d66a5ef57d548d
Commit:        9354ce6045fa968fc23b310397d66a5ef57d548d
Parent:        10e0a5066e0848fdc179a10c2a04b7d23a242639
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Fri Mar 24 14:27:59 2017 +0100
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Fri Mar 24 14:27:59 2017 +0100

man-generator: cleanup escape '-'

---
 tools/command.c |   39 ++++++++++++++++++++++-----------------
 1 files changed, 22 insertions(+), 17 deletions(-)

diff --git a/tools/command.c b/tools/command.c
index 9c9bf88..58cd17d 100644
--- a/tools/command.c
+++ b/tools/command.c
@@ -2295,53 +2295,55 @@ static void print_def_man(struct command_name *cname, int opt_enum, struct arg_d
 		printf(" ...");
 }
 
-static const char *_emit_long_opt_name(char *buf, const char *long_opt_name, ssize_t len)
+static const char *_emit_long_opt_name(char *buf, const char *long_opt_name, size_t len)
 {
 	strcpy(buf, "\\-\\-");
-	strncat(buf, long_opt_name + 2, len - 3);
+	strncat(buf, long_opt_name + 2, strlen(buf) - 1);
 	return buf;
 }
 
-static char *man_long_opt_name(const char *cmdname, int opt_enum)
+#define	LONG_OPT_NAME_LEN	64
+static const char *man_long_opt_name(const char *cmdname, int opt_enum)
 {
-	static char long_opt_name[64];
+	static char long_opt_name[LONG_OPT_NAME_LEN];
+	const char *long_opt;
 
 	memset(&long_opt_name, 0, sizeof(long_opt_name));
 
 	switch (opt_enum) {
 	case syncaction_ARG:
-		strncpy(long_opt_name, "\\-\\-[raid]syncaction", 63);
+		long_opt = "--[raid]syncaction";
 		break;
 	case writemostly_ARG:
-		strncpy(long_opt_name, "\\-\\-[raid]writemostly", 63);
+		long_opt = "--[raid]writemostly";
 		break;
 	case minrecoveryrate_ARG:
-		strncpy(long_opt_name, "\\-\\-[raid]minrecoveryrate", 63);
+		long_opt = "--[raid]minrecoveryrate";
 		break;
 	case maxrecoveryrate_ARG:
-		strncpy(long_opt_name, "\\-\\-[raid]maxrecoveryrate", 63);
+		long_opt = "--[raid]maxrecoveryrate";
 		break;
 	case writebehind_ARG:
-		strncpy(long_opt_name, "\\-\\-[raid]writebehind", 63);
+		long_opt = "--[raid]writebehind";
 		break;
 	case vgmetadatacopies_ARG:
 		if (!strncmp(cmdname, "vg", 2))
-			strncpy(long_opt_name, "\\-\\-[vg]metadatacopies", 63);
+			long_opt = "--[vg]metadatacopies";
 		else
-			strncpy(long_opt_name, "\\-\\-vgmetadatacopies", 63);
+			long_opt = "--vgmetadatacopies";
 		break;
 	case pvmetadatacopies_ARG:
 		if (!strncmp(cmdname, "pv", 2))
-			strncpy(long_opt_name, "\\-\\-[pv]metadatacopies", 63);
+			long_opt = "--[pv]metadatacopies";
 		else
-			strncpy(long_opt_name, "\\-\\-pvmetadatacopies", 63);
+			long_opt = "--pvmetadatacopies";
 		break;
 	default:
-		_emit_long_opt_name(long_opt_name, opt_names[opt_enum].long_opt, 63);
+		long_opt = opt_names[opt_enum].long_opt;
 		break;
 	}
 
-	return long_opt_name;
+	return _emit_long_opt_name(long_opt_name, long_opt, sizeof(long_opt_name));
 }
 
 static void _print_man_usage(char *lvmname, struct command *cmd)
@@ -2351,7 +2353,9 @@ static void _print_man_usage(char *lvmname, struct command *cmd)
 	int sep, ro, rp, oo, op, opt_enum;
 	int need_ro_indent_end = 0;
 	int include_extents = 0;
-	char long_opt_name[64];
+	char long_opt_name[LONG_OPT_NAME_LEN];
+
+	memset (long_opt_name, 0, sizeof(long_opt_name));
 
 	if (!(cname = find_command_name(cmd->name)))
 		return;
@@ -2489,7 +2493,8 @@ static void _print_man_usage(char *lvmname, struct command *cmd)
 				       opt_names[opt_enum].short_opt,
 				       man_long_opt_name(cmd->name, opt_enum));
 			} else {
-				_emit_long_opt_name(long_opt_name, opt_names[cmd->required_opt_args[ro].opt].long_opt, 63);
+				_emit_long_opt_name(long_opt_name, opt_names[cmd->required_opt_args[ro].opt].long_opt,
+						    sizeof(long_opt_name));
 				printf(" \\fB%s\\fP", long_opt_name);
 			}
 


