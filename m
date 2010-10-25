From: agk@sourceware.org <agk@sourceware.org>
Date: 25 Oct 2010 11:20:58 -0000
Subject: LVM2 ./WHATS_NEW doc/example.conf.in lib/comma ...
Message-ID: <20101025112058.5607.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-10-25 11:20:56

Modified files:
	.              : WHATS_NEW 
	doc            : example.conf.in 
	lib/commands   : toolcontext.c toolcontext.h 
	lib/config     : defaults.h 
	lib/locking    : locking.c 
	lib/metadata   : metadata.c 
	tools          : commands.h lvmcmdline.c tools.h 

Log message:
	Add global/metadata_read_only to use unrepaired metadata in read-only cmds.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1768&r2=1.1769
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/doc/example.conf.in.diff?cvsroot=lvm2&r1=1.15&r2=1.16
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/commands/toolcontext.c.diff?cvsroot=lvm2&r1=1.106&r2=1.107
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/commands/toolcontext.h.diff?cvsroot=lvm2&r1=1.39&r2=1.40
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/config/defaults.h.diff?cvsroot=lvm2&r1=1.70&r2=1.71
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/locking.c.diff?cvsroot=lvm2&r1=1.86&r2=1.87
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.405&r2=1.406
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/commands.h.diff?cvsroot=lvm2&r1=1.156&r2=1.157
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvmcmdline.c.diff?cvsroot=lvm2&r1=1.128&r2=1.129
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/tools.h.diff?cvsroot=lvm2&r1=1.71&r2=1.72

--- LVM2/WHATS_NEW	2010/10/25 10:40:13	1.1768
+++ LVM2/WHATS_NEW	2010/10/25 11:20:54	1.1769
@@ -1,5 +1,6 @@
 Version 2.02.75 - 
 =====================================
+  Add global/metadata_read_only to use unrepaired metadata in read-only cmds.
   Don't take write lock in vgchange --refresh, --poll or --monitor.
   Skip dm devices in scan if they contain only error targets or are empty.
   Fix strict-aliasing compile warning in partition table scanning.
--- LVM2/doc/example.conf.in	2010/10/15 16:28:15	1.15
+++ LVM2/doc/example.conf.in	2010/10/25 11:20:55	1.16
@@ -334,6 +334,13 @@
     # Treat any internal errors as fatal errors, aborting the process that
     # encountered the internal error. Please only enable for debugging.
     abort_on_internal_errors = 0
+
+    # If set to 1, no operations that change on-disk metadata will be permitted.
+    # Additionally, read-only commands that encounter metadata in need of repair
+    # will still be allowed to proceed exactly as if the repair had been 
+    # performed (except for the unchanged vg_seqno).
+    # Inappropriate use could mess up your system, so seek advice first!
+    metadata_read_only = 0
 }
 
 activation {
--- LVM2/lib/commands/toolcontext.c	2010/10/13 15:40:38	1.106
+++ LVM2/lib/commands/toolcontext.c	2010/10/25 11:20:55	1.107
@@ -314,6 +314,9 @@
 			if ((cv->type != CFG_STRING) || !cv->v.str[0]) 
 				log_error("Ignoring invalid activation/mlock_filter entry in config file");
 
+	cmd->metadata_read_only = find_config_tree_int(cmd, "global/metadata_read_only",
+						       DEFAULT_METADATA_READ_ONLY);
+
 	return 1;
 }
 
--- LVM2/lib/commands/toolcontext.h	2010/08/11 12:14:23	1.39
+++ LVM2/lib/commands/toolcontext.h	2010/10/25 11:20:55	1.40
@@ -73,6 +73,7 @@
 	unsigned handles_unknown_segments:1;
 	unsigned partial_activation:1;
 	unsigned si_unit_consistency:1;
+	unsigned metadata_read_only:1;
 
 	struct dev_filter *filter;
 	int dump_filter;	/* Dump filter when exiting? */
--- LVM2/lib/config/defaults.h	2010/10/15 16:28:15	1.70
+++ LVM2/lib/config/defaults.h	2010/10/25 11:20:55	1.71
@@ -44,6 +44,7 @@
 #define DEFAULT_WAIT_FOR_LOCKS 1
 #define DEFAULT_PRIORITISE_WRITE_LOCKS 1
 #define DEFAULT_USE_MLOCKALL 0
+#define DEFAULT_METADATA_READ_ONLY 0
 
 #define DEFAULT_MIRRORLOG "disk"
 #define DEFAULT_MIRROR_LOG_FAULT_POLICY "allocate"
