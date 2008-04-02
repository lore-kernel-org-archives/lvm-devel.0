From: agk@sourceware.org <agk@sourceware.org>
Date: 2 Apr 2008 21:23:39 -0000
Subject: LVM2 ./WHATS_NEW lib/cache/lvmcache.c lib/comm ...
Message-ID: <20080402212339.20555.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-04-02 21:23:39

Modified files:
	.              : WHATS_NEW 
	lib/cache      : lvmcache.c 
	lib/commands   : toolcontext.h 
	tools          : commands.h lvmcmdline.c tools.h 

Log message:
	Add per-command flags to control which commands use the VG metadata cache.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.817&r2=1.818
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/cache/lvmcache.c.diff?cvsroot=lvm2&r1=1.40&r2=1.41
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/commands/toolcontext.h.diff?cvsroot=lvm2&r1=1.21&r2=1.22
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/commands.h.diff?cvsroot=lvm2&r1=1.108&r2=1.109
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvmcmdline.c.diff?cvsroot=lvm2&r1=1.61&r2=1.62
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/tools.h.diff?cvsroot=lvm2&r1=1.60&r2=1.61

--- LVM2/WHATS_NEW	2008/04/02 19:30:12	1.817
+++ LVM2/WHATS_NEW	2008/04/02 21:23:38	1.818
@@ -1,5 +1,6 @@
 Version 2.02.34 -
 ===================================
+  Add per-command flags to control which commands use the VG metadata cache.
   Fix vgsplit locking, remove unneeded error messages when split into new VG.
   Suppress duplicate message when lvresize fails because of invalid vgname.
   Cache VG metadata internally while VG lock is held.
--- LVM2/lib/cache/lvmcache.c	2008/04/01 22:40:12	1.40
+++ LVM2/lib/cache/lvmcache.c	2008/04/02 21:23:39	1.41
@@ -868,7 +868,8 @@
 	}
 
 	/* store text representation of vg to cache */
-	if ((vginfo = vginfo_from_vgname(vg->name, NULL)))
+	if (vg->cmd->current_settings.cache_vgmetadata &&
+	    (vginfo = vginfo_from_vgname(vg->name, NULL)))
 		_store_metadata(vginfo, vg, precommitted);
 
 	return 1;
--- LVM2/lib/commands/toolcontext.h	2007/11/09 16:51:53	1.21
+++ LVM2/lib/commands/toolcontext.h	2008/04/02 21:23:39	1.22
@@ -34,6 +34,7 @@
 	int archive;		/* should we archive ? */
 	int backup;		/* should we backup ? */
 	int read_ahead;		/* DM_READ_AHEAD_NONE or _AUTO */
+	int cache_vgmetadata;
 	const char *msg_prefix;
 	struct format_type *fmt;
 	uint64_t unit_factor;
