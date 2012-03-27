From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 27 Mar 2012 11:04:48 -0000
Subject: LVM2 ./WHATS_NEW man/vgscan.8.in tools/command ...
Message-ID: <20120327110448.8713.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2012-03-27 11:04:47

Modified files:
	.              : WHATS_NEW 
	man            : vgscan.8.in 
	tools          : commands.h vgscan.c 

Log message:
	Add 'vgscan --cache' functionality for consistency with 'pvscan --cache'.
	
	Calling vgscan alone should reuse information from the lvmetad (if running).
	The --cache option should initiate direct device scan and update lvmetad
	appropriately (if running).
	
	This is mainly for vgscan to behave consistently compared to pvscan.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2370&r2=1.2371
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/vgscan.8.in.diff?cvsroot=lvm2&r1=1.2&r2=1.3
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/commands.h.diff?cvsroot=lvm2&r1=1.174&r2=1.175
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgscan.c.diff?cvsroot=lvm2&r1=1.40&r2=1.41

--- LVM2/WHATS_NEW	2012/03/26 20:33:40	1.2370
+++ LVM2/WHATS_NEW	2012/03/27 11:04:46	1.2371
@@ -1,5 +1,6 @@
 Version 2.02.96 - 
 ================================
+  Add 'vgscan --cache' functionality for consistency with 'pvscan --cache'.
   Keep exclusive activation in pvmove if LV is already active.
   Disallow pvmove for exclusive LV if some affected LVs are not exclusively activated.
   Remove unused and wrongly set cluster VG flag from clvmd lock query command.
--- LVM2/man/vgscan.8.in	2008/11/12 15:01:36	1.2
+++ LVM2/man/vgscan.8.in	2012/03/27 11:04:47	1.3
@@ -22,6 +22,10 @@
 .I \-\-mknodes
 Also checks the LVM special files in /dev that are needed for active 
 logical volumes and creates any missing ones and removes unused ones.
+.TP
+.I \-\-cache
+Scan devices for LVM physical volumes and volume groups and instruct
+the lvmetad daemon to update its cached state accordingly.
 .SH SEE ALSO
 .BR lvm (8),
 .BR vgcreate (8),
--- LVM2/tools/commands.h	2012/03/06 03:11:13	1.174
+++ LVM2/tools/commands.h	2012/03/27 11:04:47	1.175
@@ -1004,6 +1004,7 @@
    "Search for all volume groups",
    PERMITTED_READ_ONLY,
    "vgscan "
+   "\t[--cache]\n"
    "\t[-d|--debug]\n"
    "\t[-h|--help]\n"
    "\t[--ignorelockingfailure]\n"
@@ -1012,7 +1013,7 @@
    "\t[-v|--verbose]\n"
    "\t[--version]" "\n",
 
-   ignorelockingfailure_ARG, mknodes_ARG, partial_ARG)
+   cache_ARG, ignorelockingfailure_ARG, mknodes_ARG, partial_ARG)
 
 xx(vgsplit,
    "Move physical volumes into a new or existing volume group",
--- LVM2/tools/vgscan.c	2012/02/28 18:08:08	1.40
+++ LVM2/tools/vgscan.c	2012/03/27 11:04:47	1.41
@@ -15,6 +15,8 @@
 
 #include "tools.h"
 
+static int _lvmetad;
+
 static int vgscan_single(struct cmd_context *cmd, const char *vg_name,
 			 struct volume_group *vg,
 			 void *handle __attribute__((unused)))
@@ -25,16 +27,18 @@
 
 	check_current_backup(vg);
 
-	/* keep lvmetad up to date */
+	/* keep lvmetad up to date, restore the "active" state temporarily */
+	lvmetad_set_active(_lvmetad);
 	if (!lvmetad_vg_update(vg))
 		stack;
+	lvmetad_set_active(0);
 
 	return ECMD_PROCESSED;
 }
 
 int vgscan(struct cmd_context *cmd, int argc, char **argv)
 {
-	int maxret, ret, lvmetad;
+	int maxret, ret;
 
 	if (argc) {
 		log_error("Too many parameters on command line");
@@ -48,8 +52,17 @@
 
 	persistent_filter_wipe(cmd->filter);
 	lvmcache_destroy(cmd, 1);
-	lvmetad = lvmetad_active();
-	lvmetad_set_active(0); /* do not rely on lvmetad info */
+
+	_lvmetad = lvmetad_active();
+	if (arg_count(cmd, cache_ARG)) {
+		if (_lvmetad)
+			lvmetad_set_active(0); /* do not rely on lvmetad info */
+		else {
+			log_error("Cannot proceed since lvmetad is not active.");
+			unlock_vg(cmd, VG_GLOBAL);
+			return ECMD_FAILED;
+		}
+	}
 
 	log_print("Reading all physical volumes.  This may take a while...");
 
@@ -62,7 +75,7 @@
 			maxret = ret;
 	}
 
-	lvmetad_set_active(lvmetad); /* restore */
+	lvmetad_set_active(_lvmetad); /* restore */
 	unlock_vg(cmd, VG_GLOBAL);
 	return maxret;
 }


