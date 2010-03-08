From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 8 Mar 2010 16:05:09 -0000
Subject: LVM2 ./WHATS_NEW_DM man/dmsetup.8.in tools/dms ...
Message-ID: <20100308160509.20262.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2010-03-08 16:05:08

Modified files:
	.              : WHATS_NEW_DM 
	man            : dmsetup.8.in 
	tools          : dmsetup.c 

Log message:
	Add --help dmsetup option as the synonym for help command.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.347&r2=1.348
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/dmsetup.8.in.diff?cvsroot=lvm2&r1=1.32&r2=1.33
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/dmsetup.c.diff?cvsroot=lvm2&r1=1.134&r2=1.135

--- LVM2/WHATS_NEW_DM	2010/03/08 16:04:32	1.347
+++ LVM2/WHATS_NEW_DM	2010/03/08 16:05:07	1.348
@@ -1,6 +1,7 @@
 Version 1.02.45 -
 ====================================
   Add --showkeys parameter description into dmsetup man page.
+  Add --help option as the synonym for help command.
 
 Version 1.02.44 - 15th February 2010
 ====================================
--- LVM2/man/dmsetup.8.in	2010/03/08 16:04:32	1.32
+++ LVM2/man/dmsetup.8.in	2010/03/08 16:05:08	1.33
@@ -112,6 +112,10 @@
 .IP \fB-c|-C|--columns
 .br
 Display output in columns rather than as Field: Value lines.
+.IP \fB-h|--help
+.br
+Outputs a summary of the commands available, optionally including
+the list of report fields (synonym with \fBhelp\fP command).
 .IP \fB--inactive
 .br
 When returning any table information from the kernel report on the 
--- LVM2/tools/dmsetup.c	2010/02/15 16:21:34	1.134
+++ LVM2/tools/dmsetup.c	2010/03/08 16:05:08	1.135
@@ -124,6 +124,7 @@
 	EXEC_ARG,
 	FORCE_ARG,
 	GID_ARG,
+	HELP_ARG,
 	INACTIVE_ARG,
 	MAJOR_ARG,
 	MINOR_ARG,
@@ -2720,7 +2721,8 @@
 	int i;
 
 	fprintf(out, "Usage:\n\n");
-	fprintf(out, "dmsetup [--version] [-v|--verbose [-v|--verbose ...]]\n"
+	fprintf(out, "dmsetup [--version] [-h|--help [-c|-C|--columns]]\n"
+		"        [-v|--verbose [-v|--verbose ...]]\n"
 		"        [-r|--readonly] [--noopencount] [--nolockfs] [--inactive]\n"
 		"        [--udevcookie] [--noudevrules] [--noudevsync] [-y|--yes]\n"
 		"        [--readahead [+]<sectors>|auto|none]\n"
@@ -3083,6 +3085,7 @@
 		{"exec", 1, &ind, EXEC_ARG},
 		{"force", 0, &ind, FORCE_ARG},
 		{"gid", 1, &ind, GID_ARG},
+		{"help", 0, &ind, HELP_ARG},
 		{"inactive", 0, &ind, INACTIVE_ARG},
 		{"major", 1, &ind, MAJOR_ARG},
 		{"minor", 1, &ind, MINOR_ARG},
@@ -3167,10 +3170,12 @@
 
 	optarg = 0;
 	optind = OPTIND_INIT;
-	while ((ind = -1, c = GETOPTLONG_FN(*argc, *argv, "cCfG:j:m:M:no:O:ru:U:vy",
+	while ((ind = -1, c = GETOPTLONG_FN(*argc, *argv, "cCfG:hj:m:M:no:O:ru:U:vy",
 					    long_options, NULL)) != -1) {
 		if (c == ':' || c == '?')
 			return 0;
+		if (c == 'h' || ind == HELP_ARG)
+			_switches[HELP_ARG]++;
 		if (c == 'c' || c == 'C' || ind == COLS_ARG)
 			_switches[COLS_ARG]++;
 		if (c == 'f' || ind == FORCE_ARG)
@@ -3329,6 +3334,11 @@
 		goto out;
 	}
 
+	if (_switches[HELP_ARG]) {
+		c = _find_command("help");
+		goto doit;
+	}
+
 	if (_switches[VERSION_ARG]) {
 		c = _find_command("version");
 		goto doit;


