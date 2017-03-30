From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Thu, 30 Mar 2017 13:56:05 -0400
Subject: master - man-generator: don't ignore description file errors
Message-ID: <201703301756.v2UHu5oA025500@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=0da040b1ebfd4796f9a649f469ebbeb012c7ea1c
Commit:        0da040b1ebfd4796f9a649f469ebbeb012c7ea1c
Parent:        980e4f673eb9189f9fe2dd5844a56f107d078f40
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Thu Mar 30 19:51:35 2017 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Thu Mar 30 19:51:35 2017 +0200

man-generator: don't ignore description file errors

In case we provide a description file it has to
succeed opening and reading.  Dynamically allocate
buffer space for it whilst on it.
---
 tools/command.c |   75 ++++++++++++++++++++++++++++++++++++-------------------
 1 files changed, 49 insertions(+), 26 deletions(-)

diff --git a/tools/command.c b/tools/command.c
index 0eecb24..4c65e6b 100644
--- a/tools/command.c
+++ b/tools/command.c
@@ -3215,29 +3215,51 @@ static char *upper_command_name(char *str)
 
 #define MAX_MAN_DESC (1024 * 1024)
 
-static void include_description_file(char *name, char *des_file)
+static int include_description_file(char *name, char *des_file)
 {
-	char buf[MAX_MAN_DESC];
-	int fd;
+	char *buf;
+	int fd, r = 0;
+	ssize_t sz;
+	struct stat stat;
 
-	memset(buf, 0, sizeof(buf));
-	
-	fd = open(des_file, O_RDONLY);
+	if ((fd = open(des_file, O_RDONLY)) < 0) {
+		log_error("Failed to open description file %s.", des_file);
+		return 0;
+	}
 
-	if (fd < 0)
-		return;
+	if (fstat(fd, &stat) < 0) {
+		log_error("Failed to stat description file %s.", des_file);
+		goto out_close;
+	}
+
+	if (stat.st_size > MAX_MAN_DESC) {
+		log_error("Description file %s is too large.", des_file);
+		goto out_close;
+	}
 
-	(void)read(fd, buf, sizeof(buf));
+	if (!(buf = dm_malloc(stat.st_size + 1))) {
+		log_error("Failed to allocate buffer for description file %s.", des_file);
+		goto out_close;
+	}
 
-	buf[MAX_MAN_DESC-1] = '\0';
+	if ((sz = read(fd, buf, stat.st_size)) < 0) {
+		log_error("Failed to read description file %s.", des_file);
+		goto out_free;
+	}
 
-	printf(".SH DESCRIPTION\n");
-	printf("%s", buf);
+	buf[sz] = '\0';
+	printf(".SH DESCRIPTION\n%s", buf);
+	r = 1;
 
+out_free:
+	dm_free(buf);
+out_close:
 	close(fd);
+
+	return r;
 }
 
-static void _print_man(char *name, char *des_file, int secondary)
+static int _print_man(char *name, char *des_file, int secondary)
 {
 	struct command_name *cname;
 	struct command *cmd, *prev_cmd = NULL;
@@ -3291,7 +3313,7 @@ static void _print_man(char *name, char *des_file, int secondary)
 			prev_cmd = cmd;
 
 			if (!(cname = find_command_name(cmd->name)))
-				return;
+				return 0;
 
 			if (cname->variant_has_ro && cname->variant_has_rp)
 				printf("\\fB%s\\fP \\fIoption_args\\fP \\fIposition_args\\fP\n", lvmname);
@@ -3320,9 +3342,8 @@ static void _print_man(char *name, char *des_file, int secondary)
 				_print_man_all_options_list(cname);
 			}
 
-			if (des_file) {
-				include_description_file(lvmname, des_file);
-			}
+			if (des_file && !include_description_file(lvmname, des_file))
+				return 0;
 
 			printf(".SH USAGE\n");
 		}
@@ -3351,6 +3372,8 @@ static void _print_man(char *name, char *des_file, int secondary)
 		printf("\n");
 		continue;
 	}
+
+	return 1;
 }
 
 static void _print_man_secondary(char *name)
@@ -3360,10 +3383,8 @@ static void _print_man_secondary(char *name)
 	int header = 0;
 	int i;
 
-	if (!strncmp(name, "lvm-", 4)) {
-		name[3] = ' ';
+	if (!strncmp(name, "lvm-", 4))
 		name += 4;
-	}
 
 	for (i = 0; i < COMMAND_COUNT; i++) {
 
@@ -3403,8 +3424,7 @@ int main(int argc, char *argv[])
 	char *desfile = NULL;
 	int primary = 0;
 	int secondary = 0;
-
-	memset(&commands, 0, sizeof(commands));
+	int r = 1;
 
 	static struct option long_options[] = {
 		{"primary", no_argument, 0, 'p' },
@@ -3412,6 +3432,8 @@ int main(int argc, char *argv[])
 		{0, 0, 0, 0 }
 	};
 
+	memset(&commands, 0, sizeof(commands));
+
 	while (1) {
 		int c;
 		int option_index = 0;
@@ -3434,14 +3456,14 @@ int main(int argc, char *argv[])
 
 	if (!primary && !secondary) {
 		log_error("Usage: %s --primary|--secondary <command> [/path/to/description-file].", argv[0]);
-		exit(EXIT_FAILURE);
+		goto out;
 	}
 
 	if (optind < argc)
 		cmdname = strdup(argv[optind++]);
 	else {
 		log_error("Missing command name.");
-		exit(EXIT_FAILURE);
+		goto out;
 	}
 
 	if (optind < argc)
@@ -3454,11 +3476,12 @@ int main(int argc, char *argv[])
 	factor_common_options();
 
 	if (primary)
-		_print_man(cmdname, desfile, secondary);
+		r = _print_man(cmdname, desfile, secondary);
 	else if (secondary)
 		_print_man_secondary(cmdname);
 
-	return 0;
+out:
+	exit(r ? EXIT_SUCCESS: EXIT_FAILURE);
 }
 
 #endif


