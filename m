From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 13 Mar 2018 08:04:33 -0400
Subject: master - dmsetup: join large fprintf
Message-ID: <201803131204.w2DC4X2K002526@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=9476cf8cdc8ead9dde4b5f768df878f41091c50c
Commit:        9476cf8cdc8ead9dde4b5f768df878f41091c50c
Parent:        5f5db7cf41203a12ab5a5973459e1a621e4df17b
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Mar 12 11:41:12 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Mar 13 12:58:57 2018 +0100

dmsetup: join large fprintf

Concatenate strings and make binary slightly smaller.
---
 tools/dmsetup.c |   66 +++++++++++++++++++++++++++---------------------------
 1 files changed, 33 insertions(+), 33 deletions(-)

diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index 336d4c0..df148e4 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -6257,32 +6257,32 @@ static void _stats_usage(FILE *out)
 {
 	int i;
 
-	fprintf(out, "Usage:\n\n");
-	fprintf(out, "%s\n", _base_commands[_base_command].name);
-	fprintf(out, "        [-h|--help]\n");
-	fprintf(out, "        [-v|--verbose [-v|--verbose ...]]\n");
-	fprintf(out, "        [--areas <nr_areas>] [--areasize <size>]\n");
-	fprintf(out, "        [--userdata <data>] [--clear]\n");
-	fprintf(out, "        [--count <count>] [--interval <seconds>]\n");
-	fprintf(out, "        [-o <fields>] [-O|--sort <sort_fields>]\n");
-	fprintf(out, "	      [--programid <id>]\n");
-	fprintf(out, "        [--start <start>] [--length <length>]\n");
-	fprintf(out, "        [--segments] [--units <units>]\n\n");
+	fprintf(out, "Usage:\n\n"
+		"%s\n"
+		"        [-h|--help]\n"
+		"        [-v|--verbose [-v|--verbose ...]]\n"
+		"        [--areas <nr_areas>] [--areasize <size>]\n"
+		"        [--userdata <data>] [--clear]\n"
+		"        [--count <count>] [--interval <seconds>]\n"
+		"        [-o <fields>] [-O|--sort <sort_fields>]\n"
+		"	      [--programid <id>]\n"
+		"        [--start <start>] [--length <length>]\n"
+		"        [--segments] [--units <units>]\n\n",
+		_base_commands[_base_command].name);
 
 	for (i = 0; _stats_subcommands[i].name; i++)
 		fprintf(out, "\t%s %s\n", _stats_subcommands[i].name, _stats_subcommands[i].help);
 
-	fprintf(out, "\n<device> may be device name or (if only one) -u <uuid> or -j <major> -m <minor>\n");
-	fprintf(out, "<fields> are comma-separated.  Use 'help -c' for list.\n");
-	putc('\n', out);
+	fprintf(out, "\n<device> may be device name or (if only one) -u <uuid> or -j <major> -m <minor>\n"
+		"<fields> are comma-separated.  Use 'help -c' for list.\n\n");
 }
 
 static void _dmsetup_usage(FILE *out)
 {
 	int i;
 
-	fprintf(out, "Usage:\n\n");
-	fprintf(out, "%s\n"
+	fprintf(out, "Usage:\n\n"
+		"%s\n"
 		"        [--version] [-h|--help [-c|-C|--columns]]\n"
 		"        [-v|--verbose [-v|--verbose ...]] [-f|--force]\n"
 		"        [--checks] [--manglename {none|hex|auto}]\n"
@@ -6298,27 +6298,27 @@ static void _dmsetup_usage(FILE *out)
 		fprintf(out, "\t%s %s\n", _dmsetup_commands[i].name, _dmsetup_commands[i].help);
 
 	fprintf(out, "\n<device> may be device name or (if only one) -u <uuid> or "
-		     "-j <major> -m <minor>\n");
-	fprintf(out, "<mangling_mode> is one of 'none', 'auto' and 'hex'.\n");
-	fprintf(out, "<fields> are comma-separated.  Use 'help -c' for list.\n");
-	fprintf(out, "<concise_device_specification> has single-device entries separated by semi-colons:\n"
-		     "    <name>,<uuid>,<minor>,<flags>,<table>\n"
-		     "        where <flags> is 'ro' or 'rw' (the default) and any of <uuid>, <minor>\n"
-		     "        and <flags> may be empty. Separate extra table lines with commas.\n"
-		     "    E.g.: dev1,,,,0 100 linear 253:1 0,100 100 error;dev2,,,ro,0 1 error\n");
-	fprintf(out, "Table_file contents may be supplied on stdin.\n");
-	fprintf(out, "Options are: devno, devname, blkdevname.\n");
-	fprintf(out, "Tree specific options are: ascii, utf, vt100; compact, inverted, notrunc;\n"
-		     "                           blkdevname, [no]device, active, open, rw and uuid.\n");
-	putc('\n', out);
+		"-j <major> -m <minor>\n"
+		"<mangling_mode> is one of 'none', 'auto' and 'hex'.\n"
+		"<fields> are comma-separated.  Use 'help -c' for list.\n"
+		"<concise_device_specification> has single-device entries separated by semi-colons:\n"
+		"    <name>,<uuid>,<minor>,<flags>,<table>\n"
+		"        where <flags> is 'ro' or 'rw' (the default) and any of <uuid>, <minor>\n"
+		"        and <flags> may be empty. Separate extra table lines with commas.\n"
+		"    E.g.: dev1,,,,0 100 linear 253:1 0,100 100 error;dev2,,,ro,0 1 error\n"
+		"Table_file contents may be supplied on stdin.\n"
+		"Options are: devno, devname, blkdevname.\n"
+		"Tree specific options are: ascii, utf, vt100; compact, inverted, notrunc;\n"
+		"                           blkdevname, [no]device, active, open, rw and uuid.\n\n");
 }
 
 static void _losetup_usage(FILE *out)
 {
-	fprintf(out, "Usage:\n\n");
-	fprintf(out, "%s [-d|-a] [-e encryption] "
-		     "[-o offset] [-f|loop_device] [file]\n\n",
-		     _base_commands[_base_command].name);
+	fprintf(out,
+		"Usage:\n\n"
+		"%s [-d|-a] [-e encryption] "
+		"[-o offset] [-f|loop_device] [file]\n\n",
+		_base_commands[_base_command].name);
 }
 
 static void _usage(FILE *out)


