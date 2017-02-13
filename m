From: David Teigland <teigland@fedoraproject.org>
Date: Mon, 13 Feb 2017 22:11:32 +0000 (UTC)
Subject: master - coverity cleanups for recent command defs commits
Message-ID: <20170213221132.E00146032A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=5a87d8667d0a8cadfea13f837cf01c91d86dad0c
Commit:        5a87d8667d0a8cadfea13f837cf01c91d86dad0c
Parent:        5ab051df7a6f53ababb1c283af2ec4f8e1c7cac3
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Feb 13 16:11:04 2017 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Feb 13 16:11:04 2017 -0600

coverity cleanups for recent command defs commits

---
 tools/command.c    |   59 +++++++++++++++++++++++++++++++++------------------
 tools/lvmcmdline.c |    5 ++-
 2 files changed, 41 insertions(+), 23 deletions(-)

diff --git a/tools/command.c b/tools/command.c
index 68566fa..0ff5cd7 100644
--- a/tools/command.c
+++ b/tools/command.c
@@ -348,9 +348,11 @@ static int val_str_to_num(char *str)
 
 /* convert "--option" to foo_ARG enum */
 
+#define MAX_LONG_OPT_NAME_LEN 32
+
 static int opt_str_to_num(char *str)
 {
-	char long_name[32];
+	char long_name[MAX_LONG_OPT_NAME_LEN];
 	char *p;
 	int i;
 
@@ -361,9 +363,10 @@ static int opt_str_to_num(char *str)
 	 * short option.
 	 */
 	if (strstr(str, "_long")) {
-		strcpy(long_name, str);
-		p = strstr(long_name, "_long");
-		*p = '\0';
+		memset(long_name, 0, sizeof(long_name));
+		strncpy(long_name, str, MAX_LONG_OPT_NAME_LEN-1);
+		if ((p = strstr(long_name, "_long")))
+			*p = '\0';
 
 		for (i = 0; i < ARG_COUNT; i++) {
 			if (!opt_names[i].long_opt)
@@ -451,16 +454,19 @@ static int lv_to_enum(char *name)
  * lvt_bits |= lvt_enum_to_bit(lvt_enum)
  */
 
+#define LVTYPE_LEN 64
+
 static uint64_t lv_to_bits(char *name)
 {
-	char buf[64];
+	char buf[LVTYPE_LEN];
 	char *argv[MAX_LINE_ARGC];
 	uint64_t lvt_bits = 0;
 	int lvt_enum;
 	int argc;
 	int i;
 
-	strcpy(buf, name);
+	memset(buf, 0, sizeof(buf));
+	strncpy(buf, name, LVTYPE_LEN-1);
 
 	split_line(buf, &argc, argv, '_');
 
@@ -737,6 +743,10 @@ static void append_oo_definition_line(const char *new_line)
 	/* +2 = 1 space between old and new + 1 terminating \0 */
 	len = strlen(old_line) + strlen(new_line) + 2;
 	line = malloc(len);
+	if (!line) {
+		log_error("Parsing command defs: no memory");
+		exit(EXIT_FAILURE);
+	}
 	memset(line, 0, len);
 
 	strcat(line, old_line);
@@ -749,14 +759,17 @@ static void append_oo_definition_line(const char *new_line)
 
 /* Find a saved OO_FOO definition. */
 
+#define OO_NAME_LEN 64
+
 static char *get_oo_line(const char *str)
 {
 	char *name;
 	char *end;
-	char str2[64];
+	char str2[OO_NAME_LEN];
 	int i;
 
-	strcpy(str2, str);
+	memset(str2, 0, sizeof(str2));
+	strncpy(str2, str, OO_NAME_LEN-1);
 	if ((end = strstr(str2, ":")))
 		*end = '\0';
 	if ((end = strstr(str2, ",")))
@@ -917,7 +930,7 @@ static void update_prev_pos_arg(struct command *cmd, char *str, int required)
 
 static void add_optional_opt_line(struct command *cmd, int argc, char *argv[])
 {
-	int takes_arg;
+	int takes_arg = 0;
 	int i;
 
 	for (i = 0; i < argc; i++) {
@@ -941,7 +954,7 @@ static void add_optional_opt_line(struct command *cmd, int argc, char *argv[])
 
 static void add_ignore_opt_line(struct command *cmd, int argc, char *argv[])
 {
-	int takes_arg;
+	int takes_arg = 0;
 	int i;
 
 	for (i = 0; i < argc; i++) {
@@ -977,7 +990,7 @@ static void add_optional_pos_line(struct command *cmd, int argc, char *argv[])
 
 static void add_required_opt_line(struct command *cmd, int argc, char *argv[])
 {
-	int takes_arg;
+	int takes_arg = 0;
 	int i;
 
 	for (i = 0; i < argc; i++) {
@@ -1345,10 +1358,12 @@ int define_commands(void)
 			if (cmd->desc) {
 				int newlen = strlen(cmd->desc) + strlen(desc) + 2;
 				char *newdesc = malloc(newlen);
-				memset(newdesc, 0, newlen);
-				snprintf(newdesc, newlen, "%s %s", cmd->desc, desc);
-				cmd->desc = newdesc;
-				free(desc);
+				if (newdesc) {
+					memset(newdesc, 0, newlen);
+					snprintf(newdesc, newlen, "%s %s", cmd->desc, desc);
+					cmd->desc = newdesc;
+					free(desc);
+				}
 			} else
 				cmd->desc = desc;
 			continue;
@@ -1632,7 +1647,7 @@ void print_usage(struct command *cmd)
 
 void print_usage_common(struct command_name *cname, struct command *cmd)
 {
-	int oo, opt_enum, first;
+	int oo, opt_enum, first = 1;
 
 	printf("  Common options:");
 
@@ -1644,8 +1659,6 @@ void print_usage_common(struct command_name *cname, struct command *cmd)
 	if (cname->variants < 2)
 		goto all;
 
-	first = 1;
-
 	for (opt_enum = 0; opt_enum < ARG_COUNT; opt_enum++) {
 		if (!cname->common_options[opt_enum])
 			continue;
@@ -2527,9 +2540,11 @@ static char *upper_command_name(char *str)
 	return str_upper;
 }
 
+#define MAX_MAN_DESC (1024 * 1024)
+
 static void include_description_file(char *name, char *des_file)
 {
-	char buf[1024 * 1024];
+	char buf[MAX_MAN_DESC];
 	int fd;
 
 	memset(buf, 0, sizeof(buf));
@@ -2539,7 +2554,9 @@ static void include_description_file(char *name, char *des_file)
 	if (fd < 0)
 		return;
 
-	read(fd, buf, sizeof(buf) - 1);
+	read(fd, buf, sizeof(buf));
+
+	buf[MAX_MAN_DESC-1] = '\0';
 
 	printf(".SH DESCRIPTION\n");
 	printf("%s\n", buf);
@@ -2586,7 +2603,7 @@ void print_man(char *name, char *des_file, int include_primary, int include_seco
 		if (!(cmd->cmd_flags & CMD_FLAG_SECONDARY_SYNTAX) && !include_primary)
 			continue;
 
-		if (name && strcmp(name, cmd->name))
+		if (strcmp(name, cmd->name))
 			continue;
 
 		if (!prev_cmd || strcmp(prev_cmd->name, cmd->name)) {
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 40e1cf4..43278ff 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -1155,7 +1155,8 @@ void lvm_register_commands(void)
 		/* old style */
 		if (!commands[i].functions) {
 			struct command_name *cname = find_command_name(commands[i].name);
-			commands[i].fn = cname->fn;
+			if (cname)
+				commands[i].fn = cname->fn;
 		}
 	}
 
@@ -1365,7 +1366,7 @@ static struct command *_find_command(struct cmd_context *cmd, const char *path,
 	char buf[64];
 	int match_required, match_ro, match_rp, match_type, match_unused, mismatch_required;
 	int best_i = 0, best_required = 0, best_type = 0, best_unused = 0;
-	int close_i = 0, close_ro = 0, close_type;
+	int close_i = 0, close_ro = 0, close_type = 0;
 	int temp_unused_options[MAX_UNUSED_COUNT];
 	int temp_unused_count;
 	int best_unused_options[MAX_UNUSED_COUNT] = { 0 };


