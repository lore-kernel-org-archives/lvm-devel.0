From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 15 Feb 2012 12:02:59 -0000
Subject: LVM2 ./WHATS_NEW_DM tools/dmsetup.c
Message-ID: <20120215120259.12238.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2012-02-15 12:02:59

Modified files:
	.              : WHATS_NEW_DM 
	tools          : dmsetup.c 

Log message:
	Add --manglename option to dmsetup to select the name mangling mode.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.560&r2=1.561
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/dmsetup.c.diff?cvsroot=lvm2&r1=1.176&r2=1.177

--- LVM2/WHATS_NEW_DM	2012/02/15 11:39:38	1.560
+++ LVM2/WHATS_NEW_DM	2012/02/15 12:02:58	1.561
@@ -1,5 +1,6 @@
 Version 1.02.71 - 
 ====================================
+  Add --manglename option to dmsetup to select the name mangling mode.
   Add dm_task_get_name_mangled/unmangled to libdevmapper.
   Mangle device name on dm_task_set_name/newname call if necessary.
   Add dm_set/get_name_mangling_mode to set/get name mangling in libdevmapper.
--- LVM2/tools/dmsetup.c	2012/02/13 12:06:40	1.176
+++ LVM2/tools/dmsetup.c	2012/02/15 12:02:59	1.177
@@ -126,6 +126,7 @@
 	GID_ARG,
 	HELP_ARG,
 	INACTIVE_ARG,
+	MANGLENAME_ARG,
 	MAJOR_ARG,
 	MINOR_ARG,
 	MODE_ARG,
@@ -2908,7 +2909,7 @@
 
 	fprintf(out, "Usage:\n\n");
 	fprintf(out, "dmsetup [--version] [-h|--help [-c|-C|--columns]]\n"
-		"        [--checks] [-v|--verbose [-v|--verbose ...]]\n"
+		"        [--checks] [--manglename <mangling_mode>] [-v|--verbose [-v|--verbose ...]]\n"
 		"        [-r|--readonly] [--noopencount] [--nolockfs] [--inactive]\n"
 		"        [--udevcookie [cookie]] [--noudevrules] [--noudevsync] [--verifyudev]\n"
 		"        [-y|--yes] [--readahead [+]<sectors>|auto|none] [--retry]\n"
@@ -2918,6 +2919,7 @@
 		fprintf(out, "\t%s %s\n", _commands[i].name, _commands[i].help);
 	fprintf(out, "\n<device> may be device name or -u <uuid> or "
 		     "-j <major> -m <minor>\n");
+	fprintf(out, "<mangling_mode> is one of 'none', 'auto' and 'hex'.\n");
 	fprintf(out, "<fields> are comma-separated.  Use 'help -c' for list.\n");
 	fprintf(out, "Table_file contents may be supplied on stdin.\n");
 	fprintf(out, "Options are: devno, devname, blkdevname.\n");
@@ -3322,6 +3324,7 @@
 		{"gid", 1, &ind, GID_ARG},
 		{"help", 0, &ind, HELP_ARG},
 		{"inactive", 0, &ind, INACTIVE_ARG},
+		{"manglename", 1, &ind, MANGLENAME_ARG},
 		{"major", 1, &ind, MAJOR_ARG},
 		{"minor", 1, &ind, MINOR_ARG},
 		{"mode", 1, &ind, MODE_ARG},
@@ -3494,6 +3497,20 @@
 		}
 		if (ind == INACTIVE_ARG)
 		       _switches[INACTIVE_ARG]++;
+		if ((ind == MANGLENAME_ARG)) {
+			_switches[MANGLENAME_ARG]++;
+			if (!strcasecmp(optarg, "none"))
+				_int_args[MANGLENAME_ARG] = DM_STRING_MANGLING_NONE;
+			else if (!strcasecmp(optarg, "auto"))
+				_int_args[MANGLENAME_ARG] = DM_STRING_MANGLING_AUTO;
+			else if (!strcasecmp(optarg, "hex"))
+				_int_args[MANGLENAME_ARG] = DM_STRING_MANGLING_HEX;
+			else {
+				log_error("Unknown name mangling mode");
+				return 0;
+			}
+			dm_set_name_mangling_mode(_int_args[MANGLENAME_ARG]);
+		}
 		if (ind == NAMEPREFIXES_ARG)
 			_switches[NAMEPREFIXES_ARG]++;
 		if (ind == NOFLUSH_ARG)