--- LVM2/lib/locking/locking.c	2010/10/13 15:40:39	1.86
+++ LVM2/lib/locking/locking.c	2010/10/25 11:20:55	1.87
@@ -374,6 +374,13 @@
 		return 0;
 	}
 
+	if (cmd->metadata_read_only &&
+	    ((flags & LCK_TYPE_MASK) == LCK_WRITE) &&
+	    strcmp(resource, VG_GLOBAL)) {
+		log_error("Operation prohibited while global/metadata_read_only is set.");
+		return 0;
+	}
+
 	if ((ret = _locking.lock_resource(cmd, resource, flags))) {
 		if ((flags & LCK_SCOPE_MASK) == LCK_VG &&
 		    !(flags & LCK_CACHE)) {
--- LVM2/lib/metadata/metadata.c	2010/10/13 12:18:53	1.405
+++ LVM2/lib/metadata/metadata.c	2010/10/25 11:20:56	1.406
@@ -2729,8 +2729,14 @@
 
 		/* FIXME Also ensure contents same - checksum compare? */
 		if (correct_vg->seqno != vg->seqno) {
-			inconsistent = 1;
-			inconsistent_seqno = 1;
+			if (cmd->metadata_read_only)
+				log_very_verbose("Not repairing VG %s metadata seqno (%d != %d) "
+						  "as global/metadata_read_only is set.",
+						  vgname, vg->seqno, correct_vg->seqno);
+			else {
+				inconsistent = 1;
+				inconsistent_seqno = 1;
+			}
 			if (vg->seqno > correct_vg->seqno) {
 				vg_release(correct_vg);
 				correct_vg = vg;
@@ -2805,8 +2811,8 @@
 			}
 		}
 
-		if (dm_list_size(&correct_vg->pvs) != dm_list_size(pvids)
-		    + vg_missing_pv_count(correct_vg)) {
+		if (dm_list_size(&correct_vg->pvs) !=
+		    dm_list_size(pvids) + vg_missing_pv_count(correct_vg)) {
 			log_debug("Cached VG %s had incorrect PV list",
 				  vgname);
 
@@ -2882,8 +2888,15 @@
 
 			/* FIXME Also ensure contents same - checksums same? */
 			if (correct_vg->seqno != vg->seqno) {
-				inconsistent = 1;
-				inconsistent_seqno = 1;
+				/* Ignore inconsistent seqno if told to skip repair logic */
+				if (cmd->metadata_read_only)
+					log_very_verbose("Not repairing VG %s metadata seqno (%d != %d) "
+							  "as global/metadata_read_only is set.",
+							  vgname, vg->seqno, correct_vg->seqno);
+				else {
+					inconsistent = 1;
+					inconsistent_seqno = 1;
+				}
 				if (!_update_pv_list(cmd->mem, &all_pvs, vg)) {
 					vg_release(vg);
 					vg_release(correct_vg);
--- LVM2/tools/commands.h	2010/10/15 16:28:16	1.156
+++ LVM2/tools/commands.h	2010/10/25 11:20:56	1.157
@@ -30,7 +30,7 @@
 
 xx(dumpconfig,
    "Dump active configuration",
-   0,
+   PERMITTED_READ_ONLY,
    "dumpconfig "
    "\t[-f|--file filename] " "\n"
    "[ConfigurationVariable...]\n",
@@ -38,12 +38,12 @@
 
 xx(formats,
    "List available metadata formats",
-   0,
+   PERMITTED_READ_ONLY,
    "formats\n")
 
 xx(help,
    "Display help for commands",
-   0,
+   PERMITTED_READ_ONLY,
    "help <command>" "\n")
 
 /*********
@@ -58,7 +58,7 @@
 
 xx(lvchange,
    "Change the attributes of logical volume(s)",
-   CACHE_VGMETADATA,
+   CACHE_VGMETADATA | PERMITTED_READ_ONLY,
    "lvchange\n"
    "\t[-A|--autobackup y|n]\n"
    "\t[-a|--available [e|l]y|n]\n"
@@ -207,7 +207,7 @@
 
 xx(lvdisplay,
    "Display information about a logical volume",
-   0,
+   PERMITTED_READ_ONLY,
    "lvdisplay\n"
    "\t[-a|--all]\n"
    "\t[-c|--colon]\n"
@@ -287,7 +287,7 @@
 
 xx(lvmdiskscan,
    "List devices that may be used as physical volumes",
-   0,
+   PERMITTED_READ_ONLY,
    "lvmdiskscan\n"
    "\t[-d|--debug]\n"
    "\t[-h|--help]\n"
@@ -401,7 +401,7 @@
 
 xx(lvs,
    "Display information about logical volumes",
-   0,
+   PERMITTED_READ_ONLY,
    "lvs" "\n"
    "\t[-a|--all]\n"
    "\t[--aligned]\n"
@@ -432,7 +432,7 @@
 
 xx(lvscan,
    "List all logical volumes in all volume groups",
-   0,
+   PERMITTED_READ_ONLY,
    "lvscan " "\n"
    "\t[-a|--all]\n"
    "\t[-b|--blockdevice] " "\n"
@@ -545,7 +545,7 @@
 
 xx(pvdisplay,
    "Display various attributes of physical volume(s)",
-   CACHE_VGMETADATA,
+   CACHE_VGMETADATA | PERMITTED_READ_ONLY,
    "pvdisplay\n"
    "\t[-c|--colon]\n"
    "\t[-d|--debug]\n"
@@ -620,7 +620,7 @@
 
 xx(pvs,
    "Display information about physical volumes",
-   CACHE_VGMETADATA,
+   CACHE_VGMETADATA | PERMITTED_READ_ONLY,
    "pvs" "\n"
    "\t[-a|--all]\n"
    "\t[--aligned]\n"
@@ -651,7 +651,7 @@
 
 xx(pvscan,
    "List all physical volumes",
-   0,
+   PERMITTED_READ_ONLY,
    "pvscan " "\n"
    "\t[-d|--debug] " "\n"
    "\t{-e|--exported | -n|--novolumegroup} " "\n"
@@ -668,12 +668,12 @@
 
 xx(segtypes,
    "List available segment types",
-   0,
+   PERMITTED_READ_ONLY,
    "segtypes\n")
 
 xx(vgcfgbackup,
    "Backup volume group configuration(s)",
-   0,
+   PERMITTED_READ_ONLY,
    "vgcfgbackup " "\n"
    "\t[-d|--debug] " "\n"
    "\t[-f|--file filename] " "\n"
@@ -704,7 +704,7 @@
 
 xx(vgchange,
    "Change volume group attributes",
-   CACHE_VGMETADATA,
+   CACHE_VGMETADATA | PERMITTED_READ_ONLY,
    "vgchange" "\n"
    "\t[-A|--autobackup {y|n}] " "\n"
    "\t[--alloc AllocationPolicy] " "\n"
@@ -797,7 +797,7 @@
 
 xx(vgdisplay,
    "Display volume group information",
-   0,
+   PERMITTED_READ_ONLY,
    "vgdisplay " "\n"
    "\t[-A|--activevolumegroups]" "\n"
    "\t[-c|--colon | -s|--short | -v|--verbose]" "\n"
@@ -961,7 +961,7 @@
 
 xx(vgs,
    "Display information about volume groups",
-   0,
+   PERMITTED_READ_ONLY,
    "vgs" "\n"
    "\t[--aligned]\n"
    "\t[-a|--all]\n"
@@ -991,7 +991,7 @@
 
 xx(vgscan,
    "Search for all volume groups",
-   0,
+   PERMITTED_READ_ONLY,
    "vgscan "
    "\t[-d|--debug]\n"
    "\t[-h|--help]\n"
@@ -1029,6 +1029,6 @@
 
 xx(version,
    "Display software and driver version information",
-   0,
+   PERMITTED_READ_ONLY,
    "version\n" )
 
--- LVM2/tools/lvmcmdline.c	2010/09/30 11:44:54	1.128
+++ LVM2/tools/lvmcmdline.c	2010/10/25 11:20:56	1.129
@@ -1073,6 +1073,13 @@
 	if ((ret = _process_common_commands(cmd)))
 		goto_out;
 
+	if (cmd->metadata_read_only &&
+	    !(cmd->command->flags & PERMITTED_READ_ONLY)) {
+		log_error("%s: Command not permitted while global/metadata_read_only "
+			  "is set.", cmd->cmd_line);
+		goto out;
+	}
+
 	if (arg_count(cmd, nolocking_ARG))
 		locking_type = 0;
 	else
--- LVM2/tools/tools.h	2010/07/09 15:34:48	1.71
+++ LVM2/tools/tools.h	2010/10/25 11:20:56	1.72
@@ -117,7 +117,8 @@
 /*	void *ptr; // Currently not used. */
 };
 
-#define CACHE_VGMETADATA 0x00000001
+#define CACHE_VGMETADATA	0x00000001
+#define PERMITTED_READ_ONLY 	0x00000002
 
 /* a register of the lvm commands */
 struct command {


