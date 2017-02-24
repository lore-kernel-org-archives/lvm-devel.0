From: David Teigland <teigland@fedoraproject.org>
Date: Fri, 24 Feb 2017 21:15:02 +0000 (UTC)
Subject: master - man: change option sorting in synopsis
Message-ID: <20170224211502.0909960FC8@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=4f7631b4adb9c6fff5cd47b5bd733ee716d05c8f
Commit:        4f7631b4adb9c6fff5cd47b5bd733ee716d05c8f
Parent:        5f6bdf707db24e882b3c3f86f8a5f2e2d2007c98
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Feb 24 15:11:18 2017 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Feb 24 15:11:18 2017 -0600

man: change option sorting in synopsis

The options list was sorted as:
- options with both long and short forms, alphabetically
- options with only long form, alphabetically

This was done only for the visual effect.  Change to
sort alphabetically by long opt, without regard to
short forms.
---
 tools/command.c |   55 +++++++------------------------------------------------
 1 files changed, 7 insertions(+), 48 deletions(-)

diff --git a/tools/command.c b/tools/command.c
index 5dd0298..59818f9 100644
--- a/tools/command.c
+++ b/tools/command.c
@@ -2533,10 +2533,7 @@ static void print_man_option_desc(struct command_name *cname, int opt_enum)
 }
 
 /*
- * Print a list of all options names for a given
- * command name, listed by:
- * options with short+long names, alphabetically,
- * then options with only long names, alphabetically
+ * Print a list of all options names for a given command name.
  */
 
 void print_man_all_options_list(struct command_name *cname)
@@ -2545,63 +2542,25 @@ void print_man_all_options_list(struct command_name *cname)
 	int sep = 0;
 	int i;
 
-	/* print those with both short and long opts */
 	for (i = 0; i < ARG_COUNT; i++) {
 		opt_enum = opt_names_alpha[i]->opt_enum;
 
-
 		if (!cname->all_options[opt_enum])
 			continue;
 
-		if (!opt_names[opt_enum].short_opt)
-			continue;
-
 		if (sep)
 			printf(".br\n");
 		printf(".ad l\n");
 
-		printf(" \\fB-%c\\fP|\\fB%s\\fP",
-			opt_names[opt_enum].short_opt,
-			man_long_opt_name(cname->name, opt_enum));
-
-		val_enum = opt_names[opt_enum].val_enum;
-
-		if (!val_names[val_enum].fn) {
-			/* takes no arg */
-		} else if (!val_names[val_enum].usage) {
-			printf(" ");
-			printf("\\fI");
-			printf("%s", val_names[val_enum].name);
-			printf("\\fP");
+		if (opt_names[opt_enum].short_opt) {
+			printf(" \\fB-%c\\fP|\\fB%s\\fP",
+				opt_names[opt_enum].short_opt,
+				man_long_opt_name(cname->name, opt_enum));
 		} else {
-			printf(" ");
-			print_val_man(val_names[val_enum].usage);
+			/* spaces for alignment without short opt */
+			printf("    \\fB%s\\fP", man_long_opt_name(cname->name, opt_enum));
 		}
 
-		printf("\n.ad b\n");
-
-		sep = 1;
-	}
-
-	/* print those without short opts */
-	for (i = 0; i < ARG_COUNT; i++) {
-		opt_enum = opt_names_alpha[i]->opt_enum;
-
-		if (!cname->all_options[opt_enum])
-			continue;
-
-		if (opt_names[opt_enum].short_opt)
-			continue;
-
-		if (sep)
-			printf(".br\n");
-		printf(".ad l\n");
-
-		/* space alignment without short opt */
-		printf("   ");
-
-		printf(" \\fB%s\\fP", man_long_opt_name(cname->name, opt_enum));
-
 		val_enum = opt_names[opt_enum].val_enum;
 
 		if (!val_names[val_enum].fn) {