--- LVM2/tools/commands.h	2008/01/22 02:48:53	1.108
+++ LVM2/tools/commands.h	2008/04/02 21:23:39	1.109
@@ -30,6 +30,7 @@
 
 xx(dumpconfig,
    "Dump active configuration",
+   0,
    "dumpconfig "
    "\t[-f|--file filename] " "\n"
    "[ConfigurationVariable...]\n",
@@ -37,10 +38,12 @@
 
 xx(formats,
    "List available metadata formats",
+   0,
    "formats\n")
 
 xx(help,
    "Display help for commands",
+   0,
    "help <command>" "\n")
 
 /*********
@@ -55,6 +58,7 @@
 
 xx(lvchange,
    "Change the attributes of logical volume(s)",
+   CACHE_VGMETADATA,
    "lvchange\n"
    "\t[-A|--autobackup y|n]\n"
    "\t[-a|--available [e|l]y|n]\n"
@@ -87,6 +91,7 @@
 
 xx(lvconvert,
    "Change logical volume layout",
+   0,
    "lvconvert "
    "[-m|--mirrors Mirrors [{--mirrorlog {disk|core}|--corelog}]]\n"
    "\t[-R|--regionsize MirrorLogRegionSize]\n"
@@ -114,6 +119,7 @@
 
 xx(lvcreate,
    "Create a logical volume",
+   0,
    "lvcreate " "\n"
    "\t[-A|--autobackup {y|n}]\n"
    "\t[--addtag Tag]\n"
@@ -165,6 +171,7 @@
 
 xx(lvdisplay,
    "Display information about a logical volume",
+   0,
    "lvdisplay\n"
    "\t[-a|--all]\n"
    "\t[-c|--colon]\n"
@@ -205,6 +212,7 @@
 
 xx(lvextend,
    "Add space to a logical volume",
+   0,
    "lvextend\n"
    "\t[-A|--autobackup y|n]\n"
    "\t[--alloc AllocationPolicy]\n"
@@ -228,6 +236,7 @@
 
 xx(lvmchange,
    "With the device mapper, this is obsolete and does nothing.",
+   0,
    "lvmchange\n"
    "\t[-d|--debug]\n"
    "\t[-h|--help]\n"
@@ -239,6 +248,7 @@
 
 xx(lvmdiskscan,
    "List devices that may be used as physical volumes",
+   0,
    "lvmdiskscan\n"
    "\t[-d|--debug]\n"
    "\t[-h|--help]\n"
@@ -249,6 +259,7 @@
 
 xx(lvmsadc,
    "Collect activity data",
+   0,
    "lvmsadc\n"
    "\t[-d|--debug]\n"
    "\t[-h|--help]\n"
@@ -258,6 +269,7 @@
 
 xx(lvmsar,
    "Create activity report",
+   0,
    "lvmsar\n"
    "\t[-d|--debug]\n"
    "\t[-f|--full]\n"
@@ -271,6 +283,7 @@
 
 xx(lvreduce,
    "Reduce the size of a logical volume",
+   0,
    "lvreduce\n"
    "\t[-A|--autobackup y|n]\n"
    "\t[-d|--debug]\n"
@@ -291,6 +304,7 @@
 
 xx(lvremove,
    "Remove logical volume(s) from the system",
+   0,
    "lvremove\n"
    "\t[-A|--autobackup y|n]\n"
    "\t[-d|--debug]\n"
@@ -305,6 +319,7 @@
 
 xx(lvrename,
    "Rename a logical volume",
+   0,
    "lvrename "
    "\t[-A|--autobackup {y|n}] " "\n"
    "\t[-d|--debug] " "\n"
@@ -319,6 +334,7 @@
 
 xx(lvresize,
    "Resize a logical volume",
+   0,
    "lvresize\n"
    "\t[-A|--autobackup y|n]\n"
    "\t[--alloc AllocationPolicy]\n"
@@ -340,6 +356,7 @@
 
 xx(lvs,
    "Display information about logical volumes",
+   0,
    "lvs" "\n"
    "\t[-a|--all]\n"
    "\t[--aligned]\n"
@@ -366,6 +383,7 @@
 
 xx(lvscan,
    "List all logical volumes in all volume groups",
+   0,
    "lvscan " "\n"
    "\t[-a|--all]\n"
    "\t[-b|--blockdevice] " "\n"
@@ -380,6 +398,7 @@
 
 xx(pvchange,
    "Change attributes of physical volume(s)",
+   0,
    "pvchange\n"
    "\t[-a|--all]\n"
    "\t[-A|--autobackup y|n]\n"
@@ -399,6 +418,7 @@
 
 xx(pvresize,
    "Resize physical volume(s)",
+   0,
    "pvresize " "\n"
    "\t[-d|--debug]" "\n"
    "\t[-h|-?|--help] " "\n"
@@ -412,6 +432,7 @@
 
 xx(pvck,
    "Check the consistency of physical volume(s)",
+   0,
    "pvck "
    "\t[-d|--debug]\n"
    "\t[-h|--help]\n"
@@ -424,6 +445,7 @@
 
 xx(pvcreate,
    "Initialize physical volume(s) for use by LVM",
+   0,
    "pvcreate " "\n"
    "\t[--restorefile file]\n"
    "\t[-d|--debug]" "\n"
@@ -448,6 +470,7 @@
 
 xx(pvdata,
    "Display the on-disk metadata for physical volume(s)",
+   0,
    "pvdata " "\n"
    "\t[-a|--all] " "\n"
    "\t[-d|--debug] " "\n"
@@ -466,6 +489,7 @@
 
 xx(pvdisplay,
    "Display various attributes of physical volume(s)",
+   0,
    "pvdisplay\n"
    "\t[-c|--colon]\n"
    "\t[-d|--debug]\n"
@@ -502,6 +526,7 @@
 
 xx(pvmove,
    "Move extents from one physical volume to another",
+   0,
    "pvmove " "\n"
    "\t[--abort]\n"
    "\t[-A|--autobackup {y|n}]\n"
@@ -523,6 +548,7 @@
 
 xx(pvremove,
    "Remove LVM label(s) from physical volume(s)",
+   0,
    "pvremove " "\n"
    "\t[-d|--debug]" "\n"
    "\t[-f[f]|--force [--force]] " "\n"
@@ -537,6 +563,7 @@
 
 xx(pvs,
    "Display information about physical volumes",
+   0,
    "pvs" "\n"
    "\t[--aligned]\n"
    "\t[-a|--all]\n"
@@ -563,6 +590,7 @@
 
 xx(pvscan,
    "List all physical volumes",
+   0,
    "pvscan " "\n"
    "\t[-d|--debug] " "\n"
    "\t{-e|--exported | -n|--novolumegroup} " "\n"
@@ -579,10 +607,12 @@
 
 xx(segtypes,
    "List available segment types",
+   0,
    "segtypes\n")
 
 xx(vgcfgbackup,
    "Backup volume group configuration(s)",
+   0,
    "vgcfgbackup " "\n"
    "\t[-d|--debug] " "\n"
    "\t[-f|--file filename] " "\n"
@@ -597,6 +627,7 @@
 
 xx(vgcfgrestore,
    "Restore volume group configuration",
+   0,
    "vgcfgrestore " "\n"
    "\t[-d|--debug] " "\n"
    "\t[-f|--file filename] " "\n"
@@ -613,6 +644,7 @@
 
 xx(vgchange,
    "Change volume group attributes",
+   CACHE_VGMETADATA,
    "vgchange" "\n"
    "\t[-A|--autobackup {y|n}] " "\n"
    "\t[--alloc AllocationPolicy] " "\n"
@@ -643,6 +675,7 @@
 
 xx(vgck,
    "Check the consistency of volume group(s)",
+   0,
    "vgck "
    "\t[-d|--debug]\n"
    "\t[-h|--help]\n"
@@ -652,6 +685,7 @@
 
 xx(vgconvert,
    "Change volume group metadata format",
+   0,
    "vgconvert  " "\n"
    "\t[-d|--debug]" "\n"
    "\t[-h|--help] " "\n"
@@ -669,6 +703,7 @@
 
 xx(vgcreate,
    "Create a volume group",
+   0,
    "vgcreate" "\n"
    "\t[-A|--autobackup {y|n}] " "\n"
    "\t[--addtag Tag] " "\n"
@@ -690,6 +725,7 @@
 
 xx(vgdisplay,
    "Display volume group information",
+   0,
    "vgdisplay " "\n"
    "\t[-c|--colon | -s|--short | -v|--verbose]" "\n"
    "\t[-d|--debug] " "\n"
@@ -725,6 +761,7 @@
 
 xx(vgexport,
    "Unregister volume group(s) from the system",
+   0,
    "vgexport " "\n"
    "\t[-a|--all] " "\n"
    "\t[-d|--debug] " "\n"
@@ -737,6 +774,7 @@
 
 xx(vgextend,
    "Add physical volumes to a volume group",
+   0,
    "vgextend\n"
    "\t[-A|--autobackup y|n]\n"
    "\t[-d|--debug]\n"
@@ -750,6 +788,7 @@
 
 xx(vgimport,
    "Register exported volume group with system",
+   0,
    "vgimport " "\n"
    "\t[-a|--all]\n"
    "\t[-d|--debug] " "\n"
@@ -764,6 +803,7 @@
 
 xx(vgmerge,
    "Merge volume groups",
+   0,
    "vgmerge\n"
    "\t[-A|--autobackup y|n]\n"
    "\t[-d|--debug]\n"
@@ -778,6 +818,7 @@
 
 xx(vgmknodes,
    "Create the special files for volume group devices in /dev",
+   0,
    "vgmknodes\n"
    "\t[-d|--debug]\n"
    "\t[-h|--help]\n"
@@ -790,6 +831,7 @@
 
 xx(vgreduce,
    "Remove physical volume(s) from a volume group",
+   0,
    "vgreduce\n"
    "\t[-a|--all]\n"
    "\t[-A|--autobackup y|n]\n"
@@ -807,6 +849,7 @@
 
 xx(vgremove,
    "Remove volume group(s)",
+   0,
    "vgremove\n"
    "\t[-d|--debug]\n"
    "\t[-f|--force]\n"
@@ -820,6 +863,7 @@
 
 xx(vgrename,
    "Rename a volume group",
+   0,
    "vgrename\n"
    "\t[-A|--autobackup y|n]\n"
    "\t[-d|--debug]\n"
@@ -834,6 +878,7 @@
 
 xx(vgs,
    "Display information about volume groups",
+   0,
    "vgs" "\n"
    "\t[--aligned]\n"
    "\t[-a|--all]\n"
@@ -859,6 +904,7 @@
 
 xx(vgscan,
    "Search for all volume groups",
+   0,
    "vgscan "
    "\t[-d|--debug]\n"
    "\t[-h|--help]\n"
@@ -872,6 +918,7 @@
 
 xx(vgsplit,
    "Move physical volumes into a new or existing volume group",
+   0,
    "vgsplit " "\n"
    "\t[-A|--autobackup {y|n}] " "\n"
    "\t[--alloc AllocationPolicy] " "\n"
@@ -893,5 +940,6 @@
 
 xx(version,
    "Display software and driver version information",
+   0,
    "version\n" )
 
--- LVM2/tools/lvmcmdline.c	2008/01/30 14:00:02	1.61
+++ LVM2/tools/lvmcmdline.c	2008/04/02 21:23:39	1.62
@@ -421,6 +421,7 @@
 }
 
 static void _create_new_command(const char *name, command_fn command,
+				unsigned flags,
 				const char *desc, const char *usagestr,
 				int nargs, int *args)
 {
@@ -434,12 +435,13 @@
 	nc->desc = desc;
 	nc->usage = usagestr;
 	nc->fn = command;
+	nc->flags = flags;
 	nc->num_args = nargs;
 	nc->valid_args = args;
 }
 
-static void _register_command(const char *name, command_fn fn,
-			      const char *desc, const char *usagestr, ...)
+static void _register_command(const char *name, command_fn fn, const char *desc,
+			      unsigned flags, const char *usagestr, ...)
 {
 	int nargs = 0, i;
 	int *args;
@@ -464,16 +466,16 @@
 	va_end(ap);
 
 	/* enter the command in the register */
-	_create_new_command(name, fn, desc, usagestr, nargs, args);
+	_create_new_command(name, fn, flags, desc, usagestr, nargs, args);
 }
 
 void lvm_register_commands(void)
 {
-#define xx(a, b, c...) _register_command(# a, a, b, ## c, \
-					driverloaded_ARG, \
-					debug_ARG, help_ARG, help2_ARG, \
-					version_ARG, verbose_ARG, \
-					quiet_ARG, config_ARG, -1);
+#define xx(a, b, c, d...) _register_command(# a, a, b, c, ## d, \
+					    driverloaded_ARG, \
+					    debug_ARG, help_ARG, help2_ARG, \
+					    version_ARG, verbose_ARG, \
+					    quiet_ARG, config_ARG, -1);
 #include "commands.h"
 #undef xx
 }
@@ -707,6 +709,7 @@
 
 	cmd->current_settings.archive = arg_int_value(cmd, autobackup_ARG, cmd->current_settings.archive);
 	cmd->current_settings.backup = arg_int_value(cmd, autobackup_ARG, cmd->current_settings.backup);
+	cmd->current_settings.cache_vgmetadata = cmd->command->flags & CACHE_VGMETADATA ? 1 : 0;
 
 	if (arg_count(cmd, partial_ARG)) {
 		init_partial(1);
--- LVM2/tools/tools.h	2008/01/10 18:35:51	1.60
+++ LVM2/tools/tools.h	2008/04/02 21:23:39	1.61
@@ -117,6 +117,8 @@
 	void *ptr;
 };
 
+#define CACHE_VGMETADATA 0x00000001
+
 /* a register of the lvm commands */
 struct command {
 	const char *name;
@@ -124,6 +126,8 @@
 	const char *usage;
 	command_fn fn;
 
+	unsigned flags;
+
 	int num_args;
 	int *valid_args;
 };


