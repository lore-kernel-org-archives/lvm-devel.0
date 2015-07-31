From: Alasdair Kergon <agk@fedoraproject.org>
Date: Fri, 31 Jul 2015 15:14:29 +0000 (UTC)
Subject: master - dmsetup: Rename _commands to _dmsetup_commands.
Message-ID: <20150731151429.21DA56098C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=027fe112ecb75e46c671658e233ff353523e9ec3
Commit:        027fe112ecb75e46c671658e233ff353523e9ec3
Parent:        f54198eed62f915df6fdb7c09a186160b5bb3954
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Fri Jul 31 16:13:45 2015 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Fri Jul 31 16:13:45 2015 +0100

dmsetup: Rename _commands to _dmsetup_commands.

We'll need to accommodate sub-commands for dmstats.
---
 tools/dmsetup.c |   26 ++++++++++++++++----------
 1 files changed, 16 insertions(+), 10 deletions(-)

diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index 7a26db1..6481288 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -3057,7 +3057,7 @@ static int _help(CMD_ARGS);
 /*
  * Dispatch table
  */
-static struct command _commands[] = {
+static struct command _dmsetup_commands[] = {
 	{"help", "[-c|-C|--columns]", 0, 0, 0, _help},
 	{"create", "<dev_name> [-j|--major <major> -m|--minor <minor>]\n"
 	  "\t                  [-U|--uid <uid>] [-G|--gid <gid>] [-M|--mode <octal_mode>]\n"
@@ -3108,8 +3108,8 @@ static void _usage(FILE *out)
 		"        [-c|-C|--columns] [-o <fields>] [-O|--sort <sort_fields>]\n"
 		"        [-S|--select <selection>] [--nameprefixes] [--noheadings]\n"
 		"        [--separator <separator>]\n\n");
-	for (i = 0; _commands[i].name; i++)
-		fprintf(out, "\t%s %s\n", _commands[i].name, _commands[i].help);
+	for (i = 0; _dmsetup_commands[i].name; i++)
+		fprintf(out, "\t%s %s\n", _dmsetup_commands[i].name, _dmsetup_commands[i].help);
 	fprintf(out, "\n<device> may be device name or -u <uuid> or "
 		     "-j <major> -m <minor>\n");
 	fprintf(out, "<mangling_mode> is one of 'none', 'auto' and 'hex'.\n");
@@ -3147,17 +3147,23 @@ static int _help(CMD_ARGS)
 	return 1;
 }
 
-static struct command *_find_command(const char *name)
+static struct command *_find_command(const struct command *commands,
+				     const char *name)
 {
 	int i;
 
-	for (i = 0; _commands[i].name; i++)
-		if (!strcmp(_commands[i].name, name))
-			return _commands + i;
+	for (i = 0; commands[i].name; i++)
+		if (!strcmp(commands[i].name, name))
+			return commands + i;
 
 	return NULL;
 }
 
+static struct command *_find_dmsetup_command(const char *name)
+{
+	return _find_command(_dmsetup_commands, name);
+}
+
 static int _process_tree_options(const char *options)
 {
 	const char *s, *end;
@@ -3816,13 +3822,13 @@ int main(int argc, char **argv)
 	}
 
 	if (_switches[HELP_ARG]) {
-		if ((cmd = _find_command("help")))
+		if ((cmd = _find_dmsetup_command("help")))
 			goto doit;
 		goto unknown;
 	}
 
 	if (_switches[VERSION_ARG]) {
-		if ((cmd = _find_command("version")))
+		if ((cmd = _find_dmsetup_command("version")))
 			goto doit;
 		goto unknown;
 	}
@@ -3832,7 +3838,7 @@ int main(int argc, char **argv)
 		goto out;
 	}
 
-	if (!(cmd = _find_command(argv[0]))) {
+	if (!(cmd = _find_dmsetup_command(argv[0]))) {
 unknown:
 		fprintf(stderr, "Unknown command\n");
 		_usage(stderr);


