From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 17 Feb 2017 12:25:40 +0000 (UTC)
Subject: master - cleanup: use strchr for 1-byte lookup
Message-ID: <20170217122540.93D3360E97@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=995f7aa92fb4a80ccb3bb9f78a396be15932baf3
Commit:        995f7aa92fb4a80ccb3bb9f78a396be15932baf3
Parent:        46d6c7d3ad0f5a4151960202635f3805dc0e3f15
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Feb 17 13:09:06 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Feb 17 13:20:55 2017 +0100

cleanup: use strchr for 1-byte lookup

---
 tools/command.c |   22 +++++++++++-----------
 1 files changed, 11 insertions(+), 11 deletions(-)

diff --git a/tools/command.c b/tools/command.c
index 5342ba2..cdea72c 100644
--- a/tools/command.c
+++ b/tools/command.c
@@ -337,7 +337,7 @@ static int val_str_to_num(char *str)
 	/* compare the name before any suffix like _new or _<lvtype> */
 
 	dm_strncpy(name, str, sizeof(name));
-	if ((new = strstr(name, "_")))
+	if ((new = strchr(name, '_')))
 		*new = '\0';
 
 	for (i = 0; i < VAL_COUNT; i++) {
@@ -561,7 +561,7 @@ static int is_pos_name(char *str)
 
 static int is_oo_definition(char *str)
 {
-	if (!strncmp(str, "OO_", 3) && strstr(str, ":"))
+	if (!strncmp(str, "OO_", 3) && strchr(str, ':'))
 		return 1;
 	return 0;
 }
@@ -644,7 +644,7 @@ static void set_pos_def(struct command *cmd, char *str, struct arg_def *def)
 
 		def->val_bits |= val_enum_to_bit(val_enum);
 
-		if ((val_enum == lv_VAL) && strstr(name, "_"))
+		if ((val_enum == lv_VAL) && strchr(name, '_'))
 			def->lvt_bits = lv_to_bits(cmd, name);
 
 		if (strstr(name, "_new")) {
@@ -702,7 +702,7 @@ static void set_opt_def(struct command *cmd, char *str, struct arg_def *def)
 			def->str = dm_strdup(name);
 
 		if (val_enum == lv_VAL) {
-			if (strstr(name, "_"))
+			if (strchr(name, '_'))
 				def->lvt_bits = lv_to_bits(cmd, name);
 		}
 
@@ -735,7 +735,7 @@ static void add_oo_definition_line(struct command *cmd, const char *name, const
 	oo = &oo_lines[oo_line_count++];
 	oo->name = dm_strdup(name);
 
-	if ((colon = strstr(oo->name, ":")))
+	if ((colon = strchr(oo->name, ':')))
 		*colon = '\0';
 	else {
 		log_error("Parsing command defs: invalid OO definition");
@@ -743,7 +743,7 @@ static void add_oo_definition_line(struct command *cmd, const char *name, const
 		return;
 	}
 
-	start = strstr(line, ":") + 2;
+	start = strchr(line, ':') + 2;
 	oo->line = dm_strdup(start);
 }
 
@@ -786,9 +786,9 @@ static char *get_oo_line(const char *str)
 	int i;
 
 	dm_strncpy(str2, str, sizeof(str2));
-	if ((end = strstr(str2, ":")))
+	if ((end = strchr(str2, ':')))
 		*end = '\0';
-	if ((end = strstr(str2, ",")))
+	if ((end = strchr(str2, ',')))
 		*end = '\0';
 
 	for (i = 0; i < oo_line_count; i++) {
@@ -840,7 +840,7 @@ static void add_opt_arg(struct command *cmd, char *str, int *takes_arg, int requ
 	/* opt_arg.opt set here */
 	/* opt_arg.def will be set in update_prev_opt_arg() if needed */
 
-	if ((comma = strstr(str, ",")))
+	if ((comma = strchr(str, ',')))
 		*comma = '\0';
 
 	/*
@@ -884,7 +884,7 @@ static void update_prev_opt_arg(struct command *cmd, char *str, int required)
 	/* opt_arg.def set here */
 	/* opt_arg.opt was previously set in add_opt_arg() when --foo was read */
 
-	if ((comma = strstr(str, ",")))
+	if ((comma = strchr(str, ',')))
 		*comma = '\0';
 
 	set_opt_def(cmd, str, &def);
@@ -1792,7 +1792,7 @@ static void print_val_man(const char *str)
 		return;
 	}
 
-	if (strstr(str, "|")) {
+	if (strchr(str, '|')) {
 		int len = strlen(str);
 		line = dm_strdup(str);
 		split_line(line, &line_argc, line_argv, '|');


