From: David Teigland <teigland@sourceware.org>
Date: Wed, 21 Apr 2021 13:46:52 +0000 (GMT)
Subject: main - man-generator: add option to check for repeated command definitions
Message-ID: <20210421134652.CFFD83969022@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=7b77226df2ee7f4d1baa11d42752f600e408bf65
Commit:        7b77226df2ee7f4d1baa11d42752f600e408bf65
Parent:        a616abba03a35ec3064360ac8cab9ebb2203d645
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Apr 20 10:24:47 2021 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Apr 20 10:31:00 2021 -0500

man-generator: add option to check for repeated command definitions

Compares cmd defs based on two principles for avoiding repeated
commands (where a given command could match more than one cmd def):

. a cmd def should be a unique combination of required
  option args and position args

. avoid adding optional options to a cmd def that if
  used would make the command match a different cmd def

FIXME: record when repeated cmd defs are found so we can
avoid reporting them twice, e.g. once for A vs B and
second time for B vs A.
---
 tools/command.c | 223 ++++++++++++++++++++++++++++++++++++++++++++++++++++++--
 1 file changed, 218 insertions(+), 5 deletions(-)

diff --git a/tools/command.c b/tools/command.c
index b78271373..d6e0fec57 100644
--- a/tools/command.c
+++ b/tools/command.c
@@ -3654,6 +3654,211 @@ static void _print_man_secondary(char *name)
 	}
 }
 
