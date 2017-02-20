From: David Teigland <teigland@fedoraproject.org>
Date: Mon, 20 Feb 2017 23:10:36 +0000 (UTC)
Subject: master - man: use .HP instead of .TP
Message-ID: <20170220231037.0180760E60@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=86a660be7b31809500488792a93670a703e12a27
Commit:        86a660be7b31809500488792a93670a703e12a27
Parent:        e13639053b0d413624fb10baab535fde2c2c5bd5
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Feb 20 17:10:11 2017 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Feb 20 17:10:11 2017 -0600

man: use .HP instead of .TP

---
 tools/command.c |   18 +++++++++---------
 1 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/tools/command.c b/tools/command.c
index b1fdc1b..fe8c1f6 100644
--- a/tools/command.c
+++ b/tools/command.c
@@ -2498,7 +2498,7 @@ void print_man_all_options_desc(struct command_name *cname)
 		if (!cname->all_options[opt_enum])
 			continue;
 
-		printf("\n.TP\n");
+		printf("\n.HP\n");
 
 		if (opt_names[opt_enum].short_opt) {
 			printf("\\fB-%c\\fP|\\fB%s\\fP",
@@ -2591,7 +2591,7 @@ void print_man_all_positions_desc(struct command_name *cname)
 	}
 
 	if (has_vg_val) {
-		printf("\n.TP\n");
+		printf("\n.HP\n");
 
 		printf("\\fI%s\\fP", val_names[vg_VAL].name);
 		printf("\n");
@@ -2605,7 +2605,7 @@ void print_man_all_positions_desc(struct command_name *cname)
 	}
 
 	if (has_lv_val) {
-		printf("\n.TP\n");
+		printf("\n.HP\n");
 
 		printf("\\fI%s\\fP", val_names[lv_VAL].name);
 		printf("\n");
@@ -2619,7 +2619,7 @@ void print_man_all_positions_desc(struct command_name *cname)
 	}
 
 	if (has_pv_val) {
-		printf("\n.TP\n");
+		printf("\n.HP\n");
 
 		printf("\\fI%s\\fP", val_names[pv_VAL].name);
 		printf("\n");
@@ -2632,7 +2632,7 @@ void print_man_all_positions_desc(struct command_name *cname)
 	}
 
 	if (has_tag_val) {
-		printf("\n.TP\n");
+		printf("\n.HP\n");
 
 		printf("\\fI%s\\fP", val_names[tag_VAL].name);
 		printf("\n");
@@ -2642,7 +2642,7 @@ void print_man_all_positions_desc(struct command_name *cname)
 	}
 
 	if (has_select_val) {
-		printf("\n.TP\n");
+		printf("\n.HP\n");
 
 		printf("\\fI%s\\fP", val_names[select_VAL].name);
 		printf("\n");
@@ -2654,7 +2654,7 @@ void print_man_all_positions_desc(struct command_name *cname)
 
 	/* Every command uses a string arg somewhere. */
 
-	printf("\n.TP\n");
+	printf("\n.HP\n");
 	printf("\\fI%s\\fP", val_names[string_VAL].name);
 	printf("\n");
 	printf(".br\n");
@@ -2662,7 +2662,7 @@ void print_man_all_positions_desc(struct command_name *cname)
 
 	/* Nearly every command uses a number arg somewhere. */
 
-	printf("\n.TP\n");
+	printf("\n.HP\n");
 	printf("\\fINumber\\fP, \\fISize\\fP");
 	printf("\n");
 	printf(".br\n");
@@ -2671,7 +2671,7 @@ void print_man_all_positions_desc(struct command_name *cname)
 	       "The default input unit is specified by letter, followed by |unit which\n"
 	       "represents other possible input units: bBsSkKmMgGtTpPeE.\n");
 
-	printf("\n.TP\n");
+	printf("\n.HP\n");
 	printf("Environment");
 	printf("\n");
 	printf(".br\n");