+static void _print_opt_list(const char *prefix, int *opt_list, int opt_count)
+{
+	int i;
+	int opt_enum;
+
+	printf("%s ", prefix);
+	for (i = 0; i < opt_count; i++) {
+		opt_enum = opt_list[i];
+		printf(" %s", opt_names[opt_enum].long_opt);
+	}
+	printf("\n");
+}
+
+/* return 1 if the lists do not match, 0 if they match */
+static int _compare_opt_lists(int *list1, int count1, int *list2, int count2, const char *type1_str, const char *type2_str)
+{
+	int i, j;
+
+	if (count1 != count2)
+		return 1;
+
+	for (i = 0; i < count1; i++) {
+		for (j = 0; j < count2; j++) {
+
+			/* lists do not match if one has --type foo and the other --type bar */
+			if ((list1[i] == type_ARG) && (list2[j] == type_ARG) &&
+			    type1_str && type2_str && strcmp(type1_str, type2_str)) {
+				return 1;
+			}
+
+			if (list1[i] == list2[j])
+				goto next;
+		}
+		return 1;
+ next:
+		;
+	}
+
+	return 0;
+}
+
+static int _compare_cmds(struct command *cmd1, struct command *cmd2, int *all_req_opts)
+{
+	const char *cmd1_type_str = NULL;
+	const char *cmd2_type_str = NULL;
+	int opt_list_1[ARG_COUNT] = { 0 };
+	int opt_list_2[ARG_COUNT] = { 0 };
+	int opt_count_1 = 0;
+	int opt_count_2 = 0;
+	int i, j;
+	int r = 1;
+
+	/* different number of required pos items means different cmds */
+	if (cmd1->rp_count != cmd2->rp_count)
+		return 1;
+
+	/* different types of required pos items means different cmds */
+	for (i = 0; i < cmd1->rp_count; i++) {
+		if (cmd1->required_pos_args[i].def.val_bits != cmd2->required_pos_args[i].def.val_bits)
+			return 1;
+	}
+
+	/* create opt list from cmd1 */
+	for (i = 0; i < cmd1->ro_count; i++) {
+		if (!all_req_opts[cmd1->required_opt_args[i].opt])
+			continue;
+
+		opt_list_1[opt_count_1++] = cmd1->required_opt_args[i].opt;
+
+		if (cmd1->required_opt_args[i].opt == type_ARG)
+			cmd1_type_str = cmd1->required_opt_args[i].def.str;
+	}
+
+	/* create opt list from cmd2 */
+	for (i = 0; i < cmd2->ro_count; i++) {
+		if (!all_req_opts[cmd2->required_opt_args[i].opt])
+			continue;
+
+		opt_list_2[opt_count_2++] = cmd2->required_opt_args[i].opt;
+
+		if (cmd2->required_opt_args[i].opt == type_ARG)
+			cmd2_type_str = cmd2->required_opt_args[i].def.str;
+	}
+
+	/* "--type foo" and "--type bar" are different */
+	if (cmd1_type_str && cmd2_type_str && strcmp(cmd1_type_str, cmd2_type_str))
+		return 1;
+
+	/* compare opt_list_1 and opt_list_2 */
+	if (!_compare_opt_lists(opt_list_1, opt_count_1, opt_list_2, opt_count_2, NULL, NULL)) {
+		log_error("Repeated commands %s %s", cmd1->command_id, cmd2->command_id);
+		log_error("cmd1: %s", cmd1->desc);
+		log_error("cmd2: %s", cmd2->desc);
+		_print_opt_list("cmd1 options: ", opt_list_1, opt_count_1);
+		_print_opt_list("cmd2 options: ", opt_list_2, opt_count_2);
+		printf("\n");
+		r = 0;
+	}
+
+	/* check if cmd1 matches cmd2 + one of its oo */
+	for (i = 0; i < cmd2->oo_count; i++) {
+		/* for each cmd2 optional_opt_arg, add it to opt_list_2
+		   and compare opt_list_1 and opt_list_2 again */
+
+		/* cmd1 "--type foo" and cmd2 OO "--type bar" are different */
+		if (cmd2->optional_opt_args[i].opt == type_ARG) {
+			if (cmd2->optional_opt_args[i].def.str && cmd1_type_str &&
+			    strcmp(cmd2->optional_opt_args[i].def.str, cmd1_type_str))
+				return 1;
+		}
+
+		opt_list_2[opt_count_2] = cmd2->optional_opt_args[i].opt;
+
+		if (!_compare_opt_lists(opt_list_1, opt_count_1, opt_list_2, opt_count_2+1, NULL, NULL)) {
+			log_error("Repeated commands %s %s", cmd1->command_id, cmd2->command_id);
+			log_error("cmd1: %s", cmd1->desc);
+			log_error("cmd2: %s", cmd2->desc);
+			log_error("Included cmd2 OO: %s", opt_names[cmd2->optional_opt_args[i].opt].long_opt);
+			_print_opt_list("cmd1 options: ", opt_list_1, opt_count_1);
+			_print_opt_list("cmd2 options: ", opt_list_2, opt_count_2+1);
+			printf("\n");
+			r = 0;
+		}
+	}
+
+	/* check if cmd1 + an oo matches cmd2 + an oo */
+
+	if (!cmd1_type_str) {
+		for (i = 0; i < cmd1->oo_count; i++) {
+			if (cmd1->optional_opt_args[i].opt == type_ARG)
+				cmd1_type_str = cmd1->optional_opt_args[i].def.str;
+		}
+	}
+	if (!cmd2_type_str) {
+		for (j = 0; j < cmd2->oo_count; j++) {
+			if (cmd2->optional_opt_args[j].opt == type_ARG)
+				cmd2_type_str = cmd2->optional_opt_args[j].def.str;
+		}
+	}
+
+	for (i = 0; i < cmd1->oo_count; i++) {
+
+		for (j = 0; j < cmd2->oo_count; j++) {
+			if (cmd1->optional_opt_args[i].opt == cmd2->optional_opt_args[j].opt)
+				continue;
+
+			opt_list_1[opt_count_1] = cmd1->optional_opt_args[i].opt;
+			opt_list_2[opt_count_2] = cmd2->optional_opt_args[j].opt;
+
+			if (!_compare_opt_lists(opt_list_1, opt_count_1+1, opt_list_2, opt_count_2+1, cmd1_type_str, cmd2_type_str)) {
+				log_error("Repeated commands %s %s", cmd1->command_id, cmd2->command_id);
+				log_error("cmd1: %s", cmd1->desc);
+				log_error("cmd2: %s", cmd2->desc);
+				log_error("Included cmd1 OO: %s and cmd2 OO: %s",
+					  opt_names[cmd1->optional_opt_args[i].opt].long_opt,
+					  opt_names[cmd2->optional_opt_args[j].opt].long_opt);
+				_print_opt_list("cmd1 options: ", opt_list_1, opt_count_1+1);
+				_print_opt_list("cmd2 options: ", opt_list_2, opt_count_2+1);
+				printf("\n");
+				r = 0;
+			}
+		}
+	}
+	return r;
+}
+
+static int _check_overlap(void)
+{
+	int all_req_opts[ARG_COUNT] = { 0 };
+	struct command *cmd1, *cmd2;
+	int i, j;
+	int r = 1;
+
+	for (i = 0; i < COMMAND_COUNT; i++) {
+		cmd1 = &commands[i];
+		for (j = 0; j < cmd1->ro_count; j++)
+			all_req_opts[cmd1->required_opt_args[j].opt] = 1;
+	}
+
+	for (i = 0; i < COMMAND_COUNT; i++) {
+
+		cmd1 = &commands[i];
+
+		if (cmd1->any_ro_count)
+			continue;
+
+		for (j = 0; j < COMMAND_COUNT; j++) {
+			if (i == j)
+				continue;
+
+			cmd2 = &commands[j];
+
+			if (cmd2->any_ro_count)
+				continue;
+
+			if (strcmp(cmd1->name, cmd2->name))
+				continue;
+
+			if (!_compare_cmds(cmd1, cmd2, all_req_opts))
+				r = 0;
+		}
+	}
+	return r;
+}
+
 #define	STDOUT_BUF_SIZE	 (MAX_MAN_DESC + 4 * 1024)
 
 int main(int argc, char *argv[])
@@ -3664,12 +3869,14 @@ int main(int argc, char *argv[])
 	char *stdout_buf;
 	int primary = 0;
 	int secondary = 0;
+	int check = 0;
 	int r = 0;
 	size_t sz = STDOUT_BUF_SIZE;
 
 	static struct option long_options[] = {
 		{"primary", no_argument, 0, 'p' },
 		{"secondary", no_argument, 0, 's' },
+		{"check", no_argument, 0, 'c' },
 		{0, 0, 0, 0 }
 	};
 
@@ -3684,7 +3891,7 @@ int main(int argc, char *argv[])
 		int c;
 		int option_index = 0;
 
-		c = getopt_long(argc, argv, "ps", long_options, &option_index);
+		c = getopt_long(argc, argv, "psc", long_options, &option_index);
 		if (c == -1)
 			break;
 
@@ -3697,11 +3904,14 @@ int main(int argc, char *argv[])
 		case 's':
 			secondary = 1;
 			break;
+		case 'c':
+			check = 1;
+			break;
 		}
 	}
 
-	if (!primary && !secondary) {
-		log_error("Usage: %s --primary|--secondary <command> [/path/to/description-file].", argv[0]);
+	if (!primary && !secondary && !check) {
+		log_error("Usage: %s --primary|--secondary|--check <command> [/path/to/description-file].", argv[0]);
 		goto out_free;
 	}
 
@@ -3710,7 +3920,7 @@ int main(int argc, char *argv[])
 			log_error("Out of memory.");
 			goto out_free;
 		}
-	} else {
+	} else if (!check) {
 		log_error("Missing command name.");
 		goto out_free;
 	}
@@ -3720,7 +3930,8 @@ int main(int argc, char *argv[])
 
 	define_commands(&cmdtool, NULL);
 
-	configure_command_option_values(cmdname);
+	if (!check)
+		configure_command_option_values(cmdname);
 
 	factor_common_options();
 
@@ -3729,6 +3940,8 @@ int main(int argc, char *argv[])
 	else if (secondary) {
 		r = 1;
 		_print_man_secondary(cmdname);
+	} else if (check) {
+		r = _check_overlap();
 	}
 
 out_free:


