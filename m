From: David Teigland <teigland@fedoraproject.org>
Date: Mon, 13 Feb 2017 18:09:57 +0000 (UTC)
Subject: master - commands: new method for defining commands
Message-ID: <20170213180957.5294660EE0@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=1e2420bca85da9a37570871cd70192e9ae831786
Commit:        1e2420bca85da9a37570871cd70192e9ae831786
Parent:        19267fa6aa0709e3d0c962ad0904920f06102a5b
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Aug 12 15:52:18 2016 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Feb 13 08:20:10 2017 -0600

commands: new method for defining commands

. Define a prototype for every lvm command.
. Match every user command with one definition.
. Generate help text and man pages from them.

The new file command-lines.in defines a prototype for every
unique lvm command.  A unique lvm command is a unique
combination of: command name + required option args +
required positional args.  Each of these prototypes also
includes the optional option args and optional positional
args that the command will accept, a description, and a
unique string ID for the definition.  Any valid command
will match one of the prototypes.

Here's an example of the lvresize command definitions from
command-lines.in, there are three unique lvresize commands:

lvresize --size SizeMB LV
OO: --alloc Alloc, --autobackup Bool, --force,
--nofsck, --nosync, --noudevsync, --reportformat String, --resizefs,
--stripes Number, --stripesize SizeKB, --poolmetadatasize SizeMB
OP: PV ...
ID: lvresize_by_size
DESC: Resize an LV by a specified size.

lvresize LV PV ...
OO: --alloc Alloc, --autobackup Bool, --force,
--nofsck, --nosync, --noudevsync,
--reportformat String, --resizefs, --stripes Number, --stripesize SizeKB
ID: lvresize_by_pv
DESC: Resize an LV by specified PV extents.
FLAGS: SECONDARY_SYNTAX

lvresize --poolmetadatasize SizeMB LV_thinpool
OO: --alloc Alloc, --autobackup Bool, --force,
--nofsck, --nosync, --noudevsync,
--reportformat String, --stripes Number, --stripesize SizeKB
OP: PV ...
ID: lvresize_pool_metadata_by_size
DESC: Resize a pool metadata SubLV by a specified size.

The three commands have separate definitions because they have
different required parameters.  Required parameters are specified
on the first line of the definition.  Optional options are
listed after OO, and optional positional args are listed after OP.

This data is used to generate corresponding command definition
structures for lvm in command-lines.h.  usage/help output is also
auto generated, so it is always in sync with the definitions.

Every user-entered command is compared against the set of
command structures, and matched with one.  An error is
reported if an entered command does not have the required
parameters for any definition.  The closest match is printed
as a suggestion, and running lvresize --help will display
the usage for each possible lvresize command.

The prototype syntax used for help/man output includes
required --option and positional args on the first line,
and optional --option and positional args enclosed in [ ]
on subsequent lines.

  command_name <required_opt_args> <required_pos_args>
          [ <optional_opt_args> ]
          [ <optional_pos_args> ]

Command definitions that are not to be advertised/suggested
have the flag SECONDARY_SYNTAX.  These commands will not be
printed in the normal help output.

Man page prototypes are also generated from the same original
command definitions, and are always in sync with the code
and help text.

Very early in command execution, a matching command definition
is found.  lvm then knows the operation being done, and that
the provided args conform to the definition.  This will allow
lots of ad hoc checking/validation to be removed throughout
the code.

Each command definition can also be routed to a specific
function to implement it.  The function is associated with
an enum value for the command definition (generated from
the ID string.)  These per-command-definition implementation
functions have not yet been created, so all commands
currently fall back to the existing per-command-name
implementation functions.

Using per-command-definition functions will allow lots of
code to be removed which tries to figure out what the
command is meant to do.  This is currently based on ad hoc
and complicated option analysis.  When using the new
functions, what the command is doing is already known
from the associated command definition.
---
 lib/commands/toolcontext.h            |   10 +-
 lib/metadata/lv_manip.c               |    3 +-
 lib/metadata/metadata-exported.h      |    9 +-
 lib/metadata/thin_manip.c             |   13 +
 test/shell/lvconvert-thin-raid.sh     |    4 +-
 test/shell/lvconvert-thin.sh          |    4 +-
 test/shell/lvcreate-cache.sh          |    2 +-
 test/shell/vgextend-restoremissing.sh |    1 -
 tools/Makefile.in                     |   11 +-
 tools/args.h                          |  407 +++---
 tools/command-lines.in                | 1579 +++++++++++++++++
 tools/command.h                       |  207 +++
 tools/commands.h                      | 1428 +---------------
 tools/create-commands.c               | 2990 +++++++++++++++++++++++++++++++++
 tools/lv_props.h                      |   56 +
 tools/lv_types.h                      |   34 +
 tools/lvm.c                           |   32 +-
 tools/lvm2cmdline.h                   |    9 +-
 tools/lvmcmdlib.c                     |    4 +-
 tools/lvmcmdline.c                    | 1446 ++++++++++++++--
 tools/toollib.c                       |  641 +++++++-
 tools/toollib.h                       |    6 +
 tools/tools.h                         |   86 +-
 tools/vals.h                          |  136 ++
 tools/vgchange.c                      |    3 +
 tools/vgconvert.c                     |   14 +-
 tools/vgextend.c                      |    6 -
 27 files changed, 7305 insertions(+), 1836 deletions(-)

diff --git a/lib/commands/toolcontext.h b/lib/commands/toolcontext.h
index bb962dc..2dc1c28 100644
--- a/lib/commands/toolcontext.h
+++ b/lib/commands/toolcontext.h
@@ -88,12 +88,20 @@ struct cmd_context {
 	 * Command line and arguments.
 	 */
 	const char *cmd_line;
+	const char *name; /* needed before cmd->command is set */
 	struct command *command;
 	char **argv;
-	struct arg_values *arg_values;
+	struct arg_values *opt_arg_values;
 	struct dm_list arg_value_groups;
 
 	/*
+	 * Position args remaining after command name
+	 * and --options are removed from original argc/argv.
+	 */
+	int position_argc;
+	char **position_argv;
+
+	/*
 	 * Format handlers.
 	 */
 	const struct format_type *fmt;		/* current format to use by default */
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 01ab96b..bc599de 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -319,7 +319,6 @@ static int _lv_layout_and_role_thin(struct dm_pool *mem,
 {
 	int top_level = 0;
 	unsigned snap_count;
-	struct lv_segment *seg;
 
 	/* non-top-level LVs */
 	if (lv_is_thin_pool_metadata(lv)) {
@@ -353,7 +352,7 @@ static int _lv_layout_and_role_thin(struct dm_pool *mem,
 			    !str_list_add_no_dup_check(mem, role, _lv_type_names[LV_TYPE_MULTITHINORIGIN]))
 				goto_bad;
 		}
-		if ((seg = first_seg(lv)) && (seg->origin || seg->external_lv))
+		if (lv_is_thin_snapshot(lv))
 			if (!str_list_add(mem, role, _lv_type_names[LV_TYPE_SNAPSHOT]) ||
 			    !str_list_add_no_dup_check(mem, role, _lv_type_names[LV_TYPE_THINSNAPSHOT]))
 				goto_bad;
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 5fe169c..420893c 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -1067,9 +1067,16 @@ struct lv_segment *get_only_segment_using_this_lv(const struct logical_volume *l
 * Useful functions for managing snapshots.
 */
 int lv_is_origin(const struct logical_volume *lv);
+#define lv_is_thick_origin lv_is_origin
+
 int lv_is_thin_origin(const struct logical_volume *lv, unsigned *snap_count);
-int lv_is_cache_origin(const struct logical_volume *lv);
+int lv_is_thin_snapshot(const struct logical_volume *lv);
+
 int lv_is_cow(const struct logical_volume *lv);
+#define lv_is_thick_snapshot lv_is_cow
+
+int lv_is_cache_origin(const struct logical_volume *lv);
+
 int lv_is_merging_cow(const struct logical_volume *cow);
 uint32_t cow_max_extents(const struct logical_volume *origin, uint32_t chunk_size);
 int cow_has_min_chunks(const struct volume_group *vg, uint32_t cow_extents, uint32_t chunk_size);
diff --git a/lib/metadata/thin_manip.c b/lib/metadata/thin_manip.c
index 42ec552..3e2a185 100644
--- a/lib/metadata/thin_manip.c
+++ b/lib/metadata/thin_manip.c
@@ -752,6 +752,19 @@ int lv_is_thin_origin(const struct logical_volume *lv, unsigned int *snap_count)
 	return r;
 }
 
+int lv_is_thin_snapshot(const struct logical_volume *lv)
+{
+	struct lv_segment *seg;
+
+	if (!lv_is_thin_volume(lv))
+		return 0;
+
+	if ((seg = first_seg(lv)) && (seg->origin || seg->external_lv))
+		return 1;
+
+	return 0;
+}
+
 /*
  * Explict check of new thin pool for usability
  *
diff --git a/test/shell/lvconvert-thin-raid.sh b/test/shell/lvconvert-thin-raid.sh
index 7fa8733..33e5b6d 100644
--- a/test/shell/lvconvert-thin-raid.sh
+++ b/test/shell/lvconvert-thin-raid.sh
@@ -30,8 +30,8 @@ aux wait_for_sync $vg $lv2
 lvchange -an $vg/$lv1
 
 # conversion fails for internal volumes
-invalid lvconvert --thinpool $vg/${lv1}_rimage_0
-invalid lvconvert --yes --thinpool $vg/$lv1 --poolmetadata $vg/${lv2}_rimage_0
+not lvconvert --thinpool $vg/${lv1}_rimage_0
+not lvconvert --yes --thinpool $vg/$lv1 --poolmetadata $vg/${lv2}_rimage_0
 
 lvconvert --yes --thinpool $vg/$lv1 --poolmetadata $vg/$lv2
 
diff --git a/test/shell/lvconvert-thin.sh b/test/shell/lvconvert-thin.sh
index 4bd1acd..3878fcb 100644
--- a/test/shell/lvconvert-thin.sh
+++ b/test/shell/lvconvert-thin.sh
@@ -58,13 +58,13 @@ lvchange -an $vg/$lv1
 # conversion fails for mirror segment type
 fail lvconvert --thinpool $vg/$lv1
 # cannot use same LV
-invalid lvconvert --yes --thinpool $vg/$lv2 --poolmetadata $vg/$lv2
+not lvconvert --yes --thinpool $vg/$lv2 --poolmetadata $vg/$lv2
 
 prepare_lvs
 
 # conversion fails for internal volumes
 # can't use --readahead with --poolmetadata
-invalid lvconvert --thinpool $vg/$lv1 --poolmetadata $vg/$lv2 --readahead 512
+not lvconvert --thinpool $vg/$lv1 --poolmetadata $vg/$lv2 --readahead 512
 lvconvert --yes --thinpool $vg/$lv1 --poolmetadata $vg/$lv2
 
 prepare_lvs
diff --git a/test/shell/lvcreate-cache.sh b/test/shell/lvcreate-cache.sh
index c38549f..9222bea 100644
--- a/test/shell/lvcreate-cache.sh
+++ b/test/shell/lvcreate-cache.sh
@@ -56,7 +56,7 @@ fail lvcreate -l 1 --cachepool pool8 $vg
 
 # no size specified
 invalid lvcreate --cachepool pool $vg 2>&1 | tee err
-grep "specify either size or extents" err
+# grep "specify either size or extents" err
 
 # Check nothing has been created yet
 check vg_field $vg lv_count 0
diff --git a/test/shell/vgextend-restoremissing.sh b/test/shell/vgextend-restoremissing.sh
index 7346519..2a82115 100644
--- a/test/shell/vgextend-restoremissing.sh
+++ b/test/shell/vgextend-restoremissing.sh
@@ -23,7 +23,6 @@ lvcreate -l 1 -n lv1 $vg "$dev1"
 invalid vgextend
 # --metadatacopies => use --pvmetadatacopies
 invalid vgextend --metadatacopies 3 $vg "$dev1" 2>&1 | tee out
-grep -- "use --pvmetadatacopies" out
 
 # VG name should exist
 fail vgextend --restoremissing $vg-invalid "$dev1"
diff --git a/tools/Makefile.in b/tools/Makefile.in
index d93c31b..887bc69 100644
--- a/tools/Makefile.in
+++ b/tools/Makefile.in
@@ -76,6 +76,7 @@ SOURCES2 =\
 
 TARGETS =\
 	.commands \
+	command-lines.h \
 	liblvm2cmd.a \
 	lvm
 
@@ -99,7 +100,8 @@ LIB_VERSION = $(LIB_VERSION_LVM)
 CLEAN_TARGETS = liblvm2cmd.$(LIB_SUFFIX) $(TARGETS_DM) \
 	liblvm2cmd.$(LIB_SUFFIX).$(LIB_VERSION) lvm-static.o \
 	liblvm2cmd-static.a dmsetup.static lvm.static \
-	$(LDDEPS) .exported_symbols_generated
+	$(LDDEPS) .exported_symbols_generated \
+	ccmd command-lines.h command-lines-count.h
 
 ifeq ("@CMDLIB@", "yes")
 	TARGETS += liblvm2cmd.$(LIB_SUFFIX).$(LIB_VERSION)
@@ -171,6 +173,13 @@ liblvm2cmd.$(LIB_SUFFIX).$(LIB_VERSION): liblvm2cmd.$(LIB_SUFFIX)
 	$(CC) -E -P $(srcdir)/cmdnames.h 2> /dev/null | \
 		egrep -v '^ *(|#.*|config|devtypes|dumpconfig|formats|fullreport|help|lastlog|lvpoll|pvdata|segtypes|systemid|tags|version) *$$' > .commands
 
+ccmd: create-commands.c
+	$(CC) create-commands.c -o ccmd
+
+command-lines.h: ccmd
+	./ccmd --output struct command-lines.in > command-lines.h
+	./ccmd --output count command-lines.in > command-lines-count.h
+
 ifneq ("$(CFLOW_CMD)", "")
 CFLOW_SOURCES = $(addprefix $(srcdir)/, $(SOURCES))
 -include $(top_builddir)/libdm/libdevmapper.cflow
diff --git a/tools/args.h b/tools/args.h
index a6fc77c..8f5f0ec 100644
--- a/tools/args.h
+++ b/tools/args.h
@@ -17,215 +17,216 @@
  * Put all long args that don't have a corresponding short option first.
  */
 /* *INDENT-OFF* */
-arg(abort_ARG, '\0', "abort", NULL, 0, 0)
-arg(activationmode_ARG, '\0', "activationmode", string_arg, 0, 0)
-arg(addtag_ARG, '\0', "addtag", tag_arg, ARG_GROUPABLE, 0)
-arg(aligned_ARG, '\0', "aligned", NULL, 0, 0)
-arg(alloc_ARG, '\0', "alloc", alloc_arg, 0, 0)
-arg(atomic_ARG, '\0', "atomic", NULL, 0, 0)
-arg(atversion_ARG, '\0', "atversion", string_arg, 0, 0)
-arg(binary_ARG, '\0', "binary", NULL, 0, 0)
-arg(bootloaderareasize_ARG, '\0', "bootloaderareasize", size_mb_arg, 0, 0)
-arg(cache_long_ARG, '\0', "cache", NULL, 0, 0)
-arg(cachemode_ARG, '\0', "cachemode", cachemode_arg, 0, 0)
-arg(cachepool_ARG, '\0', "cachepool", string_arg, 0, 0)
-arg(commandprofile_ARG, '\0', "commandprofile", string_arg, 0, 0)
-arg(config_ARG, '\0', "config", string_arg, 0, 0)
-arg(configreport_ARG, '\0', "configreport", string_arg, ARG_GROUPABLE, 1)
-arg(configtype_ARG, '\0', "type", string_arg, 0, 0)
-arg(corelog_ARG, '\0', "corelog", NULL, 0, 0)
-arg(dataalignment_ARG, '\0', "dataalignment", size_kb_arg, 0, 0)
-arg(dataalignmentoffset_ARG, '\0', "dataalignmentoffset", size_kb_arg, 0, 0)
-arg(deltag_ARG, '\0', "deltag", tag_arg, ARG_GROUPABLE, 0)
-arg(detachprofile_ARG, '\0', "detachprofile", NULL, 0, 0)
-arg(discards_ARG, '\0', "discards", discards_arg, 0, 0)
-arg(driverloaded_ARG, '\0', "driverloaded", yes_no_arg, 0, 0)
-arg(errorwhenfull_ARG, '\0', "errorwhenfull", yes_no_arg, 0, 0)
-arg(force_long_ARG, '\0', "force", NULL, ARG_COUNTABLE, 0)
-arg(foreign_ARG, '\0', "foreign", NULL, 0, 0)
-arg(handlemissingpvs_ARG, '\0', "handlemissingpvs", NULL, 0, 0)
-arg(ignoreadvanced_ARG, '\0', "ignoreadvanced", NULL, 0, 0)
-arg(ignorelocal_ARG, '\0', "ignorelocal", NULL, 0, 0)
-arg(ignorelockingfailure_ARG, '\0', "ignorelockingfailure", NULL, 0, 0)
-arg(ignoremonitoring_ARG, '\0', "ignoremonitoring", NULL, 0, 0)
-arg(ignoreskippedcluster_ARG, '\0', "ignoreskippedcluster", NULL, 0, 0)
-arg(ignoreunsupported_ARG, '\0', "ignoreunsupported", NULL, 0, 0)
-arg(labelsector_ARG, '\0', "labelsector", int_arg, 0, 0)
-arg(lockopt_ARG, '\0', "lockopt", string_arg, 0, 0)
-arg(lockstart_ARG, '\0', "lockstart", NULL, 0, 0)
-arg(lockstop_ARG, '\0', "lockstop", NULL, 0, 0)
-arg(locktype_ARG, '\0', "locktype", locktype_arg, 0, 0)
-arg(logonly_ARG, '\0', "logonly", NULL, 0, 0)
-arg(maxrecoveryrate_ARG, '\0', "maxrecoveryrate", size_kb_arg, 0, 0)
-arg(merge_ARG, '\0', "merge", NULL, 0, 0)
-arg(mergedconfig_ARG, '\0', "mergedconfig", NULL, 0, 0)
-arg(metadatacopies_ARG, '\0', "metadatacopies", metadatacopies_arg, 0, 0)
-arg(metadataignore_ARG, '\0', "metadataignore", yes_no_arg, 0, 0)
-arg(metadataprofile_ARG, '\0', "metadataprofile", string_arg, 0, 0)
-arg(metadatasize_ARG, '\0', "metadatasize", size_mb_arg, 0, 0)
-arg(minor_ARG, '\0', "minor", int_arg, ARG_GROUPABLE, 0)
-arg(minrecoveryrate_ARG, '\0', "minrecoveryrate", size_kb_arg, 0, 0)
-arg(mirrorlog_ARG, '\0', "mirrorlog", mirrorlog_arg, 0, 0)
-arg(mirrorsonly_ARG, '\0', "mirrorsonly", NULL, 0, 0)
-arg(mknodes_ARG, '\0', "mknodes", NULL, 0, 0)
-arg(monitor_ARG, '\0', "monitor", yes_no_arg, 0, 0)
-arg(nameprefixes_ARG, '\0', "nameprefixes", NULL, 0, 0)
-arg(noheadings_ARG, '\0', "noheadings", NULL, 0, 0)
-arg(nohistory_ARG, '\0', "nohistory", NULL, 0, 0)
-arg(nolocking_ARG, '\0', "nolocking", NULL, 0, 0)
-arg(norestorefile_ARG, '\0', "norestorefile", NULL, 0, 0)
-arg(nosuffix_ARG, '\0', "nosuffix", NULL, 0, 0)
-arg(nosync_ARG, '\0', "nosync", NULL, 0, 0)
-arg(notifydbus_ARG, '\0', "notifydbus", NULL, 0, 0)
-arg(noudevsync_ARG, '\0', "noudevsync", NULL, 0, 0)
-arg(originname_ARG, '\0', "originname", string_arg, 0, 0)
-arg(physicalvolumesize_ARG, '\0', "setphysicalvolumesize", size_mb_arg, 0, 0)
-arg(poll_ARG, '\0', "poll", yes_no_arg, 0, 0)
-arg(polloperation_ARG, '\0', "polloperation", string_arg, 0, 0)
-arg(pooldatasize_ARG, '\0', "pooldatasize", size_mb_arg, 0, 0)
-arg(poolmetadata_ARG, '\0', "poolmetadata", string_arg, 0, 0)
-arg(poolmetadatasize_ARG, '\0', "poolmetadatasize", size_mb_arg, 0, 0)
-arg(poolmetadataspare_ARG, '\0', "poolmetadataspare", yes_no_arg, 0, 0)
-arg(profile_ARG, '\0', "profile", string_arg, 0, 0)
-arg(pvmetadatacopies_ARG, '\0', "pvmetadatacopies", int_arg, 0, 0)
-arg(raidrebuild_ARG, '\0', "raidrebuild", string_arg, ARG_GROUPABLE, 0)
-arg(raidmaxrecoveryrate_ARG, '\0', "raidmaxrecoveryrate", size_kb_arg, 0, 0)
-arg(raidminrecoveryrate_ARG, '\0', "raidminrecoveryrate", size_kb_arg, 0, 0)
-arg(raidsyncaction_ARG, '\0', "raidsyncaction", string_arg, 0, 0)
-arg(raidwritebehind_ARG, '\0', "raidwritebehind", int_arg, 0, 0)
-arg(raidwritemostly_ARG, '\0', "raidwritemostly", string_arg, ARG_GROUPABLE, 0)
-arg(readonly_ARG, '\0', "readonly", NULL, 0, 0)
-arg(refresh_ARG, '\0', "refresh", NULL, 0, 0)
-arg(removemissing_ARG, '\0', "removemissing", NULL, 0, 0)
-arg(rebuild_ARG, '\0', "rebuild", string_arg, ARG_GROUPABLE, 0)
-arg(repair_ARG, '\0', "repair", NULL, 0, 0)
-arg(replace_ARG, '\0', "replace", string_arg, ARG_GROUPABLE, 0)
-arg(reportformat_ARG, '\0', "reportformat", string_arg, 0, 0)
-arg(restorefile_ARG, '\0', "restorefile", string_arg, 0, 0)
-arg(restoremissing_ARG, '\0', "restoremissing", NULL, 0, 0)
-arg(resync_ARG, '\0', "resync", NULL, 0, 0)
-arg(rows_ARG, '\0', "rows", NULL, 0, 0)
-arg(segments_ARG, '\0', "segments", NULL, 0, 0)
-arg(separator_ARG, '\0', "separator", string_arg, 0, 0)
-arg(shared_ARG, '\0', "shared", NULL, 0, 0)
-arg(sinceversion_ARG, '\0', "sinceversion", string_arg, 0, 0)
-arg(split_ARG, '\0', "split", NULL, 0, 0)
-arg(splitcache_ARG, '\0', "splitcache", NULL, 0, 0)
-arg(splitmirrors_ARG, '\0', "splitmirrors", int_arg, 0, 0)
-arg(splitsnapshot_ARG, '\0', "splitsnapshot", NULL, 0, 0)
-arg(showdeprecated_ARG, '\0', "showdeprecated", NULL, 0, 0)
-arg(showunsupported_ARG, '\0', "showunsupported", NULL, 0, 0)
-arg(stripes_long_ARG, '\0', "stripes", int_arg, 0, 0)
-arg(syncaction_ARG, '\0', "syncaction", string_arg, 0, 0)	/* FIXME Use custom validation fn */
-arg(sysinit_ARG, '\0', "sysinit", NULL, 0, 0)
-arg(systemid_ARG, '\0', "systemid", string_arg, 0, 0)
-arg(thinpool_ARG, '\0', "thinpool", string_arg, 0, 0)
-arg(trackchanges_ARG, '\0', "trackchanges", NULL, 0, 0)
-arg(trustcache_ARG, '\0', "trustcache", NULL, 0, 0)
-arg(type_ARG, '\0', "type", segtype_arg, 0, 0)
-arg(unbuffered_ARG, '\0', "unbuffered", NULL, 0, 0)
-arg(uncache_ARG, '\0', "uncache", NULL, 0, 0)
-arg(cachepolicy_ARG, '\0', "cachepolicy", string_arg, 0, 0)
-arg(cachesettings_ARG, '\0', "cachesettings", string_arg, ARG_GROUPABLE, 0)
-arg(unconfigured_ARG, '\0', "unconfigured", NULL, 0, 0)
-arg(units_ARG, '\0', "units", string_arg, 0, 0)
-arg(unquoted_ARG, '\0', "unquoted", NULL, 0, 0)
-arg(usepolicies_ARG, '\0', "usepolicies", NULL, 0, 0)
-arg(validate_ARG, '\0', "validate", NULL, 0, 0)
-arg(version_ARG, '\0', "version", NULL, 0, 0)
-arg(vgmetadatacopies_ARG, '\0', "vgmetadatacopies", metadatacopies_arg, 0, 0)
-arg(virtualoriginsize_ARG, '\0', "virtualoriginsize", size_mb_arg, 0, 0)
-arg(withsummary_ARG, '\0', "withsummary", NULL, 0, 0)
-arg(withcomments_ARG, '\0', "withcomments", NULL, 0, 0)
-arg(withspaces_ARG, '\0', "withspaces", NULL, 0, 0)
-arg(withversions_ARG, '\0', "withversions", NULL, 0, 0)
-arg(writebehind_ARG, '\0', "writebehind", int_arg, 0, 0)
-arg(writemostly_ARG, '\0', "writemostly", string_arg, ARG_GROUPABLE, 0)
+arg(ARG_UNUSED, '-', "", 0, 0, 0)  /* place holder for unused 0 value */
+
+arg(abort_ARG, '\0', "abort", 0, 0, 0)
+arg(activationmode_ARG, '\0', "activationmode", activationmode_VAL, 0, 0)
+arg(addtag_ARG, '\0', "addtag", tag_VAL, ARG_GROUPABLE, 0)
+arg(aligned_ARG, '\0', "aligned", 0, 0, 0)
+arg(alloc_ARG, '\0', "alloc", alloc_VAL, 0, 0)
+arg(atomic_ARG, '\0', "atomic", 0, 0, 0)
+arg(atversion_ARG, '\0', "atversion", string_VAL, 0, 0)
+arg(binary_ARG, '\0', "binary", 0, 0, 0)
+arg(bootloaderareasize_ARG, '\0', "bootloaderareasize", sizemb_VAL, 0, 0)
+arg(cache_long_ARG, '\0', "cache", 0, 0, 0)
+arg(cachemode_ARG, '\0', "cachemode", cachemode_VAL, 0, 0)
+arg(cachepool_ARG, '\0', "cachepool", lv_VAL, 0, 0)
+arg(commandprofile_ARG, '\0', "commandprofile", string_VAL, 0, 0)
+arg(config_ARG, '\0', "config", string_VAL, 0, 0)
+arg(configreport_ARG, '\0', "configreport", configreport_VAL, ARG_GROUPABLE, 1)
+arg(configtype_ARG, '\0', "typeconfig", configtype_VAL, 0, 0)
+arg(corelog_ARG, '\0', "corelog", 0, 0, 0)
+arg(dataalignment_ARG, '\0', "dataalignment", sizekb_VAL, 0, 0)
+arg(dataalignmentoffset_ARG, '\0', "dataalignmentoffset", sizekb_VAL, 0, 0)
+arg(deltag_ARG, '\0', "deltag", tag_VAL, ARG_GROUPABLE, 0)
+arg(detachprofile_ARG, '\0', "detachprofile", 0, 0, 0)
+arg(discards_ARG, '\0', "discards", discards_VAL, 0, 0)
+arg(driverloaded_ARG, '\0', "driverloaded", bool_VAL, 0, 0)
+arg(errorwhenfull_ARG, '\0', "errorwhenfull", bool_VAL, 0, 0)
+arg(force_long_ARG, '\0', "force", 0, ARG_COUNTABLE, 0)
+arg(foreign_ARG, '\0', "foreign", 0, 0, 0)
+arg(handlemissingpvs_ARG, '\0', "handlemissingpvs", 0, 0, 0)
+arg(ignoreadvanced_ARG, '\0', "ignoreadvanced", 0, 0, 0)
+arg(ignorelocal_ARG, '\0', "ignorelocal", 0, 0, 0)
+arg(ignorelockingfailure_ARG, '\0', "ignorelockingfailure", 0, 0, 0)
+arg(ignoremonitoring_ARG, '\0', "ignoremonitoring", 0, 0, 0)
+arg(ignoreskippedcluster_ARG, '\0', "ignoreskippedcluster", 0, 0, 0)
+arg(ignoreunsupported_ARG, '\0', "ignoreunsupported", 0, 0, 0)
+arg(labelsector_ARG, '\0', "labelsector", number_VAL, 0, 0)
+arg(lockopt_ARG, '\0', "lockopt", string_VAL, 0, 0)
+arg(lockstart_ARG, '\0', "lockstart", 0, 0, 0)
+arg(lockstop_ARG, '\0', "lockstop", 0, 0, 0)
+arg(locktype_ARG, '\0', "locktype", locktype_VAL, 0, 0)
+arg(logonly_ARG, '\0', "logonly", 0, 0, 0)
+arg(maxrecoveryrate_ARG, '\0', "maxrecoveryrate", sizekb_VAL, 0, 0)
+arg(merge_ARG, '\0', "merge", 0, 0, 0)
+arg(mergedconfig_ARG, '\0', "mergedconfig", 0, 0, 0)
+arg(metadatacopies_ARG, '\0', "metadatacopies", metadatacopies_VAL, 0, 0)
+arg(metadataignore_ARG, '\0', "metadataignore", bool_VAL, 0, 0)
+arg(metadataprofile_ARG, '\0', "metadataprofile", string_VAL, 0, 0)
+arg(metadatasize_ARG, '\0', "metadatasize", sizemb_VAL, 0, 0)
+arg(minor_ARG, '\0', "minor", number_VAL, ARG_GROUPABLE, 0)
+arg(minrecoveryrate_ARG, '\0', "minrecoveryrate", sizekb_VAL, 0, 0)
+arg(mirrorlog_ARG, '\0', "mirrorlog", mirrorlog_VAL, 0, 0)
+arg(mirrorsonly_ARG, '\0', "mirrorsonly", 0, 0, 0)
+arg(mknodes_ARG, '\0', "mknodes", 0, 0, 0)
+arg(monitor_ARG, '\0', "monitor", bool_VAL, 0, 0)
+arg(nameprefixes_ARG, '\0', "nameprefixes", 0, 0, 0)
+arg(noheadings_ARG, '\0', "noheadings", 0, 0, 0)
+arg(nohistory_ARG, '\0', "nohistory", 0, 0, 0)
+arg(nolocking_ARG, '\0', "nolocking", 0, 0, 0)
+arg(norestorefile_ARG, '\0', "norestorefile", 0, 0, 0)
+arg(nosuffix_ARG, '\0', "nosuffix", 0, 0, 0)
+arg(nosync_ARG, '\0', "nosync", 0, 0, 0)
+arg(notifydbus_ARG, '\0', "notifydbus", 0, 0, 0)
+arg(noudevsync_ARG, '\0', "noudevsync", 0, 0, 0)
+arg(originname_ARG, '\0', "originname", lv_VAL, 0, 0)
+arg(physicalvolumesize_ARG, '\0', "setphysicalvolumesize", sizemb_VAL, 0, 0)
+arg(poll_ARG, '\0', "poll", bool_VAL, 0, 0)
+arg(polloperation_ARG, '\0', "polloperation", polloperation_VAL, 0, 0)
+arg(pooldatasize_ARG, '\0', "pooldatasize", sizemb_VAL, 0, 0)
+arg(poolmetadata_ARG, '\0', "poolmetadata", lv_VAL, 0, 0)
+arg(poolmetadatasize_ARG, '\0', "poolmetadatasize", sizemb_VAL, 0, 0)
+arg(poolmetadataspare_ARG, '\0', "poolmetadataspare", bool_VAL, 0, 0)
+arg(profile_ARG, '\0', "profile", string_VAL, 0, 0)
+arg(pvmetadatacopies_ARG, '\0', "pvmetadatacopies", pvmetadatacopies_VAL, 0, 0)
+arg(raidrebuild_ARG, '\0', "raidrebuild", pv_VAL, ARG_GROUPABLE, 0)
+arg(raidmaxrecoveryrate_ARG, '\0', "raidmaxrecoveryrate", sizekb_VAL, 0, 0)
+arg(raidminrecoveryrate_ARG, '\0', "raidminrecoveryrate", sizekb_VAL, 0, 0)
+arg(raidsyncaction_ARG, '\0', "raidsyncaction", syncaction_VAL, 0, 0)
+arg(raidwritebehind_ARG, '\0', "raidwritebehind", number_VAL, 0, 0)
+arg(raidwritemostly_ARG, '\0', "raidwritemostly", writemostly_VAL, ARG_GROUPABLE, 0)
+arg(readonly_ARG, '\0', "readonly", 0, 0, 0)
+arg(refresh_ARG, '\0', "refresh", 0, 0, 0)
+arg(removemissing_ARG, '\0', "removemissing", 0, 0, 0)
+arg(rebuild_ARG, '\0', "rebuild", pv_VAL, ARG_GROUPABLE, 0)
+arg(repair_ARG, '\0', "repair", 0, 0, 0)
+arg(replace_ARG, '\0', "replace", pv_VAL, ARG_GROUPABLE, 0)
+arg(reportformat_ARG, '\0', "reportformat", reportformat_VAL, 0, 0)
+arg(restorefile_ARG, '\0', "restorefile", string_VAL, 0, 0)
+arg(restoremissing_ARG, '\0', "restoremissing", 0, 0, 0)
+arg(resync_ARG, '\0', "resync", 0, 0, 0)
+arg(rows_ARG, '\0', "rows", 0, 0, 0)
+arg(segments_ARG, '\0', "segments", 0, 0, 0)
+arg(separator_ARG, '\0', "separator", string_VAL, 0, 0)
+arg(shared_ARG, '\0', "shared", 0, 0, 0)
+arg(sinceversion_ARG, '\0', "sinceversion", string_VAL, 0, 0)
+arg(split_ARG, '\0', "split", 0, 0, 0)
+arg(splitcache_ARG, '\0', "splitcache", 0, 0, 0)
+arg(splitmirrors_ARG, '\0', "splitmirrors", number_VAL, 0, 0)
+arg(splitsnapshot_ARG, '\0', "splitsnapshot", 0, 0, 0)
+arg(showdeprecated_ARG, '\0', "showdeprecated", 0, 0, 0)
+arg(showunsupported_ARG, '\0', "showunsupported", 0, 0, 0)
+arg(stripes_long_ARG, '\0', "stripes", number_VAL, 0, 0)
+arg(syncaction_ARG, '\0', "syncaction", syncaction_VAL, 0, 0)
+arg(sysinit_ARG, '\0', "sysinit", 0, 0, 0)
+arg(systemid_ARG, '\0', "systemid", string_VAL, 0, 0)
+arg(thinpool_ARG, '\0', "thinpool", lv_VAL, 0, 0)
+arg(trackchanges_ARG, '\0', "trackchanges", 0, 0, 0)
+arg(trustcache_ARG, '\0', "trustcache", 0, 0, 0)
+arg(type_ARG, '\0', "type", segtype_VAL, 0, 0)
+arg(unbuffered_ARG, '\0', "unbuffered", 0, 0, 0)
+arg(uncache_ARG, '\0', "uncache", 0, 0, 0)
+arg(cachepolicy_ARG, '\0', "cachepolicy", string_VAL, 0, 0)
+arg(cachesettings_ARG, '\0', "cachesettings", string_VAL, ARG_GROUPABLE, 0)
+arg(unconfigured_ARG, '\0', "unconfigured", 0, 0, 0)
+arg(units_ARG, '\0', "units", units_VAL, 0, 0)
+arg(unquoted_ARG, '\0', "unquoted", 0, 0, 0)
+arg(usepolicies_ARG, '\0', "usepolicies", 0, 0, 0)
+arg(validate_ARG, '\0', "validate", 0, 0, 0)
+arg(version_ARG, '\0', "version", 0, 0, 0)
+arg(vgmetadatacopies_ARG, '\0', "vgmetadatacopies", vgmetadatacopies_VAL, 0, 0)
+arg(virtualoriginsize_ARG, '\0', "virtualoriginsize", sizemb_VAL, 0, 0)
+arg(withsummary_ARG, '\0', "withsummary", 0, 0, 0)
+arg(withcomments_ARG, '\0', "withcomments", 0, 0, 0)
+arg(withspaces_ARG, '\0', "withspaces", 0, 0, 0)
+arg(withversions_ARG, '\0', "withversions", 0, 0, 0)
+arg(writebehind_ARG, '\0', "writebehind", number_VAL, 0, 0)
+arg(writemostly_ARG, '\0', "writemostly", writemostly_VAL, ARG_GROUPABLE, 0)
 
 /* Allow some variations */
-arg(allocation_ARG, '\0', "allocation", yes_no_arg, 0, 0)
-arg(available_ARG, '\0', "available", activation_arg, 0, 0)
-arg(resizable_ARG, '\0', "resizable", yes_no_arg, 0, 0)
+arg(allocation_ARG, '\0', "allocation", bool_VAL, 0, 0)
+arg(available_ARG, '\0', "available", activation_VAL, 0, 0)
+arg(resizable_ARG, '\0', "resizable", bool_VAL, 0, 0)
 
 /*
  * ... and now the short args.
  */
-arg(activate_ARG, 'a', "activate", activation_arg, 0, 0)
-arg(all_ARG, 'a', "all", NULL, 0, 0)
-arg(autobackup_ARG, 'A', "autobackup", yes_no_arg, 0, 0)
-arg(activevolumegroups_ARG, 'A', "activevolumegroups", NULL, 0, 0)
-arg(background_ARG, 'b', "background", NULL, 0, 0)
-arg(backgroundfork_ARG, 'b', "background", NULL, 0, 0)
-arg(basevgname_ARG, 'n', "basevgname", string_arg, 0, 0)
-arg(blockdevice_ARG, 'b', "blockdevice", NULL, 0, 0)
-arg(chunksize_ARG, 'c', "chunksize", size_kb_arg, 0, 0)
-arg(clustered_ARG, 'c', "clustered", yes_no_arg, 0, 0)
-arg(colon_ARG, 'c', "colon", NULL, 0, 0)
-arg(columns_ARG, 'C', "columns", NULL, 0, 0)
-arg(contiguous_ARG, 'C', "contiguous", yes_no_arg, 0, 0)
-arg(debug_ARG, 'd', "debug", NULL, ARG_COUNTABLE, 0)
-arg(exported_ARG, 'e', "exported", NULL, 0, 0)
-arg(physicalextent_ARG, 'E', "physicalextent", NULL, 0, 0)
-arg(file_ARG, 'f', "file", string_arg, 0, 0)
-arg(force_ARG, 'f', "force", NULL, ARG_COUNTABLE, 0)
-arg(full_ARG, 'f', "full", NULL, 0, 0)
-arg(help_ARG, 'h', "help", NULL, 0, 0)
-arg(cache_ARG, 'H', "cache", NULL, 0, 0)
-arg(history_ARG, 'H', "history", NULL, 0, 0)
-arg(help2_ARG, '?', "", NULL, 0, 0)
-arg(import_ARG, 'i', "import", NULL, 0, 0)
-arg(interval_ARG, 'i', "interval", int_arg, 0, 0)
-arg(iop_version_ARG, 'i', "iop_version", NULL, 0, 0)
-arg(stripes_ARG, 'i', "stripes", int_arg, 0, 0)
-arg(stripesize_ARG, 'I', "stripesize", size_kb_arg, 0, 0)
-arg(logicalvolume_ARG, 'l', "logicalvolume", uint32_arg, 0, 0)
-arg(maxlogicalvolumes_ARG, 'l', "maxlogicalvolumes", uint32_arg, 0, 0)
-arg(extents_ARG, 'l', "extents", int_arg_with_sign_and_percent, 0, 0)
-arg(list_ARG, 'l', "list", NULL, 0, 0)
-arg(lvmpartition_ARG, 'l', "lvmpartition", NULL, 0, 0)
-arg(logicalextent_ARG, 'L', "logicalextent", int_arg_with_sign, 0, 0)
-arg(size_ARG, 'L', "size", size_mb_arg, 0, 0)
-arg(persistent_ARG, 'M', "persistent", yes_no_arg, 0, 0)
-arg(major_ARG, 'j', "major", int_arg, ARG_GROUPABLE, 0)
-arg(setactivationskip_ARG, 'k', "setactivationskip", yes_no_arg, 0, 0)
-arg(ignoreactivationskip_ARG, 'K', "ignoreactivationskip", NULL, 0, 0)
-arg(maps_ARG, 'm', "maps", NULL, 0, 0)
-arg(mirrors_ARG, 'm', "mirrors", int_arg_with_sign, 0, 0)
-arg(metadatatype_ARG, 'M', "metadatatype", metadatatype_arg, 0, 0)
-arg(name_ARG, 'n', "name", string_arg, 0, 0)
-arg(nofsck_ARG, 'n', "nofsck", NULL, 0, 0)
-arg(novolumegroup_ARG, 'n', "novolumegroup", NULL, 0, 0)
-arg(oldpath_ARG, 'n', "oldpath", NULL, 0, 0)
-arg(options_ARG, 'o', "options", string_arg, ARG_GROUPABLE, 0)
-arg(sort_ARG, 'O', "sort", string_arg, ARG_GROUPABLE, 0)
-arg(maxphysicalvolumes_ARG, 'p', "maxphysicalvolumes", uint32_arg, 0, 0)
-arg(permission_ARG, 'p', "permission", permission_arg, 0, 0)
-arg(partial_ARG, 'P', "partial", NULL, 0, 0)
-arg(physicalvolume_ARG, 'P', "physicalvolume", NULL, 0, 0)
-arg(quiet_ARG, 'q', "quiet", NULL, ARG_COUNTABLE, 0)
-arg(readahead_ARG, 'r', "readahead", readahead_arg, 0, 0)
-arg(resizefs_ARG, 'r', "resizefs", NULL, 0, 0)
-arg(reset_ARG, 'R', "reset", NULL, 0, 0)
-arg(regionsize_ARG, 'R', "regionsize", size_mb_arg, 0, 0)
-arg(physicalextentsize_ARG, 's', "physicalextentsize", size_mb_arg, 0, 0)
-arg(snapshot_ARG, 's', "snapshot", NULL, 0, 0)
-arg(short_ARG, 's', "short", NULL, 0, 0)
-arg(stdin_ARG, 's', "stdin", NULL, 0, 0)
-arg(select_ARG, 'S', "select", string_arg, ARG_GROUPABLE, 0)
-arg(test_ARG, 't', "test", NULL, 0, 0)
-arg(thin_ARG, 'T', "thin", NULL, 0, 0)
-arg(uuid_ARG, 'u', "uuid", NULL, 0, 0)
-arg(uuidstr_ARG, 'u', "uuid", string_arg, 0, 0)
-arg(uuidlist_ARG, 'U', "uuidlist", NULL, 0, 0)
-arg(verbose_ARG, 'v', "verbose", NULL, ARG_COUNTABLE, 0)
-arg(volumegroup_ARG, 'V', "volumegroup", NULL, 0, 0)
-arg(virtualsize_ARG, 'V', "virtualsize", size_mb_arg, 0, 0)
-arg(wipesignatures_ARG, 'W', "wipesignatures", yes_no_arg, 0, 0)
-arg(allocatable_ARG, 'x', "allocatable", yes_no_arg, 0, 0)
-arg(resizeable_ARG, 'x', "resizeable", yes_no_arg, 0, 0)
-arg(yes_ARG, 'y', "yes", NULL, 0, 0)
-arg(zero_ARG, 'Z', "zero", yes_no_arg, 0, 0)
+arg(activate_ARG, 'a', "activate", activation_VAL, 0, 0)
+arg(all_ARG, 'a', "all", 0, 0, 0)
+arg(autobackup_ARG, 'A', "autobackup", bool_VAL, 0, 0)
+arg(activevolumegroups_ARG, 'A', "activevolumegroups", 0, 0, 0)
+arg(background_ARG, 'b', "background", 0, 0, 0)
+arg(backgroundfork_ARG, 'b', "background", 0, 0, 0)
+arg(basevgname_ARG, 'n', "basevgname", string_VAL, 0, 0)
+arg(blockdevice_ARG, 'b', "blockdevice", 0, 0, 0)
+arg(chunksize_ARG, 'c', "chunksize", sizekb_VAL, 0, 0)
+arg(clustered_ARG, 'c', "clustered", bool_VAL, 0, 0)
+arg(colon_ARG, 'c', "colon", 0, 0, 0)
+arg(columns_ARG, 'C', "columns", 0, 0, 0)
+arg(contiguous_ARG, 'C', "contiguous", bool_VAL, 0, 0)
+arg(debug_ARG, 'd', "debug", 0, ARG_COUNTABLE, 0)
+arg(exported_ARG, 'e', "exported", 0, 0, 0)
+arg(physicalextent_ARG, 'E', "physicalextent", 0, 0, 0)
+arg(file_ARG, 'f', "file", string_VAL, 0, 0)
+arg(force_ARG, 'f', "force", 0, ARG_COUNTABLE, 0)
+arg(full_ARG, 'f', "full", 0, 0, 0)
+arg(help_ARG, 'h', "help", 0, ARG_COUNTABLE, 0)
+arg(cache_ARG, 'H', "cache", 0, 0, 0)
+arg(history_ARG, 'H', "history", 0, 0, 0)
+arg(help2_ARG, '?', "", 0, 0, 0)
+arg(import_ARG, 'i', "import", 0, 0, 0)
+arg(interval_ARG, 'i', "interval", number_VAL, 0, 0)
+arg(iop_version_ARG, 'i', "iop_version", 0, 0, 0)
+arg(stripes_ARG, 'i', "stripes", number_VAL, 0, 0)
+arg(stripesize_ARG, 'I', "stripesize", sizekb_VAL, 0, 0)
+arg(logicalvolume_ARG, 'l', "logicalvolume", number_VAL, 0, 0)
+arg(maxlogicalvolumes_ARG, 'l', "maxlogicalvolumes", number_VAL, 0, 0)
+arg(extents_ARG, 'l', "extents", numsignedper_VAL, 0, 0)
+arg(list_ARG, 'l', "list", 0, 0, 0)
+arg(lvmpartition_ARG, 'l', "lvmpartition", 0, 0, 0)
+arg(size_ARG, 'L', "size", sizemb_VAL, 0, 0)
+arg(persistent_ARG, 'M', "persistent", bool_VAL, 0, 0)
+arg(major_ARG, 'j', "major", number_VAL, ARG_GROUPABLE, 0)
+arg(setactivationskip_ARG, 'k', "setactivationskip", bool_VAL, 0, 0)
+arg(ignoreactivationskip_ARG, 'K', "ignoreactivationskip", 0, 0, 0)
+arg(maps_ARG, 'm', "maps", 0, 0, 0)
+arg(mirrors_ARG, 'm', "mirrors", numsigned_VAL, 0, 0)
+arg(metadatatype_ARG, 'M', "metadatatype", metadatatype_VAL, 0, 0)
+arg(name_ARG, 'n', "name", string_VAL, 0, 0)
+arg(nofsck_ARG, 'n', "nofsck", 0, 0, 0)
+arg(novolumegroup_ARG, 'n', "novolumegroup", 0, 0, 0)
+arg(oldpath_ARG, 'n', "oldpath", 0, 0, 0)
+arg(options_ARG, 'o', "options", string_VAL, ARG_GROUPABLE, 0)
+arg(sort_ARG, 'O', "sort", string_VAL, ARG_GROUPABLE, 0)
+arg(maxphysicalvolumes_ARG, 'p', "maxphysicalvolumes", number_VAL, 0, 0)
+arg(permission_ARG, 'p', "permission", permission_VAL, 0, 0)
+arg(partial_ARG, 'P', "partial", 0, 0, 0)
+arg(physicalvolume_ARG, 'P', "physicalvolume", 0, 0, 0)
+arg(quiet_ARG, 'q', "quiet", 0, ARG_COUNTABLE, 0)
+arg(readahead_ARG, 'r', "readahead", readahead_VAL, 0, 0)
+arg(resizefs_ARG, 'r', "resizefs", 0, 0, 0)
+arg(reset_ARG, 'R', "reset", 0, 0, 0)
+arg(regionsize_ARG, 'R', "regionsize", sizemb_VAL, 0, 0)
+arg(physicalextentsize_ARG, 's', "physicalextentsize", sizemb_VAL, 0, 0)
+arg(snapshot_ARG, 's', "snapshot", 0, 0, 0)
+arg(short_ARG, 's', "short", 0, 0, 0)
+arg(stdin_ARG, 's', "stdin", 0, 0, 0)
+arg(select_ARG, 'S', "select", string_VAL, ARG_GROUPABLE, 0)
+arg(test_ARG, 't', "test", 0, 0, 0)
+arg(thin_ARG, 'T', "thin", 0, 0, 0)
+arg(uuid_ARG, 'u', "uuid", 0, 0, 0)
+arg(uuidstr_ARG, 'u', "uuid", string_VAL, 0, 0)
+arg(uuidlist_ARG, 'U', "uuidlist", 0, 0, 0)
+arg(verbose_ARG, 'v', "verbose", 0, ARG_COUNTABLE, 0)
+arg(volumegroup_ARG, 'V', "volumegroup", 0, 0, 0)
+arg(virtualsize_ARG, 'V', "virtualsize", sizemb_VAL, 0, 0)
+arg(wipesignatures_ARG, 'W', "wipesignatures", bool_VAL, 0, 0)
+arg(allocatable_ARG, 'x', "allocatable", bool_VAL, 0, 0)
+arg(resizeable_ARG, 'x', "resizeable", bool_VAL, 0, 0)
+arg(yes_ARG, 'y', "yes", 0, 0, 0)
+arg(zero_ARG, 'Z', "zero", bool_VAL, 0, 0)
 
 /* this should always be last */
-arg(ARG_COUNT, '-', "", NULL, 0, 0)
+arg(ARG_COUNT, '-', "", 0, 0, 0)
 /* *INDENT-ON* */
diff --git a/tools/command-lines.in b/tools/command-lines.in
new file mode 100644
index 0000000..b54f851
--- /dev/null
+++ b/tools/command-lines.in
@@ -0,0 +1,1579 @@
+#
+# When this file is changed, tools/command-lines.h
+# and tools/command-lines-count.h must be regenerated
+# with:
+#
+# tools/create-commands --output count tools/command-lines.in > tools/command-lines-count.h
+# tools/create-commands --output struct tools/command-lines.in > tools/command-lines.h
+#
+
+#
+# Syntax
+#
+# A new command has a unique combination of:
+# command name, required option args and required
+# positional args.
+#
+# To define a new command, begin a single line with a
+# command name, followed by required options/args,
+# (e.g. --foo, or --foo val), followed by required
+# positional args, (e.g. VG)
+#
+# After the single line of required elements are lines
+# of optional elements:
+# OO: <optional --option args>
+# OP: <optional positional args>
+#
+# command_name required_opt_arg ... required_pos_arg ...
+# OO: optional_opt_arg, ...
+# OP: optional_pos_arg ...
+#
+# required_opt_arg/optional_opt_arg must begin with the
+# long form option name, e.g. --foo.  If the option name
+# takes a value, then the type of value is specified,
+# e.g. --foo String.
+#
+# Possible option names are listed in args.h
+#
+# Use --foo_long to specify that only the long form of
+# --foo is accepted by the command.  (This is uncommon.)
+#
+# Possible option arg types are shown in tools/vals.h,
+# e.g. Bool, String, VG, SizeMB.
+#
+# --option args outside the list of types in vals.h are treated
+# as literal (non-variable) strings or numbers.
+#
+# positional args can be multiple types separated by |, e.g. VG|LV|Tag
+#
+# If a positional arg is repeatable, it is followed by ..., e.g. VG|LV|Tag ...
+#
+# LV can have a suffix indicating the LV type, e.g. LV_linear, LV_thinpool.
+# LV_raid represents any raidN.  LV_type1_type2_type3 when the LV is
+# limited to multiple specific types.
+#
+# Note that two commands whose required paramters differ only by
+# the LV types they accept are ambiguous.  That is, they cannot be
+# distinguished by just looking at the command, but require reading
+# the VG to find the LV type.  So, command definitions that differ
+# only in accepted LV types are not allowed.  It would be best to
+# distinguish them by using different option names.
+# There are FIXME's below for some of these cases.
+#
+# VG, LV can have the suffix _new, indicating the named VG or LV
+# does not yet exist.
+#
+# If Select is included in pos_arg, it means that the pos_arg
+# may be empty if the --select option is used.
+#
+# --size and --extents are interchangable, but only --size is used
+# in these definitions to keep them simpler.  --extents is
+# automatically included and recognized as an alternative to --size.
+#
+# lvcreate generally requires a VG arg in position 1 and does not
+# require the --name option (when --name is omitted, a name is
+# generated).  But, all commands of that form have a variant which
+# is not defined here, but which is automatically recognized as
+# being equivalent.  That variant allows the required VG arg to
+# be omitted when --name VG/LV is specified, or when the
+# LVM_VG_NAME env var is set and --name LV is specified.
+# The lvcreate variants with --name and without a VG arg are
+# automatically recognized as an alternative to the defined
+# command forms requiring the VG and no --name.
+# Also, --thinpool VG/LV or --cachepool VG/LV can be used in
+# place of --name to provide the VG name instead of pos 1.
+#
+# Note that one the most difficult aspect of these definitions is
+# the variants of --thin / --type thin / --type thin-pool,
+# --cache / --type cache / --type cache-pool.
+# There are no consistent rules to follow and the behaviors are
+# unpredictable; each possible variation and combination needs
+# to be tested individually to see what it means.
+#
+# Some options have multiple names, but only one form of the name
+# is used in these definitions.  Synonyms will be recognized when
+# matching a command to a command definition.
+#
+# used in definitions below (equivalent but not used in definitions)
+# mirrorlog core (not corelog)
+# resizeable (resizable or allocation)
+# allocatable (allocation)
+# activate (available)
+# rebuild (raidrebuild)
+# syncaction (raidsyncaction)
+# writemostly (raidwritemostly)
+# minrecoveryrate (raidminrecoveryrate)
+# maxrecoveryrate (raidmaxrecoveryrate)
+# writebehind (raidwritebehind)
+# virtualsize (virtualoriginsize)
+# vgmetadatacopies (metadatacopies)
+# pvmetadatacopies (metadatacopies)
+#
+# "---" is like a comment line, used to separate text for readability
+#
+# ID: A unique string identifying the command.  Two commands that do
+# the same thing, but are alternate syntaxes can share the same ID,
+# in which case the implementation would have to sort out which
+# args to look at for the required parameters.  Or, the two commands
+# could use differnet IDs, in which case the implementation would
+# know where to look for each parameter.
+#
+# DESC: A description of the command.  The "DESC:" tags will be
+# included in the text as indicators of new lines when printing
+# the descriptions for help/man output.
+#
+# RULE: rules that a given command must follow, i.e. required (and)
+# or invalid (not) combinations of options, LV types or LV properties.
+#
+# RULE: A and|not B
+#
+# Conditions in A are applied to a given command+LV.
+# If the conditions in A are true, then the checks in B
+# are applied.  If the checks in B are true|false according
+# to and|not, then the command fails|continues.
+#
+# When A is "all", the conditions in B are always applied.
+#
+# Conditions:
+# . if any --option listed is set, the checks may apply
+# . if any LV_type listed matches LV, the checks may apply
+# . if all lv_is_prop listed matches LV, the checks may apply
+# . if all of the above pass, then perform the checks
+#
+# Checks for "and":
+# . if any --option listed is not set, then fail
+# . if none of the LV_types matches the LV, then fail
+# . if any of the lv_is_prop do not match the LV, then fail
+#
+# Checks for "not":
+# . if any --option listed is set, then fail
+# . if any of the LV_types matches the LV, then fail
+# . if any of the lv_is_prop match the LV, then fail
+#
+# RULE: --option|LV_type|lv_is_prop|all ... and|not --option|LV_type|lv_is_prop ...
+#
+# RULE: --opt1 not --opt2
+# RULE: --opt1 and --opt2
+# RULE: --opt1 LV_type1 lv_is_prop1 and --opt2
+# RULE: --opt1 LV_type1 and lv_is_prop1
+# RULE: LV_type1 and lv_is_prop1
+#
+#
+
+#
+# For efficiency, sets of options can be defined and reused
+# in multiple command definitions.
+#
+# To define a common set of options:
+# OO_NAME: --foo, --bar String
+#
+# To use this set of options, include it on the OO: line, e.g.
+# OO: --example, OO_NAME
+#
+# which is expaneded to
+# OO: --example, --foo, --bar String
+#
+# Including OO_NAME after a command name on the required line
+# means that any one of the options is required and the rest
+# are optional.  The usage syntax for this case is printed as:
+# command (--foo A, --bar B)
+#
+
+#
+# OO_ALL is included in every command automatically.
+#
+OO_ALL: --commandprofile String, --config String, --debug,
+--driverloaded Bool, --help, --profile String, --quiet,
+--verbose, --version, --yes, --test
+
+#
+# This list only applies to printing the usage text.
+# These common options are displayed once at the end of
+# a given command's usage.  This is done to avoid excessive
+# repetition of common options, which may obscure the more
+# interesting and relevant parts of a common prototype.
+# This definition is *only* used when generating the command
+# usage strings, and is the basis for the division between
+# the "usage" and "usage_common" strings. This OO defn does
+# not relate to which optional opts are accepted by commands,
+# which is defined by the OO line.
+#
+OO_USAGE_COMMON: OO_ALL, --force, --noudevsync
+
+#
+# options for pvs, lvs, vgs, fullreport
+#
+OO_REPORT: --aligned, --all, --binary, --configreport ConfigReport, --foreign,
+--ignorelockingfailure, --ignoreskippedcluster, --logonly,
+--nameprefixes, --noheadings, --nolocking, --nosuffix,
+--options String, --partial, --readonly, --reportformat ReportFmt, --rows,
+--select String, --separator String, --shared, --sort String,
+--trustcache, --unbuffered, --units Units, --unquoted
+
+#
+# options for config, dumpconfig, lvmconfig
+#
+OO_CONFIG: --atversion String, --typeconfig ConfigType, --file String, --ignoreadvanced,
+--ignoreunsupported, --ignorelocal, --list, --mergedconfig, --metadataprofile String,
+--sinceversion String, --showdeprecated, --showunsupported, --validate, --withsummary,
+--withcomments, --withspaces, --unconfigured, --withversions
+
+---
+
+# None of these can function as a required option for lvchange.
+
+OO_LVCHANGE: --autobackup Bool, --force, --ignoremonitoring,
+--ignoreskippedcluster, --noudevsync, --reportformat ReportFmt,
+--select String
+
+# Any of these can function as a required option for lvchange.
+# profile is also part of OO_ALL, but is repeated in OO_LVCHANGE_META
+# because it can function as a required opt.
+
+OO_LVCHANGE_META: --addtag Tag, --deltag Tag,
+--alloc Alloc, --contiguous Bool,
+--detachprofile, --metadataprofile String, --profile String,
+--permission Permission, --readahead Readahead, --setactivationskip Bool,
+--errorwhenfull Bool, --discards Discards, --zero Bool,
+--cachemode CacheMode, --cachepolicy String, --cachesettings String,
+--minrecoveryrate SizeKB, --maxrecoveryrate SizeKB,
+--writebehind Number, --writemostly WriteMostlyPV, --persistent n
+
+lvchange OO_LVCHANGE_META VG|LV|Tag|Select ...
+OO: OO_LVCHANGE
+ID: lvchange_properties
+DESC: Change a general LV property.
+RULE: all not lv_is_pvmove lv_is_mirror_log lv_is_mirror_image
+RULE: all and lv_is_vg_writable
+RULE: --contiguous not --alloc
+RULE: --profile not --detachprofile
+RULE: --metadataprofile not --detachprofile
+RULE: --minrecoveryrate --maxrecoveryrate and LV_raid
+RULE: --writebehind --writemostly and LV_raid1
+RULE: --cachemode --cachepolicy --cachesettings and LV_cache LV_cachepool
+RULE: --errorwhenfull --discards --zero and LV_thinpool
+RULE: --permission not lv_is_external_origin lv_is_raid_metadata lv_is_raid_image LV_thinpool
+RULE: --alloc --contiguous --metadataprofile --permission --persistent --profile --readahead not lv_is_thick_origin
+RULE: --alloc --discards --zero --cachemode --cachepolicy --cachesettings not lv_is_partial
+
+lvchange --resync VG|LV_raid_mirror|Tag|Select ...
+OO: OO_LVCHANGE
+ID: lvchange_resync
+DESC: Resyncronize a mirror or raid LV.
+RULE: all not lv_is_pvmove lv_is_locked
+RULE: all not LV_raid0
+
+lvchange --syncaction SyncAction VG|LV_raid|Tag|Select ...
+OO: OO_LVCHANGE
+ID: lvchange_syncaction
+DESC: Resynchronize or check a raid LV.
+RULE: all not LV_raid0
+
+lvchange --rebuild PV VG|LV_raid|Tag|Select ...
+OO: OO_LVCHANGE
+ID: lvchange_rebuild
+DESC: Reconstruct data on specific PVs of a raid LV.
+RULE: all not LV_raid0
+
+# try removing the META change options from here?
+lvchange --activate Active VG|LV|Tag|Select ...
+OO: --activationmode ActivationMode, --partial, --ignoreactivationskip,
+--ignorelockingfailure, --sysinit, OO_LVCHANGE_META, OO_LVCHANGE
+ID: lvchange_activate
+DESC: Activate or deactivate an LV.
+
+lvchange --refresh VG|LV|Tag|Select ...
+OO: --partial, OO_LVCHANGE
+ID: lvchange_refresh
+DESC: Reactivate an LV using the latest metadata.
+
+lvchange --monitor Bool VG|LV|Tag|Select ...
+OO: --poll Bool, OO_LVCHANGE
+ID: lvchange_monitor
+DESC: Start or stop monitoring an LV from dmeventd.
+RULE: all not lv_is_pvmove
+
+lvchange --poll Bool VG|LV|Tag|Select ...
+OO: --monitor Bool, OO_LVCHANGE
+ID: lvchange_poll
+DESC: Start or stop processing an LV conversion.
+
+lvchange --persistent y --minor Number LV
+OO: --major Number, OO_LVCHANGE
+ID: lvchange_persistent
+DESC: Make the minor device number persistent for an LV.
+RULE: all not LV_thinpool LV_cachepool
+
+---
+
+OO_LVCONVERT_RAID: --mirrors SNumber, --stripes_long Number,
+--stripesize SizeKB, --regionsize SizeMB, --interval Number
+
+OO_LVCONVERT_POOL: --poolmetadata LV, --poolmetadatasize SizeMB,
+--poolmetadataspare Bool, --readahead Readahead, --chunksize SizeKB
+
+OO_LVCONVERT: --alloc Alloc, --background, --force, --noudevsync
+
+---
+
+# These cover all the core, raid-related type conversions.
+# They are all routed into the core raid conversion code.
+
+lvconvert --type linear LV
+OO: OO_LVCONVERT_RAID, OO_LVCONVERT
+OP: PV ...
+ID: lvconvert_raid_types
+DESC: Convert LV to linear.
+RULE: all not lv_is_locked lv_is_pvmove
+
+lvconvert --type striped LV
+OO: OO_LVCONVERT_RAID, OO_LVCONVERT
+OP: PV ...
+ID: lvconvert_raid_types
+DESC: Convert LV to striped.
+
+lvconvert --type mirror LV
+OO: OO_LVCONVERT_RAID, OO_LVCONVERT, --mirrorlog MirrorLog
+OP: PV ...
+ID: lvconvert_raid_types
+DESC: Convert LV to type mirror (also see type raid1).
+
+lvconvert --type raid LV
+OO: OO_LVCONVERT_RAID, OO_LVCONVERT
+OP: PV ...
+ID: lvconvert_raid_types
+DESC: Convert LV to raid.
+
+lvconvert --mirrors SNumber LV
+OO: OO_LVCONVERT_RAID, OO_LVCONVERT, --mirrorlog MirrorLog
+OP: PV ...
+ID: lvconvert_raid_types
+DESC: Convert LV to raid1 or mirror, or change number of mirror images.
+
+---
+
+# lvconvert raid-related utilities
+# Create a new command set for these and migrate them out of lvconvert?
+
+lvconvert --splitmirrors Number --name LV_new LV_raid1_mirror_cache
+OO: OO_LVCONVERT
+OP: PV ...
+ID: lvconvert_split_mirror_images
+DESC: Split images from a raid1 or mirror LV and use them to create a new LV.
+
+lvconvert --splitmirrors Number --trackchanges LV_raid1_cache
+OO: OO_LVCONVERT
+OP: PV ...
+ID: lvconvert_split_mirror_images
+DESC: Split images from a raid1 LV and track changes to origin.
+
+lvconvert --mirrorlog MirrorLog LV_mirror
+OO: OO_LVCONVERT
+OP: PV ...
+ID: lvconvert_change_mirrorlog
+DESC: Change the type of mirror log used by a mirror LV.
+
+---
+
+# lvconvert utilities for creating/maintaining thin and cache objects.
+# Create a new command set for these and migrate them out of lvconvert?
+
+lvconvert --type thin --thinpool LV LV_linear_striped_raid
+OO: --thin, --originname LV_new, --zero Bool, OO_LVCONVERT_POOL, OO_LVCONVERT
+ID: lvconvert_to_thin_with_external
+DESC: Convert LV to type thin with an external origin.
+
+# alternate form of lvconvert --type thin
+lvconvert --thin --thinpool LV LV_linear_striped_raid
+OO: --type thin, --originname LV_new, --zero Bool, OO_LVCONVERT_POOL, OO_LVCONVERT
+ID: lvconvert_to_thin_with_external
+DESC: Convert LV to type thin with an external origin
+DESC: (variant, infers --type thin).
+FLAGS: SECONDARY_SYNTAX
+
+---
+
+lvconvert --type cache --cachepool LV LV_linear_striped_raid_thinpool
+OO: --cache, --cachemode CacheMode, --cachepolicy String,
+--cachesettings String, --zero Bool, OO_LVCONVERT_POOL, OO_LVCONVERT
+ID: lvconvert_to_cache_vol
+DESC: Convert LV to type cache.
+
+# alternate form of lvconvert --type cache
+lvconvert --cache --cachepool LV LV_linear_striped_raid_thinpool
+OO: --type cache, --cachemode CacheMode, --cachepolicy String,
+--cachesettings String, --zero Bool, OO_LVCONVERT_POOL, OO_LVCONVERT
+ID: lvconvert_to_cache_vol
+DESC: Convert LV to type cache (variant, infers --type cache).
+FLAGS: SECONDARY_SYNTAX
+
+---
+
+lvconvert --type thin-pool LV_linear_striped_raid_cache
+OO: --stripes_long Number, --stripesize SizeKB,
+--discards Discards, --zero Bool, OO_LVCONVERT_POOL, OO_LVCONVERT
+OP: PV ...
+ID: lvconvert_to_thinpool
+DESC: Convert LV to type thin-pool.
+
+# alternate form of lvconvert --type thin-pool
+# deprecated because of non-standard syntax (missing positional arg)
+lvconvert --thinpool LV_linear_striped_raid_cache
+OO: --type thin-pool, --stripes_long Number, --stripesize SizeKB,
+--discards Discards, --zero Bool, OO_LVCONVERT_POOL, OO_LVCONVERT
+OP: PV ...
+ID: lvconvert_to_thinpool
+DESC: Convert LV to type thin-pool (variant, use --type thin-pool).
+FLAGS: SECONDARY_SYNTAX
+
+---
+
+lvconvert --type cache-pool LV_linear_striped_raid
+OO: OO_LVCONVERT_POOL, OO_LVCONVERT,
+--cachemode CacheMode, --cachepolicy String, --cachesettings String
+OP: PV ...
+ID: lvconvert_to_cachepool
+DESC: Convert LV to type cache-pool.
+
+# alternate form of lvconvert --type cache-pool
+# deprecated because of non-standard syntax (missing positional arg)
+lvconvert --cachepool LV_linear_striped_raid
+OO: --type cache-pool, OO_LVCONVERT_POOL, OO_LVCONVERT,
+--cachemode CacheMode, --cachepolicy String, --cachesettings String
+ID: lvconvert_to_cachepool
+DESC: Convert LV to type cache-pool (variant, use --type cache-pool).
+FLAGS: SECONDARY_SYNTAX
+
+---
+
+lvconvert --splitcache LV_cachepool_cache_thinpool
+OO: OO_LVCONVERT
+ID: lvconvert_split_and_keep_cachepool
+DESC: Separate and keep the cache pool from a cache LV.
+
+---
+
+lvconvert --uncache LV_cache_thinpool
+OO: OO_LVCONVERT
+ID: lvconvert_split_and_delete_cachepool
+DESC: Separate and delete the cache pool from a cache LV.
+
+---
+
+# FIXME: add a new option defining this operation, e.g. --swapmetadata
+
+lvconvert --poolmetadata LV LV_thinpool_cachepool
+OO: OO_LVCONVERT
+ID: lvconvert_swap_pool_metadata
+DESC: Swap metadata LV in a thin pool or cache pool (temporary command).
+FLAGS: SECONDARY_SYNTAX
+
+---
+
+# lvconvert utilities related to snapshots and repair.
+# Create a new command set for these and migrate them out of lvconvert?
+
+# FIXME: lvconvert --merge is an extremely ambiguous command.
+# It can do very different operations, but which one depends
+# on knowing the LV type.  So, the command doesn't know what
+# it's actually doing until quite late, when processing a
+# single LV.
+#
+# Use different option names for different merge operations
+# so that we can have different command definitions,
+# different behaviors, different optional options, etc:
+#
+# lvconvert --merge-mirror LV_linear_striped_raid ...
+# DESC: Merge LV that was previously split from a mirror.
+#
+# lvconvert --merge-thin LV_thin
+# DESC: Merge thin LV into its origin LV.
+#
+# lvconvert --merge-snapshot LV_snapshot
+# DESC: Merge COW snapshot LV into its origin.
+#
+# Then we could add VG|Tag to --merge-mirror arg pos 1, because
+# "lvconvert --merge VG|Tag" is a terrible command.  It will do
+# different operations on each LV it finds, depending on the
+# current LV type.
+
+lvconvert --merge LV_linear_striped_raid_thin_snapshot|VG|Tag ...
+OO: --background, --interval Number, OO_LVCONVERT
+ID: lvconvert_merge
+DESC: Merge LV that was previously split from a mirror.
+DESC: Merge thin LV into its origin LV.
+DESC: Merge COW snapshot LV into its origin.
+RULE: all not lv_is_merging_origin lv_is_virtual_origin lv_is_external_origin lv_is_merging_cow
+
+---
+
+# FIXME: by using two different positional args, this is the
+# single violation of the standard method of using process_each_lv().
+# Before calling process_each, it steals the first positional arg
+# and adjusts argv/argc so it's not seen by process_each.
+
+# alternate form of lvconvert --snapshot
+lvconvert --type snapshot LV_linear_striped_raid LV_snapshot
+OO: --snapshot, --chunksize SizeKB, --zero Bool, OO_LVCONVERT
+ID: lvconvert_combine_split_snapshot
+DESC: Combine LV with a previously split snapshot LV.
+FLAGS: SECONDARY_SYNTAX
+
+lvconvert --snapshot LV_linear_striped_raid LV_snapshot
+OO: --type snapshot, --chunksize SizeKB, --zero Bool, OO_LVCONVERT
+ID: lvconvert_combine_split_snapshot
+DESC: Combine LV with a previously split snapshot LV.
+
+---
+
+# FIXME: use specific option names to distinguish these two
+# very different commands, e.g.
+#
+# lvconvert --repair-pvs LV_raid_mirror
+# DESC: Replace failed PVs in a raid or mirror LV.
+#
+# lvconvert --repair-thinpool LV_thinpool
+# DESC: Repair a thin pool.
+#
+# lvm may want to do different things, or allow different options 
+# depending on which operation is being run, but as it stands, it
+# cannot do anything operation-specific until after the VG is read
+# and the LV type is known.
+
+lvconvert --repair LV_raid_mirror_thinpool
+OO: --usepolicies, OO_LVCONVERT
+OP: PV ...
+ID: lvconvert_repair_pvs_or_thinpool
+DESC: Replace failed PVs in a raid or mirror LV.
+DESC: Repair a thin pool.
+
+---
+
+lvconvert --replace PV LV_raid
+OO: OO_LVCONVERT
+OP: PV ...
+ID: lvconvert_replace_pv
+DESC: Replace specific PV(s) in a raid* LV with another PV.
+
+---
+
+lvconvert --splitsnapshot LV_snapshot
+OO: OO_LVCONVERT
+ID: lvconvert_split_cow_snapshot
+DESC: Separate a COW snapshot from its origin LV.
+
+---
+
+# FIXME: add a new option defining this operation, e.g. --poll-mirror
+# The purpose of this command is not entirely clear.
+
+lvconvert LV_mirror
+OO: OO_LVCONVERT
+ID: lvconvert_poll_start
+DESC: Poll mirror LV to collapse resync layers.
+FLAGS: SECONDARY_SYNTAX
+
+---
+
+# --extents is not specified; it's an automatic alternative for --size
+
+OO_LVCREATE: --addtag Tag, --alloc Alloc, --autobackup Bool, --activate Active,
+--contiguous Bool, --ignoreactivationskip, --ignoremonitoring, --major Number,
+--metadataprofile String, --minor Number, --monitor Bool, --name String, --nosync,
+--noudevsync, --permission Permission, --persistent Bool, --readahead Readahead,
+--reportformat ReportFmt, --setactivationskip Bool, --wipesignatures Bool,
+--zero Bool
+
+OO_LVCREATE_CACHE: --cachemode CacheMode, --cachepolicy String, --cachesettings String
+
+OO_LVCREATE_POOL: --poolmetadatasize SizeMB, --poolmetadataspare Bool, --chunksize SizeKB
+
+OO_LVCREATE_THIN: --discards Discards, --errorwhenfull Bool
+
+OO_LVCREATE_RAID: --mirrors SNumber, --stripes Number, --stripesize SizeKB,
+--regionsize SizeMB, --minrecoveryrate SizeKB, --maxrecoveryrate SizeKB
+
+---
+
+lvcreate --type error --size SizeMB VG
+OO: OO_LVCREATE
+ID: lvcreate_error_vol
+DESC: Create an LV that returns errors when used.
+FLAGS: SECONDARY_SYNTAX
+
+---
+
+lvcreate --type zero --size SizeMB VG
+OO: OO_LVCREATE
+ID: lvcreate_zero_vol
+DESC: Create an LV that returns zeros when read.
+FLAGS: SECONDARY_SYNTAX
+
+---
+
+lvcreate --type linear --size SizeMB VG
+OO: OO_LVCREATE
+OP: PV ...
+IO: --mirrors 0, --stripes 1
+ID: lvcreate_linear
+DESC: Create a linear LV.
+FLAGS: SECONDARY_SYNTAX
+
+# This is the one place we mention the optional --name
+# because it's the most common case and may be confusing
+# to people to not see the name parameter.
+
+lvcreate --size SizeMB VG
+OO: --type linear, OO_LVCREATE
+OP: PV ...
+IO: --mirrors 0, --stripes 1
+ID: lvcreate_linear
+DESC: Create a linear LV (default --type linear).
+DESC: When --name is omitted, the name is generated.
+
+---
+
+lvcreate --type striped --size SizeMB VG
+OO: --stripes Number, --stripesize SizeKB, OO_LVCREATE
+OP: PV ...
+ID: lvcreate_striped
+DESC: Create a striped LV.
+
+lvcreate --stripes Number --size SizeMB VG
+OO: --type striped, --stripesize SizeKB, OO_LVCREATE
+OP: PV ...
+ID: lvcreate_striped
+DESC: Create a striped LV (infers --type striped).
+
+---
+
+lvcreate --type mirror --size SizeMB VG
+OO: --mirrors SNumber, --mirrorlog MirrorLog, --regionsize SizeMB, --stripes Number, OO_LVCREATE
+OP: PV ...
+ID: lvcreate_mirror
+DESC: Create a mirror LV (also see --type raid1).
+
+# alternate form of lvcreate --type raid1|mirror
+lvcreate --mirrors SNumber --size SizeMB VG
+OO: --type raid1, --type mirror, --mirrorlog MirrorLog, --stripes Number, OO_LVCREATE_RAID, OO_LVCREATE
+OP: PV ...
+ID: lvcreate_mirror_or_raid1
+DESC: Create a raid1 or mirror LV (variant, infers --type raid1|mirror).
+
+---
+
+lvcreate --type raid --size SizeMB VG
+OO: OO_LVCREATE_RAID, OO_LVCREATE
+OP: PV ...
+ID: lvcreate_raid_any
+DESC: Create a raid LV (a specific raid level must be used, e.g. raid1.)
+
+---
+
+# FIXME: the LV created by these commands actually has type linear or striped,
+# not snapshot as specified by the command.  If LVs never have type
+# snapshot, perhaps "snapshot" should not be considered an LV type, but
+# another new LV property?
+#
+# This is the one case where the --type variant is the unpreferred,
+# secondary syntax, because the LV type is not actually "snapshot".
+
+# alternate form of lvcreate --snapshot
+lvcreate --type snapshot --size SizeMB LV
+OO: --snapshot, --stripes Number, --stripesize SizeKB,
+--chunksize SizeKB, OO_LVCREATE
+OP: PV ...
+ID: lvcreate_cow_snapshot
+DESC: Create a COW snapshot LV from an origin LV.
+FLAGS: SECONDARY_SYNTAX
+
+lvcreate --snapshot --size SizeMB LV
+OO: --type snapshot, --stripes Number, --stripesize SizeKB,
+--chunksize SizeKB, OO_LVCREATE
+OP: PV ...
+ID: lvcreate_cow_snapshot
+DESC: Create a COW snapshot LV from an origin LV.
+
+---
+
+# alternate form of lvcreate --snapshot
+lvcreate --type snapshot --size SizeMB --virtualsize SizeMB VG
+OO: --snapshot, --chunksize SizeKB, OO_LVCREATE
+OP: PV ...
+ID: lvcreate_cow_snapshot_with_virtual_origin
+DESC: Create a sparse COW snapshot LV of a virtual origin LV.
+FLAGS: SECONDARY_SYNTAX
+
+lvcreate --snapshot --size SizeMB --virtualsize SizeMB VG
+OO: --type snapshot, --chunksize SizeKB, OO_LVCREATE
+OP: PV ...
+ID: lvcreate_cow_snapshot_with_virtual_origin
+DESC: Create a sparse COW snapshot LV of a virtual origin LV.
+
+---
+
+lvcreate --type thin-pool --size SizeMB VG
+OO: --thinpool LV_new, OO_LVCREATE_POOL, OO_LVCREATE_THIN, OO_LVCREATE,
+--stripes Number, --stripesize SizeKB
+OP: PV ...
+IO: --mirrors 0
+ID: lvcreate_thinpool
+DESC: Create a thin pool.
+
+# alternate form of lvcreate --type thin-pool
+lvcreate --thin --size SizeMB VG
+OO: --type thin-pool, OO_LVCREATE_POOL, OO_LVCREATE_THIN, OO_LVCREATE,
+--stripes Number, --stripesize SizeKB
+OP: PV ...
+IO: --mirrors 0
+ID: lvcreate_thinpool
+DESC: Create a thin pool (variant, infers --type thin-pool).
+FLAGS: SECONDARY_SYNTAX
+
+# alternate form of lvcreate --type thin-pool
+lvcreate --size SizeMB --thinpool LV_new VG
+OO: --thin, --type thin-pool, OO_LVCREATE_POOL, OO_LVCREATE_THIN, OO_LVCREATE,
+--stripes Number, --stripesize SizeKB
+OP: PV ...
+IO: --mirrors 0
+ID: lvcreate_thinpool
+DESC: Create a thin pool named by the --thinpool arg
+DESC: (variant, infers --type thin-pool).
+FLAGS: SECONDARY_SYNTAX
+
+---
+
+# NB. there are no alternate forms of these commands that
+# use --cache in place of --type cache-pool, but --cache
+# still needs to be listed as an optional addition to
+# --type cache-pool.
+
+lvcreate --type cache-pool --size SizeMB VG
+OO: --cache, OO_LVCREATE_POOL, OO_LVCREATE_CACHE, OO_LVCREATE
+OP: PV ...
+ID: lvcreate_cachepool
+DESC: Create a cache pool.
+
+# alternate form of lvcreate --type cache-pool
+lvcreate --type cache-pool --size SizeMB --cachepool LV_new VG
+OO: --cache, OO_LVCREATE_POOL, OO_LVCREATE_CACHE, OO_LVCREATE
+OP: PV ...
+ID: lvcreate_cachepool
+DESC: Create a cache pool named by the --cachepool arg
+DESC: (variant, uses --cachepool in place of --name).
+FLAGS: SECONDARY_SYNTAX
+
+---
+
+lvcreate --type thin --virtualsize SizeMB --thinpool LV_thinpool VG
+OO: --thin, OO_LVCREATE_POOL, OO_LVCREATE_THIN, OO_LVCREATE
+IO: --mirrors 0
+ID: lvcreate_thin_vol
+DESC: Create a thin LV in a thin pool.
+
+# alternate form of lvcreate --type thin
+lvcreate --type thin --virtualsize SizeMB LV_thinpool
+OO: --thin, OO_LVCREATE_THIN, OO_LVCREATE
+IO: --mirrors 0
+ID: lvcreate_thin_vol
+DESC: Create a thin LV in a thin pool named in the first arg
+DESC: (variant, also see --thinpool for naming pool).
+FLAGS: SECONDARY_SYNTAX
+
+# NB. this is the variant which can substitute
+# --thin for --type thin, even though --thin is in OO.
+
+# alternate form of lvcreate --type thin
+lvcreate --virtualsize SizeMB --thinpool LV_thinpool VG
+OO: --type thin, --thin, OO_LVCREATE_THIN, OO_LVCREATE
+IO: --mirrors 0
+ID: lvcreate_thin_vol
+DESC: Create a thin LV in a thin pool (variant, infers --type thin).
+FLAGS: SECONDARY_SYNTAX
+
+# alternate form of lvcreate --type thin
+lvcreate --virtualsize SizeMB LV_thinpool
+OO: --type thin, --thin, OO_LVCREATE_THIN, OO_LVCREATE
+IO: --mirrors 0
+ID: lvcreate_thin_vol
+DESC: Create a thin LV in the thin pool named in the first arg
+DESC: (variant, infers --type thin, also see --thinpool for
+DESC: naming pool.)
+FLAGS: SECONDARY_SYNTAX
+
+---
+
+lvcreate --type thin LV_thin
+OO: --thin, OO_LVCREATE_THIN, OO_LVCREATE
+IO: --mirrors 0
+ID: lvcreate_thin_snapshot
+DESC: Create a thin LV that is a snapshot of an existing thin LV.
+
+# alternate form of lvcreate --type thin
+lvcreate --thin LV_thin
+OO: --type thin, OO_LVCREATE_THIN, OO_LVCREATE
+IO: --mirrors 0
+ID: lvcreate_thin_snapshot
+DESC: Create a thin LV that is a snapshot of an existing thin LV
+DESC: (infers --type thin).
+FLAGS: SECONDARY_SYNTAX
+
+# alternate form of lvcreate --type thin
+lvcreate --snapshot LV_thin
+OO: --type thin, OO_LVCREATE_THIN, OO_LVCREATE
+IO: --mirrors 0
+ID: lvcreate_thin_snapshot
+DESC: Create a thin LV that is a snapshot of an existing thin LV
+DESC: (infers --type thin).
+
+lvcreate --type thin --thinpool LV_thinpool LV
+OO: --thin, OO_LVCREATE_POOL, OO_LVCREATE_THIN, OO_LVCREATE
+IO: --mirrors 0
+ID: lvcreate_thin_snapshot_of_external
+DESC: Create a thin LV that is a snapshot of an external origin LV.
+
+# alternate form of lvcreate --type thin --thinpool LV_thinpool LV
+lvcreate --snapshot --thinpool LV_thinpool LV
+OO: --type thin, OO_LVCREATE_THIN, OO_LVCREATE
+IO: --mirrors 0
+ID: lvcreate_thin_snapshot_of_external
+DESC: Create a thin LV that is a snapshot of an external origin LV
+DESC: (infers --type thin).
+
+---
+
+# stripes option is not intuitive when creating a thin LV,
+# but here it applies to creating the new thin pool that
+# is used for the thin LV
+
+# FIXME: there are commands here that differ only in that
+# one takes LV_new in arg pos 1, and the other takes a VG name
+# in arg pos 1.  The commands that take LV_new use that
+# name as the new name of the pool, but the commands that
+# take a VG automatically generate the LV name.  The problem
+# is that currently the command matching function cannot
+# distinguish between an LV name and a VG name being used
+# in arg pos 1, so a user-entered command would just match
+# the first it finds and not necessarily the correct
+# definition.  Note that when LV_new is used in arg pos 1,
+# it needs to include a VG name, i.e. VG/LV_new
+
+lvcreate --type thin --virtualsize SizeMB --size SizeMB --thinpool LV_new
+OO: --thin, OO_LVCREATE_POOL, OO_LVCREATE_THIN, OO_LVCREATE,
+--stripes Number, --stripesize SizeKB
+OP: PV ...
+IO: --mirrors 0
+ID: lvcreate_thin_vol_and_thinpool
+DESC: Create a thin LV, first creating a thin pool for it,
+DESC: where the new thin pool is named by the --thinpool arg.
+
+# alternate form of lvcreate --type thin
+lvcreate --thin --virtualsize SizeMB --size SizeMB --thinpool LV_new
+OO: --type thin, OO_LVCREATE_POOL, OO_LVCREATE_THIN, OO_LVCREATE,
+--stripes Number, --stripesize SizeKB
+OP: PV ...
+IO: --mirrors 0
+ID: lvcreate_thin_vol_and_thinpool
+DESC: Create a thin LV, first creating a thin pool for it,
+DESC: where the new thin pool is named by the --thinpool arg
+DESC: (variant, infers --type thin).
+FLAGS: SECONDARY_SYNTAX
+
+# alternate form of lvcreate --type thin
+lvcreate --type thin --virtualsize SizeMB --size SizeMB LV_new|VG
+OO: --thin, OO_LVCREATE_POOL, OO_LVCREATE_THIN, OO_LVCREATE,
+--stripes Number, --stripesize SizeKB
+OP: PV ...
+IO: --mirrors 0
+ID: lvcreate_thin_vol_and_thinpool
+DESC: Create a thin LV, first creating a thin pool for it,
+DESC: where the new thin pool is named in the first arg,
+DESC: or the new thin pool name is generated when the first
+DESC: arg is a VG name.
+FLAGS: SECONDARY_SYNTAX
+
+# alternate form of lvcreate --type thin
+lvcreate --thin --virtualsize SizeMB --size SizeMB LV_new|VG
+OO: --type thin, OO_LVCREATE_POOL, OO_LVCREATE_THIN, OO_LVCREATE,
+--stripes Number, --stripesize SizeKB
+OP: PV ...
+IO: --mirrors 0
+ID: lvcreate_thin_vol_and_thinpool
+DESC: Create a thin LV, first creating a thin pool for it,
+DESC: where the new thin pool is named in the first arg,
+DESC: or the new thin pool name is generated when the first
+DESC: arg is a VG name (variant, infers --type thin).
+FLAGS: SECONDARY_SYNTAX
+
+---
+
+lvcreate --size SizeMB --virtualsize SizeMB VG
+OO: --type thin, --type snapshot, --thin, --snapshot, OO_LVCREATE_POOL, OO_LVCREATE_THIN, OO_LVCREATE,
+--stripes Number, --stripesize SizeKB
+OP: PV ...
+IO: --mirrors 0
+ID: lvcreate_thin_vol_with_thinpool_or_sparse_snapshot
+DESC: Create a thin LV, first creating a thin pool for it
+DESC: (infers --type thin).
+DESC: Create a sparse snapshot of a virtual origin LV
+DESC: (infers --type snapshot).
+DESC: Chooses --type thin or --type snapshot according to
+DESC: config setting sparse_segtype_default.
+FLAGS: SECONDARY_SYNTAX
+
+---
+
+# stripes option is not intuitive when creating a cache LV,
+# but here it applies to creating the new origin that
+# is used to create the cache LV
+
+lvcreate --type cache --size SizeMB --cachepool LV_cachepool VG
+OO: --cache, OO_LVCREATE_POOL, OO_LVCREATE_CACHE, OO_LVCREATE,
+--stripes Number, --stripesize SizeKB
+OP: PV ...
+ID: lvcreate_cache_vol_with_new_origin
+DESC: Create a cache LV, first creating a new origin LV,
+DESC: then combining it with the existing cache pool named
+DESC: by the --cachepool arg.
+
+# alternate form of lvcreate --type cache
+lvcreate --size SizeMB --cachepool LV_cachepool VG
+OO: --type cache, --cache, OO_LVCREATE_CACHE, OO_LVCREATE,
+--stripes Number, --stripesize SizeKB
+OP: PV ...
+ID: lvcreate_cache_vol_with_new_origin
+DESC: Create a cache LV, first creating a new origin LV,
+DESC: then combining it with the existing cache pool named
+DESC: by the --cachepool arg (variant, infers --type cache).
+FLAGS: SECONDARY_SYNTAX
+
+# alternate form of lvcreate --type cache
+lvcreate --type cache --size SizeMB LV_cachepool
+OO: --cache, OO_LVCREATE_POOL, OO_LVCREATE_CACHE, OO_LVCREATE,
+--stripes Number, --stripesize SizeKB
+OP: PV ...
+ID: lvcreate_cache_vol_with_new_origin
+DESC: Create a cache LV, first creating a new origin LV,
+DESC: then combining it with the existing cache pool named
+DESC: in the first arg (variant, also use --cachepool).
+FLAGS: SECONDARY_SYNTAX
+
+# This is a ridiculously crazy command which nobody could
+# understand.  It should be be eliminated.  It does two different
+# things depending on whether LV in pos 1 is a cachepool LV
+# or not.  Both variations are unnecessary.
+#
+# 1. If LV is a cachepool, then it's an alternate form of
+#    an already complicated command above.
+#
+# # alternate form for lvcreate_cache_vol_with_new_origin
+# lvcreate --cache --size SizeMB LV_cachepool
+# OO: --type cache, --cache, OO_LVCREATE_CACHE, OO_LVCREATE, --stripes Number, --stripesize SizeKB
+# OP: PV ...
+# ID: lvcreate_cache_vol_with_new_origin
+# DESC: Create a cache LV, first creating a new origin LV,
+# DESC: then combining it with the existing cache pool named
+# DESC: in the first arg (variant, infers --type cache,
+# DESC: also use --cachepool).
+#
+# 2. If LV is not a cachepool, then it's a disguised lvconvert.
+#
+# # FIXME: this should be done by lvconvert, and this command removed
+# lvcreate --type cache --size SizeMB LV
+# OO: OO_LVCREATE_POOL, OO_LVCREATE_CACHE, OO_LVCREATE
+# OP: PV ...
+# ID: lvcreate_convert_to_cache_vol_with_cachepool
+# DESC: Convert the specified LV to type cache after creating a new
+# DESC: cache pool LV to use (use lvconvert).
+#
+# Note that stripes are accepted by the first and not by the
+# second, but it's not possible to validate this until after
+# the LV type is known.
+#
+# So, to define this syntax we have to combine both of
+# those variants, each crazy on it's own, into one
+# ridiculous command.
+
+# def1: alternate form of lvcreate --type cache, or
+# def2: it should be done by lvconvert.
+lvcreate --cache --size SizeMB LV
+OO: OO_LVCREATE_CACHE, OO_LVCREATE_POOL, OO_LVCREATE,
+--stripes Number, --stripesize SizeKB
+OP: PV ...
+ID: lvcreate_cache_vol_with_new_origin_or_convert_to_cache_vol_with_cachepool
+DESC: When LV is a cache pool, create a cache LV,
+DESC: first creating a new origin LV, then combining it with
+DESC: the existing cache pool named in the first arg
+DESC: (variant, infers --type cache, also use --cachepool).
+DESC: When LV is not a cache pool, convert the specified LV
+DESC: to type cache after creating a new cache pool LV to use
+DESC: (use lvconvert).
+FLAGS: SECONDARY_SYNTAX
+
+---
+
+lvdisplay
+OO: --aligned, --all, --binary, --colon, --columns,
+--configreport ConfigReport, --foreign, --history, --ignorelockingfailure,
+--ignoreskippedcluster, --logonly, --maps, --noheadings,
+--nosuffix, --options String, --sort String, --partial, --readonly,
+--reportformat ReportFmt, --segments, --select String, --separator String,
+--shared, --unbuffered, --units Units
+OP: VG|LV|Tag ...
+ID: lvdisplay_general
+
+---
+
+# --extents is not specified; it's an automatic alternative for --size
+
+lvextend --size SizeMB LV
+OO: --alloc Alloc, --autobackup Bool, --force, --mirrors SNumber,
+--nofsck, --nosync, --noudevsync, --reportformat ReportFmt, --resizefs,
+--stripes Number, --stripesize SizeKB, --poolmetadatasize SizeMB
+OP: PV ...
+ID: lvextend_by_size
+DESC: Extend an LV by a specified size.
+
+lvextend LV PV ...
+OO: --alloc Alloc, --autobackup Bool, --force, --mirrors SNumber,
+--nofsck, --nosync, --noudevsync,
+--reportformat ReportFmt, --resizefs, --stripes Number, --stripesize SizeKB
+ID: lvextend_by_pv
+DESC: Extend an LV by specified PV extents.
+FLAGS: SECONDARY_SYNTAX
+
+lvextend --poolmetadatasize SizeMB LV_thinpool
+OO: --alloc Alloc, --autobackup Bool, --force, --mirrors SNumber,
+--nofsck, --nosync, --noudevsync,
+--reportformat ReportFmt, --stripes Number, --stripesize SizeKB
+OP: PV ...
+ID: lvextend_pool_metadata_by_size
+DESC: Extend a pool metadata SubLV by a specified size.
+
+lvextend --usepolicies LV_thinpool_snapshot
+OO: --alloc Alloc, --autobackup Bool, --force, --mirrors SNumber,
+--nofsck, --nosync, --noudevsync,
+--reportformat ReportFmt, --resizefs
+OP: PV ...
+ID: lvextend_by_policy
+DESC: Extend an LV according to a predefined policy.
+
+---
+
+lvmconfig
+OO: OO_CONFIG
+OP: String ...
+ID: lvmconfig_general
+
+---
+
+lvreduce --size SizeMB LV
+OO: --autobackup Bool, --force, --nofsck, --noudevsync,
+--reportformat ReportFmt, --resizefs
+ID: lvreduce_general
+
+---
+
+lvremove VG|LV|Tag|Select ...
+OO: --autobackup Bool, --force, --nohistory, --noudevsync,
+--reportformat ReportFmt, --select String
+ID: lvremove_general
+
+---
+
+lvrename VG LV LV_new
+OO: --autobackup Bool, --noudevsync, --reportformat ReportFmt
+ID: lvrename_vg_lv_lv
+
+lvrename LV LV_new
+OO: --autobackup Bool, --noudevsync, --reportformat ReportFmt
+ID: lvrename_lv_lv
+
+---
+
+lvresize --size SizeMB LV
+OO: --alloc Alloc, --autobackup Bool, --force,
+--nofsck, --nosync, --noudevsync, --reportformat ReportFmt, --resizefs,
+--stripes Number, --stripesize SizeKB, --poolmetadatasize SizeMB
+OP: PV ...
+ID: lvresize_by_size
+DESC: Resize an LV by a specified size.
+
+lvresize LV PV ...
+OO: --alloc Alloc, --autobackup Bool, --force,
+--nofsck, --nosync, --noudevsync,
+--reportformat ReportFmt, --resizefs, --stripes Number, --stripesize SizeKB
+ID: lvresize_by_pv
+DESC: Resize an LV by specified PV extents.
+FLAGS: SECONDARY_SYNTAX
+
+lvresize --poolmetadatasize SizeMB LV_thinpool
+OO: --alloc Alloc, --autobackup Bool, --force,
+--nofsck, --nosync, --noudevsync,
+--reportformat ReportFmt, --stripes Number, --stripesize SizeKB
+OP: PV ...
+ID: lvresize_pool_metadata_by_size
+DESC: Resize a pool metadata SubLV by a specified size.
+
+---
+
+lvs
+OO: --history, --segments, OO_REPORT
+OP: VG|LV|Tag ...
+ID: lvs_general
+
+---
+
+lvscan
+OO: --all, --blockdevice, --ignorelockingfailure, --partial,
+--readonly, --reportformat ReportFmt
+ID: lvscan_general
+
+lvscan --cache_long
+OO: --blockdevice, --ignorelockingfailure, --partial,
+--readonly, --reportformat ReportFmt
+OP: LV ...
+ID: lvscan_cache
+
+---
+
+# None of these can function as a required option for pvchange.
+OO_PVCHANGE: --autobackup Bool, --force, --ignoreskippedcluster,
+--reportformat ReportFmt, --uuid
+
+# Any of these can function as a required option for pvchange.
+OO_PVCHANGE_META: --allocatable Bool, --addtag Tag, --deltag Tag,
+--uuid, --metadataignore Bool
+
+pvchange OO_PVCHANGE_META --all
+OO: OO_PVCHANGE
+ID: pvchange_properties_all
+DESC: Change properties of all PVs.
+
+pvchange OO_PVCHANGE_META PV|Select ...
+OO: --select String, OO_PVCHANGE
+ID: pvchange_properties_some
+DESC: Change properties of specified PVs.
+
+---
+
+pvresize PV ...
+OO: --setphysicalvolumesize SizeMB, --reportformat ReportFmt
+ID: pvresize_general
+
+---
+
+pvck PV ...
+OO: --labelsector Number
+ID: pvck_general
+
+---
+
+# Use --uuidstr here which will be converted to uuidstr_ARG
+# which is actually --uuid string on the command line.
+
+pvcreate PV ...
+OO: --dataalignment SizeKB, --dataalignmentoffset SizeKB, --bootloaderareasize SizeMB,
+--force, --labelsector Number, --metadatatype MetadataType,
+--pvmetadatacopies MetadataCopiesPV, --metadatasize SizeMB,
+--metadataignore Bool, --norestorefile, --setphysicalvolumesize SizeMB,
+--reportformat ReportFmt, --restorefile String, --uuidstr String, --zero Bool
+ID: pvcreate_general
+
+---
+
+pvdisplay
+OO: --aligned, --all, --binary, --colon, --columns, --configreport ConfigReport,
+--foreign, --ignorelockingfailure, --ignoreskippedcluster,
+--logonly, --maps, --noheadings, --nosuffix, --options String,
+--readonly, --reportformat ReportFmt, --select String, --separator String, --shared,
+--short, --sort String, --unbuffered, --units Units
+OP: PV|Tag ...
+ID: pvdisplay_general
+
+---
+
+pvmove PV
+OO: --abort, --alloc Alloc, --atomic, --autobackup Bool, --background,
+--interval Number, --name LV, --noudevsync, --reportformat ReportFmt
+OP: PV ...
+ID: pvmove_one
+DESC: Move PV extents.
+
+pvmove
+OO: --abort, --background, --interval Number
+ID: pvmove_any
+DESC: Continue or abort existing pvmove operations.
+
+---
+
+pvremove PV ...
+OO: --force, --reportformat ReportFmt
+ID: pvremove_general
+
+---
+
+pvs
+OO: --segments, OO_REPORT
+OP: PV|Tag ...
+ID: pvs_general
+
+---
+
+pvscan
+OO: --ignorelockingfailure, --reportformat ReportFmt, --exported, --novolumegroup,
+--short, --uuid
+ID: pvscan_show
+DESC: Display PV information.
+
+pvscan --cache_long
+OO: --ignorelockingfailure, --reportformat ReportFmt, --background,
+--activate Active, --major Number, --minor Number
+OP: PV|String ...
+ID: pvscan_cache
+DESC: Populate the lvmetad cache by scanning PVs.
+
+---
+
+vgcfgbackup
+OO: --file String, --foreign, --ignorelockingfailure, --partial, --readonly,
+--reportformat ReportFmt
+OP: VG ...
+ID: vgcfgbackup_general
+
+---
+
+OO_VGCFGRESTORE: --force_long, --metadatatype MetadataType
+
+vgcfgrestore VG
+OO: OO_VGCFGRESTORE
+ID: vgcfgrestore_by_vg
+DESC: Restore VG metadata from last backup.
+
+vgcfgrestore --file String VG
+OO: OO_VGCFGRESTORE
+ID: vgcfgrestore_by_file
+DESC: Restore VG metadata from specified file.
+
+vgcfgrestore --list VG
+OO: OO_VGCFGRESTORE
+ID: vgcfgrestore_list_by_vg
+DESC: List all VG metadata backups.
+
+# FIXME: the optional VG pos arg is not used or checked and can be
+# anything, but a test in the test suite uses it.  Fix the test or
+# verify that the positional VG is correct?
+
+vgcfgrestore --list --file String
+OO: OO_VGCFGRESTORE
+OP: VG
+ID: vgcfgrestore_list_by_file
+DESC: List one VG metadata backup file.
+
+---
+
+# None of these can function as a required option for vgchange.
+
+OO_VGCHANGE: --autobackup Bool, --ignoremonitoring, --ignoreskippedcluster,
+--noudevsync, --reportformat ReportFmt, --select String, --force
+
+# Any of these can function as a required option for vgchange.
+# profile is also part of OO_ALL, but is repeated in OO_VGCHANGE_META
+# because it can function as a required opt.
+
+OO_VGCHANGE_META: --addtag Tag, --deltag Tag,
+--logicalvolume Number, --maxphysicalvolumes Number, --alloc Alloc, --uuid,
+--clustered Bool, --pvmetadatacopies MetadataCopiesPV, --vgmetadatacopies MetadataCopiesVG,
+--physicalextentsize SizeMB, --resizeable Bool, --systemid String, --locktype LockType,
+--profile String, --detachprofile, --metadataprofile String
+
+vgchange OO_VGCHANGE_META
+OO: OO_VGCHANGE
+OP: VG|Tag|Select ...
+ID: vgchange_properties
+DESC: Change a general VG property.
+
+vgchange --monitor Bool
+OO: --sysinit, --ignorelockingfailure, --poll Bool, OO_VGCHANGE
+OP: VG|Tag|Select ...
+ID: vgchange_monitor
+DESC: Start or stop monitoring LVs from dmeventd.
+
+vgchange --poll Bool
+OO: --ignorelockingfailure, OO_VGCHANGE
+OP: VG|Tag|Select ...
+ID: vgchange_poll
+DESC: Start or stop processing LV conversions.
+
+vgchange --activate Active
+OO: --activationmode ActivationMode, --ignoreactivationskip, --partial, --sysinit,
+--ignorelockingfailure, --monitor Bool, --poll Bool, OO_VGCHANGE
+OP: VG|Tag|Select ...
+ID: vgchange_activate
+DESC: Activate or deactivate LVs.
+
+vgchange --refresh
+OO: --sysinit, --ignorelockingfailure, --monitor Bool, --poll Bool, OO_VGCHANGE
+OP: VG|Tag|Select ...
+ID: vgchange_refresh
+DESC: Reactivate LVs using the latest metadata.
+
+vgchange --lockstart
+OO: --lockopt String, OO_VGCHANGE
+OP: VG|Tag|Select ...
+ID: vgchange_lockstart
+DESC: Start the lockspace of a shared VG in lvmlockd.
+
+vgchange --lockstop
+OO: --lockopt String, OO_VGCHANGE
+OP: VG|Tag|Select ...
+ID: vgchange_lockstop
+DESC: Stop the lockspace of a shared VG in lvmlockd.
+
+---
+
+vgck
+OO: --reportformat ReportFmt
+OP: VG|Tag ...
+ID: vgck_general
+
+---
+
+vgconvert VG ...
+OO: --force, --labelsector Number, --bootloaderareasize SizeMB,
+--metadatatype MetadataType, --pvmetadatacopies MetadataCopiesPV,
+--metadatasize SizeMB, --reportformat ReportFmt
+ID: vgconvert_general
+
+---
+
+vgcreate VG_new PV ...
+OO: --addtag Tag, --alloc Alloc, --autobackup Bool, --clustered Bool, --maxlogicalvolumes Number,
+--maxphysicalvolumes Number, --metadataprofile String, --metadatatype MetadataType,
+--physicalextentsize SizeMB, --force, --zero Bool, --labelsector Number,
+--metadatasize SizeMB, --pvmetadatacopies MetadataCopiesPV, --vgmetadatacopies MetadataCopiesVG,
+--reportformat ReportFmt, --dataalignment SizeKB, --dataalignmentoffset SizeKB,
+--shared, --systemid String, --locktype LockType, --lockopt String
+ID: vgcreate_general
+
+---
+
+vgdisplay
+OO: --activevolumegroups, --aligned, --binary, --colon, --columns,
+--configreport ConfigReport, --foreign, --ignorelockingfailure,
+--ignoreskippedcluster, --logonly, --noheadings, --nosuffix,
+--options String, --partial, --readonly, --reportformat ReportFmt, --select String,
+--shared, --short, --separator String, --sort String, --unbuffered, --units Units
+OP: VG|Tag ...
+ID: vgdisplay_general
+
+---
+
+OO_VGEXPORT: --reportformat ReportFmt
+
+vgexport VG|Tag|Select ...
+OO: --select String, OO_VGEXPORT
+ID: vgexport_some
+DESC: Export specified VGs.
+
+vgexport --all
+OO: OO_VGEXPORT
+ID: vgexport_all
+DESC: Export all VGs.
+FLAGS: SECONDARY_SYNTAX
+
+---
+
+vgextend VG PV ...
+OO: --autobackup Bool,
+--force, --zero Bool, --labelsector Number, --metadatatype MetadataType,
+--metadatasize SizeMB, --pvmetadatacopies MetadataCopiesPV,
+--metadataignore Bool, --dataalignment SizeKB, --dataalignmentoffset SizeKB,
+--reportformat ReportFmt, --restoremissing
+ID: vgextend_general
+
+---
+
+OO_VGIMPORT: --force, --reportformat ReportFmt
+
+vgimport VG|Tag|Select ...
+OO: --select String, OO_VGIMPORT
+ID: vgimport_some
+DESC: Import specified VGs.
+
+vgimport --all
+OO: OO_VGIMPORT
+ID: vgimport_all
+DESC: Import all VGs.
+
+---
+
+vgimportclone PV ...
+OO: --basevgname VG, --import
+ID: vgimportclone_general
+
+---
+
+vgmerge VG VG
+OO: --autobackup Bool, --list
+ID: vgmerge_general
+
+---
+
+vgmknodes
+OO: --ignorelockingfailure, --refresh, --reportformat ReportFmt
+OP: VG|LV|Tag ...
+ID: vgmknodes_general
+
+---
+
+OO_VGREDUCE: --autobackup Bool, --force, --reportformat ReportFmt
+
+vgreduce VG PV ...
+OO: OO_VGREDUCE
+ID: vgreduce_by_pv
+DESC: Remove a PV from a VG.
+
+vgreduce --all VG
+OO: OO_VGREDUCE
+ID: vgreduce_all
+DESC: Remove all unused PVs from a VG.
+
+vgreduce --removemissing VG
+OO: --mirrorsonly, OO_VGREDUCE
+ID: vgreduce_missing
+DESC: Remove all missing PVs from a VG.
+
+---
+
+vgremove VG|Tag|Select ...
+OO: --force, --noudevsync, --reportformat ReportFmt, --select String
+ID: vgremove_general
+
+---
+
+vgrename VG VG_new
+OO: --autobackup Bool, --force, --reportformat ReportFmt
+ID: vgrename_by_name
+DESC: Rename a VG.
+
+vgrename String VG_new
+OO: --autobackup Bool, --force, --reportformat ReportFmt
+ID: vgrename_by_uuid
+DESC: Rename a VG by specifying the VG UUID.
+
+---
+
+vgs
+OO: OO_REPORT
+OP: VG|Tag ...
+ID: vgs_general
+
+---
+
+vgscan
+OO: --cache_long, --ignorelockingfailure, --mknodes, --notifydbus,
+--partial, --reportformat ReportFmt
+ID: vgscan_general
+
+---
+
+OO_VGSPLIT: --autobackup Bool
+
+# used only when the destination VG is new
+OO_VGSPLIT_NEW: --alloc Alloc, --clustered Bool,
+--maxlogicalvolumes Number, --maxphysicalvolumes Number,
+--metadatatype MetadataType, --vgmetadatacopies MetadataCopiesVG
+
+vgsplit VG VG PV ...
+OO: OO_VGSPLIT, OO_VGSPLIT_NEW
+ID: vgsplit_by_pv
+DESC: Split a VG by specified PVs.
+
+vgsplit --name LV VG VG
+OO: OO_VGSPLIT, OO_VGSPLIT_NEW
+ID: vgsplit_by_lv
+DESC: Split a VG by PVs in a specified LV.
+
+---
+
+# built-in and deprecated commands
+
+# use lvmconfig
+config
+OO: OO_CONFIG
+OP: String ...
+ID: lvmconfig_general
+FLAGS: SECONDARY_SYNTAX
+
+# use lvmconfig
+dumpconfig
+OO: OO_CONFIG
+OP: String ...
+ID: lvmconfig_general
+FLAGS: SECONDARY_SYNTAX
+
+devtypes
+OO: --aligned, --binary, --nameprefixes, --noheadings,
+--nosuffix, --options String, --reportformat ReportFmt, --rows,
+--select String, --separator String, --sort String, --unbuffered, --unquoted
+ID: devtypes_general
+
+fullreport
+OO: OO_REPORT
+OP: VG ...
+ID: fullreport_general
+
+lastlog
+OO: --reportformat ReportFmt, --select String
+ID: lastlog_general
+
+lvpoll --polloperation PollOp LV ...
+OO: --abort, --autobackup Bool, --handlemissingpvs, --interval Number
+ID: lvpoll_general
+
+formats
+ID: formats_general
+
+help
+ID: help_general
+
+version
+ID: version_general
+
+# deprecated
+pvdata
+ID: pvdata_general
+FLAGS: SECONDARY_SYNTAX
+
+segtypes
+ID: segtypes_general
+
+systemid
+ID: systemid_general
+
+tags
+ID: tags_general
+
+# deprecated
+lvmchange
+ID: lvmchange_general
+FLAGS: SECONDARY_SYNTAX
+
+# deprecated
+lvmdiskscan
+OO: --lvmpartition, --readonly
+ID: lvmdiskscan_general
+FLAGS: SECONDARY_SYNTAX
+
+# deprecated
+lvmsadc
+ID: lvmsadc_general
+FLAGS: SECONDARY_SYNTAX
+
+# deprecated
+lvmsar
+OO: --full, --stdin
+ID: lvmsar_general
+FLAGS: SECONDARY_SYNTAX
+
diff --git a/tools/command.h b/tools/command.h
new file mode 100644
index 0000000..e4ce989
--- /dev/null
+++ b/tools/command.h
@@ -0,0 +1,207 @@
+/*
+ * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.  
+ * Copyright (C) 2004-2015 Red Hat, Inc. All rights reserved.
+ *
+ * This file is part of LVM2.
+ *
+ * This copyrighted material is made available to anyone wishing to use,
+ * modify, copy, or redistribute it subject to the terms and conditions
+ * of the GNU Lesser General Public License v.2.1.
+ *
+ * You should have received a copy of the GNU Lesser General Public License
+ * along with this program; if not, write to the Free Software Foundation,
+ * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
+ */
+
+#ifndef _LVM_COMMAND_H
+#define _LVM_COMMAND_H
+
+struct cmd_context;
+
+/* old per-command-name function */
+typedef int (*command_fn) (struct cmd_context *cmd, int argc, char **argv);
+
+/* new per-command-line-id functions */
+typedef int (*command_line_fn) (struct cmd_context *cmd, int argc, char **argv);
+
+struct command_function {
+	int command_line_enum;
+	command_line_fn fn;
+};
+
+struct command_name {
+	const char *name;
+	const char *desc; /* general command description from commands.h */
+	unsigned int flags;
+
+	/* union of {required,optional}_opt_args for all commands with this name */
+	int valid_args[ARG_COUNT];
+	int num_args;
+};
+
+/*
+ * Command defintion
+ *
+ * A command is defined in terms of a command name,
+ * required options (+args), optional options (+args),
+ * required positional args, optional positional args.
+ *
+ * A positional arg always has non-zero pos_arg.def.types.
+ * The first positional arg has pos_arg.pos of 1.
+ */
+
+/* arg_def flags */
+#define ARG_DEF_FLAG_NEW_VG             1 << 0
+#define ARG_DEF_FLAG_NEW_LV             1 << 1
+#define ARG_DEF_FLAG_MAY_REPEAT         1 << 2
+
+static inline int val_bit_is_set(uint64_t val_bits, int val_enum)
+{
+	return (val_bits & (1 << val_enum)) ? 1 : 0;
+}
+
+static inline uint64_t val_enum_to_bit(int val_enum)
+{
+	return (1ULL << val_enum);
+}
+
+static inline int lvp_bit_is_set(uint64_t lvp_bits, int lvp_enum)
+{
+	return (lvp_bits & (1 << lvp_enum)) ? 1 : 0;
+}
+
+static inline uint64_t lvp_enum_to_bit(int lvp_enum)
+{
+	return (1ULL << lvp_enum);
+}
+
+static inline int lvt_bit_is_set(uint64_t lvt_bits, int lvt_enum)
+{
+	return (lvt_bits & (1 << lvt_enum)) ? 1 : 0;
+}
+
+static inline uint64_t lvt_enum_to_bit(int lvt_enum)
+{
+	return (1ULL << lvt_enum);
+}
+
+/* Description a value that follows an option or exists in a position. */
+
+struct arg_def {
+	uint64_t val_bits;   /* bits of x_VAL, can be multiple for pos_arg */
+	uint64_t lvt_bits;   /* lvt_enum_to_bit(x_LVT) for lv_VAL, can be multiple */
+	uint64_t num;        /* a literal number for conststr_VAL */
+	const char *str;     /* a literal string for constnum_VAL */
+	uint32_t flags;      /* ARG_DEF_FLAG_ */
+};
+
+/* Description of an option and the value that follows it. */
+
+struct opt_arg {
+	int opt;             /* option, e.g. foo_ARG */
+	struct arg_def def;  /* defines accepted values */
+};
+
+/* Description of a position and the value that exists there. */
+
+struct pos_arg {
+	int pos;             /* position, e.g. first is 1 */
+	struct arg_def def;  /* defines accepted values */
+};
+
+/*
+ *
+ * Commands using a given command definition must follow a set
+ * of rules.  If a given command+LV matches the conditions in
+ * opts/lvt_bits/lvp_bits, then the checks are applied.
+ * If one condition is not met, the checks are not applied.
+ * If no conditions are set, the checks are always applied.
+ */
+
+#define RULE_INVALID 1
+#define RULE_REQUIRE 2
+
+struct cmd_rule {
+	int *opts;			/* if any option in this list is set, the check may apply */
+	uint64_t lvt_bits;		/* if LV has one of these types (lvt_enum_to_bit), the check may apply */
+	uint64_t lvp_bits;		/* if LV has all of these properties (lvp_enum_to_bit), the check may apply */
+
+	int *check_opts;		/* used options must [not] be in this list */
+	uint64_t check_lvt_bits;	/* LV must [not] have one of these type */
+	uint64_t check_lvp_bits;	/* LV must [not] have all of these properties */
+
+	uint32_t rule;			/* RULE_INVALID, RULE_REQUIRE: check values must [not] be true */
+	int opts_count;			/* entries in opts[] */
+	int check_opts_count;		/* entries in check_opts[] */
+
+};
+
+/*
+ * CMD_RO_ARGS needs to accomodate a list of options,
+ * of which one is required after which the rest are
+ * optional.
+ */
+#define CMD_RO_ARGS 64          /* required opt args */
+#define CMD_OO_ARGS 150         /* optional opt args */
+#define CMD_RP_ARGS 8           /* required positional args */
+#define CMD_OP_ARGS 8           /* optional positional args */
+#define CMD_IO_ARGS 8           /* ignore opt args */
+#define CMD_MAX_RULES 32        /* max number of rules per command def */
+
+/*
+ * one or more from required_opt_args is required,
+ * then the rest are optional.
+ */
+#define CMD_FLAG_ONE_REQUIRED_OPT   1
+#define CMD_FLAG_SECONDARY_SYNTAX   2
+
+/* a register of the lvm commands */
+struct command {
+	const char *name;
+	const char *desc; /* specific command description from command-lines.h */
+	const char *usage; /* excludes common options like --help, --debug */
+	const char *usage_common; /* includes commmon options like --help, --debug */
+	const char *command_line_id;
+	int command_line_enum; /* <command_line_id>_CMD */
+
+	struct command_name *cname;
+
+	command_fn fn;                      /* old style */
+	struct command_function *functions; /* new style */
+
+	unsigned int flags; /* copied from command_name.flags from commands.h */
+
+	unsigned int cmd_flags; /* CMD_FLAG_ */
+
+	/* definitions of opt/pos args */
+
+	/* required args following an --opt */
+	struct opt_arg required_opt_args[CMD_RO_ARGS];
+
+	/* optional args following an --opt */
+	struct opt_arg optional_opt_args[CMD_OO_ARGS];
+
+	/* required positional args */
+	struct pos_arg required_pos_args[CMD_RP_ARGS];
+
+	/* optional positional args */
+	struct pos_arg optional_pos_args[CMD_OP_ARGS];
+
+	/* unused opt args, are ignored instead of causing an error */
+	struct opt_arg ignore_opt_args[CMD_IO_ARGS];
+
+	struct cmd_rule rules[CMD_MAX_RULES];
+
+	int ro_count;
+	int oo_count;
+	int rp_count;
+	int op_count;
+	int io_count;
+
+	/* used for processing current position */
+	int pos_count;
+
+	int rule_count;
+};
+
+#endif
diff --git a/tools/commands.h b/tools/commands.h
index baf89b1..c663207 100644
--- a/tools/commands.h
+++ b/tools/commands.h
@@ -13,1546 +13,232 @@
  * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
  */
 
-/***********  Replace with script?
-xx(e2fsadm,
-   "Resize logical volume and ext2 filesystem",
-   "e2fsadm "
-   "[-d|--debug] " "[-h|--help] " "[-n|--nofsck]\n"
-   "\t{[-l|--extents] [+|-]LogicalExtentsNumber |\n"
-   "\t [-L|--size] [+|-]LogicalVolumeSize[bBsSkKmMgGtTpPeE]}\n"
-   "\t[-t|--test]\n"
-   "\t[-v|--verbose]\n"
-   "\t[--version]\n"
-   "\tLogicalVolumePath\n",
-
-    extents_ARG, size_ARG, nofsck_ARG, test_ARG)
-*********/
-
 xx(config,
    "Display and manipulate configuration information",
-   PERMITTED_READ_ONLY | NO_METADATA_PROCESSING,
-   "config\n"
-   "\t[-f|--file filename]\n"
-   "\t[--type {current|default|diff|full|list|missing|new|profilable|profilable-command|profilable-metadata}]\n"
-   "\t[--atversion version]\n"
-   "\t[--ignoreadvanced]\n"
-   "\t[--ignoreunsupported]\n"
-   "\t[--ignorelocal]\n"
-   "\t[-l|--list]\n"
-   "\t[--config ConfigurationString]\n"
-   "\t[--commandprofile ProfileName]\n"
-   "\t[--profile ProfileName]\n"
-   "\t[--metadataprofile ProfileName]\n"
-   "\t[--mergedconfig]\n"
-   "\t[--sinceversion version]\n"
-   "\t[--showdeprecated]\n"
-   "\t[--showunsupported]\n"
-   "\t[--validate]\n"
-   "\t[--withsummary]\n"
-   "\t[--withcomments]\n"
-   "\t[--withspaces]\n"
-   "\t[--unconfigured]\n"
-   "\t[--withversions]\n"
-   "\t[ConfigurationNode...]\n",
-   atversion_ARG, configtype_ARG, file_ARG, ignoreadvanced_ARG,
-   ignoreunsupported_ARG, ignorelocal_ARG, list_ARG, mergedconfig_ARG, metadataprofile_ARG,
-   sinceversion_ARG, showdeprecated_ARG, showunsupported_ARG, validate_ARG, withsummary_ARG,
-   withcomments_ARG, withspaces_ARG, unconfigured_ARG, withversions_ARG)
+   PERMITTED_READ_ONLY | NO_METADATA_PROCESSING)
 
 xx(devtypes,
    "Display recognised built-in block device types",
-   PERMITTED_READ_ONLY | NO_METADATA_PROCESSING,
-   "devtypes\n"
-   "\t[--aligned]\n"
-   "\t[--binary]\n"
-   "\t[--commandprofile ProfileName]\n"
-   "\t[-d|--debug]\n"
-   "\t[-h|--help]\n"
-   "\t[--nameprefixes]\n"
-   "\t[--noheadings]\n"
-   "\t[--nosuffix]\n"
-   "\t[-o|--options [+|-|#]Field[,Field]]\n"
-   "\t[-O|--sort [+|-]key1[,[+|-]key2[,...]]]\n"
-   "\t[--reportformat {basic|json}]\n"
-   "\t[--rows]\n"
-   "\t[-S|--select Selection]\n"
-   "\t[--separator Separator]\n"
-   "\t[--unbuffered]\n"
-   "\t[--unquoted]\n"
-   "\t[--version]\n",
-
-   aligned_ARG, binary_ARG, nameprefixes_ARG, noheadings_ARG,
-   nosuffix_ARG, options_ARG, reportformat_ARG, rows_ARG,
-   select_ARG, separator_ARG, sort_ARG, unbuffered_ARG, unquoted_ARG)
+   PERMITTED_READ_ONLY | NO_METADATA_PROCESSING)
 
 xx(dumpconfig,
    "Display and manipulate configuration information",
-   PERMITTED_READ_ONLY | NO_METADATA_PROCESSING,
-   "dumpconfig\n"
-   "\t[-f|--file filename]\n"
-   "\t[--type {current|default|diff|full|list|missing|new|profilable|profilable-command|profilable-metadata}]\n"
-   "\t[--atversion version]\n"
-   "\t[--ignoreadvanced]\n"
-   "\t[--ignoreunsupported]\n"
-   "\t[--ignorelocal]\n"
-   "\t[-l|--list]\n"
-   "\t[--config ConfigurationString]\n"
-   "\t[--commandprofile ProfileName]\n"
-   "\t[--profile ProfileName]\n"
-   "\t[--metadataprofile ProfileName]\n"
-   "\t[--mergedconfig]\n"
-   "\t[--sinceversion version]\n"
-   "\t[--showdeprecated]\n"
-   "\t[--showunsupported]\n"
-   "\t[--validate]\n"
-   "\t[--withsummary]\n"
-   "\t[--withcomments]\n"
-   "\t[--withspaces]\n"
-   "\t[--unconfigured]\n"
-   "\t[--withversions]\n"
-   "\t[ConfigurationNode...]\n",
-   atversion_ARG, configtype_ARG, file_ARG, ignoreadvanced_ARG,
-   ignoreunsupported_ARG, ignorelocal_ARG, list_ARG, mergedconfig_ARG, metadataprofile_ARG,
-   sinceversion_ARG, showdeprecated_ARG, showunsupported_ARG, validate_ARG, withsummary_ARG,
-   withcomments_ARG, withspaces_ARG, unconfigured_ARG, withversions_ARG)
+   PERMITTED_READ_ONLY | NO_METADATA_PROCESSING)
 
 xx(formats,
    "List available metadata formats",
-   PERMITTED_READ_ONLY | NO_METADATA_PROCESSING,
-   "formats\n")
+   PERMITTED_READ_ONLY | NO_METADATA_PROCESSING)
 
 xx(help,
    "Display help for commands",
-   PERMITTED_READ_ONLY | NO_METADATA_PROCESSING,
-   "help <command>\n")
-
-/*********
-xx(lvactivate,
-   "Activate logical volume on given partition(s)",
-   "lvactivate "
-   "\t[-d|--debug]\n"
-   "\t[-h|--help]\n"
-   "\t[-v|--verbose]\n"
-   "Logical Volume(s)\n")
-***********/
+   PERMITTED_READ_ONLY | NO_METADATA_PROCESSING)
 
 xx(fullreport,
    "Display full report",
-   PERMITTED_READ_ONLY | ALL_VGS_IS_DEFAULT | LOCKD_VG_SH,
-   "fullreport\n"
-   "\t[--aligned]\n"
-   "\t[--binary]\n"
-   "\t[-a|--all]\n"
-   "\t[--commandprofile ProfileName]\n"
-   "\t[--configreport ReportName]\n"
-   "\t[-d|--debug]\n"
-   "\t[--foreign]\n"
-   "\t[-h|--help]\n"
-   "\t[--ignorelockingfailure]\n"
-   "\t[--ignoreskippedcluster]\n"
-   "\t[--logonly]\n"
-   "\t[--nameprefixes]\n"
-   "\t[--noheadings]\n"
-   "\t[--nosuffix]\n"
-   "\t[-o|--options [+|-|#]Field[,Field]]\n"
-   "\t[-O|--sort [+|-]key1[,[+|-]key2[,...]]]\n"
-   "\t[-P|--partial]\n"
-   "\t[--readonly]\n"
-   "\t[--reportformat {basic|json}]\n"
-   "\t[--rows]\n"
-   "\t[-S|--select Selection]\n"
-   "\t[--separator Separator]\n"
-   "\t[--trustcache]\n"
-   "\t[--unbuffered]\n"
-   "\t[--units hHbBsSkKmMgGtTpPeE]\n"
-   "\t[--unquoted]\n"
-   "\t[-v|--verbose]\n"
-   "\t[--version]\n"
-   "\t[VolumeGroupName [VolumeGroupName...]]\n",
-
-   aligned_ARG, all_ARG, binary_ARG, configreport_ARG, foreign_ARG,
-   ignorelockingfailure_ARG, ignoreskippedcluster_ARG, logonly_ARG,
-   nameprefixes_ARG, noheadings_ARG, nolocking_ARG, nosuffix_ARG,
-   options_ARG, partial_ARG, readonly_ARG, reportformat_ARG, rows_ARG,
-   select_ARG, separator_ARG, shared_ARG, sort_ARG, trustcache_ARG,
-   unbuffered_ARG, units_ARG, unquoted_ARG)
+   PERMITTED_READ_ONLY | ALL_VGS_IS_DEFAULT | LOCKD_VG_SH)
 
 xx(lastlog,
    "Display last command's log report",
-   PERMITTED_READ_ONLY | NO_METADATA_PROCESSING,
-   "log\n"
-   "\t[--reportformat {basic|json}]\n"
-   "\t[-S|--select Selection]\n",
-
-   reportformat_ARG, select_ARG)
+   PERMITTED_READ_ONLY | NO_METADATA_PROCESSING)
 
 xx(lvchange,
    "Change the attributes of logical volume(s)",
-   CACHE_VGMETADATA | PERMITTED_READ_ONLY,
-   "lvchange\n"
-   "\t[-A|--autobackup {y|n}]\n"
-   "\t[-a|--activate [a][e|s|l]{y|n}]\n"
-   "\t[--activationmode {complete|degraded|partial}"
-   "\t[--addtag <Tag>]\n"
-   "\t[--alloc <AllocationPolicy>]\n"
-   "\t[--rebuild PhysicalVolume]\n"
-   "\t[-C|--contiguous {y|n}]\n"
-   "\t[--cachemode <CacheMode>]\n"
-   "\t[--cachepolicy <policyname>] [--cachesettings <parameter=value>]\n"
-   "\t[--commandprofile <ProfileName>]\n"
-   "\t[-d|--debug]\n"
-   "\t[--deltag <Tag>]\n"
-   "\t[--detachprofile]\n"
-   "\t[--errorwhenfull {y|n}]\n"
-   "\t[-f|--force]\n"
-   "\t[-h|--help]\n"
-   "\t[--discards {ignore|nopassdown|passdown}]\n"
-   "\t[--ignorelockingfailure]\n"
-   "\t[--ignoremonitoring]\n"
-   "\t[--ignoreskippedcluster]\n"
-   "\t[-k|--setactivationskip {y|n}]\n"
-   "\t[-K|--ignoreactivationskip]\n"
-   "\t[--monitor {y|n}]\n"
-   "\t[--poll {y|n}]\n"
-   "\t[--noudevsync]\n"
-   "\t[-M|--persistent {y|n}] [-j|--major <major>] [--minor <minor>]\n"
-   "\t[--metadataprofile <ProfileName>]\n"
-   "\t[-P|--partial]\n"
-   "\t[-p|--permission {r|rw}]\n"
-   "\t[--[raid]minrecoveryrate <Rate>]\n"
-   "\t[--[raid]maxrecoveryrate <Rate>]\n"
-   "\t[--[raid]syncaction {check|repair}\n"
-   "\t[--[raid]writebehind <IOCount>]\n"
-   "\t[--[raid]writemostly <PhysicalVolume>[:{t|n|y}]]\n"
-   "\t[-r|--readahead <ReadAheadSectors>|auto|none]\n"
-   "\t[--refresh]\n"
-   "\t[--reportformat {basic|json}]\n"
-   "\t[--resync]\n"
-   "\t[-S|--select Selection]\n"
-   "\t[--sysinit]\n"
-   "\t[-t|--test]\n"
-   "\t[-v|--verbose]\n"
-   "\t[--version]\n"
-   "\t[-y|--yes]\n"
-   "\t[-Z|--zero {y|n}]\n"
-   "\t<LogicalVolume[Path]> [<LogicalVolume[Path]>...]\n",
-
-   activationmode_ARG, addtag_ARG, alloc_ARG, autobackup_ARG, activate_ARG,
-   available_ARG, cachemode_ARG, cachepolicy_ARG, cachesettings_ARG,
-   contiguous_ARG, deltag_ARG,
-   discards_ARG, detachprofile_ARG, errorwhenfull_ARG, force_ARG,
-   ignorelockingfailure_ARG, ignoremonitoring_ARG, ignoreactivationskip_ARG,
-   ignoreskippedcluster_ARG, major_ARG, metadataprofile_ARG, minor_ARG,
-   monitor_ARG, minrecoveryrate_ARG, maxrecoveryrate_ARG, noudevsync_ARG,
-   partial_ARG, permission_ARG, persistent_ARG, poll_ARG,
-   raidrebuild_ARG, raidminrecoveryrate_ARG, raidmaxrecoveryrate_ARG,
-   raidsyncaction_ARG, raidwritebehind_ARG, raidwritemostly_ARG, readahead_ARG,
-   reportformat_ARG, rebuild_ARG, resync_ARG, refresh_ARG, select_ARG, setactivationskip_ARG,
-   syncaction_ARG, sysinit_ARG, test_ARG, writebehind_ARG, writemostly_ARG, zero_ARG)
-
-#define COMMON_OPTS \
-	"\t[--commandprofile <ProfileName>] [-d|--debug] [-h|-?|--help]\n" \
-	"\t[--noudevsync] [-t|--test] [-v|--verbose] [--version] [-y|--yes]\n"
+   CACHE_VGMETADATA | PERMITTED_READ_ONLY)
 
 xx(lvconvert,
    "Change logical volume layout",
-   0,
-   "lvconvert "
-   "[-m|--mirrors <Mirrors> [--mirrorlog {disk|core|mirrored}|--corelog]]\n"
-   "\t[--type <SegmentType>]\n"
-   "\t[--rebuild PhysicalVolume]\n"
-   "\t[--repair [--use-policies]]\n"
-   "\t[--replace PhysicalVolume]\n"
-   "\t[-R|--regionsize <MirrorLogRegionSize>]\n"
-   "\t[--alloc <AllocationPolicy>]\n"
-   "\t[-b|--background]\n"
-   "\t[-f|--force]\n"
-   "\t[-i|--interval <Seconds>]\n"
-   "\t[--stripes <Stripes> [-I|--stripesize <StripeSize>]]\n"
-   COMMON_OPTS
-   "\tLogicalVolume[Path] [PhysicalVolume[Path]...]\n\n"
-
-   "lvconvert "
-   "[--splitmirrors <Images> --trackchanges]\n"
-   "\t[--splitmirrors Images --name SplitLogicalVolumeName]\n"
-   COMMON_OPTS
-   "\tLogicalVolume[Path] [SplittablePhysicalVolume[Path]...]\n\n"
-
-   "lvconvert "
-   "--splitsnapshot\n"
-   COMMON_OPTS
-   "\tSnapshotLogicalVolume[Path]\n\n"
-
-   "lvconvert "
-   "--splitcache\n"
-   COMMON_OPTS
-   "\tCacheLogicalVolume[Path]\n\n"
-
-   "lvconvert "
-   "--split\n"
-   "\t[--name SplitLogicalVolumeName]\n"
-   COMMON_OPTS
-   "\tSplitableLogicalVolume[Path]\n\n"
-
-   "lvconvert "
-   "--uncache\n"
-   COMMON_OPTS
-   "\tCacheLogicalVolume[Path]\n\n"
-
-   "lvconvert "
-   "[--type snapshot|-s|--snapshot]\n"
-   "\t[-c|--chunksize <ChunkSize>]\n"
-   "\t[-Z|--zero {y|n}]\n"
-   COMMON_OPTS
-   "\tOriginalLogicalVolume[Path] SnapshotLogicalVolume[Path]\n\n"
-
-   "lvconvert "
-   "--merge\n"
-   "\t[-b|--background]\n"
-   "\t[-i|--interval <Seconds>]\n"
-   COMMON_OPTS
-   "\tLogicalVolume[Path]\n\n"
-
-   "lvconvert "
-   "[--type thin[-pool]|-T|--thin]\n"
-   "\t[--thinpool ThinPoolLogicalVolume[Path]]\n"
-   "\t[--chunksize <ChunkSize>]\n"
-   "\t[--discards {ignore|nopassdown|passdown}]\n"
-   "\t[--poolmetadataspare {y|n}]\n"
-   "\t[--poolmetadata ThinMetadataLogicalVolume[Path] |\n"
-   "\t --poolmetadatasize <MetadataSize>]\n"
-   "\t[-r|--readahead <ReadAheadSectors>|auto|none]\n"
-   "\t[--stripes <Stripes> [-I|--stripesize <StripeSize>]]]\n"
-   "\t[--originname NewExternalOriginVolumeName]]\n"
-   "\t[-Z|--zero {y|n}]\n"
-   COMMON_OPTS
-   "\t[ExternalOrigin|ThinDataPool]LogicalVolume[Path] [PhysicalVolumePath...]\n\n"
-
-   "lvconvert "
-   "[--type cache[-pool]|-H|--cache]\n"
-   "\t[--cachepool CacheDataLogicalVolume[Path]]\n"
-   "\t[--cachemode <CacheMode>]\n"
-   "\t[--cachepolicy <CachePolicy>]\n"
-   "\t[--cachesettings <Key>=<Value>]\n"
-   "\t[--chunksize <ChunkSize>]\n"
-   "\t[--poolmetadata CacheMetadataLogicalVolume[Path] |\n"
-   "\t --poolmetadatasize <MetadataSize>]\n"
-   "\t[--poolmetadataspare {y|n}]]\n"
-   COMMON_OPTS
-   "\t[Cache|CacheDataPool]LogicalVolume[Path] [PhysicalVolumePath...]\n\n",
-
-   alloc_ARG, background_ARG, cache_ARG, cachemode_ARG,
-   cachepool_ARG, cachepolicy_ARG, cachesettings_ARG, chunksize_ARG,
-   corelog_ARG, discards_ARG, force_ARG, interval_ARG, merge_ARG, mirrorlog_ARG,
-   mirrors_ARG, name_ARG, noudevsync_ARG, originname_ARG, poolmetadata_ARG,
-   poolmetadatasize_ARG, poolmetadataspare_ARG, readahead_ARG, regionsize_ARG,
-   repair_ARG, replace_ARG, snapshot_ARG,
-   split_ARG, splitcache_ARG, splitmirrors_ARG, splitsnapshot_ARG,
-   stripes_long_ARG, stripesize_ARG, test_ARG, thin_ARG, thinpool_ARG,
-   trackchanges_ARG, type_ARG, uncache_ARG, usepolicies_ARG, zero_ARG)
+   0)
 
 xx(lvcreate,
    "Create a logical volume",
-   0,
-   "lvcreate\n"
-   "\t[-A|--autobackup {y|n}]\n"
-   "\t[-a|--activate [a|e|l]{y|n}]\n"
-   "\t[--addtag Tag]\n"
-   "\t[--alloc AllocationPolicy]\n"
-   "\t[-H|--cache\n"
-   "\t  [--cachemode {writeback|writethrough}]\n"
-   "\t  [--cachepolicy policy]\n"
-   "\t  [--cachesettings key=value]\n"
-   "\t[--cachepool CachePoolLogicalVolume{Name|Path}]\n"
-   "\t[-c|--chunksize ChunkSize]\n"
-   "\t[-C|--contiguous {y|n}]\n"
-   "\t[--commandprofile ProfileName]\n"
-   "\t[-d|--debug]\n"
-   "\t[-h|-?|--help]\n"
-   "\t[--errorwhenfull {y|n}]\n"
-   "\t[--ignoremonitoring]\n"
-   "\t[--monitor {y|n}]\n"
-   "\t[-i|--stripes Stripes [-I|--stripesize StripeSize]]\n"
-   "\t[-k|--setactivationskip {y|n}]\n"
-   "\t[-K|--ignoreactivationskip]\n"
-   "\t{-l|--extents LogicalExtentsNumber[%{VG|PVS|FREE}] |\n"
-   "\t -L|--size LogicalVolumeSize[bBsSkKmMgGtTpPeE]}\n"
-   "\t[-M|--persistent {y|n}] [-j|--major major] [--minor minor]\n"
-   "\t[--metadataprofile ProfileName]\n"
-   "\t[-m|--mirrors Mirrors [--nosync]\n"
-   "\t  [{--mirrorlog {disk|core|mirrored}|--corelog}]]\n"
-   "\t[-n|--name LogicalVolumeName]\n"
-   "\t[--noudevsync]\n"
-   "\t[-p|--permission {r|rw}]\n"
-   //"\t[--pooldatasize DataSize[bBsSkKmMgGtTpPeE]]\n"
-   "\t[--poolmetadatasize MetadataSize[bBsSkKmMgG]]\n"
-   "\t[--poolmetadataspare {y|n}]]\n"
-   "\t[--[raid]minrecoveryrate Rate]\n"
-   "\t[--[raid]maxrecoveryrate Rate]\n"
-   "\t[-r|--readahead {ReadAheadSectors|auto|none}]\n"
-   "\t[--reportformat {basic|json}]\n"
-   "\t[-R|--regionsize MirrorLogRegionSize]\n"
-   "\t[-T|--thin\n"
-   "\t  [--discards {ignore|nopassdown|passdown}]\n"
-   "\t[--thinpool ThinPoolLogicalVolume{Name|Path}]\n"
-   "\t[-t|--test]\n"
-   "\t[--type VolumeType]\n"
-   "\t[-v|--verbose]\n"
-   "\t[-W|--wipesignatures {y|n}]\n"
-   "\t[-Z|--zero {y|n}]\n"
-   "\t[--version]\n"
-   "\tVolumeGroupName [PhysicalVolumePath...]\n\n"
-
-   "lvcreate\n"
-   "\t{ {-s|--snapshot} OriginalLogicalVolume[Path] |\n"
-   "\t  [-s|--snapshot] VolumeGroupName[Path] -V|--virtualsize VirtualSize}\n"
-   "\t  {-H|--cache} VolumeGroupName[Path][/OriginalLogicalVolume]\n"
-   "\t  {-T|--thin} VolumeGroupName[Path][/PoolLogicalVolume]\n"
-   "\t              -V|--virtualsize VirtualSize}\n"
-   "\t[-A|--autobackup {y|n}]\n"
-   "\t[--addtag Tag]\n"
-   "\t[--alloc AllocationPolicy]\n"
-   "\t[--cachepolicy Policy] [--cachesettings Key=Value]\n"
-   "\t[-c|--chunksize]\n"
-   "\t[-C|--contiguous {y|n}]\n"
-   "\t[--commandprofile ProfileName]\n"
-   "\t[-d|--debug]\n"
-   "\t[--discards {ignore|nopassdown|passdown}]\n"
-   "\t[-h|-?|--help]\n"
-   "\t[--ignoremonitoring]\n"
-   "\t[--monitor {y|n}]\n"
-   "\t[-i|--stripes Stripes [-I|--stripesize StripeSize]]\n"
-   "\t[-k|--setactivationskip {y|n}]\n"
-   "\t[-K|--ignoreactivationskip]\n"
-   "\t{-l|--extents LogicalExtentsNumber[%{VG|FREE|ORIGIN}] |\n"
-   "\t -L|--size LogicalVolumeSize[bBsSkKmMgGtTpPeE]}\n"
-   //"\t[--pooldatasize DataVolumeSize[bBsSkKmMgGtTpPeE]]\n"
-   "\t[--poolmetadatasize MetadataVolumeSize[bBsSkKmMgG]]\n"
-   "\t[-M|--persistent {y|n}] [-j|--major major] [--minor minor]\n"
-   "\t[--metadataprofile ProfileName]\n"
-   "\t[-n|--name LogicalVolumeName]\n"
-   "\t[--noudevsync]\n"
-   "\t[-p|--permission {r|rw}]\n"
-   "\t[-r|--readahead ReadAheadSectors|auto|none]\n"
-   "\t[--reportformat {basic|json}]\n"
-   "\t[-t|--test]\n"
-   "\t[{--thinpool ThinPoolLogicalVolume[Path] |\n"
-   "\t  --cachepool CachePoolLogicalVolume[Path]}]\n"
-   "\t[-v|--verbose]\n"
-   "\t[--version]\n"
-   "\t[PhysicalVolumePath...]\n\n",
-
-   addtag_ARG, alloc_ARG, autobackup_ARG, activate_ARG, available_ARG,
-   cache_ARG, cachemode_ARG, cachepool_ARG, cachepolicy_ARG, cachesettings_ARG,
-   chunksize_ARG, contiguous_ARG, corelog_ARG, discards_ARG, errorwhenfull_ARG,
-   extents_ARG, ignoreactivationskip_ARG, ignoremonitoring_ARG, major_ARG,
-   metadataprofile_ARG, minor_ARG, mirrorlog_ARG, mirrors_ARG, monitor_ARG,
-   minrecoveryrate_ARG, maxrecoveryrate_ARG, name_ARG, nosync_ARG,
-   noudevsync_ARG, permission_ARG, persistent_ARG,
-   //pooldatasize_ARG,
-   poolmetadatasize_ARG, poolmetadataspare_ARG,
-   raidminrecoveryrate_ARG, raidmaxrecoveryrate_ARG,
-   readahead_ARG, regionsize_ARG, reportformat_ARG, setactivationskip_ARG,
-   size_ARG, snapshot_ARG, stripes_ARG, stripesize_ARG, test_ARG, thin_ARG,
-   thinpool_ARG, type_ARG, virtualoriginsize_ARG, virtualsize_ARG,
-   wipesignatures_ARG, zero_ARG)
+   0)
 
 xx(lvdisplay,
    "Display information about a logical volume",
-   PERMITTED_READ_ONLY | ALL_VGS_IS_DEFAULT | LOCKD_VG_SH,
-   "lvdisplay\n"
-   "\t[-a|--all]\n"
-   "\t[-c|--colon]\n"
-   "\t[--commandprofile ProfileName]\n"
-   "\t[-d|--debug]\n"
-   "\t[--foreign]\n"
-   "\t[-h|--help]\n"
-   "\t[-H|--history]\n"
-   "\t[--ignorelockingfailure]\n"
-   "\t[--ignoreskippedcluster]\n"
-   "\t[-m|--maps]\n"
-   "\t[--nosuffix]\n"
-   "\t[-P|--partial]\n"
-   "\t[--readonly]\n"
-   "\t[--reportformat {basic|json}]\n"
-   "\t[-S|--select Selection]\n"
-   "\t[--units hHbBsSkKmMgGtTpPeE]\n"
-   "\t[-v|--verbose]\n"
-   "\t[--version]\n"
-   "\t[LogicalVolume[Path] [LogicalVolume[Path]...]]\n"
-   "\n"
-   "lvdisplay --columns|-C\n"
-   "\t[--aligned]\n"
-   "\t[-a|--all]\n"
-   "\t[--binary]\n"
-   "\t[--commandprofile ProfileName]\n"
-   "\t[--configreport ReportName]\n"
-   "\t[-d|--debug]\n"
-   "\t[--foreign]\n"
-   "\t[-h|--help]\n"
-   "\t[-H|--history]\n"
-   "\t[--ignorelockingfailure]\n"
-   "\t[--ignoreskippedcluster]\n"
-   "\t[--logonly]\n"
-   "\t[--noheadings]\n"
-   "\t[--nosuffix]\n"
-   "\t[-o|--options [+|-|#]Field[,Field]]\n"
-   "\t[-O|--sort [+|-]key1[,[+|-]key2[,...]]]\n"
-   "\t[-S|--select Selection]\n"
-   "\t[-P|--partial]\n"
-   "\t[--readonly]\n"
-   "\t[--reportformat {basic|json}]\n"
-   "\t[--segments]\n"
-   "\t[--separator Separator]\n"
-   "\t[--unbuffered]\n"
-   "\t[--units hHbBsSkKmMgGtTpPeE]\n"
-   "\t[-v|--verbose]\n"
-   "\t[--version]\n"
-   "\t[LogicalVolume[Path] [LogicalVolume[Path]...]]\n",
-
-    aligned_ARG, all_ARG, binary_ARG, colon_ARG, columns_ARG,
-    configreport_ARG, foreign_ARG, history_ARG, ignorelockingfailure_ARG,
-    ignoreskippedcluster_ARG, logonly_ARG, maps_ARG, noheadings_ARG,
-    nosuffix_ARG, options_ARG, sort_ARG, partial_ARG, readonly_ARG,
-    reportformat_ARG, segments_ARG, select_ARG, separator_ARG,
-    shared_ARG, unbuffered_ARG, units_ARG)
+   PERMITTED_READ_ONLY | ALL_VGS_IS_DEFAULT | LOCKD_VG_SH)
 
 xx(lvextend,
    "Add space to a logical volume",
-   0,
-   "lvextend\n"
-   "\t[-A|--autobackup y|n]\n"
-   "\t[--alloc AllocationPolicy]\n"
-   "\t[--commandprofile ProfileName]\n"
-   "\t[-d|--debug]\n"
-   "\t[-f|--force]\n"
-   "\t[-h|--help]\n"
-   "\t[-i|--stripes Stripes [-I|--stripesize StripeSize]]\n"
-   "\t{-l|--extents [+]LogicalExtentsNumber[%{VG|LV|PVS|FREE|ORIGIN}] |\n"
-   "\t -L|--size [+]LogicalVolumeSize[bBsSkKmMgGtTpPeE]}\n"
-   "\t --poolmetadatasize [+]MetadataVolumeSize[bBsSkKmMgG]}\n"
-   "\t[-m|--mirrors Mirrors]\n"
-   "\t[--nosync]\n"
-   "\t[--use-policies]\n"
-   "\t[-n|--nofsck]\n"
-   "\t[--noudevsync]\n"
-   "\t[--reportformat {basic|json}]\n"
-   "\t[-r|--resizefs]\n"
-   "\t[-t|--test]\n"
-   "\t[--type VolumeType]\n"
-   "\t[-v|--verbose]\n"
-   "\t[--version]\n"
-   "\tLogicalVolume[Path] [ PhysicalVolumePath... ]\n",
-
-   alloc_ARG, autobackup_ARG, extents_ARG, force_ARG, mirrors_ARG,
-   nofsck_ARG, nosync_ARG, noudevsync_ARG, poolmetadatasize_ARG,
-   reportformat_ARG, resizefs_ARG, size_ARG, stripes_ARG, stripesize_ARG,
-   test_ARG, type_ARG, usepolicies_ARG)
+   0)
 
 xx(lvmchange,
    "With the device mapper, this is obsolete and does nothing.",
-   0,
-   "lvmchange\n"
-   "\t[--commandprofile ProfileName]\n"
-   "\t[-d|--debug]\n"
-   "\t[-h|--help]\n"
-   "\t[-R|--reset]\n"
-   "\t[-v|--verbose]\n"
-   "\t[--version]\n",
-
-    reset_ARG)
+   0)
 
 xx(lvmconfig,
    "Display and manipulate configuration information",
-   PERMITTED_READ_ONLY | NO_METADATA_PROCESSING,
-   "lvmconfig\n"
-   "\t[-f|--file filename]\n"
-   "\t[--type {current|default|diff|full|list|missing|new|profilable|profilable-command|profilable-metadata}]\n"
-   "\t[--atversion version]\n"
-   "\t[--ignoreadvanced]\n"
-   "\t[--ignoreunsupported]\n"
-   "\t[--ignorelocal]\n"
-   "\t[-l|--list]\n"
-   "\t[--config ConfigurationString]\n"
-   "\t[--commandprofile ProfileName]\n"
-   "\t[--profile ProfileName]\n"
-   "\t[--metadataprofile ProfileName]\n"
-   "\t[--mergedconfig]\n"
-   "\t[--sinceversion version]\n"
-   "\t[--showdeprecated]\n"
-   "\t[--showunsupported]\n"
-   "\t[--validate]\n"
-   "\t[--withsummary]\n"
-   "\t[--withcomments]\n"
-   "\t[--withspaces]\n"
-   "\t[--unconfigured]\n"
-   "\t[--withversions]\n"
-   "\t[ConfigurationNode...]\n",
-   atversion_ARG, configtype_ARG, file_ARG, ignoreadvanced_ARG,
-   ignoreunsupported_ARG, ignorelocal_ARG, list_ARG, mergedconfig_ARG, metadataprofile_ARG,
-   sinceversion_ARG, showdeprecated_ARG, showunsupported_ARG, validate_ARG, withsummary_ARG,
-   withcomments_ARG, withspaces_ARG, unconfigured_ARG, withversions_ARG)
+   PERMITTED_READ_ONLY | NO_METADATA_PROCESSING)
 
 xx(lvmdiskscan,
    "List devices that may be used as physical volumes",
-   PERMITTED_READ_ONLY | ENABLE_ALL_DEVS,
-   "lvmdiskscan\n"
-   "\t[--commandprofile ProfileName]\n"
-   "\t[-d|--debug]\n"
-   "\t[-h|--help]\n"
-   "\t[-l|--lvmpartition]\n"
-   "\t[--readonly]\n"
-   "\t[--version]\n",
-
-   lvmpartition_ARG, readonly_ARG)
+   PERMITTED_READ_ONLY | ENABLE_ALL_DEVS)
 
 xx(lvmsadc,
    "Collect activity data",
-   0,
-   "lvmsadc\n"
-   "\t[--commandprofile ProfileName]\n"
-   "\t[-d|--debug]\n"
-   "\t[-h|--help]\n"
-   "\t[-v|--verbose]\n"
-   "\t[--version]\n"
-   "\t[LogFilePath]\n")
+   0)
 
 xx(lvmsar,
    "Create activity report",
-   0,
-   "lvmsar\n"
-   "\t[--commandprofile ProfileName]\n"
-   "\t[-d|--debug]\n"
-   "\t[-f|--full]\n"
-   "\t[-h|--help]\n"
-   "\t[-s|--stdin]\n"
-   "\t[-v|--verbose]\n"
-   "\t[--version]\n"
-   "\tLogFilePath\n",
-
-   full_ARG, stdin_ARG)
+   0)
 
 xx(lvreduce,
    "Reduce the size of a logical volume",
-   0,
-   "lvreduce\n"
-   "\t[-A|--autobackup y|n]\n"
-   "\t[--commandprofile ProfileName]\n"
-   "\t[-d|--debug]\n"
-   "\t[-f|--force]\n"
-   "\t[-h|--help]\n"
-   "\t{-l|--extents [-]LogicalExtentsNumber[%{VG|LV|FREE|ORIGIN}] |\n"
-   "\t -L|--size [-]LogicalVolumeSize[bBsSkKmMgGtTpPeE]}\n"
-   "\t[-n|--nofsck]\n"
-   "\t[--noudevsync]\n"
-   "\t[-r|--resizefs]\n"
-   "\t[--reportformat {basic|json}]\n"
-   "\t[-t|--test]\n"
-   "\t[-v|--verbose]\n"
-   "\t[--version]\n"
-   "\t[-y|--yes]\n"
-   "\tLogicalVolume[Path]\n",
-
-   autobackup_ARG, force_ARG,  extents_ARG, nofsck_ARG, noudevsync_ARG,
-   reportformat_ARG, resizefs_ARG, size_ARG, test_ARG)
+   0)
 
 xx(lvremove,
    "Remove logical volume(s) from the system",
-   ALL_VGS_IS_DEFAULT, /* all VGs only with --select */
-   "lvremove\n"
-   "\t[-A|--autobackup y|n]\n"
-   "\t[--commandprofile ProfileName]\n"
-   "\t[-d|--debug]\n"
-   "\t[-f|--force]\n"
-   "\t[-h|--help]\n"
-   "\t[--nohistory]\n"
-   "\t[--noudevsync]\n"
-   "\t[--reportformat {basic|json}]\n"
-   "\t[-S|--select Selection]\n"
-   "\t[-t|--test]\n"
-   "\t[-v|--verbose]\n"
-   "\t[--version]\n"
-   "\tLogicalVolume[Path] [LogicalVolume[Path]...]\n",
-
-   autobackup_ARG, force_ARG, nohistory_ARG, noudevsync_ARG,
-   reportformat_ARG, select_ARG, test_ARG)
+   ALL_VGS_IS_DEFAULT) /* all VGs only with --select */
 
 xx(lvrename,
    "Rename a logical volume",
-   0,
-   "lvrename\n"
-   "\t[-A|--autobackup {y|n}]\n"
-   "\t[--commandprofile ProfileName]\n"
-   "\t[-d|--debug]\n"
-   "\t[-h|-?|--help]\n"
-   "\t[--noudevsync]\n"
-   "\t[--reportformat {basic|json}]\n"
-   "\t[-t|--test]\n"
-   "\t[-v|--verbose]\n"
-   "\t[--version]\n"
-   "\t{ OldLogicalVolumePath NewLogicalVolumePath |\n"
-   "\t  VolumeGroupName OldLogicalVolumeName NewLogicalVolumeName }\n",
-
-   autobackup_ARG, noudevsync_ARG, reportformat_ARG, test_ARG)
+   0)
 
 xx(lvresize,
    "Resize a logical volume",
-   0,
-   "lvresize\n"
-   "\t[-A|--autobackup y|n]\n"
-   "\t[--alloc AllocationPolicy]\n"
-   "\t[--commandprofile ProfileName]\n"
-   "\t[-d|--debug]\n"
-   "\t[-f|--force]\n"
-   "\t[-h|--help]\n"
-   "\t[-i|--stripes Stripes [-I|--stripesize StripeSize]]\n"
-   "\t{-l|--extents [+|-]LogicalExtentsNumber[%{VG|LV|PVS|FREE|ORIGIN}] |\n"
-   "\t -L|--size [+|-]LogicalVolumeSize[bBsSkKmMgGtTpPeE]}\n"
-   "\t --poolmetadatasize [+]MetadataVolumeSize[bBsSkKmMgG]}\n"
-   "\t[-n|--nofsck]\n"
-   "\t[--noudevsync]\n"
-   "\t[--reportformat {basic|json}]\n"
-   "\t[-r|--resizefs]\n"
-   "\t[-t|--test]\n"
-   "\t[--type VolumeType]\n"
-   "\t[-v|--verbose]\n"
-   "\t[--version]\n"
-   "\tLogicalVolume[Path] [ PhysicalVolumePath... ]\n",
-
-   alloc_ARG, autobackup_ARG, extents_ARG, force_ARG, nofsck_ARG,
-   noudevsync_ARG, reportformat_ARG, resizefs_ARG,
-   poolmetadatasize_ARG, size_ARG, stripes_ARG, stripesize_ARG,
-   test_ARG, type_ARG)
+   0)
 
 xx(lvs,
    "Display information about logical volumes",
-   PERMITTED_READ_ONLY | ALL_VGS_IS_DEFAULT | LOCKD_VG_SH,
-   "lvs\n"
-   "\t[-a|--all]\n"
-   "\t[--aligned]\n"
-   "\t[--binary]\n"
-   "\t[--commandprofile ProfileName]\n"
-   "\t[--configreport ReportName]\n"
-   "\t[-d|--debug]\n"
-   "\t[--foreign]\n"
-   "\t[-h|--help]\n"
-   "\t[-H|--history]\n"
-   "\t[--ignorelockingfailure]\n"
-   "\t[--ignoreskippedcluster]\n"
-   "\t[--logonly]\n"
-   "\t[--nameprefixes]\n"
-   "\t[--noheadings]\n"
-   "\t[--nosuffix]\n"
-   "\t[-o|--options [+|-|#]Field[,Field]]\n"
-   "\t[-O|--sort [+|-]key1[,[+|-]key2[,...]]]\n"
-   "\t[-P|--partial]\n"
-   "\t[--readonly]\n"
-   "\t[--reportformat {basic|json}]\n"
-   "\t[--rows]\n"
-   "\t[--segments]\n"
-   "\t[-S|--select Selection]\n"
-   "\t[--separator Separator]\n"
-   "\t[--trustcache]\n"
-   "\t[--unbuffered]\n"
-   "\t[--units hHbBsSkKmMgGtTpPeE]\n"
-   "\t[--unquoted]\n"
-   "\t[-v|--verbose]\n"
-   "\t[--version]\n"
-   "\t[LogicalVolume[Path] [LogicalVolume[Path]...]]\n",
-
-   aligned_ARG, all_ARG, binary_ARG, configreport_ARG, foreign_ARG, history_ARG,
-   ignorelockingfailure_ARG, ignoreskippedcluster_ARG, logonly_ARG,
-   nameprefixes_ARG, noheadings_ARG, nolocking_ARG, nosuffix_ARG,
-   options_ARG, partial_ARG, readonly_ARG, reportformat_ARG, rows_ARG,
-   segments_ARG, select_ARG, separator_ARG, shared_ARG, sort_ARG,
-   trustcache_ARG, unbuffered_ARG, units_ARG, unquoted_ARG)
+   PERMITTED_READ_ONLY | ALL_VGS_IS_DEFAULT | LOCKD_VG_SH)
 
 xx(lvscan,
    "List all logical volumes in all volume groups",
-   PERMITTED_READ_ONLY | ALL_VGS_IS_DEFAULT | LOCKD_VG_SH | NO_LVMETAD_AUTOSCAN,
-   "lvscan\n"
-   "\t[-a|--all]\n"
-   "\t[-b|--blockdevice]\n"
-   "\t[--cache]\n"
-   "\t[--commandprofile ProfileName]\n"
-   "\t[-d|--debug]\n"
-   "\t[-h|-?|--help]\n"
-   "\t[--ignorelockingfailure]\n"
-   "\t[-P|--partial]\n"
-   "\t[--readonly]\n"
-   "\t[--reportformat {basic|json}]\n"
-   "\t[-v|--verbose]\n"
-   "\t[--version]\n",
-
-   all_ARG, blockdevice_ARG, ignorelockingfailure_ARG, partial_ARG,
-   readonly_ARG, reportformat_ARG, cache_long_ARG)
+   PERMITTED_READ_ONLY | ALL_VGS_IS_DEFAULT | LOCKD_VG_SH | NO_LVMETAD_AUTOSCAN)
 
 xx(pvchange,
    "Change attributes of physical volume(s)",
-   0,
-   "pvchange\n"
-   "\t[-a|--all]\n"
-   "\t[-A|--autobackup y|n]\n"
-   "\t[--commandprofile ProfileName]\n"
-   "\t[-d|--debug]\n"
-   "\t[-f|--force]\n"
-   "\t[-h|--help]\n"
-   "\t[--ignoreskippedcluster]\n"
-   "\t[--metadataignore y|n]\n"
-   "\t[--reportformat {basic|json}]\n"
-   "\t[-S|--select Selection]\n"
-   "\t[-t|--test]\n"
-   "\t[-u|--uuid]\n"
-   "\t[-x|--allocatable y|n]\n"
-   "\t[-v|--verbose]\n"
-   "\t[--addtag Tag]\n"
-   "\t[--deltag Tag]\n"
-   "\t[--version]\n"
-   "\t[PhysicalVolumePath...]\n",
-
-   all_ARG, allocatable_ARG, allocation_ARG, autobackup_ARG, deltag_ARG,
-   addtag_ARG, force_ARG, ignoreskippedcluster_ARG, metadataignore_ARG,
-   reportformat_ARG, select_ARG, test_ARG, uuid_ARG)
+   0)
 
 xx(pvresize,
    "Resize physical volume(s)",
-   0,
-   "pvresize\n"
-   "\t[--commandprofile ProfileName]\n"
-   "\t[-d|--debug]\n"
-   "\t[-h|-?|--help]\n"
-   "\t[--reportformat {basic|json}]\n"
-   "\t[--setphysicalvolumesize PhysicalVolumeSize[bBsSkKmMgGtTpPeE]\n"
-   "\t[-t|--test]\n"
-   "\t[-v|--verbose]\n"
-   "\t[--version]\n"
-   "\tPhysicalVolume [PhysicalVolume...]\n",
-
-   physicalvolumesize_ARG, reportformat_ARG, test_ARG)
+   0)
 
 xx(pvck,
    "Check the consistency of physical volume(s)",
-   LOCKD_VG_SH,
-   "pvck "
-   "\t[--commandprofile ProfileName]\n"
-   "\t[-d|--debug]\n"
-   "\t[-h|--help]\n"
-   "\t[--labelsector sector]\n"
-   "\t[-v|--verbose]\n"
-   "\t[--version]\n"
-   "\tPhysicalVolume [PhysicalVolume...]\n",
-
-   labelsector_ARG)
+   LOCKD_VG_SH)
 
 xx(pvcreate,
    "Initialize physical volume(s) for use by LVM",
-   ENABLE_ALL_DEVS,
-   "pvcreate\n"
-   "\t[--norestorefile]\n"
-   "\t[--restorefile file]\n"
-   "\t[--reportformat {basic|json}]\n"
-   "\t[--commandprofile ProfileName]\n"
-   "\t[-d|--debug]\n"
-   "\t[-f[f]|--force [--force]]\n"
-   "\t[-h|-?|--help]\n"
-   "\t[--labelsector sector]\n"
-   "\t[-M|--metadatatype 1|2]\n"
-   "\t[--pvmetadatacopies #copies]\n"
-   "\t[--bootloaderareasize BootLoaderAreaSize[bBsSkKmMgGtTpPeE]]\n"
-   "\t[--metadatasize MetadataSize[bBsSkKmMgGtTpPeE]]\n"
-   "\t[--dataalignment Alignment[bBsSkKmMgGtTpPeE]]\n"
-   "\t[--dataalignmentoffset AlignmentOffset[bBsSkKmMgGtTpPeE]]\n"
-   "\t[--setphysicalvolumesize PhysicalVolumeSize[bBsSkKmMgGtTpPeE]\n"
-   "\t[-t|--test]\n"
-   "\t[-u|--uuid uuid]\n"
-   "\t[-v|--verbose]\n"
-   "\t[-y|--yes]\n"
-   "\t[-Z|--zero {y|n}]\n"
-   "\t[--version]\n"
-   "\tPhysicalVolume [PhysicalVolume...]\n",
-
-   dataalignment_ARG, dataalignmentoffset_ARG, bootloaderareasize_ARG,
-   force_ARG, test_ARG, labelsector_ARG, metadatatype_ARG,
-   metadatacopies_ARG, metadatasize_ARG, metadataignore_ARG,
-   norestorefile_ARG, physicalvolumesize_ARG, pvmetadatacopies_ARG,
-   reportformat_ARG, restorefile_ARG, uuidstr_ARG, zero_ARG)
+   ENABLE_ALL_DEVS)
 
 xx(pvdata,
    "Display the on-disk metadata for physical volume(s)",
-   0,
-   "pvdata\n"
-   "\t[-a|--all]\n"
-   "\t[--commandprofile ProfileName]\n"
-   "\t[-d|--debug]\n"
-   "\t[-E|--physicalextent]\n"
-   "\t[-h|-?|--help]\n"
-   "\t[-L|--logicalvolume]\n"
-   "\t[-P[P]|--physicalvolume [--physicalvolume]]\n"
-   "\t[-U|--uuidlist]\n"
-   "\t[-v[v]|--verbose [--verbose]]\n"
-   "\t[-V|--volumegroup]\n"
-   "\t[--version]\n"
-   "\tPhysicalVolume [PhysicalVolume...]\n",
-
-   all_ARG,  logicalextent_ARG, physicalextent_ARG,
-   physicalvolume_ARG, uuidlist_ARG, volumegroup_ARG)
+   0)
 
 xx(pvdisplay,
    "Display various attributes of physical volume(s)",
-   CACHE_VGMETADATA | PERMITTED_READ_ONLY | ENABLE_ALL_DEVS | ENABLE_DUPLICATE_DEVS | LOCKD_VG_SH,
-   "pvdisplay\n"
-   "\t[-c|--colon]\n"
-   "\t[--commandprofile ProfileName]\n"
-   "\t[-d|--debug]\n"
-   "\t[--foreign]\n"
-   "\t[-h|--help]\n"
-   "\t[--ignorelockingfailure]\n"
-   "\t[--ignoreskippedcluster]\n"
-   "\t[-m|--maps]\n"
-   "\t[--nosuffix]\n"
-   "\t[--readonly]\n"
-   "\t[--reportformat {basic|json}]\n"
-   "\t[-S|--select Selection]\n"
-   "\t[-s|--short]\n"
-   "\t[--units hHbBsSkKmMgGtTpPeE]\n"
-   "\t[-v|--verbose]\n"
-   "\t[--version]\n"
-   "\t[PhysicalVolumePath [PhysicalVolumePath...]]\n"
-   "\n"
-   "pvdisplay --columns|-C\n"
-   "\t[--aligned]\n"
-   "\t[-a|--all]\n"
-   "\t[--binary]\n"
-   "\t[--commandprofile ProfileName]\n"
-   "\t[--configreport ReportName]\n"
-   "\t[-d|--debug]\n"
-   "\t[--foreign]\n"
-   "\t[-h|--help]\n"
-   "\t[--ignorelockingfailure]\n"
-   "\t[--ignoreskippedcluster]\n"
-   "\t[--logonly]\n"
-   "\t[--noheadings]\n"
-   "\t[--nosuffix]\n"
-   "\t[-o|--options [+|-|#]Field[,Field]]\n"
-   "\t[-O|--sort [+|-]key1[,[+|-]key2[,...]]]\n"
-   "\t[--reportformat {basic|json}]\n"
-   "\t[-S|--select Selection]\n"
-   "\t[--readonly]\n"
-   "\t[--separator Separator]\n"
-   "\t[--unbuffered]\n"
-   "\t[--units hHbBsSkKmMgGtTpPeE]\n"
-   "\t[-v|--verbose]\n"
-   "\t[--version]\n"
-   "\t[PhysicalVolumePath [PhysicalVolumePath...]]\n",
-
-   aligned_ARG, all_ARG, binary_ARG, colon_ARG, columns_ARG, configreport_ARG,
-   foreign_ARG, ignorelockingfailure_ARG, ignoreskippedcluster_ARG,
-   logonly_ARG, maps_ARG, noheadings_ARG, nosuffix_ARG, options_ARG,
-   readonly_ARG, reportformat_ARG, select_ARG, separator_ARG, shared_ARG,
-   short_ARG, sort_ARG, unbuffered_ARG, units_ARG)
+   CACHE_VGMETADATA | PERMITTED_READ_ONLY | ENABLE_ALL_DEVS | ENABLE_DUPLICATE_DEVS | LOCKD_VG_SH)
 
 /* ALL_VGS_IS_DEFAULT is for polldaemon to find pvmoves in-progress using process_each_vg. */
 
 xx(pvmove,
    "Move extents from one physical volume to another",
-   ALL_VGS_IS_DEFAULT | DISALLOW_TAG_ARGS,
-   "pvmove\n"
-   "\t[--abort]\n"
-   "\t[--alloc AllocationPolicy]\n"
-   "\t[--atomic]\n"
-   "\t[-A|--autobackup {y|n}]\n"
-   "\t[-b|--background]\n"
-   "\t[--commandprofile ProfileName]\n"
-   "\t[-d|--debug]\n "
-   "\t[-h|-?|--help]\n"
-   "\t[-i|--interval seconds]\n"
-   "\t[--noudevsync]\n"
-   "\t[--reportformat {basic|json}]\n"
-   "\t[-t|--test]\n "
-   "\t[-v|--verbose]\n "
-   "\t[--version]\n"
-   "\t[{-n|--name} LogicalVolume]\n"
-/* "\t[{-n|--name} LogicalVolume[:LogicalExtent[-LogicalExtent]...]]\n" */
-   "\tSourcePhysicalVolume[:PhysicalExtent[-PhysicalExtent]...]}\n"
-   "\t[DestinationPhysicalVolume[:PhysicalExtent[-PhysicalExtent]...]...]\n",
-
-   abort_ARG, alloc_ARG, atomic_ARG, autobackup_ARG, background_ARG,
-   interval_ARG, name_ARG, noudevsync_ARG, reportformat_ARG, test_ARG)
+   ALL_VGS_IS_DEFAULT | DISALLOW_TAG_ARGS)
 
 xx(lvpoll,
    "Continue already initiated poll operation on a logical volume",
-   0,
-   "\t[--abort]\n"
-   "\t[-A|--autobackup {y|n}]\n"
-   "\t[--commandprofile ProfileName]\n"
-   "\t[-d|--debug]\n "
-   "\t[-h|-?|--help]\n"
-   "\t[--handlemissingpvs]\n"
-   "\t[-i|--interval seconds]\n"
-   "\t[--polloperation]\n"
-   "\t[-t|--test]\n "
-   "\t[-v|--verbose]\n "
-   "\t[--version]\n",
-
-   abort_ARG, autobackup_ARG, handlemissingpvs_ARG, interval_ARG, polloperation_ARG,
-   test_ARG)
+   0)
 
 xx(pvremove,
    "Remove LVM label(s) from physical volume(s)",
-   ENABLE_ALL_DEVS,
-   "pvremove\n"
-   "\t[--commandprofile ProfileName]\n"
-   "\t[-d|--debug]\n"
-   "\t[-f[f]|--force [--force]]\n"
-   "\t[-h|-?|--help]\n"
-   "\t[--reportformat {basic|json}]\n"
-   "\t[-t|--test]\n"
-   "\t[-v|--verbose]\n"
-   "\t[--version]\n"
-   "\t[-y|--yes]\n"
-   "\tPhysicalVolume [PhysicalVolume...]\n",
-
-   force_ARG, reportformat_ARG, test_ARG)
+   ENABLE_ALL_DEVS)
 
 xx(pvs,
    "Display information about physical volumes",
-   CACHE_VGMETADATA | PERMITTED_READ_ONLY | ALL_VGS_IS_DEFAULT | ENABLE_ALL_DEVS | ENABLE_DUPLICATE_DEVS | LOCKD_VG_SH,
-   "pvs\n"
-   "\t[-a|--all]\n"
-   "\t[--aligned]\n"
-   "\t[--binary]\n"
-   "\t[--commandprofile ProfileName]\n"
-   "\t[--configreport ReportName]\n"
-   "\t[-d|--debug]\n"
-   "\t[--foreign]\n"
-   "\t[-h|-?|--help]\n"
-   "\t[--ignorelockingfailure]\n"
-   "\t[--ignoreskippedcluster]\n"
-   "\t[--logonly]\n"
-   "\t[--nameprefixes]\n"
-   "\t[--noheadings]\n"
-   "\t[--nosuffix]\n"
-   "\t[-o|--options [+|-|#]Field[,Field]]\n"
-   "\t[-O|--sort [+|-]key1[,[+|-]key2[,...]]]\n"
-   "\t[-P|--partial]\n"
-   "\t[--readonly]\n"
-   "\t[--reportformat {basic|json}]\n"
-   "\t[--rows]\n"
-   "\t[--segments]\n"
-   "\t[-S|--select Selection]\n"
-   "\t[--separator Separator]\n"
-   "\t[--trustcache]\n"
-   "\t[--unbuffered]\n"
-   "\t[--units hHbBsSkKmMgGtTpPeE]\n"
-   "\t[--unquoted]\n"
-   "\t[-v|--verbose]\n"
-   "\t[--version]\n"
-   "\t[PhysicalVolume [PhysicalVolume...]]\n",
-
-   aligned_ARG, all_ARG, binary_ARG, configreport_ARG, foreign_ARG,
-   ignorelockingfailure_ARG, ignoreskippedcluster_ARG, logonly_ARG,
-   nameprefixes_ARG, noheadings_ARG, nolocking_ARG, nosuffix_ARG,
-   options_ARG, partial_ARG, readonly_ARG, reportformat_ARG, rows_ARG,
-   segments_ARG, select_ARG, separator_ARG, shared_ARG, sort_ARG,
-   trustcache_ARG, unbuffered_ARG, units_ARG, unquoted_ARG)
+   CACHE_VGMETADATA | PERMITTED_READ_ONLY | ALL_VGS_IS_DEFAULT | ENABLE_ALL_DEVS | ENABLE_DUPLICATE_DEVS | LOCKD_VG_SH)
 
 xx(pvscan,
    "List all physical volumes",
-   PERMITTED_READ_ONLY | LOCKD_VG_SH | NO_LVMETAD_AUTOSCAN,
-   "pvscan\n"
-   "\t[-b|--background]\n"
-   "\t[--cache [-a|--activate ay] [ DevicePath | -j|--major major --minor minor]...]\n"
-   "\t[--commandprofile ProfileName]\n"
-   "\t[-d|--debug]\n"
-   "\t{-e|--exported | -n|--novolumegroup}\n"
-   "\t[-h|-?|--help]\n"
-   "\t[--ignorelockingfailure]\n"
-   "\t[-P|--partial]\n"
-   "\t[--readonly]\n"
-   "\t[--reportformat {basic|json}]\n"
-   "\t[-s|--short]\n"
-   "\t[-u|--uuid]\n"
-   "\t[-v|--verbose]\n"
-   "\t[--version]\n",
-
-   activate_ARG, available_ARG, backgroundfork_ARG, cache_long_ARG,
-   exported_ARG, ignorelockingfailure_ARG, major_ARG, minor_ARG,
-   novolumegroup_ARG, partial_ARG, readonly_ARG, reportformat_ARG,
-   short_ARG, uuid_ARG)
+   PERMITTED_READ_ONLY | LOCKD_VG_SH | NO_LVMETAD_AUTOSCAN)
 
 xx(segtypes,
    "List available segment types",
-   PERMITTED_READ_ONLY | NO_METADATA_PROCESSING,
-   "segtypes\n")
+   PERMITTED_READ_ONLY | NO_METADATA_PROCESSING)
 
 xx(systemid,
    "Display the system ID, if any, currently set on this host",
-   PERMITTED_READ_ONLY | NO_METADATA_PROCESSING,
-   "systemid\n")
+   PERMITTED_READ_ONLY | NO_METADATA_PROCESSING)
 
 xx(tags,
    "List tags defined on this host",
-   PERMITTED_READ_ONLY | NO_METADATA_PROCESSING,
-   "tags\n")
+   PERMITTED_READ_ONLY | NO_METADATA_PROCESSING)
 
 xx(vgcfgbackup,
    "Backup volume group configuration(s)",
-   PERMITTED_READ_ONLY | ALL_VGS_IS_DEFAULT | LOCKD_VG_SH,
-   "vgcfgbackup\n"
-   "\t[--commandprofile ProfileName]\n"
-   "\t[-d|--debug]\n"
-   "\t[-f|--file filename]\n"
-   "\t[--foreign]\n"
-   "\t[-h|-?|--help]\n"
-   "\t[--ignorelockingfailure]\n"
-   "\t[-P|--partial]\n"
-   "\t[--readonly]\n"
-   "\t[--reportformat {basic|json}]\n"
-   "\t[-v|--verbose]\n"
-   "\t[--version]\n"
-   "\t[VolumeGroupName...]\n",
-
-   file_ARG, foreign_ARG, ignorelockingfailure_ARG, partial_ARG, readonly_ARG,
-   reportformat_ARG)
+   PERMITTED_READ_ONLY | ALL_VGS_IS_DEFAULT | LOCKD_VG_SH)
 
 xx(vgcfgrestore,
    "Restore volume group configuration",
-   0,
-   "vgcfgrestore\n"
-   "\t[--commandprofile ProfileName]\n"
-   "\t[-d|--debug]\n"
-   "\t[-f|--file filename]\n"
-   "\t[--force]\n"
-   "\t[-l[l]|--list [--list]]\n"
-   "\t[-M|--metadatatype 1|2]\n"
-   "\t[-h|--help]\n"
-   "\t[-t|--test]\n"
-   "\t[-v|--verbose]\n"
-   "\t[--version]\n"
-   "\tVolumeGroupName",
-
-   file_ARG, force_long_ARG, list_ARG, metadatatype_ARG, test_ARG)
+   0)
 
 xx(vgchange,
    "Change volume group attributes",
-   CACHE_VGMETADATA | PERMITTED_READ_ONLY | ALL_VGS_IS_DEFAULT,
-   "vgchange\n"
-   "\t[-A|--autobackup {y|n}]\n"
-   "\t[--alloc AllocationPolicy]\n"
-   "\t[-P|--partial]\n"
-   "\t[--commandprofile ProfileName]\n"
-   "\t[-d|--debug]\n"
-   "\t[--detachprofile]\n"
-   "\t[-h|--help]\n"
-   "\t[--ignorelockingfailure]\n"
-   "\t[--ignoremonitoring]\n"
-   "\t[--ignoreskippedcluster]\n"
-   "\t[-K|--ignoreactivationskip]\n"
-   "\t[--metadataprofile ProfileName]\n"
-   "\t[--monitor {y|n}]\n"
-   "\t[--[vg]metadatacopies #copies]\n"
-   "\t[--poll {y|n}]\n"
-   "\t[--noudevsync]\n"
-   "\t[--refresh]\n"
-   "\t[--reportformat {basic|json}]\n"
-   "\t[-S|--select Selection]\n"
-   "\t[--sysinit]\n"
-   "\t[--systemid SystemID]\n"
-   "\t[-t|--test]\n"
-   "\t[-u|--uuid]\n"
-   "\t[-v|--verbose]\n"
-   "\t[--version]\n"
-   "\t{-a|--activate [a|e|l]{y|n}  |\n"
-   "\t[--activationmode {complete|degraded|partial}]\n"
-   "\t -c|--clustered {y|n} |\n"
-   "\t -x|--resizeable {y|n} |\n"
-   "\t -l|--logicalvolume MaxLogicalVolumes |\n"
-   "\t -p|--maxphysicalvolumes MaxPhysicalVolumes |\n"
-   "\t -s|--physicalextentsize PhysicalExtentSize[bBsSkKmMgGtTpPeE] |\n"
-   "\t --addtag Tag |\n"
-   "\t --deltag Tag}\n"
-   "\t[VolumeGroupName...]\n",
-
-   activationmode_ARG, addtag_ARG, alloc_ARG, allocation_ARG, autobackup_ARG,
-   activate_ARG, available_ARG, clustered_ARG, deltag_ARG, detachprofile_ARG,
-   ignoreactivationskip_ARG, ignorelockingfailure_ARG, ignoremonitoring_ARG,
-   ignoreskippedcluster_ARG, logicalvolume_ARG, maxphysicalvolumes_ARG,
-   metadataprofile_ARG, monitor_ARG, noudevsync_ARG, metadatacopies_ARG,
-   vgmetadatacopies_ARG, partial_ARG, physicalextentsize_ARG, poll_ARG,
-   refresh_ARG, reportformat_ARG, resizeable_ARG, resizable_ARG, select_ARG,
-   sysinit_ARG, systemid_ARG, test_ARG, uuid_ARG, lockstart_ARG, lockstop_ARG,
-   locktype_ARG, lockopt_ARG, force_ARG)
+   CACHE_VGMETADATA | PERMITTED_READ_ONLY | ALL_VGS_IS_DEFAULT)
 
 xx(vgck,
    "Check the consistency of volume group(s)",
-   ALL_VGS_IS_DEFAULT | LOCKD_VG_SH,
-   "vgck "
-   "\t[--commandprofile ProfileName]\n"
-   "\t[-d|--debug]\n"
-   "\t[-h|--help]\n"
-   "\t[--reportformat {basic|json}]\n"
-   "\t[-v|--verbose]\n"
-   "\t[--version]\n"
-   "\t[VolumeGroupName...]\n",
-
-   reportformat_ARG)
+   ALL_VGS_IS_DEFAULT | LOCKD_VG_SH)
 
 xx(vgconvert,
    "Change volume group metadata format",
-   0,
-   "vgconvert\n"
-   "\t[--commandprofile ProfileName]\n"
-   "\t[-d|--debug]\n"
-   "\t[-h|--help]\n"
-   "\t[--labelsector sector]\n"
-   "\t[-M|--metadatatype 1|2]\n"
-   "\t[--pvmetadatacopies #copies]\n"
-   "\t[--metadatasize MetadataSize[bBsSkKmMgGtTpPeE]]\n"
-   "\t[--bootloaderareasize BootLoaderAreaSize[bBsSkKmMgGtTpPeE]]\n"
-   "\t[--reportformat {basic|json}]\n"
-   "\t[-t|--test]\n"
-   "\t[-v|--verbose]\n"
-   "\t[--version]\n"
-   "\tVolumeGroupName [VolumeGroupName...]\n",
-
-   force_ARG, test_ARG, labelsector_ARG, bootloaderareasize_ARG,
-   metadatatype_ARG, metadatacopies_ARG, pvmetadatacopies_ARG,
-   metadatasize_ARG, reportformat_ARG)
+   0)
 
 xx(vgcreate,
    "Create a volume group",
-   MUST_USE_ALL_ARGS | ENABLE_ALL_DEVS,
-   "vgcreate\n"
-   "\t[-A|--autobackup {y|n}]\n"
-   "\t[--addtag Tag]\n"
-   "\t[--alloc AllocationPolicy]\n"
-   "\t[-c|--clustered {y|n}]\n"
-   "\t[--commandprofile ProfileName]\n"
-   "\t[-d|--debug]\n"
-   "\t[-h|--help]\n"
-   "\t[-l|--maxlogicalvolumes MaxLogicalVolumes]\n"
-   "\t[--metadataprofile ProfileName]\n"
-   "\t[-M|--metadatatype 1|2]\n"
-   "\t[--[vg]metadatacopies #copies]\n"
-   "\t[-p|--maxphysicalvolumes MaxPhysicalVolumes]\n"
-   "\t[--reportformat {basic|json}]\n"
-   "\t[-s|--physicalextentsize PhysicalExtentSize[bBsSkKmMgGtTpPeE]]\n"
-   "\t[--systemid SystemID]\n"
-   "\t[-t|--test]\n"
-   "\t[-v|--verbose]\n"
-   "\t[--version]\n"
-   "\t[-y|--yes]\n"
-   "\t[ PHYSICAL DEVICE OPTIONS ]\n"
-   "\tVolumeGroupName PhysicalDevicePath [PhysicalDevicePath...]\n",
-
-   addtag_ARG, alloc_ARG, autobackup_ARG, clustered_ARG, maxlogicalvolumes_ARG,
-   maxphysicalvolumes_ARG, metadataprofile_ARG, metadatatype_ARG,
-   physicalextentsize_ARG, test_ARG, force_ARG, zero_ARG, labelsector_ARG,
-   metadatasize_ARG, pvmetadatacopies_ARG, reportformat_ARG, metadatacopies_ARG,
-   vgmetadatacopies_ARG, dataalignment_ARG, dataalignmentoffset_ARG,
-   shared_ARG, systemid_ARG, locktype_ARG, lockopt_ARG)
+   MUST_USE_ALL_ARGS | ENABLE_ALL_DEVS)
 
 xx(vgdisplay,
    "Display volume group information",
-   PERMITTED_READ_ONLY | ALL_VGS_IS_DEFAULT | LOCKD_VG_SH,
-   "vgdisplay\n"
-   "\t[-A|--activevolumegroups]\n"
-   "\t[-c|--colon | -s|--short | -v|--verbose]\n"
-   "\t[--commandprofile ProfileName]\n"
-   "\t[-d|--debug]\n"
-   "\t[--foreign]\n"
-   "\t[-h|--help]\n"
-   "\t[--ignorelockingfailure]\n"
-   "\t[--ignoreskippedcluster]\n"
-   "\t[--nosuffix]\n"
-   "\t[-P|--partial]\n"
-   "\t[--readonly]\n"
-   "\t[--reportformat {basic|json}]\n"
-   "\t[-S|--select Selection]\n"
-   "\t[--units hHbBsSkKmMgGtTpPeE]\n"
-   "\t[--version]\n"
-   "\t[VolumeGroupName [VolumeGroupName...]]\n"
-   "\n"
-   "vgdisplay --columns|-C\n"
-   "\t[--aligned]\n"
-   "\t[--binary]\n"
-   "\t[--commandprofile ProfileName]\n"
-   "\t[--configreport ReportName]\n"
-   "\t[-d|--debug]\n"
-   "\t[--foreign]\n"
-   "\t[-h|--help]\n"
-   "\t[--ignorelockingfailure]\n"
-   "\t[--ignoreskippedcluster]\n"
-   "\t[--logonly]\n"
-   "\t[--noheadings]\n"
-   "\t[--nosuffix]\n"
-   "\t[-o|--options [+|-|#]Field[,Field]]\n"
-   "\t[-O|--sort [+|-]key1[,[+|-]key2[,...]]]\n"
-   "\t[-P|--partial]\n"
-   "\t[--reportformat {basic|json}]\n"
-   "\t[-S|--select Selection]\n"
-   "\t[--readonly]\n"
-   "\t[--separator Separator]\n"
-   "\t[--unbuffered]\n"
-   "\t[--units hHbBsSkKmMgGtTpPeE]\n"
-   "\t[--verbose]\n"
-   "\t[--version]\n"
-   "\t[VolumeGroupName [VolumeGroupName...]]\n",
-
-   activevolumegroups_ARG, aligned_ARG, binary_ARG, colon_ARG, columns_ARG,
-   configreport_ARG, foreign_ARG, ignorelockingfailure_ARG,
-   ignoreskippedcluster_ARG, logonly_ARG, noheadings_ARG, nosuffix_ARG,
-   options_ARG, partial_ARG, readonly_ARG, reportformat_ARG, select_ARG,
-   shared_ARG, short_ARG, separator_ARG, sort_ARG, unbuffered_ARG, units_ARG)
+   PERMITTED_READ_ONLY | ALL_VGS_IS_DEFAULT | LOCKD_VG_SH)
 
 xx(vgexport,
    "Unregister volume group(s) from the system",
-   ALL_VGS_IS_DEFAULT,
-   "vgexport\n"
-   "\t[-a|--all]\n"
-   "\t[--commandprofile ProfileName]\n"
-   "\t[-d|--debug]\n"
-   "\t[-h|--help]\n"
-   "\t[--reportformat {basic|json}]\n"
-   "\t[-S|--select Selection]\n"
-   "\t[-v|--verbose]\n"
-   "\t[--version]\n"
-   "\tVolumeGroupName [VolumeGroupName...]\n",
-
-   all_ARG, reportformat_ARG, select_ARG, test_ARG)
+   ALL_VGS_IS_DEFAULT)
 
 xx(vgextend,
    "Add physical volumes to a volume group",
-   MUST_USE_ALL_ARGS | ENABLE_ALL_DEVS,
-   "vgextend\n"
-   "\t[-A|--autobackup y|n]\n"
-   "\t[--restoremissing]\n"
-   "\t[--commandprofile ProfileName]\n"
-   "\t[-d|--debug]\n"
-   "\t[-f|--force]\n"
-   "\t[-h|--help]\n"
-   "\t[--reportformat {basic|json}]\n"
-   "\t[-t|--test]\n"
-   "\t[-v|--verbose]\n"
-   "\t[--version]\n"
-   "\t[-y|--yes]\n"
-   "\t[ PHYSICAL DEVICE OPTIONS ]\n"
-   "\tVolumeGroupName PhysicalDevicePath [PhysicalDevicePath...]\n",
-
-   autobackup_ARG, test_ARG,
-   force_ARG, zero_ARG, labelsector_ARG, metadatatype_ARG,
-   metadatasize_ARG, pvmetadatacopies_ARG, metadatacopies_ARG,
-   metadataignore_ARG, dataalignment_ARG, dataalignmentoffset_ARG,
-   reportformat_ARG, restoremissing_ARG)
+   MUST_USE_ALL_ARGS | ENABLE_ALL_DEVS)
 
 xx(vgimport,
    "Register exported volume group with system",
-   ALL_VGS_IS_DEFAULT | NO_LVMETAD_AUTOSCAN,
-   "vgimport\n"
-   "\t[-a|--all]\n"
-   "\t[--commandprofile ProfileName]\n"
-   "\t[-d|--debug]\n"
-   "\t[-f|--force]\n"
-   "\t[-h|--help]\n"
-   "\t[--reportformat {basic|json}]\n"
-   "\t[-S|--select Selection]\n"
-   "\t[-t|--test]\n"
-   "\t[-v|--verbose]\n"
-   "\t[--version]\n"
-   "\tVolumeGroupName...\n",
-
-   all_ARG, force_ARG, reportformat_ARG, select_ARG, test_ARG)
+   ALL_VGS_IS_DEFAULT | NO_LVMETAD_AUTOSCAN)
 
 xx(vgimportclone,
    "Import a VG from cloned PVs",
-   NO_LVMETAD_AUTOSCAN,
-   "vgimportclone\n"
-   "\t[-d|--debug]\n"
-   "\t[-h|--help]\n"
-   "\t[-i|--import]\n"
-   "\t[-n|--basevgname]\n"
-   "\t[-t|--test]\n"
-   "\t[-v|--verbose]\n"
-   "\t[--version]\n"
-   "\t[PhysicalVolumePath...]\n",
-
-   basevgname_ARG, test_ARG, import_ARG)
+   NO_LVMETAD_AUTOSCAN)
 
 xx(vgmerge,
    "Merge volume groups",
-   0,
-   "vgmerge\n"
-   "\t[-A|--autobackup y|n]\n"
-   "\t[--commandprofile ProfileName]\n"
-   "\t[-d|--debug]\n"
-   "\t[-h|--help]\n"
-   "\t[-l|--list]\n"
-   "\t[-t|--test]\n"
-   "\t[-v|--verbose]\n"
-   "\t[--version]\n"
-   "\tDestinationVolumeGroupName SourceVolumeGroupName\n",
-
-   autobackup_ARG, list_ARG, test_ARG)
+   0)
 
 xx(vgmknodes,
    "Create the special files for volume group devices in /dev",
-   ALL_VGS_IS_DEFAULT,
-   "vgmknodes\n"
-   "\t[--commandprofile ProfileName]\n"
-   "\t[-d|--debug]\n"
-   "\t[-h|--help]\n"
-   "\t[--ignorelockingfailure]\n"
-   "\t[--refresh]\n"
-   "\t[--reportformat {basic|json}]\n"
-   "\t[-v|--verbose]\n"
-   "\t[--version]\n"
-   "\t[VolumeGroupName...]\n",
-
-   ignorelockingfailure_ARG, refresh_ARG, reportformat_ARG)
+   ALL_VGS_IS_DEFAULT)
 
 xx(vgreduce,
    "Remove physical volume(s) from a volume group",
-   0,
-   "vgreduce\n"
-   "\t[-a|--all]\n"
-   "\t[-A|--autobackup y|n]\n"
-   "\t[--commandprofile ProfileName]\n"
-   "\t[-d|--debug]\n"
-   "\t[-h|--help]\n"
-   "\t[--mirrorsonly]\n"
-   "\t[--removemissing]\n"
-   "\t[--reportformat {basic|json}]\n"
-   "\t[-f|--force]\n"
-   "\t[-t|--test]\n"
-   "\t[-v|--verbose]\n"
-   "\t[--version]\n"
-   "\tVolumeGroupName\n"
-   "\t[PhysicalVolumePath...]\n",
-
-   all_ARG, autobackup_ARG, force_ARG, mirrorsonly_ARG, removemissing_ARG,
-   reportformat_ARG, test_ARG)
+   0)
 
 xx(vgremove,
    "Remove volume group(s)",
-   ALL_VGS_IS_DEFAULT, /* all VGs only with select */
-   "vgremove\n"
-   "\t[--commandprofile ProfileName]\n"
-   "\t[-d|--debug]\n"
-   "\t[-f|--force]\n"
-   "\t[-h|--help]\n"
-   "\t[--noudevsync]\n"
-   "\t[--reportformat {basic|json}]\n"
-   "\t[-S|--select Selection]\n"
-   "\t[-t|--test]\n"
-   "\t[-v|--verbose]\n"
-   "\t[--version]\n"
-   "\tVolumeGroupName [VolumeGroupName...]\n",
-
-   force_ARG, noudevsync_ARG, reportformat_ARG, select_ARG, test_ARG)
+   ALL_VGS_IS_DEFAULT) /* all VGs only with select */
 
 xx(vgrename,
    "Rename a volume group",
-   ALLOW_UUID_AS_NAME | REQUIRES_FULL_LABEL_SCAN,
-   "vgrename\n"
-   "\t[-A|--autobackup y|n]\n"
-   "\t[--commandprofile ProfileName]\n"
-   "\t[-d|--debug]\n"
-   "\t[-h|--help]\n"
-   "\t[--reportformat {basic|json}]\n"
-   "\t[-t|--test]\n"
-   "\t[-v|--verbose]\n"
-   "\t[--version]\n"
-   "\tOldVolumeGroupPath NewVolumeGroupPath |\n"
-   "\tOldVolumeGroupName NewVolumeGroupName\n",
-
-   autobackup_ARG, force_ARG, reportformat_ARG, test_ARG)
+   ALLOW_UUID_AS_NAME | REQUIRES_FULL_LABEL_SCAN)
 
 xx(vgs,
    "Display information about volume groups",
-   PERMITTED_READ_ONLY | ALL_VGS_IS_DEFAULT | LOCKD_VG_SH,
-   "vgs\n"
-   "\t[--aligned]\n"
-   "\t[--binary]\n"
-   "\t[-a|--all]\n"
-   "\t[--commandprofile ProfileName]\n"
-   "\t[--configreport ReportName]\n"
-   "\t[-d|--debug]\n"
-   "\t[--foreign]\n"
-   "\t[-h|--help]\n"
-   "\t[--ignorelockingfailure]\n"
-   "\t[--ignoreskippedcluster]\n"
-   "\t[--logonly]\n"
-   "\t[--nameprefixes]\n"
-   "\t[--noheadings]\n"
-   "\t[--nosuffix]\n"
-   "\t[-o|--options [+|-|#]Field[,Field]]\n"
-   "\t[-O|--sort [+|-]key1[,[+|-]key2[,...]]]\n"
-   "\t[-P|--partial]\n"
-   "\t[--readonly]\n"
-   "\t[--reportformat {basic|json}]\n"
-   "\t[--rows]\n"
-   "\t[-S|--select Selection]\n"
-   "\t[--separator Separator]\n"
-   "\t[--trustcache]\n"
-   "\t[--unbuffered]\n"
-   "\t[--units hHbBsSkKmMgGtTpPeE]\n"
-   "\t[--unquoted]\n"
-   "\t[-v|--verbose]\n"
-   "\t[--version]\n"
-   "\t[VolumeGroupName [VolumeGroupName...]]\n",
-
-   aligned_ARG, all_ARG, binary_ARG, configreport_ARG, foreign_ARG,
-   ignorelockingfailure_ARG, ignoreskippedcluster_ARG, logonly_ARG,
-   nameprefixes_ARG, noheadings_ARG, nolocking_ARG, nosuffix_ARG,
-   options_ARG, partial_ARG, readonly_ARG, reportformat_ARG, rows_ARG,
-   select_ARG, separator_ARG, shared_ARG, sort_ARG, trustcache_ARG,
-   unbuffered_ARG, units_ARG, unquoted_ARG)
+   PERMITTED_READ_ONLY | ALL_VGS_IS_DEFAULT | LOCKD_VG_SH)
 
 xx(vgscan,
    "Search for all volume groups",
-   PERMITTED_READ_ONLY | ALL_VGS_IS_DEFAULT | LOCKD_VG_SH | NO_LVMETAD_AUTOSCAN,
-   "vgscan "
-   "\t[--cache]\n"
-   "\t[--commandprofile ProfileName]\n"
-   "\t[-d|--debug]\n"
-   "\t[-h|--help]\n"
-   "\t[--ignorelockingfailure]\n"
-   "\t[--mknodes]\n"
-   "\t[--notifydbus]\n"
-   "\t[-P|--partial]\n"
-   "\t[--reportformat {basic|json}]\n"
-   "\t[-v|--verbose]\n"
-   "\t[--version]\n",
-
-   cache_long_ARG, ignorelockingfailure_ARG, mknodes_ARG, notifydbus_ARG,
-   partial_ARG, reportformat_ARG)
+   PERMITTED_READ_ONLY | ALL_VGS_IS_DEFAULT | LOCKD_VG_SH | NO_LVMETAD_AUTOSCAN)
 
 xx(vgsplit,
    "Move physical volumes into a new or existing volume group",
-   0,
-   "vgsplit\n"
-   "\t[-A|--autobackup {y|n}]\n"
-   "\t[--alloc AllocationPolicy]\n"
-   "\t[-c|--clustered {y|n}]\n"
-   "\t[--commandprofile ProfileName]\n"
-   "\t[-d|--debug]\n"
-   "\t[-h|--help]\n"
-   "\t[-l|--maxlogicalvolumes MaxLogicalVolumes]\n"
-   "\t[-M|--metadatatype 1|2]\n"
-   "\t[--[vg]metadatacopies #copies]\n"
-   "\t[-n|--name LogicalVolumeName]\n"
-   "\t[-p|--maxphysicalvolumes MaxPhysicalVolumes]\n"
-   "\t[-t|--test]\n"
-   "\t[-v|--verbose]\n"
-   "\t[--version]\n"
-   "\tSourceVolumeGroupName DestinationVolumeGroupName\n"
-   "\t[PhysicalVolumePath...]\n",
-
-   alloc_ARG, autobackup_ARG, clustered_ARG,
-   maxlogicalvolumes_ARG, maxphysicalvolumes_ARG,
-   metadatatype_ARG, vgmetadatacopies_ARG, name_ARG, test_ARG)
+   0)
 
 xx(version,
    "Display software and driver version information",
-   PERMITTED_READ_ONLY | NO_METADATA_PROCESSING,
-   "version\n")
+   PERMITTED_READ_ONLY | NO_METADATA_PROCESSING)
diff --git a/tools/create-commands.c b/tools/create-commands.c
new file mode 100644
index 0000000..704ec47
--- /dev/null
+++ b/tools/create-commands.c
@@ -0,0 +1,2990 @@
+#include <asm/types.h>
+#include <sys/types.h>
+#include <sys/ioctl.h>
+#include <sys/stat.h>
+#include <sys/time.h>
+#include <sys/wait.h>
+#include <stdio.h>
+#include <errno.h>
+#include <string.h>
+#include <stdlib.h>
+#include <stddef.h>
+#include <stdint.h>
+#include <stdarg.h>
+#include <limits.h>
+#include <unistd.h>
+#include <syslog.h>
+#include <sched.h>
+#include <dirent.h>
+#include <ctype.h>
+#include <getopt.h>
+
+/* needed to include args.h */
+#define ARG_COUNTABLE 0x00000001
+#define ARG_GROUPABLE 0x00000002
+struct cmd_context;
+struct arg_values;
+
+int yes_no_arg(struct cmd_context *cmd, struct arg_values *av) { return 0; }
+int activation_arg(struct cmd_context *cmd, struct arg_values *av) { return 0; }
+int cachemode_arg(struct cmd_context *cmd, struct arg_values *av) { return 0; }
+int discards_arg(struct cmd_context *cmd, struct arg_values *av) { return 0; }
+int mirrorlog_arg(struct cmd_context *cmd, struct arg_values *av) { return 0; }
+int size_kb_arg(struct cmd_context *cmd, struct arg_values *av) { return 0; }
+int size_mb_arg(struct cmd_context *cmd, struct arg_values *av) { return 0; }
+int size_mb_arg_with_percent(struct cmd_context *cmd, struct arg_values *av) { return 0; }
+int int_arg(struct cmd_context *cmd, struct arg_values *av) { return 0; }
+int int_arg_with_sign(struct cmd_context *cmd, struct arg_values *av) { return 0; }
+int int_arg_with_sign_and_percent(struct cmd_context *cmd, struct arg_values *av) { return 0; }
+int major_arg(struct cmd_context *cmd, struct arg_values *av) { return 0; }
+int minor_arg(struct cmd_context *cmd, struct arg_values *av) { return 0; }
+int string_arg(struct cmd_context *cmd, struct arg_values *av) { return 0; }
+int tag_arg(struct cmd_context *cmd, struct arg_values *av) { return 0; }
+int permission_arg(struct cmd_context *cmd, struct arg_values *av) { return 0; }
+int metadatatype_arg(struct cmd_context *cmd, struct arg_values *av) { return 0; }
+int units_arg(struct cmd_context *cmd, struct arg_values *av) { return 0; }
+int segtype_arg(struct cmd_context *cmd, struct arg_values *av) { return 0; }
+int alloc_arg(struct cmd_context *cmd, struct arg_values *av) { return 0; }
+int locktype_arg(struct cmd_context *cmd, struct arg_values *av) { return 0; }
+int readahead_arg(struct cmd_context *cmd, struct arg_values *av) { return 0; }
+int vgmetadatacopies_arg(struct cmd_context *cmd __attribute__((unused)), struct arg_values *av) { return 0; }
+int pvmetadatacopies_arg(struct cmd_context *cmd __attribute__((unused)), struct arg_values *av) { return 0; }
+int metadatacopies_arg(struct cmd_context *cmd __attribute__((unused)), struct arg_values *av) { return 0; }
+int polloperation_arg(struct cmd_context *cmd __attribute__((unused)), struct arg_values *av) { return 0; }
+int writemostly_arg(struct cmd_context *cmd __attribute__((unused)), struct arg_values *av) { return 0; }
+int syncaction_arg(struct cmd_context *cmd __attribute__((unused)), struct arg_values *av) { return 0; }
+int reportformat_arg(struct cmd_context *cmd __attribute__((unused)), struct arg_values *av) { return 0; }
+int configreport_arg(struct cmd_context *cmd __attribute__((unused)), struct arg_values *av) { return 0; }
+int configtype_arg(struct cmd_context *cmd __attribute__((unused)), struct arg_values *av) { return 0; }
+
+/* also see arg_props in tools.h and args.h */
+struct opt_name {
+	const char *name;       /* "foo_ARG" */
+	int opt_enum;           /* foo_ARG */
+	const char short_opt;   /* -f */
+	char _padding[7];
+	const char *long_opt;   /* --foo */
+	int val_enum;           /* xyz_VAL when --foo takes a val like "--foo xyz" */
+	uint32_t unused1;
+	uint32_t unused2;
+};
+
+/* also see val_props in tools.h and vals.h */
+struct val_name {
+	const char *enum_name;  /* "foo_VAL" */
+	int val_enum;           /* foo_VAL */
+	int (*fn) (struct cmd_context *cmd, struct arg_values *av); /* foo_arg() */
+	const char *name;       /* FooVal */
+	const char *usage;
+};
+
+/* also see lv_props in tools.h and lv_props.h */
+struct lvp_name {
+	const char *enum_name; /* "is_foo_LVP" */
+	int lvp_enum;          /* is_foo_LVP */
+	const char *name;      /* "lv_is_foo" */
+};
+
+/* also see lv_types in tools.h and lv_types.h */
+struct lvt_name {
+	const char *enum_name; /* "foo_LVT" */
+	int lvt_enum;          /* foo_LVT */
+	const char *name;      /* "foo" */
+};
+
+/* create foo_VAL enums for option and position values */
+
+enum {
+#define val(a, b, c, d) a ,
+#include "vals.h"
+#undef val
+};
+
+/* create foo_ARG enums for --option's */
+
+enum {
+#define arg(a, b, c, d, e, f) a ,
+#include "args.h"
+#undef arg
+};
+
+/* create foo_LVP enums for LV properties */
+
+enum {
+#define lvp(a, b, c) a,
+#include "lv_props.h"
+#undef lvp
+};
+
+/* create foo_LVT enums for LV types */
+
+enum {
+#define lvt(a, b, c) a,
+#include "lv_types.h"
+#undef lvt
+};
+
+/* create table of value names, e.g. String, and corresponding enum from vals.h */
+
+static struct val_name val_names[VAL_COUNT + 1] = {
+#define val(a, b, c, d) { # a, a, b, c, d },
+#include "vals.h"
+#undef val
+};
+
+/* create table of option names, e.g. --foo, and corresponding enum from args.h */
+
+static struct opt_name opt_names[ARG_COUNT + 1] = {
+#define arg(a, b, c, d, e, f) { # a, a, b, "", "--" c, d, e, f },
+#include "args.h"
+#undef arg
+};
+
+/* create table of lv property names, e.g. lv_is_foo, and corresponding enum from lv_props.h */
+
+static struct lvp_name lvp_names[LVP_COUNT + 1] = {
+#define lvp(a, b, c) { # a, a, b },
+#include "lv_props.h"
+#undef lvp
+};
+
+/* create table of lv type names, e.g. linear and corresponding enum from lv_types.h */
+
+static struct lvt_name lvt_names[LVT_COUNT + 1] = {
+#define lvt(a, b, c) { # a, a, b },
+#include "lv_types.h"
+#undef lvt
+};
+
+#include "command.h"
+
+#define MAX_CMD_NAMES 128
+struct cmd_name {
+	const char *name;
+	const char *desc;
+	int common_options[ARG_COUNT + 1];
+	int all_options[ARG_COUNT + 1];
+	int variants;
+	int variant_has_ro;
+	int variant_has_rp;
+	int variant_has_oo;
+	int variant_has_op;
+};
+
+/* create table of command names, e.g. vgcreate */
+
+static struct cmd_name cmd_names[MAX_CMD_NAMES] = {
+#define xx(a, b, c) { # a , b } ,
+#include "commands.h"
+#undef xx
+};
+
+#define MAX_LINE 1024
+#define MAX_LINE_ARGC 256
+
+#define REQUIRED 1  /* required option */
+#define OPTIONAL 0  /* optional option */
+#define IGNORE -1   /* ignore option */
+
+struct oo_line {
+	char *name;
+	char *line;
+};
+
+#define MAX_CMDS 256
+int cmd_count;
+struct command cmd_array[MAX_CMDS];
+
+struct command lvm_all; /* for printing common options for all lvm commands */
+
+#define MAX_OO_LINES 256
+int oo_line_count;
+struct oo_line oo_lines[MAX_OO_LINES];
+
+static int include_man_secondary = 1;
+static int include_man_primary = 1;
+static char *man_command_name = NULL;
+
+static void add_optional_opt_line(struct command *cmd, int argc, char *argv[]);
+
+/*
+ * modifies buf, replacing the sep characters with \0
+ * argv pointers point to positions in buf
+ */
+
+static char *split_line(char *buf, int *argc, char **argv, char sep)
+{
+	char *p = buf, *rp = NULL;
+	int i;
+
+	argv[0] = p;
+
+	for (i = 1; i < MAX_LINE_ARGC; i++) {
+		p = strchr(buf, sep);
+		if (!p)
+			break;
+		*p = '\0';
+
+		argv[i] = p + 1;
+		buf = p + 1;
+	}
+	*argc = i;
+
+	/* we ended by hitting \0, return the point following that */
+	if (!rp)
+		rp = strchr(buf, '\0') + 1;
+
+	return rp;
+}
+
+/* convert value string, e.g. Number, to foo_VAL enum */
+
+static int val_str_to_num(char *str)
+{
+	char name[32] = { 0 };
+	char *new;
+	int i;
+
+	/* compare the name before any suffix like _new or _<lvtype> */
+
+	strncpy(name, str, 31);
+	if ((new = strstr(name, "_")))
+		*new = '\0';
+
+	for (i = 0; i < VAL_COUNT; i++) {
+		if (!val_names[i].name)
+			break;
+		if (!strncmp(name, val_names[i].name, strlen(val_names[i].name)))
+			return val_names[i].val_enum;
+	}
+
+	return 0;
+}
+
+/* convert "--option" to foo_ARG enum */
+
+static int opt_str_to_num(char *str)
+{
+	char long_name[32];
+	char *p;
+	int i;
+
+	/*
+	 * --foo_long means there are two args entries
+	 * for --foo, one with a short option and one
+	 * without, and we want the one without the
+	 * short option.
+	 */
+	if (strstr(str, "_long")) {
+		strcpy(long_name, str);
+		p = strstr(long_name, "_long");
+		*p = '\0';
+
+		for (i = 0; i < ARG_COUNT; i++) {
+			if (!opt_names[i].long_opt)
+				continue;
+			/* skip anything with a short opt */
+			if (opt_names[i].short_opt)
+				continue;
+			if (!strcmp(opt_names[i].long_opt, long_name))
+				return opt_names[i].opt_enum;
+		}
+
+		printf("Unknown opt str: %s %s\n", str, long_name);
+		exit(1);
+	}
+
+	for (i = 0; i < ARG_COUNT; i++) {
+		if (!opt_names[i].long_opt)
+			continue;
+		/* These are only selected using --foo_long */
+		if (strstr(opt_names[i].name, "_long_ARG"))
+			continue;
+		if (!strcmp(opt_names[i].long_opt, str))
+			return opt_names[i].opt_enum;
+	}
+
+	printf("Unknown opt str: \"%s\"\n", str);
+	exit(1);
+}
+
+static char *val_bits_to_str(uint64_t val_bits)
+{
+	static char buf[1024];
+	int i;
+	int or = 0;
+
+	memset(buf, 0, sizeof(buf));
+
+	for (i = 0; i < VAL_COUNT; i++) {
+		if (val_bits & val_enum_to_bit(i)) {
+			if (or) strcat(buf, " | ");
+			strcat(buf, "val_enum_to_bit(");
+			strcat(buf, val_names[i].enum_name);
+			strcat(buf, ")");
+			or = 1;
+		}
+	}
+
+	return buf;
+}
+
+/*
+ * When bits for foo_LVP and bar_LVP are both set in bits, print:
+ * lvp_enum_to_bit(foo_LVP) | lvp_enum_to_bit(bar_LVP)
+ */
+
+static char *lvp_bits_to_str(uint64_t bits)
+{
+	static char lvp_buf[1024];
+	int i;
+	int or = 0;
+
+	memset(lvp_buf, 0, sizeof(lvp_buf));
+
+	for (i = 0; i < LVP_COUNT; i++) {
+		if (bits & lvp_enum_to_bit(i)) {
+			if (or) strcat(lvp_buf, " | ");
+			strcat(lvp_buf, "lvp_enum_to_bit(");
+			strcat(lvp_buf, lvp_names[i].enum_name);
+			strcat(lvp_buf, ")");
+			or = 1;
+		}
+	}
+
+	return lvp_buf;
+}
+
+/*
+ * When bits for foo_LVT and bar_LVT are both set in bits, print:
+ * lvt_enum_to_bit(foo_LVT) | lvt_enum_to_bit(bar_LVT)
+ */
+
+static char *lvt_bits_to_str(uint64_t bits)
+{
+	static char lvt_buf[1024];
+	int i;
+	int or = 0;
+
+	memset(lvt_buf, 0, sizeof(lvt_buf));
+
+	for (i = 1; i < LVT_COUNT; i++) {
+		if (bits & lvt_enum_to_bit(i)) {
+			if (or) strcat(lvt_buf, " | ");
+			strcat(lvt_buf, "lvt_enum_to_bit(");
+			strcat(lvt_buf, lvt_names[i].enum_name);
+			strcat(lvt_buf, ")");
+			or = 1;
+		}
+	}
+
+	return lvt_buf;
+}
+
+/* "lv_is_prop" to is_prop_LVP */
+
+static int lvp_name_to_enum(char *str)
+{
+	int i;
+
+	for (i = 1; i < LVP_COUNT; i++) {
+		if (!strcmp(str, lvp_names[i].name))
+			return lvp_names[i].lvp_enum;
+	}
+	printf("unknown lv property %s\n", str);
+	exit(1);
+}
+
+/* type_LVT to "type" */
+
+static const char *lvt_enum_to_name(int lvt_enum)
+{
+	return lvt_names[lvt_enum].name;
+}
+
+/* "type" to type_LVT */
+
+static int lvt_name_to_enum(char *str)
+{
+	int i;
+
+	for (i = 1; i < LVT_COUNT; i++) {
+		if (!strcmp(str, lvt_names[i].name))
+			return lvt_names[i].lvt_enum;
+	}
+	printf("unknown lv type %s\n", str);
+	exit(1);
+}
+
+/* LV_<type> to <type>_LVT */
+
+int lv_to_enum(char *name)
+{
+	return lvt_name_to_enum(name + 3);
+}
+
+/*
+ * LV_<type1>_<type2> to lvt_bits
+ *
+ * type1 to lvt_enum
+ * lvt_bits |= lvt_enum_to_bit(lvt_enum)
+ * type2 to lvt_enum
+ * lvt_bits |= lvt_enum_to_bit(lvt_enum)
+ */
+
+uint64_t lv_to_bits(char *name)
+{
+	char buf[64];
+	char *argv[MAX_LINE_ARGC];
+	uint64_t lvt_bits = 0;
+	int lvt_enum;
+	int argc;
+	int i;
+
+	strcpy(buf, name);
+
+	split_line(buf, &argc, argv, '_');
+
+	/* 0 is "LV" */
+	for (i = 1; i < argc; i++) {
+		if (!strcmp(argv[i], "new"))
+			continue;
+		lvt_enum = lvt_name_to_enum(argv[i]);
+		lvt_bits |= lvt_enum_to_bit(lvt_enum);
+	}
+
+	return lvt_bits;
+}
+
+static const char *is_command_name(char *str)
+{
+	int i;
+
+	for (i = 0; i < MAX_CMD_NAMES; i++) {
+		if (!cmd_names[i].name)
+			break;
+		if (!strcmp(cmd_names[i].name, str))
+			return cmd_names[i].name;
+	}
+	return NULL;
+}
+
+static const char *cmd_name_desc(const char *name)
+{
+	int i;
+
+	for (i = 0; i < MAX_CMD_NAMES; i++) {
+		if (!cmd_names[i].name)
+			break;
+		if (!strcmp(cmd_names[i].name, name))
+			return cmd_names[i].desc;
+	}
+	return NULL;
+}
+
+static struct cmd_name *find_command_name(const char *str)
+{
+	int i;
+
+	for (i = 0; i < MAX_CMD_NAMES; i++) {
+		if (!cmd_names[i].name)
+			break;
+		if (!strcmp(cmd_names[i].name, str))
+			return &cmd_names[i];
+	}
+	return NULL;
+}
+
+static int is_opt_name(char *str)
+{
+	if (!strncmp(str, "--", 2))
+		return 1;
+
+	if ((str[0] == '-') && (str[1] != '-')) {
+		printf("Options must be specified in long form: %s\n", str);
+		exit(1);
+	}
+
+	return 0;
+}
+
+/*
+ * "Select" as a pos name means that the position
+ * can be empty if the --select option is used.
+ */
+
+static int is_pos_name(char *str)
+{
+	if (!strncmp(str, "VG", 2))
+		return 1;
+	if (!strncmp(str, "LV", 2))
+		return 1;
+	if (!strncmp(str, "PV", 2))
+		return 1;
+	if (!strncmp(str, "Tag", 3))
+		return 1;
+	if (!strncmp(str, "String", 6))
+		return 1;
+	if (!strncmp(str, "Select", 6))
+		return 1;
+	return 0;
+}
+
+static int is_oo_definition(char *str)
+{
+	if (!strncmp(str, "OO_", 3) && strstr(str, ":"))
+		return 1;
+	return 0;
+}
+
+static int is_oo_line(char *str)
+{
+	if (!strncmp(str, "OO:", 3))
+		return 1;
+	return 0;
+}
+
+static int is_io_line(char *str)
+{
+	if (!strncmp(str, "IO:", 3))
+		return 1;
+	return 0;
+}
+
+static int is_op_line(char *str)
+{
+	if (!strncmp(str, "OP:", 3))
+		return 1;
+	return 0;
+}
+
+static int is_desc_line(char *str)
+{
+	if (!strncmp(str, "DESC:", 5))
+		return 1;
+	return 0;
+}
+
+static int is_flags_line(char *str)
+{
+	if (!strncmp(str, "FLAGS:", 6))
+		return 1;
+	return 0;
+}
+
+static int is_rule_line(char *str)
+{
+	if (!strncmp(str, "RULE:", 5))
+		return 1;
+	return 0;
+}
+
+static int is_id_line(char *str)
+{
+	if (!strncmp(str, "ID:", 3))
+		return 1;
+	return 0;
+}
+
+/*
+ * parse str for anything that can appear in a position,
+ * like VG, VG|LV, VG|LV_linear|LV_striped, etc
+ */
+
+static void set_pos_def(struct command *cmd, char *str, struct arg_def *def)
+{
+	char *argv[MAX_LINE_ARGC];
+	int argc;
+	char *name;
+	int val_enum;
+	int i;
+
+	split_line(str, &argc, argv, '|');
+
+	for (i = 0; i < argc; i++) {
+		name = argv[i];
+
+		val_enum = val_str_to_num(name);
+
+		if (!val_enum) {
+			printf("Unknown pos arg: %s\n", name);
+			exit(1);
+		}
+
+		def->val_bits |= val_enum_to_bit(val_enum);
+
+		if ((val_enum == lv_VAL) && strstr(name, "_"))
+			def->lvt_bits = lv_to_bits(name);
+
+		if (strstr(name, "_new")) {
+			if (val_enum == lv_VAL)
+				def->flags |= ARG_DEF_FLAG_NEW_LV;
+			else if (val_enum == vg_VAL)
+				def->flags |= ARG_DEF_FLAG_NEW_VG;
+		}
+	}
+}
+
+/*
+ * parse str for anything that can follow --option
+ */
+
+static void set_opt_def(struct command *cmd, char *str, struct arg_def *def)
+{
+	char *argv[MAX_LINE_ARGC];
+	int argc;
+	char *name;
+	int val_enum;
+	int i, j;
+
+	split_line(str, &argc, argv, '|');
+
+	for (i = 0; i < argc; i++) {
+		name = argv[i];
+
+		val_enum = val_str_to_num(name);
+
+		if (!val_enum) {
+			/* a literal number or string */
+
+			if (isdigit(name[0]))
+				val_enum = constnum_VAL;
+
+			else if (isalpha(name[0]))
+				val_enum = conststr_VAL;
+
+			else {
+				printf("Unknown opt arg: %s\n", name);
+				exit(0);
+			}
+		}
+
+
+		def->val_bits |= val_enum_to_bit(val_enum);
+
+		if (val_enum == constnum_VAL)
+			def->num = (uint64_t)atoi(name);
+
+		if (val_enum == conststr_VAL)
+			def->str = strdup(name);
+
+		if (val_enum == lv_VAL) {
+			if (strstr(name, "_"))
+				def->lvt_bits = lv_to_bits(name);
+		}
+
+		if (strstr(name, "_new")) {
+			if (val_enum == lv_VAL)
+				def->flags |= ARG_DEF_FLAG_NEW_LV;
+			else if (val_enum == vg_VAL)
+				def->flags |= ARG_DEF_FLAG_NEW_VG;
+				
+		}
+	}
+}
+
+
+/*
+ * OO_FOO: --opt1 ...
+ *
+ * oo->name = "OO_FOO";
+ * oo->line = "--opt1 ...";
+ */
+
+static void add_oo_definition_line(const char *name, const char *line)
+{
+	struct oo_line *oo;
+	char *colon;
+	char *start;
+
+	oo = &oo_lines[oo_line_count++];
+	oo->name = strdup(name);
+
+	if ((colon = strstr(oo->name, ":")))
+		*colon = '\0';
+	else {
+		printf("invalid OO definition\n");
+		exit(1);
+	}
+
+	start = strstr(line, ":") + 2;
+	oo->line = strdup(start);
+}
+
+/* when OO_FOO: continues on multiple lines */
+
+static void append_oo_definition_line(const char *new_line)
+{
+	struct oo_line *oo;
+	char *old_line;
+	char *line;
+	int len;
+
+	oo = &oo_lines[oo_line_count-1];
+
+	old_line = oo->line;
+
+	/* +2 = 1 space between old and new + 1 terminating \0 */
+	len = strlen(old_line) + strlen(new_line) + 2;
+	line = malloc(len);
+	memset(line, 0, len);
+
+	strcat(line, old_line);
+	strcat(line, " ");
+	strcat(line, new_line);
+
+	free(oo->line);
+	oo->line = line;
+}
+
+char *get_oo_line(char *str)
+{
+	char *name;
+	char *end;
+	char str2[64];
+	int i;
+
+	strcpy(str2, str);
+	if ((end = strstr(str2, ":")))
+		*end = '\0';
+	if ((end = strstr(str2, ",")))
+		*end = '\0';
+
+	for (i = 0; i < oo_line_count; i++) {
+		name = oo_lines[i].name;
+		if (!strcmp(name, str2))
+			return oo_lines[i].line;
+	}
+	return NULL;
+}
+
+/* add optional_opt_args entries when OO_FOO appears on OO: line */
+
+static void include_optional_opt_args(struct command *cmd, char *str)
+{
+	char *oo_line;
+	char *line;
+	char *line_argv[MAX_LINE_ARGC];
+	int line_argc;
+
+	if (!(oo_line = get_oo_line(str))) {
+		printf("No OO line found for %s\n", str);
+		exit(1);
+	}
+
+	if (!(line = strdup(oo_line)))
+		exit(1); 
+
+	split_line(line, &line_argc, line_argv, ' ');
+	add_optional_opt_line(cmd, line_argc, line_argv);
+	free(line);
+}
+
+static void add_opt_arg(struct command *cmd, char *str, int *takes_arg, int required)
+{
+	char *comma;
+	int opt;
+
+	/* opt_arg.opt set here */
+	/* opt_arg.def will be set in update_prev_opt_arg() if needed */
+
+	if ((comma = strstr(str, ",")))
+		*comma = '\0';
+
+	/*
+	 * Work around nasty hack where --uuid is used for both uuid_ARG
+	 * and uuidstr_ARG.  The input uses --uuidstr, where an actual
+	 * command uses --uuid string.
+	 */
+	if (!strcmp(str, "--uuidstr")) {
+		opt = uuidstr_ARG;
+		goto skip;
+	}
+
+	opt = opt_str_to_num(str);
+skip:
+	if (required > 0)
+		cmd->required_opt_args[cmd->ro_count++].opt = opt;
+	else if (!required)
+		cmd->optional_opt_args[cmd->oo_count++].opt = opt;
+	else if (required < 0)
+		cmd->ignore_opt_args[cmd->io_count++].opt = opt;
+	else
+		exit(1);
+
+	*takes_arg = opt_names[opt].val_enum ? 1 : 0;
+}
+
+static void update_prev_opt_arg(struct command *cmd, char *str, int required)
+{
+	struct arg_def def = { 0 };
+	char *comma;
+
+	if (str[0] == '-') {
+		printf("Option %s must be followed by an arg.\n", str);
+		exit(1);
+	}
+
+	/* opt_arg.def set here */
+	/* opt_arg.opt was previously set in add_opt_arg() when --foo was read */
+
+	if ((comma = strstr(str, ",")))
+		*comma = '\0';
+
+	set_opt_def(cmd, str, &def);
+
+	if (required > 0)
+		cmd->required_opt_args[cmd->ro_count-1].def = def;
+	else if (!required)
+		cmd->optional_opt_args[cmd->oo_count-1].def = def;
+	else if (required < 0)
+		cmd->ignore_opt_args[cmd->io_count-1].def = def;
+	else
+		exit(1);
+}
+
+static void add_pos_arg(struct command *cmd, char *str, int required)
+{
+	struct arg_def def = { 0 };
+
+	/* pos_arg.pos and pos_arg.def are set here */
+
+	set_pos_def(cmd, str, &def);
+
+	if (required) {
+		cmd->required_pos_args[cmd->rp_count].pos = cmd->pos_count++;
+		cmd->required_pos_args[cmd->rp_count].def = def;
+		cmd->rp_count++;
+	} else {
+		cmd->optional_pos_args[cmd->op_count].pos = cmd->pos_count++;;
+		cmd->optional_pos_args[cmd->op_count].def = def;
+		cmd->op_count++;
+	}
+}
+
+/* process something that follows a pos arg, which is not a new pos arg */
+
+static void update_prev_pos_arg(struct command *cmd, char *str, int required)
+{
+	struct arg_def *def;
+
+	/* a previous pos_arg.def is modified here */
+
+	if (required)
+		def = &cmd->required_pos_args[cmd->rp_count-1].def;
+	else
+		def = &cmd->optional_pos_args[cmd->op_count-1].def;
+
+	if (!strcmp(str, "..."))
+		def->flags |= ARG_DEF_FLAG_MAY_REPEAT;
+	else {
+		printf("Unknown pos arg: %s\n", str);
+		exit(1);
+	}
+}
+
+/* process what follows OO:, which are optional opt args */
+
+static void add_optional_opt_line(struct command *cmd, int argc, char *argv[])
+{
+	int takes_arg;
+	int i;
+
+	for (i = 0; i < argc; i++) {
+		if (!i && !strncmp(argv[i], "OO:", 3))
+			continue;
+		if (is_opt_name(argv[i]))
+			add_opt_arg(cmd, argv[i], &takes_arg, OPTIONAL);
+		else if (!strncmp(argv[i], "OO_", 3))
+			include_optional_opt_args(cmd, argv[i]);
+		else if (takes_arg)
+			update_prev_opt_arg(cmd, argv[i], OPTIONAL);
+		else
+			printf("Can't parse argc %d argv %s prev %s\n",
+				i, argv[i], argv[i-1]);
+	}
+}
+
+static void add_ignore_opt_line(struct command *cmd, int argc, char *argv[])
+{
+	int takes_arg;
+	int i;
+
+	for (i = 0; i < argc; i++) {
+		if (!i && !strncmp(argv[i], "IO:", 3))
+			continue;
+		if (is_opt_name(argv[i]))
+			add_opt_arg(cmd, argv[i], &takes_arg, IGNORE);
+		else if (takes_arg)
+			update_prev_opt_arg(cmd, argv[i], IGNORE);
+		else
+			printf("Can't parse argc %d argv %s prev %s\n",
+				i, argv[i], argv[i-1]);
+	}
+}
+
+/* process what follows OP:, which are optional pos args */
+
+static void add_optional_pos_line(struct command *cmd, int argc, char *argv[])
+{
+	int i;
+
+	for (i = 0; i < argc; i++) {
+		if (!i && !strncmp(argv[i], "OP:", 3))
+			continue;
+		if (is_pos_name(argv[i]))
+			add_pos_arg(cmd, argv[i], OPTIONAL);
+		else
+			update_prev_pos_arg(cmd, argv[i], OPTIONAL);
+	}
+}
+
+/* add required opt args from OO_FOO definition */
+
+static void add_required_opt_line(struct command *cmd, int argc, char *argv[])
+{
+	int takes_arg;
+	int i;
+
+	for (i = 0; i < argc; i++) {
+		if (is_opt_name(argv[i]))
+			add_opt_arg(cmd, argv[i], &takes_arg, REQUIRED);
+		else if (takes_arg)
+			update_prev_opt_arg(cmd, argv[i], REQUIRED);
+		else
+			printf("Can't parse argc %d argv %s prev %s\n",
+				i, argv[i], argv[i-1]);
+	}
+}
+
+/* add to required_opt_args when OO_FOO appears on required line */
+ 
+static void include_required_opt_args(struct command *cmd, char *str)
+{
+	char *oo_line;
+	char *line;
+	char *line_argv[MAX_LINE_ARGC];
+	int line_argc;
+
+	if (!(oo_line = get_oo_line(str))) {
+		printf("No OO line found for %s\n", str);
+		exit(1);
+	}
+
+	if (!(line = strdup(oo_line)))
+		exit(1); 
+
+	split_line(line, &line_argc, line_argv, ' ');
+	add_required_opt_line(cmd, line_argc, line_argv);
+	free(line);
+}
+
+/* process what follows command_name, which are required opt/pos args */
+
+static void add_required_line(struct command *cmd, int argc, char *argv[])
+{
+	int i;
+	int takes_arg;
+	int prev_was_opt = 0, prev_was_pos = 0;
+
+	/* argv[0] is command name */
+
+	for (i = 1; i < argc; i++) {
+		if (is_opt_name(argv[i])) {
+			add_opt_arg(cmd, argv[i], &takes_arg, REQUIRED);
+			prev_was_opt = 1;
+			prev_was_pos = 0;
+		} else if (prev_was_opt && takes_arg) {
+			update_prev_opt_arg(cmd, argv[i], REQUIRED);
+			prev_was_opt = 0;
+			prev_was_pos = 0;
+		} else if (is_pos_name(argv[i])) {
+			add_pos_arg(cmd, argv[i], REQUIRED);
+			prev_was_opt = 0;
+			prev_was_pos = 1;
+		} else if (!strncmp(argv[i], "OO_", 3)) {
+			cmd->cmd_flags |= CMD_FLAG_ONE_REQUIRED_OPT;
+			include_required_opt_args(cmd, argv[i]);
+		} else if (prev_was_pos) {
+			update_prev_pos_arg(cmd, argv[i], REQUIRED);
+		} else
+			printf("Can't parse argc %d argv %s prev %s\n",
+				i, argv[i], argv[i-1]);
+
+	}
+}
+
+static void print_def(struct arg_def *def, int usage)
+{
+	int val_enum;
+	int lvt_enum;
+	int sep = 0;
+	int i;
+
+	for (val_enum = 0; val_enum < VAL_COUNT; val_enum++) {
+		if (def->val_bits & val_enum_to_bit(val_enum)) {
+
+			if (val_enum == conststr_VAL)
+				printf("%s", def->str);
+
+			else if (val_enum == constnum_VAL)
+				printf("%llu", (unsigned long long)def->num);
+
+			else {
+				if (sep) printf("|");
+
+				if (!usage || !val_names[val_enum].usage)
+					printf("%s", val_names[val_enum].name);
+				else
+					printf("%s", val_names[val_enum].usage);
+
+				sep = 1;
+			}
+
+			if (val_enum == lv_VAL && def->lvt_bits) {
+				for (lvt_enum = 1; lvt_enum < LVT_COUNT; lvt_enum++) {
+					if (lvt_bit_is_set(def->lvt_bits, lvt_enum))
+						printf("_%s", lvt_enum_to_name(lvt_enum));
+				}
+			}
+
+			if ((val_enum == vg_VAL) && (def->flags & ARG_DEF_FLAG_NEW_VG))
+				printf("_new");
+			if ((val_enum == lv_VAL) && (def->flags & ARG_DEF_FLAG_NEW_LV))
+				printf("_new");
+		}
+	}
+
+	if (def->flags & ARG_DEF_FLAG_MAY_REPEAT)
+		printf(" ...");
+}
+
+void print_expanded(void)
+{
+	struct command *cmd;
+	int onereq;
+	int i, ro, rp, oo, op;
+
+	for (i = 0; i < cmd_count; i++) {
+		cmd = &cmd_array[i];
+		printf("%s", cmd->name);
+
+		onereq = (cmd->cmd_flags & CMD_FLAG_ONE_REQUIRED_OPT) ? 1 : 0;
+
+		if (cmd->ro_count) {
+			if (onereq)
+				printf(" (");
+
+			for (ro = 0; ro < cmd->ro_count; ro++) {
+				if (ro && onereq)
+					printf(",");
+				printf(" %s", opt_names[cmd->required_opt_args[ro].opt].long_opt);
+				if (cmd->required_opt_args[ro].def.val_bits) {
+					printf(" ");
+					print_def(&cmd->required_opt_args[ro].def, 0);
+				}
+			}
+			if (onereq)
+				printf(" )");
+		}
+
+		if (cmd->rp_count) {
+			for (rp = 0; rp < cmd->rp_count; rp++) {
+				if (cmd->required_pos_args[rp].def.val_bits) {
+					printf(" ");
+					print_def(&cmd->required_pos_args[rp].def, 0);
+				}
+			}
+		}
+
+		if (cmd->oo_count) {
+			printf("\n");
+			printf("OO:");
+			for (oo = 0; oo < cmd->oo_count; oo++) {
+				if (oo)
+					printf(",");
+				printf(" %s", opt_names[cmd->optional_opt_args[oo].opt].long_opt);
+				if (cmd->optional_opt_args[oo].def.val_bits) {
+					printf(" ");
+					print_def(&cmd->optional_opt_args[oo].def, 0);
+				}
+			}
+		}
+
+		if (cmd->op_count) {
+			printf("\n");
+			printf("OP:");
+			for (op = 0; op < cmd->op_count; op++) {
+				if (cmd->optional_pos_args[op].def.val_bits) {
+					printf(" ");
+					print_def(&cmd->optional_pos_args[op].def, 0);
+				}
+			}
+		}
+
+		printf("\n\n");
+	}
+}
+
+static int opt_arg_matches(struct opt_arg *oa1, struct opt_arg *oa2)
+{
+	if (oa1->opt != oa2->opt)
+		return 0;
+
+	/* FIXME: some cases may need more specific val_bits checks */
+	if (oa1->def.val_bits != oa2->def.val_bits)
+		return 0;
+
+	if (oa1->def.str && oa2->def.str && strcmp(oa1->def.str, oa2->def.str))
+		return 0;
+
+	if (oa1->def.num != oa2->def.num)
+		return 0;
+
+	/*
+	 * Do NOT compare lv_types because we are checking if two
+	 * command lines are ambiguous before the LV type is known.
+	 */
+
+	return 1;
+}
+
+static int pos_arg_matches(struct pos_arg *pa1, struct pos_arg *pa2)
+{
+	if (pa1->pos != pa2->pos)
+		return 0;
+
+	/* FIXME: some cases may need more specific val_bits checks */
+	if (pa1->def.val_bits != pa2->def.val_bits)
+		return 0;
+
+	if (pa1->def.str && pa2->def.str && strcmp(pa1->def.str, pa2->def.str))
+		return 0;
+
+	if (pa1->def.num != pa2->def.num)
+		return 0;
+
+	/*
+	 * Do NOT compare lv_types because we are checking if two
+	 * command lines are ambiguous before the LV type is known.
+	 */
+
+	return 1;
+}
+
+static const char *opt_to_enum_str(int opt)
+{
+	return opt_names[opt].name;
+}
+
+static char *flags_to_str(int flags)
+{
+	static char buf_flags[32];
+
+	memset(buf_flags, 0, sizeof(buf_flags));
+
+	if (flags & ARG_DEF_FLAG_MAY_REPEAT) {
+		if (buf_flags[0])
+			strcat(buf_flags, " | ");
+		strcat(buf_flags, "ARG_DEF_FLAG_MAY_REPEAT");
+	}
+	if (flags & ARG_DEF_FLAG_NEW_VG) {
+		if (buf_flags[0])
+			strcat(buf_flags, " | ");
+		strcat(buf_flags, "ARG_DEF_FLAG_NEW_VG");
+	}
+	if (flags & ARG_DEF_FLAG_NEW_LV) {
+		if (buf_flags[0])
+			strcat(buf_flags, " | ");
+		strcat(buf_flags, "ARG_DEF_FLAG_NEW_LV");
+	}
+
+	return buf_flags;
+}
+
+static void add_flags(struct command *cmd, char *line)
+{
+	if (strstr(line, "SECONDARY_SYNTAX"))
+		cmd->cmd_flags |= CMD_FLAG_SECONDARY_SYNTAX;
+}
+
+#define MAX_RULE_OPTS 64
+
+static void add_rule(struct command *cmd, char *line)
+{
+	struct cmd_rule *rule;
+	char *line_argv[MAX_LINE_ARGC];
+	char *arg;
+	int line_argc;
+	int i, lvt_enum, lvp_enum;
+	int check = 0;
+
+	if (cmd->rule_count == CMD_MAX_RULES) {
+		printf("too many rules for cmd\n");
+		exit(1);
+	}
+
+	rule = &cmd->rules[cmd->rule_count++];
+
+	split_line(line, &line_argc, line_argv, ' ');
+
+	for (i = 0; i < line_argc; i++) {
+		arg = line_argv[i];
+
+		if (!strcmp(arg, "not")) {
+			rule->rule = RULE_INVALID;
+			check = 1;
+		}
+
+		else if (!strcmp(arg, "and")) {
+			rule->rule = RULE_REQUIRE;
+			check = 1;
+		}
+
+		else if (!strncmp(arg, "all", 3)) {
+			/* opt/lvt_bits/lvp_bits all remain 0 to mean all */
+			continue;
+		}
+
+		else if (!strncmp(arg, "--", 2)) {
+			if (!rule->opts) {
+				if (!(rule->opts = malloc(MAX_RULE_OPTS * sizeof(int)))) {
+					printf("no mem\n");
+					exit(1);
+				}
+				memset(rule->opts, 0, MAX_RULE_OPTS * sizeof(int));
+			}
+
+			if (!rule->check_opts) {
+				if (!(rule->check_opts = malloc(MAX_RULE_OPTS * sizeof(int)))) {
+					printf("no mem\n");
+					exit(1);
+				}
+				memset(rule->check_opts, 0, MAX_RULE_OPTS * sizeof(int));
+			}
+
+			if (check)
+				rule->check_opts[rule->check_opts_count++] = opt_str_to_num(arg);
+			else
+				rule->opts[rule->opts_count++] = opt_str_to_num(arg);
+		}
+
+		else if (!strncmp(arg, "LV_", 3)) {
+			lvt_enum = lv_to_enum(arg);
+
+			if (check)
+				rule->check_lvt_bits |= lvt_enum_to_bit(lvt_enum);
+			else
+				rule->lvt_bits |= lvt_enum_to_bit(lvt_enum);
+		}
+
+		else if (!strncmp(arg, "lv_is_", 6)) {
+			lvp_enum = lvp_name_to_enum(arg);
+
+			if (check)
+				rule->check_lvp_bits |= lvp_enum_to_bit(lvp_enum);
+			else
+				rule->lvp_bits |= lvp_enum_to_bit(lvp_enum);
+		}
+	}
+}
+
+static char *rule_to_define_str(int rule_type)
+{
+	switch (rule_type) {
+	case RULE_INVALID:
+		return "RULE_INVALID";
+	case RULE_REQUIRE:
+		return "RULE_REQUIRE";
+	}
+}
+
+static char *cmd_flags_to_str(uint32_t flags)
+{
+	static char buf_cmd_flags[32];
+
+	memset(buf_cmd_flags, 0, sizeof(buf_cmd_flags));
+
+	if (flags & CMD_FLAG_SECONDARY_SYNTAX) {
+		if (buf_cmd_flags[0])
+			strcat(buf_cmd_flags, " | ");
+		strcat(buf_cmd_flags, "CMD_FLAG_SECONDARY_SYNTAX");
+	}
+	if (flags & CMD_FLAG_ONE_REQUIRED_OPT) {
+		if (buf_cmd_flags[0])
+			strcat(buf_cmd_flags, " | ");
+		strcat(buf_cmd_flags, "CMD_FLAG_ONE_REQUIRED_OPT");
+	}
+
+	return buf_cmd_flags;
+}
+
+void print_command_count(void)
+{
+	struct command *cmd;
+	int i, j;
+
+	printf("/* Do not edit. This file is generated by tools/create-commands */\n");
+	printf("/* using command definitions from tools/command-lines.in */\n");
+	printf("#define COMMAND_COUNT %d\n", cmd_count);
+
+	printf("enum {\n");
+	printf("\tno_CMD,\n");  /* enum value 0 is not used */
+
+	for (i = 0; i < cmd_count; i++) {
+		cmd = &cmd_array[i];
+
+		if (!cmd->command_line_id) {
+			printf("Missing ID: at %d\n", i);
+			exit(1);
+		}
+
+		for (j = 0; j < i; j++) {
+			if (!strcmp(cmd->command_line_id, cmd_array[j].command_line_id))
+				goto next;
+		}
+
+		printf("\t%s_CMD,\n", cmd->command_line_id);
+	next:
+		;
+	}
+	printf("\tCOMMAND_ID_COUNT,\n");
+	printf("};\n");
+}
+
+static int is_lvm_all_opt(int opt)
+{
+	int oo;
+
+	for (oo = 0; oo < lvm_all.oo_count; oo++) {
+		if (lvm_all.optional_opt_args[oo].opt == opt)
+			return 1;
+	}
+	return 0;
+}
+
+static void factor_common_options(void)
+{
+	int cn, opt_enum, ci, oo, ro, found;
+	struct command *cmd;
+
+	for (cn = 0; cn < MAX_CMD_NAMES; cn++) {
+		if (!cmd_names[cn].name)
+			break;
+
+		for (ci = 0; ci < cmd_count; ci++) {
+			cmd = &cmd_array[ci];
+
+			if (strcmp(cmd->name, cmd_names[cn].name))
+				continue;
+
+			cmd_names[cn].variants++;
+		}
+
+		for (opt_enum = 0; opt_enum < ARG_COUNT; opt_enum++) {
+
+			for (ci = 0; ci < cmd_count; ci++) {
+				cmd = &cmd_array[ci];
+
+				if (strcmp(cmd->name, cmd_names[cn].name))
+					continue;
+
+				if (cmd->ro_count)
+					cmd_names[cn].variant_has_ro = 1;
+				if (cmd->rp_count)
+					cmd_names[cn].variant_has_rp = 1;
+				if (cmd->oo_count)
+					cmd_names[cn].variant_has_oo = 1;
+				if (cmd->op_count)
+					cmd_names[cn].variant_has_op = 1;
+
+				for (ro = 0; ro < cmd->ro_count; ro++) {
+					cmd_names[cn].all_options[cmd->required_opt_args[ro].opt] = 1;
+
+					if ((cmd->required_opt_args[ro].opt == size_ARG) && !strncmp(cmd->name, "lv", 2))
+						cmd_names[cn].all_options[extents_ARG] = 1;
+				}
+				for (oo = 0; oo < cmd->oo_count; oo++)
+					cmd_names[cn].all_options[cmd->optional_opt_args[oo].opt] = 1;
+
+				found = 0;
+
+				for (oo = 0; oo < cmd->oo_count; oo++) {
+					if (cmd->optional_opt_args[oo].opt == opt_enum) {
+						found = 1;
+						break;
+					}
+				}
+
+				if (!found)
+					goto next_opt;
+			}
+
+			/* all commands starting with this name use this option */
+			cmd_names[cn].common_options[opt_enum] = 1;
+ next_opt:
+			;
+		}
+	}
+
+	/*
+	for (cn = 0; cn < MAX_CMD_NAMES; cn++) {
+		if (!cmd_names[cn].name)
+			break;
+
+		printf("%s (%d)\n", cmd_names[cn].name, cmd_names[cn].variants);
+		for (opt_enum = 0; opt_enum < ARG_COUNT; opt_enum++) {
+			if (cmd_names[cn].common_options[opt_enum])
+				printf("  %s\n", opt_names[opt_enum].long_opt);
+		}
+	}
+	*/
+}
+
+void print_usage_common(struct command *cmd)
+{
+	struct cmd_name *cname;
+	int i, sep, ro, rp, oo, op, opt_enum;
+
+	if (!(cname = find_command_name(cmd->name)))
+		return;
+
+	sep = 0;
+
+	/*
+	 * when there's more than one variant, options that
+	 * are common to all commands with a common name.
+	 */
+
+	if (cname->variants < 2)
+		goto all;
+
+	for (opt_enum = 0; opt_enum < ARG_COUNT; opt_enum++) {
+		if (!cname->common_options[opt_enum])
+			continue;
+
+		if (is_lvm_all_opt(opt_enum))
+			continue;
+
+		if (!sep) {
+			printf("\n");
+			printf("\" [");
+		} else {
+			printf(",");
+		}
+
+		for (oo = 0; oo < cmd->oo_count; oo++) {
+			if (cmd->optional_opt_args[oo].opt != opt_enum)
+				continue;
+
+			printf(" %s", opt_names[opt_enum].long_opt);
+			if (cmd->optional_opt_args[oo].def.val_bits) {
+				printf(" ");
+				print_def(&cmd->optional_opt_args[oo].def, 1);
+			}
+			sep = 1;
+			break;
+		}
+	}
+
+ all:
+	/* options that are common to all lvm commands */
+
+	for (oo = 0; oo < lvm_all.oo_count; oo++) {
+		opt_enum = lvm_all.optional_opt_args[oo].opt;
+
+		if (!sep) {
+			printf("\n");
+			printf("\" [");
+		} else {
+			printf(",");
+		}
+
+		printf(" %s", opt_names[opt_enum].long_opt);
+		if (lvm_all.optional_opt_args[oo].def.val_bits) {
+			printf(" ");
+			print_def(&lvm_all.optional_opt_args[oo].def, 1);
+		}
+		sep = 1;
+	}
+
+	printf(" ]\"");
+	printf(";\n");
+}
+
+void print_usage(struct command *cmd)
+{
+	struct cmd_name *cname;
+	int onereq = (cmd->cmd_flags & CMD_FLAG_ONE_REQUIRED_OPT) ? 1 : 0;
+	int i, sep, ro, rp, oo, op, opt_enum;
+
+	if (!(cname = find_command_name(cmd->name)))
+		return;
+
+	printf("\"%s", cmd->name);
+
+	if (cmd->ro_count) {
+		if (onereq)
+			printf(" (");
+		for (ro = 0; ro < cmd->ro_count; ro++) {
+			if (ro && onereq)
+				printf(",");
+			printf(" %s", opt_names[cmd->required_opt_args[ro].opt].long_opt);
+
+			if (cmd->required_opt_args[ro].def.val_bits) {
+				printf(" ");
+				print_def(&cmd->required_opt_args[ro].def, 1);
+			}
+		}
+		if (onereq)
+			printf(" )");
+	}
+
+	if (cmd->rp_count) {
+		for (rp = 0; rp < cmd->rp_count; rp++) {
+			if (cmd->required_pos_args[rp].def.val_bits) {
+				printf(" ");
+				print_def(&cmd->required_pos_args[rp].def, 1);
+			}
+		}
+	}
+
+	printf("\"");
+
+ oo_count:
+	if (!cmd->oo_count)
+		goto op_count;
+
+	sep = 0;
+
+	if (cmd->oo_count) {
+		printf("\n");
+		printf("\" [");
+
+		for (oo = 0; oo < cmd->oo_count; oo++) {
+			opt_enum = cmd->optional_opt_args[oo].opt;
+
+			/*
+			 * Skip common opts which are in the usage_common string.
+			 * The common opts are those in lvm_all and in
+			 * cname->common_options.
+			 */
+
+			if (is_lvm_all_opt(opt_enum))
+				continue;
+
+			if ((cname->variants > 1) && cname->common_options[opt_enum])
+				continue;
+
+			if (sep)
+				printf(",");
+
+			printf(" %s", opt_names[opt_enum].long_opt);
+			if (cmd->optional_opt_args[oo].def.val_bits) {
+				printf(" ");
+				print_def(&cmd->optional_opt_args[oo].def, 1);
+			}
+			sep = 1;
+		}
+
+		if (sep)
+			printf(",");
+		printf(" COMMON_OPTIONS");
+		printf(" ]\"");
+	}
+
+ op_count:
+	if (!cmd->op_count)
+		goto done;
+
+	printf("\n");
+	printf("\" [");
+
+	if (cmd->op_count) {
+		for (op = 0; op < cmd->op_count; op++) {
+			if (cmd->optional_pos_args[op].def.val_bits) {
+				printf(" ");
+				print_def(&cmd->optional_pos_args[op].def, 1);
+			}
+		}
+	}
+
+	printf(" ]\"");
+
+ done:
+	printf(";\n");
+}
+
+static void print_val_man(const char *str)
+{
+	char *line;
+	char *line_argv[MAX_LINE_ARGC];
+	int line_argc;
+	int i;
+
+	if (!strcmp(str, "Number") ||
+	    !strcmp(str, "String") ||
+	    !strncmp(str, "VG", 2) ||
+	    !strncmp(str, "LV", 2) ||
+	    !strncmp(str, "PV", 2) ||
+	    !strcmp(str, "Tag")) {
+		printf("\\fI%s\\fP", str);
+		return;
+	}
+
+	if (strstr(str, "Number[") || strstr(str, "]Number")) {
+		for (i = 0; i < strlen(str); i++) {
+			if (str[i] == 'N')
+				printf("\\fI");
+			if (str[i] == 'r') {
+				printf("%c", str[i]);
+				printf("\\fP");
+				continue;
+			}
+			printf("%c", str[i]);
+		}
+		return;
+	}
+
+	if (strstr(str, "|")) {
+		int len = strlen(str);
+		line = strdup(str);
+		split_line(line, &line_argc, line_argv, '|');
+		for (i = 0; i < line_argc; i++) {
+			if (i) {
+				printf("|");
+
+				/* this is a hack to add a line break for
+				   a long string of opt values */
+				if ((len > 40) && (i >= (line_argc / 2) + 1)) {
+					printf("\n");
+					printf("       ");
+					len = 0;
+				}
+			}
+			if (strstr(line_argv[i], "Number"))
+				printf("\\fI%s\\fP", line_argv[i]);
+			else
+				printf("\\fB%s\\fP", line_argv[i]);
+		}
+		return;
+	}
+
+	printf("\\fB%s\\fP", str);
+}
+
+static void print_def_man(struct arg_def *def, int usage)
+{
+	int val_enum;
+	int lvt_enum;
+	int sep = 0;
+	int i;
+
+	for (val_enum = 0; val_enum < VAL_COUNT; val_enum++) {
+		if (def->val_bits & val_enum_to_bit(val_enum)) {
+
+			if (val_enum == conststr_VAL) {
+				printf("\\fB");
+				printf("%s", def->str);
+				printf("\\fP");
+			}
+
+			else if (val_enum == constnum_VAL) {
+				printf("\\fB");
+				printf("%llu", (unsigned long long)def->num);
+				printf("\\fP");
+			}
+
+			else {
+				if (sep) printf("|");
+
+				if (!usage || !val_names[val_enum].usage) {
+					printf("\\fI");
+					printf("%s", val_names[val_enum].name);
+					printf("\\fP");
+				} else {
+					print_val_man(val_names[val_enum].usage);
+				}
+
+				sep = 1;
+			}
+
+			if (val_enum == lv_VAL && def->lvt_bits) {
+				printf("\\fI");
+				for (lvt_enum = 1; lvt_enum < LVT_COUNT; lvt_enum++) {
+					if (lvt_bit_is_set(def->lvt_bits, lvt_enum))
+						printf("_%s", lvt_enum_to_name(lvt_enum));
+				}
+				printf("\\fP");
+			}
+
+			if ((val_enum == vg_VAL) && (def->flags & ARG_DEF_FLAG_NEW_VG)) {
+				printf("\\fI");
+				printf("_new");
+				printf("\\fP");
+			}
+			if ((val_enum == lv_VAL) && (def->flags & ARG_DEF_FLAG_NEW_LV)) {
+				printf("\\fI");
+				printf("_new");
+				printf("\\fP");
+			}
+		}
+	}
+
+	if (def->flags & ARG_DEF_FLAG_MAY_REPEAT)
+		printf(" ...");
+}
+
+static char *man_long_opt_name(const char *cmdname, int opt_enum)
+{
+	static char long_opt_name[64];
+
+	memset(&long_opt_name, 0, sizeof(long_opt_name));
+
+	switch (opt_enum) {
+	case syncaction_ARG:
+		strncpy(long_opt_name, "--[raid]syncaction", 63);
+		break;
+	case writemostly_ARG:
+		strncpy(long_opt_name, "--[raid]writemostly", 63);
+		break;
+	case minrecoveryrate_ARG:
+		strncpy(long_opt_name, "--[raid]minrecoveryrate", 63);
+		break;
+	case maxrecoveryrate_ARG:
+		strncpy(long_opt_name, "--[raid]maxrecoveryrate", 63);
+		break;
+	case writebehind_ARG:
+		strncpy(long_opt_name, "--[raid]writebehind", 63);
+		break;
+	case vgmetadatacopies_ARG:
+		if (!strncmp(cmdname, "vg", 2))
+			strncpy(long_opt_name, "--[vg]metadatacopies", 63);
+		else
+			strncpy(long_opt_name, "--vgmetadatacopies", 63);
+		break;
+	case pvmetadatacopies_ARG:
+		if (!strncmp(cmdname, "pv", 2))
+			strncpy(long_opt_name, "--[pv]metadatacopies", 63);
+		else
+			strncpy(long_opt_name, "--pvmetadatacopies", 63);
+		break;
+	default:
+		strncpy(long_opt_name, opt_names[opt_enum].long_opt, 63);
+		break;
+	}
+
+	return long_opt_name;
+}
+
+void print_man_usage(struct command *cmd)
+{
+	struct cmd_name *cname;
+	int onereq = (cmd->cmd_flags & CMD_FLAG_ONE_REQUIRED_OPT) ? 1 : 0;
+	int i, sep, ro, rp, oo, op, opt_enum;
+
+	if (!(cname = find_command_name(cmd->name)))
+		return;
+
+	printf("\\fB%s\\fP", cmd->name);
+
+	if (!onereq)
+		goto ro_normal;
+
+	/*
+	 * one required option in a set, print as:
+	 * ( -a|--a,
+	 *   -b|--b,
+	 *      --c,
+	 *      --d )
+	 *
+	 * First loop through ro prints those with short opts,
+	 * and the second loop prints those without short opts.
+	 */
+
+	if (cmd->ro_count) {
+		printf("\n");
+		printf(".RS 4\n");
+		printf("(");
+
+		sep = 0;
+
+		/* print required options with a short opt */
+		for (ro = 0; ro < cmd->ro_count; ro++) {
+			opt_enum = cmd->required_opt_args[ro].opt;
+
+			if (!opt_names[opt_enum].short_opt)
+				continue;
+
+			if (sep) {
+				printf(",");
+				printf("\n.br\n");
+				printf(" ");
+			}
+
+			if (opt_names[opt_enum].short_opt) {
+				printf(" \\fB-%c\\fP|\\fB%s\\fP",
+				       opt_names[opt_enum].short_opt,
+				       man_long_opt_name(cmd->name, opt_enum));
+			} else {
+				printf("   ");
+				printf(" \\fB%s\\fP", man_long_opt_name(cmd->name, opt_enum));
+			}
+
+			if (cmd->required_opt_args[ro].def.val_bits) {
+				printf(" ");
+				print_def_man(&cmd->required_opt_args[ro].def, 1);
+			}
+
+			sep = 1;
+		}
+
+		/* print required options without a short opt */
+		for (ro = 0; ro < cmd->ro_count; ro++) {
+			opt_enum = cmd->required_opt_args[ro].opt;
+
+			if (opt_names[opt_enum].short_opt)
+				continue;
+
+			if (sep) {
+				printf(",");
+				printf("\n.br\n");
+				printf(" ");
+			}
+
+			printf("   ");
+			printf(" \\fB%s\\fP", man_long_opt_name(cmd->name, opt_enum));
+
+			if (cmd->required_opt_args[ro].def.val_bits) {
+				printf(" ");
+				print_def_man(&cmd->required_opt_args[ro].def, 1);
+			}
+
+			sep = 1;
+		}
+
+		printf(" )\n");
+		printf(".RE\n");
+	}
+
+	/* print required position args on a new line after the onereq set */
+	if (cmd->rp_count) {
+		printf(".RS 4\n");
+		for (rp = 0; rp < cmd->rp_count; rp++) {
+			if (cmd->required_pos_args[rp].def.val_bits) {
+				printf(" ");
+				print_def_man(&cmd->required_pos_args[rp].def, 1);
+			}
+		}
+
+		printf("\n");
+		printf(".RE\n");
+	} else {
+		/* printf("\n"); */
+	}
+
+	printf(".br\n");
+	goto oo_count;
+
+ ro_normal:
+
+	/*
+	 * all are required options, print as:
+	 * -a|--aaa <val> -b|--bbb <val>
+	 */
+
+	if (cmd->ro_count) {
+		for (ro = 0; ro < cmd->ro_count; ro++) {
+			opt_enum = cmd->required_opt_args[ro].opt;
+
+			if (opt_names[opt_enum].short_opt) {
+				printf(" \\fB-%c\\fP|\\fB%s\\fP",
+				       opt_names[opt_enum].short_opt,
+				       man_long_opt_name(cmd->name, opt_enum));
+			} else {
+				printf(" \\fB%s\\fP", opt_names[cmd->required_opt_args[ro].opt].long_opt);
+			}
+
+			if (cmd->required_opt_args[ro].def.val_bits) {
+				printf(" ");
+				print_def_man(&cmd->required_opt_args[ro].def, 1);
+			}
+		}
+	}
+
+	/* print required position args on the same line as the required options */
+	if (cmd->rp_count) {
+		for (rp = 0; rp < cmd->rp_count; rp++) {
+			if (cmd->required_pos_args[rp].def.val_bits) {
+				printf(" ");
+				print_def_man(&cmd->required_pos_args[rp].def, 1);
+			}
+		}
+
+		printf("\n");
+	} else {
+		printf("\n");
+	}
+
+	printf(".br\n");
+
+ oo_count:
+	if (!cmd->oo_count)
+		goto op_count;
+
+	sep = 0;
+
+	if (cmd->oo_count) {
+		printf(".RS 4\n");
+		printf("[");
+
+		/* print optional options with short opts */
+
+		for (oo = 0; oo < cmd->oo_count; oo++) {
+			opt_enum = cmd->optional_opt_args[oo].opt;
+
+			if (!opt_names[opt_enum].short_opt)
+				continue;
+
+			/*
+			 * Skip common opts which are in the usage_common string.
+			 * The common opts are those in lvm_all and in
+			 * cname->common_options.
+			 */
+
+			if (is_lvm_all_opt(opt_enum))
+				continue;
+
+			if ((cname->variants > 1) && cname->common_options[opt_enum])
+				continue;
+
+			if (sep) {
+				printf(",");
+				printf("\n.br\n");
+				printf(" ");
+			}
+
+			printf(" \\fB-%c\\fP|\\fB%s\\fP",
+				opt_names[opt_enum].short_opt,
+				man_long_opt_name(cmd->name, opt_enum));
+
+			if (cmd->optional_opt_args[oo].def.val_bits) {
+				printf(" ");
+				print_def_man(&cmd->optional_opt_args[oo].def, 1);
+			}
+			sep = 1;
+		}
+
+		/* print optional options without short opts */
+
+		for (oo = 0; oo < cmd->oo_count; oo++) {
+			opt_enum = cmd->optional_opt_args[oo].opt;
+
+			if (opt_names[opt_enum].short_opt)
+				continue;
+
+			/*
+			 * Skip common opts which are in the usage_common string.
+			 * The common opts are those in lvm_all and in
+			 * cname->common_options.
+			 */
+
+			if (is_lvm_all_opt(opt_enum))
+				continue;
+
+			if ((cname->variants > 1) && cname->common_options[opt_enum])
+				continue;
+
+			if (sep) {
+				printf(",");
+				printf("\n.br\n");
+				printf(" ");
+			}
+
+			/* space alignment without short opt */
+			printf("   ");
+
+			printf(" \\fB%s\\fP", man_long_opt_name(cmd->name, opt_enum));
+
+			if (cmd->optional_opt_args[oo].def.val_bits) {
+				printf(" ");
+				print_def_man(&cmd->optional_opt_args[oo].def, 1);
+			}
+			sep = 1;
+		}
+
+		if (sep) {
+			printf(",");
+			printf("\n.br\n");
+			printf(" ");
+			/* space alignment without short opt */
+			printf("   ");
+		}
+		printf(" COMMON_OPTIONS");
+		printf(" ]\n");
+		printf(".RE\n");
+		printf(".br\n");
+	}
+
+ op_count:
+	if (!cmd->op_count)
+		goto done;
+
+	printf(".RS 4\n");
+	printf("[");
+
+	if (cmd->op_count) {
+		for (op = 0; op < cmd->op_count; op++) {
+			if (cmd->optional_pos_args[op].def.val_bits) {
+				printf(" ");
+				print_def_man(&cmd->optional_pos_args[op].def, 1);
+			}
+		}
+	}
+
+	printf(" ]\n");
+	printf(".RE\n");
+
+ done:
+	printf("\n");
+}
+
+void print_man_usage_common(struct command *cmd)
+{
+	struct cmd_name *cname;
+	int i, sep, ro, rp, oo, op, opt_enum;
+
+	if (!(cname = find_command_name(cmd->name)))
+		return;
+
+	sep = 0;
+
+	printf(".RS 4\n");
+	printf("[");
+
+	/*
+	 * when there's more than one variant, options that
+	 * are common to all commands with a common name.
+	 */
+
+	if (cname->variants < 2)
+		goto all;
+
+	/* print those with short opts */
+	for (opt_enum = 0; opt_enum < ARG_COUNT; opt_enum++) {
+		if (!cname->common_options[opt_enum])
+			continue;
+
+		if (!opt_names[opt_enum].short_opt)
+			continue;
+
+		if (is_lvm_all_opt(opt_enum))
+			continue;
+
+		if (sep) {
+			printf(",");
+			printf("\n.br\n");
+			printf(" ");
+		}
+
+		for (oo = 0; oo < cmd->oo_count; oo++) {
+			if (cmd->optional_opt_args[oo].opt != opt_enum)
+				continue;
+
+			printf(" \\fB-%c\\fP|\\fB%s\\fP",
+				opt_names[opt_enum].short_opt,
+				man_long_opt_name(cmd->name, opt_enum));
+
+			if (cmd->optional_opt_args[oo].def.val_bits) {
+				printf(" ");
+				print_def_man(&cmd->optional_opt_args[oo].def, 1);
+			}
+			sep = 1;
+			break;
+		}
+
+	}
+
+	/* print those without short opts */
+	for (opt_enum = 0; opt_enum < ARG_COUNT; opt_enum++) {
+		if (!cname->common_options[opt_enum])
+			continue;
+
+		if (opt_names[opt_enum].short_opt)
+			continue;
+
+		if (is_lvm_all_opt(opt_enum))
+			continue;
+
+		if (sep) {
+			printf(",");
+			printf("\n.br\n");
+			printf(" ");
+		}
+
+		for (oo = 0; oo < cmd->oo_count; oo++) {
+			if (cmd->optional_opt_args[oo].opt != opt_enum)
+				continue;
+
+			/* space alignment without short opt */
+			printf("   ");
+
+			printf(" \\fB%s\\fP", man_long_opt_name(cmd->name, opt_enum));
+
+			if (cmd->optional_opt_args[oo].def.val_bits) {
+				printf(" ");
+				print_def_man(&cmd->optional_opt_args[oo].def, 1);
+			}
+			sep = 1;
+			break;
+		}
+	}
+ all:
+	/* options that are common to all lvm commands */
+
+	/* those with short opts */
+	for (oo = 0; oo < lvm_all.oo_count; oo++) {
+		opt_enum = lvm_all.optional_opt_args[oo].opt;
+
+		if (!opt_names[opt_enum].short_opt)
+			continue;
+
+		if (sep) {
+			printf(",");
+			printf("\n.br\n");
+			printf(" ");
+		}
+
+		printf(" \\fB-%c\\fP|\\fB%s\\fP",
+			opt_names[opt_enum].short_opt,
+			man_long_opt_name(cmd->name, opt_enum));
+
+		if (lvm_all.optional_opt_args[oo].def.val_bits) {
+			printf(" ");
+			print_def(&lvm_all.optional_opt_args[oo].def, 1);
+		}
+		sep = 1;
+	}
+
+	/* those without short opts */
+	for (oo = 0; oo < lvm_all.oo_count; oo++) {
+		opt_enum = lvm_all.optional_opt_args[oo].opt;
+
+		if (opt_names[opt_enum].short_opt)
+			continue;
+
+		if (sep) {
+			printf(",");
+			printf("\n.br\n");
+			printf(" ");
+		}
+
+		/* space alignment without short opt */
+		printf("   ");
+
+		printf(" \\fB%s\\fP", man_long_opt_name(cmd->name, opt_enum));
+
+		if (lvm_all.optional_opt_args[oo].def.val_bits) {
+			printf(" ");
+			print_def(&lvm_all.optional_opt_args[oo].def, 1);
+		}
+		sep = 1;
+	}
+	printf(" ]\n");
+}
+
+void print_man_all_options(struct cmd_name *cname)
+{
+	int opt_enum, val_enum;
+	int sep = 0;
+
+	/* print those with short opts */
+	for (opt_enum = 0; opt_enum < ARG_COUNT; opt_enum++) {
+		if (!cname->all_options[opt_enum])
+			continue;
+
+		if (!opt_names[opt_enum].short_opt)
+			continue;
+
+		if (sep)
+			printf("\n.br\n");
+
+		printf(" \\fB-%c\\fP|\\fB%s\\fP",
+			opt_names[opt_enum].short_opt,
+			man_long_opt_name(cname->name, opt_enum));
+
+		val_enum = opt_names[opt_enum].val_enum;
+
+		if (!val_names[val_enum].fn) {
+			/* takes no arg */
+		} else if (!val_names[val_enum].usage) {
+			printf(" ");
+			printf("\\fI");
+			printf("%s", val_names[val_enum].name);
+			printf("\\fP");
+		} else {
+			printf(" ");
+			print_val_man(val_names[val_enum].usage);
+		}
+
+		sep = 1;
+	}
+
+	/* print those without short opts */
+	for (opt_enum = 0; opt_enum < ARG_COUNT; opt_enum++) {
+		if (!cname->all_options[opt_enum])
+			continue;
+
+		if (opt_names[opt_enum].short_opt)
+			continue;
+
+		if (sep)
+			printf("\n.br\n");
+
+		/* space alignment without short opt */
+		printf("   ");
+
+		printf(" \\fB%s\\fP", man_long_opt_name(cname->name, opt_enum));
+
+		val_enum = opt_names[opt_enum].val_enum;
+
+		if (!val_names[val_enum].fn) {
+			/* takes no arg */
+		} else if (!val_names[val_enum].usage) {
+			printf(" ");
+			printf("\\fI");
+			printf("%s", val_names[val_enum].name);
+			printf("\\fP");
+		} else {
+			printf(" ");
+			print_val_man(val_names[val_enum].usage);
+		}
+
+		sep = 1;
+	}
+}
+
+#define DESC_LINE 256
+
+void print_desc_man(const char *desc)
+{
+	char buf[DESC_LINE] = {0};
+	int di = 0;
+	int bi = 0;
+
+	for (di = 0; di < strlen(desc); di++) {
+		if (desc[di] == '\0')
+			break;
+		if (desc[di] == '\n')
+			continue;
+
+		if (!strncmp(&desc[di], "DESC:", 5)) {
+			if (bi) {
+				printf("%s\n", buf);
+				printf(".br\n");
+				memset(buf, 0, sizeof(buf));
+				bi = 0;
+			}
+			di += 5;
+			continue;
+		}
+
+		if (!bi && desc[di] == ' ')
+			continue;
+
+		buf[bi++] = desc[di];
+
+		if (bi == (DESC_LINE - 1))
+			break;
+	}
+
+	if (bi) {
+		printf("%s\n", buf);
+		printf(".br\n");
+	}
+}
+
+static char *upper_command_name(char *str)
+{
+	static char str_upper[32];
+	int i = 0;
+
+	while (*str) {
+		str_upper[i++] = toupper(*str);
+		str++;
+	}
+	str_upper[i] = '\0';
+	return str_upper;
+}
+
+void print_man_command(void)
+{
+	struct cmd_name *cname;
+	struct command *cmd, *prev_cmd = NULL;
+	const char *desc;
+	int i, j, ro, rp, oo, op;
+
+	include_optional_opt_args(&lvm_all, "OO_USAGE_COMMON");
+
+	printf(".TH %s 8 \"LVM TOOLS #VERSION#\" \"Sistina Software UK\"\n",
+		man_command_name ? upper_command_name(man_command_name) : "LVM_COMMANDS");
+
+	for (i = 0; i < cmd_count; i++) {
+
+		cmd = &cmd_array[i];
+
+		if (prev_cmd && strcmp(prev_cmd->name, cmd->name)) {
+			printf("Common options:\n");
+			printf(".\n");
+			print_man_usage_common(prev_cmd);
+			prev_cmd = NULL;
+		}
+
+		if ((cmd->cmd_flags & CMD_FLAG_SECONDARY_SYNTAX) && !include_man_secondary)
+			continue;
+
+		if (!(cmd->cmd_flags & CMD_FLAG_SECONDARY_SYNTAX) && !include_man_primary)
+			continue;
+
+		if (man_command_name && strcmp(man_command_name, cmd->name))
+			continue;
+
+		if (!prev_cmd || strcmp(prev_cmd->name, cmd->name)) {
+			printf(".SH NAME\n");
+			printf(".\n");
+			if ((desc = cmd_name_desc(cmd->name)))
+				printf("%s \\- %s\n", cmd->name, desc);
+			else
+				printf("%s\n", cmd->name);
+			printf(".br\n");
+			printf(".P\n");
+			printf(".\n");
+			printf(".SH SYNOPSIS\n");
+			printf(".br\n");
+			printf(".P\n");
+			printf(".\n");
+			prev_cmd = cmd;
+
+			if (!(cname = find_command_name(cmd->name)))
+				return;
+
+			if (cname->variant_has_ro && cname->variant_has_rp)
+				printf("\\fB%s\\fP \\fIrequired_option_args\\fP \\fIrequired_position_args\\fP\n", cmd->name);
+			else if (cname->variant_has_ro && !cname->variant_has_rp)
+				printf("\\fB%s\\fP \\fIrequired_option_args\\fP\n", cmd->name);
+			else if (!cname->variant_has_ro && cname->variant_has_rp)
+				printf("\\fB%s\\fP \\fIrequired_position_args\\fP\n", cmd->name);
+			else if (!cname->variant_has_ro && !cname->variant_has_rp)
+				printf("\\fB%s\\fP\n", cmd->name);
+
+			printf(".br\n");
+
+			if (cname->variant_has_oo) {
+				printf("    [ \\fIoptional_option_args\\fP ]\n");
+				printf(".br\n");
+			}
+
+			if (cname->variant_has_op) {
+				printf("    [ \\fIoptional_position_args\\fP ]\n");
+				printf(".br\n");
+			}
+
+			printf(".P\n");
+			printf("\n");
+
+			/* listing them all when there's only 1 or 2 is just repetative */
+			if (cname->variants > 2) {
+				printf(".P\n");
+				print_man_all_options(cname);
+				printf("\n");
+				printf(".P\n");
+				printf("\n");
+			}
+
+			printf(".SH USAGE\n");
+			printf(".br\n");
+			printf(".P\n");
+			printf(".\n");
+		}
+
+		if (cmd->desc) {
+			print_desc_man(cmd->desc);
+			printf(".P\n");
+		}
+
+		print_man_usage(cmd);
+
+		if (i == (cmd_count - 1)) {
+			printf("Common options:\n");
+			printf(".\n");
+			print_man_usage_common(cmd);
+		}
+
+		printf("\n");
+		continue;
+	}
+}
+
+void print_command_struct(int only_usage)
+{
+	struct command *cmd;
+	int i, j, ro, rp, oo, op, ru, ruo, io;
+
+	include_optional_opt_args(&lvm_all, "OO_USAGE_COMMON");
+
+	printf("/* Do not edit. This file is generated by tools/create-commands */\n");
+	printf("/* using command definitions from tools/command-lines.in */\n");
+	printf("\n");
+
+	for (i = 0; i < cmd_count; i++) {
+		cmd = &cmd_array[i];
+
+		if (only_usage) {
+			print_usage(cmd);
+			print_usage_common(cmd);
+			printf("\n");
+			continue;
+		}
+
+		printf("commands[%d].name = \"%s\";\n", i, cmd->name);
+		printf("commands[%d].command_line_id = \"%s\";\n", i, cmd->command_line_id);
+		printf("commands[%d].command_line_enum = %s_CMD;\n", i, cmd->command_line_id);
+		printf("commands[%d].fn = %s;\n", i, cmd->name);
+		printf("commands[%d].ro_count = %d;\n", i, cmd->ro_count);
+		printf("commands[%d].rp_count = %d;\n", i, cmd->rp_count);
+		printf("commands[%d].oo_count = %d;\n", i, cmd->oo_count);
+		printf("commands[%d].op_count = %d;\n", i, cmd->op_count);
+		printf("commands[%d].io_count = %d;\n", i, cmd->io_count);
+		printf("commands[%d].rule_count = %d;\n", i, cmd->rule_count);
+
+		if (cmd->cmd_flags)
+			printf("commands[%d].cmd_flags = %s;\n", i, cmd_flags_to_str(cmd->cmd_flags));
+		else
+			printf("commands[%d].cmd_flags = 0;\n", i, cmd_flags_to_str(cmd->cmd_flags));
+
+		printf("commands[%d].desc = \"%s\";\n", i, cmd->desc ?: "");
+		printf("commands[%d].usage = ", i);
+		print_usage(cmd);
+
+		if (cmd->oo_count) {
+			printf("commands[%d].usage_common = ", i);
+			print_usage_common(cmd);
+		} else {
+			printf("commands[%d].usage_common = \"NULL\";\n", i);
+		}
+
+		if (cmd->ro_count) {
+			for (ro = 0; ro < cmd->ro_count; ro++) {
+				printf("commands[%d].required_opt_args[%d].opt = %s;\n",
+					i, ro, opt_to_enum_str(cmd->required_opt_args[ro].opt));
+
+				if (!cmd->required_opt_args[ro].def.val_bits)
+					continue;
+
+				printf("commands[%d].required_opt_args[%d].def.val_bits = %s;\n",
+					i, ro, val_bits_to_str(cmd->required_opt_args[ro].def.val_bits));
+
+				if (cmd->required_opt_args[ro].def.lvt_bits)
+					printf("commands[%d].required_opt_args[%d].def.lvt_bits = %s;\n",
+						i, ro, lvt_bits_to_str(cmd->required_opt_args[ro].def.lvt_bits));
+
+				if (cmd->required_opt_args[ro].def.flags)
+					printf("commands[%d].required_opt_args[%d].def.flags = %s;\n",
+						i, ro, flags_to_str(cmd->required_opt_args[ro].def.flags));
+
+				if (val_bit_is_set(cmd->required_opt_args[ro].def.val_bits, constnum_VAL))
+					printf("commands[%d].required_opt_args[%d].def.num = %d;\n",
+						i, ro, cmd->required_opt_args[ro].def.num);
+
+				if (val_bit_is_set(cmd->required_opt_args[ro].def.val_bits, conststr_VAL))
+					printf("commands[%d].required_opt_args[%d].def.str = \"%s\";\n",
+						i, ro, cmd->required_opt_args[ro].def.str ?: "NULL");
+			}
+		}
+
+		if (cmd->rp_count) {
+			for (rp = 0; rp < cmd->rp_count; rp++) {
+				printf("commands[%d].required_pos_args[%d].pos = %d;\n",
+					i, rp, cmd->required_pos_args[rp].pos);
+
+				if (!cmd->required_pos_args[rp].def.val_bits)
+					continue;
+
+				printf("commands[%d].required_pos_args[%d].def.val_bits = %s;\n",
+					i, rp, val_bits_to_str(cmd->required_pos_args[rp].def.val_bits));
+
+				if (cmd->required_pos_args[rp].def.lvt_bits)
+					printf("commands[%d].required_pos_args[%d].def.lvt_bits = %s;\n",
+						i, rp, lvt_bits_to_str(cmd->required_pos_args[rp].def.lvt_bits));
+
+				if (cmd->required_pos_args[rp].def.flags)
+					printf("commands[%d].required_pos_args[%d].def.flags = %s;\n",
+						i, rp, flags_to_str(cmd->required_pos_args[rp].def.flags));
+
+				if (val_bit_is_set(cmd->required_pos_args[rp].def.val_bits, constnum_VAL))
+					printf("commands[%d].required_pos_args[%d].def.num = %d;\n",
+						i, rp, cmd->required_pos_args[rp].def.num);
+
+				if (val_bit_is_set(cmd->required_pos_args[rp].def.val_bits, conststr_VAL))
+					printf("commands[%d].required_pos_args[%d].def.str = \"%s\";\n",
+						i, rp, cmd->required_pos_args[rp].def.str ?: "NULL");
+			}
+		}
+
+		if (cmd->oo_count) {
+			for (oo = 0; oo < cmd->oo_count; oo++) {
+				printf("commands[%d].optional_opt_args[%d].opt = %s;\n",
+					i, oo, opt_to_enum_str(cmd->optional_opt_args[oo].opt));
+
+				if (!cmd->optional_opt_args[oo].def.val_bits)
+					continue;
+
+				printf("commands[%d].optional_opt_args[%d].def.val_bits = %s;\n",
+					i, oo, val_bits_to_str(cmd->optional_opt_args[oo].def.val_bits));
+
+				if (cmd->optional_opt_args[oo].def.lvt_bits)
+					printf("commands[%d].optional_opt_args[%d].def.lvt_bits = %s;\n",
+						i, oo, lvt_bits_to_str(cmd->optional_opt_args[oo].def.lvt_bits));
+
+				if (cmd->optional_opt_args[oo].def.flags)
+					printf("commands[%d].optional_opt_args[%d].def.flags = %s;\n",
+						i, oo, flags_to_str(cmd->optional_opt_args[oo].def.flags));
+
+				if (val_bit_is_set(cmd->optional_opt_args[oo].def.val_bits, constnum_VAL)) 
+					printf("commands[%d].optional_opt_args[%d].def.num = %d;\n",
+						i, oo, cmd->optional_opt_args[oo].def.num);
+
+				if (val_bit_is_set(cmd->optional_opt_args[oo].def.val_bits, conststr_VAL))
+					printf("commands[%d].optional_opt_args[%d].def.str = \"%s\";\n",
+						i, oo, cmd->optional_opt_args[oo].def.str ?: "NULL");
+			}
+		}
+
+		if (cmd->io_count) {
+			for (io = 0; io < cmd->io_count; io++) {
+				printf("commands[%d].ignore_opt_args[%d].opt = %s;\n",
+					i, io, opt_to_enum_str(cmd->ignore_opt_args[io].opt));
+
+				if (!cmd->ignore_opt_args[io].def.val_bits)
+					continue;
+
+				printf("commands[%d].ignore_opt_args[%d].def.val_bits = %s;\n",
+					i, io, val_bits_to_str(cmd->ignore_opt_args[io].def.val_bits));
+
+				if (cmd->ignore_opt_args[io].def.lvt_bits)
+					printf("commands[%d].ignore_opt_args[%d].def.lvt_bits = %s;\n",
+						i, io, lvt_bits_to_str(cmd->ignore_opt_args[io].def.lvt_bits));
+
+				if (cmd->ignore_opt_args[io].def.flags)
+					printf("commands[%d].ignore_opt_args[%d].def.flags = %s;\n",
+						i, io, flags_to_str(cmd->ignore_opt_args[io].def.flags));
+
+				if (val_bit_is_set(cmd->ignore_opt_args[io].def.val_bits, constnum_VAL)) 
+					printf("commands[%d].ignore_opt_args[%d].def.num = %d;\n",
+						i, io, cmd->ignore_opt_args[io].def.num);
+
+				if (val_bit_is_set(cmd->ignore_opt_args[io].def.val_bits, conststr_VAL))
+					printf("commands[%d].ignore_opt_args[%d].def.str = \"%s\";\n",
+						i, io, cmd->ignore_opt_args[io].def.str ?: "NULL");
+			}
+		}
+
+		if (cmd->op_count) {
+			for (op = 0; op < cmd->op_count; op++) {
+				printf("commands[%d].optional_pos_args[%d].pos = %d;\n",
+					i, op, cmd->optional_pos_args[op].pos);
+
+				if (!cmd->optional_pos_args[op].def.val_bits)
+					continue;
+
+				printf("commands[%d].optional_pos_args[%d].def.val_bits = %s;\n",
+					i, op, val_bits_to_str(cmd->optional_pos_args[op].def.val_bits));
+
+				if (cmd->optional_pos_args[op].def.lvt_bits)
+					printf("commands[%d].optional_pos_args[%d].def.lvt_bits = %s;\n",
+						i, op, lvt_bits_to_str(cmd->optional_pos_args[op].def.lvt_bits));
+
+				if (cmd->optional_pos_args[op].def.flags)
+					printf("commands[%d].optional_pos_args[%d].def.flags = %s;\n",
+						i, op, flags_to_str(cmd->optional_pos_args[op].def.flags));
+
+				if (val_bit_is_set(cmd->optional_pos_args[op].def.val_bits, constnum_VAL))
+					printf("commands[%d].optional_pos_args[%d].def.num = %d;\n",
+						i, op, cmd->optional_pos_args[op].def.num);
+
+				if (val_bit_is_set(cmd->optional_pos_args[op].def.val_bits, conststr_VAL))
+					printf("commands[%d].optional_pos_args[%d].def.str = \"%s\";\n",
+						i, op, cmd->optional_pos_args[op].def.str ?: "NULL");
+			}
+		}
+
+		if (cmd->rule_count) {
+			for (ru = 0; ru < cmd->rule_count; ru++) {
+
+				printf("commands[%d].rules[%d].opts_count = %d;\n", i, ru, cmd->rules[ru].opts_count);
+
+				if (cmd->rules[ru].opts_count) {
+					printf("static int _command%d_rule%d_opts[] = { ", i, ru);
+					for (ruo = 0; ruo < cmd->rules[ru].opts_count; ruo++) {
+						if (ruo)
+							printf(", ");
+						printf("%s", opt_to_enum_str(cmd->rules[ru].opts[ruo]));
+					}
+					printf(" };\n");
+					printf("commands[%d].rules[%d].opts = _command%d_rule%d_opts;\n", i, ru, i, ru);
+				} else {
+					printf("commands[%d].rules[%d].opts = NULL;\n", i, ru);
+				}
+
+				printf("commands[%d].rules[%d].check_opts_count = %d;\n", i, ru, cmd->rules[ru].check_opts_count);
+
+				if (cmd->rules[ru].check_opts_count) {
+					printf("static int _command%d_rule%d_check_opts[] = { ", i, ru);
+					for (ruo = 0; ruo < cmd->rules[ru].check_opts_count; ruo++) {
+						if (ruo)
+							printf(",");
+						printf("%s ", opt_to_enum_str(cmd->rules[ru].check_opts[ruo]));
+					}
+					printf(" };\n");
+					printf("commands[%d].rules[%d].check_opts = _command%d_rule%d_check_opts;\n", i, ru, i, ru);
+				} else {
+					printf("commands[%d].rules[%d].check_opts = NULL;\n", i, ru);
+				}
+
+				printf("commands[%d].rules[%d].lvt_bits = %s;\n", i, ru,
+					cmd->rules[ru].lvt_bits ? lvt_bits_to_str(cmd->rules[ru].lvt_bits) : "0");
+
+				printf("commands[%d].rules[%d].lvp_bits = %s;\n", i, ru,
+					cmd->rules[ru].lvp_bits ? lvp_bits_to_str(cmd->rules[ru].lvp_bits) : "0");
+
+				printf("commands[%d].rules[%d].rule = %s;\n", i, ru,
+					rule_to_define_str(cmd->rules[ru].rule));
+
+				printf("commands[%d].rules[%d].check_lvt_bits = %s;\n", i, ru,
+					cmd->rules[ru].check_lvt_bits ? lvt_bits_to_str(cmd->rules[ru].check_lvt_bits) : "0");
+
+				printf("commands[%d].rules[%d].check_lvp_bits = %s;\n", i, ru,
+					cmd->rules[ru].check_lvp_bits ? lvp_bits_to_str(cmd->rules[ru].check_lvp_bits) : "0");
+			}
+		}
+
+		printf("\n");
+	}
+}
+
+struct cmd_pair {
+	int i, j;
+};
+
+static void print_ambiguous(void)
+{
+	struct command *cmd, *dup;
+	struct cmd_pair dups[64] = { 0 };
+	int found = 0;
+	int i, j, f, ro, rp;
+
+	for (i = 0; i < cmd_count; i++) {
+		cmd = &cmd_array[i];
+
+		for (j = 0; j < cmd_count; j++) {
+			dup = &cmd_array[j];
+
+			if (i == j)
+				continue;
+			if (strcmp(cmd->name, dup->name))
+				continue;
+			if (cmd->ro_count != dup->ro_count)
+				continue;
+			if (cmd->rp_count != dup->rp_count)
+				continue;
+
+			for (ro = 0; ro < cmd->ro_count; ro++) {
+				if (!opt_arg_matches(&cmd->required_opt_args[ro],
+						     &dup->required_opt_args[ro]))
+					goto next;
+			}
+
+			for (rp = 0; rp < cmd->rp_count; rp++) {
+				if (!pos_arg_matches(&cmd->required_pos_args[rp],
+						     &dup->required_pos_args[rp]))
+					goto next;
+			}
+
+			for (f = 0; f < found; f++) {
+				if ((dups[f].i == j) && (dups[f].j == i))
+					goto next;
+			}
+
+			printf("Ambiguous commands %d and %d:\n", i, j);
+			print_usage(cmd);
+			print_usage(dup);
+			printf("\n");
+
+			dups[found].i = i;
+			dups[found].j = j;
+			found++;
+next:
+			;
+		}
+	}
+}
+
+void print_command_list(void)
+{
+	int i;
+
+	for (i = 0; i < MAX_CMD_NAMES; i++) {
+		if (!cmd_names[i].name) {
+			printf("found %d command names\n", i);
+			break;
+		}
+		printf("%s\n", cmd_names[i].name);
+	}
+}
+
+void print_option_list(void)
+{
+	int i;
+
+	for (i = 0; i < ARG_COUNT; i++)
+		printf("%d %s %s %c (%d)\n",
+			opt_names[i].opt_enum, opt_names[i].name,
+			opt_names[i].long_opt, opt_names[i].short_opt ?: ' ',
+			opt_names[i].short_opt ? opt_names[i].short_opt : 0);
+}
+
+static void print_help(int argc, char *argv[])
+{
+	printf("%s [options] --output <format> <filename>\n", argv[0]);
+	printf("\n");
+	printf("output formats:\n");
+	printf("struct:    print C structures for command-lines.h\n");
+	printf("count:     print defines and enums for command-lines-count.h\n");
+	printf("ambiguous: print commands differing only by LV types\n");
+	printf("usage:     print usage format.\n");
+	printf("expanded:  print expanded input format.\n");
+	printf("man:       print man page format.\n");
+	printf("\n");
+	printf("options:\n");
+	printf("-c|--man-command <commandname>  man output for one command name\n");
+}
+
+int main(int argc, char *argv[])
+{
+	char *outputformat = NULL;
+	char *inputfile = NULL;
+	FILE *file;
+	struct command *cmd;
+	char line[MAX_LINE];
+	char line_orig[MAX_LINE];
+	const char *name;
+	char *line_argv[MAX_LINE_ARGC];
+	char *n;
+	int line_argc;
+	int prev_was_oo_def = 0;
+	int prev_was_oo = 0;
+	int prev_was_op = 0;
+
+	if (argc < 2) {
+		print_help(argc, argv);
+		exit(EXIT_FAILURE);
+	}
+
+	if (!strcmp(argv[1], "debug")) {
+		print_command_list();
+		print_option_list();
+		return 0;
+	}
+
+	static struct option long_options[] = {
+		{"help",      no_argument,       0, 'h' },
+		{"output",    required_argument, 0, 'o' },
+		{"man-primary", required_argument, 0, 'p' },
+		{"man-secondary", required_argument, 0, 's' },
+		{"man-command", required_argument, 0, 'c' },
+		{0, 0, 0, 0 }
+	};
+
+        while (1) {
+		int c;
+		int option_index = 0;
+
+		c = getopt_long(argc, argv, "ho:p:s:c:",
+				long_options, &option_index);
+		if (c == -1)
+			break;
+
+		switch (c) {
+		case '0':
+			break;
+		case 'h':
+                        print_help(argc, argv);
+			exit(EXIT_SUCCESS);
+		case 'o':
+			outputformat = strdup(optarg);
+			break;
+		case 'p':
+			include_man_primary = atoi(optarg);
+			break;
+		case 's':
+			include_man_secondary = atoi(optarg);
+			break;
+		case 'c':
+			man_command_name = strdup(optarg);
+			break;
+		}
+	}
+
+	if (optind < argc)
+		inputfile = argv[optind];
+	else {
+		printf("Missing filename.\n");
+		return 0;
+	}
+
+	if (!(file = fopen(inputfile, "r"))) {
+		printf("Cannot open %s\n", argv[1]);
+		return -1;
+	}
+
+	while (fgets(line, MAX_LINE, file)) {
+		if (line[0] == '#')
+			continue;
+		if (line[0] == '\n')
+			continue;
+		if (line[0] == '-' && line[1] == '-' && line[2] == '-')
+			continue;
+
+		if ((n = strchr(line, '\n')))
+			*n = '\0';
+
+		memcpy(line_orig, line, sizeof(line));
+		split_line(line, &line_argc, line_argv, ' ');
+
+		if (!line_argc)
+			continue;
+
+		/* command ... */
+		if ((name = is_command_name(line_argv[0]))) {
+			if (cmd_count >= MAX_CMDS) {
+				printf("MAX_CMDS too small\n");
+				return -1;
+			}
+			cmd = &cmd_array[cmd_count++];
+			cmd->name = name;
+			cmd->pos_count = 1;
+			add_required_line(cmd, line_argc, line_argv);
+
+			/* Every cmd gets the OO_ALL options */
+			include_optional_opt_args(cmd, "OO_ALL:");
+			continue;
+		}
+
+		if (is_desc_line(line_argv[0])) {
+			char *desc = strdup(line_orig);
+			if (cmd->desc) {
+				int newlen = strlen(cmd->desc) + strlen(desc) + 2;
+				char *newdesc = malloc(newlen);
+				memset(newdesc, 0, newlen);
+				snprintf(newdesc, newlen, "%s %s", cmd->desc, desc);
+				cmd->desc = newdesc;
+				free(desc);
+			} else
+				cmd->desc = desc;
+			continue;
+		}
+
+		if (is_flags_line(line_argv[0])) {
+			add_flags(cmd, line_orig);
+			continue;
+		}
+
+		if (is_rule_line(line_argv[0])) {
+			add_rule(cmd, line_orig);
+			continue;
+		}
+
+		if (is_id_line(line_argv[0])) {
+			cmd->command_line_id = strdup(line_argv[1]);
+			continue;
+		}
+
+		/* OO_FOO: ... */
+		if (is_oo_definition(line_argv[0])) {
+			add_oo_definition_line(line_argv[0], line_orig);
+			prev_was_oo_def = 1;
+			prev_was_oo = 0;
+			prev_was_op = 0;
+			continue;
+		}
+
+		/* OO: ... */
+		if (is_oo_line(line_argv[0])) {
+			add_optional_opt_line(cmd, line_argc, line_argv);
+			prev_was_oo_def = 0;
+			prev_was_oo = 1;
+			prev_was_op = 0;
+			continue;
+		}
+
+		/* OP: ... */
+		if (is_op_line(line_argv[0])) {
+			add_optional_pos_line(cmd, line_argc, line_argv);
+			prev_was_oo_def = 0;
+			prev_was_oo = 0;
+			prev_was_op = 1;
+			continue;
+		}
+
+		/* IO: ... */
+		if (is_io_line(line_argv[0])) {
+			add_ignore_opt_line(cmd, line_argc, line_argv);
+			prev_was_oo = 0;
+			prev_was_op = 0;
+			continue;
+		}
+
+		/* handle OO_FOO:, OO:, OP: continuing on multiple lines */
+
+		if (prev_was_oo_def) {
+			append_oo_definition_line(line_orig);
+			continue;
+		}
+
+		if (prev_was_oo) {
+			add_optional_opt_line(cmd, line_argc, line_argv);
+			continue;
+		}
+
+		if (prev_was_op) {
+			add_optional_pos_line(cmd, line_argc, line_argv);
+			continue;
+		}
+	}
+
+	fclose(file);
+
+	factor_common_options();
+
+	if (!outputformat)
+		print_command_struct(1);
+	else if (!strcmp(outputformat, "struct")) {
+		print_command_struct(0);
+		print_ambiguous();
+	}
+	else if (!strcmp(outputformat, "count"))
+		print_command_count();
+	else if (!strcmp(outputformat, "usage"))
+		print_command_struct(1);
+	else if (!strcmp(outputformat, "expanded"))
+		print_expanded();
+	else if (!strcmp(outputformat, "ambiguous"))
+		print_ambiguous();
+	else if (!strcmp(outputformat, "man"))
+		print_man_command();
+	else
+		print_help(argc, argv);
+
+	return 0;
+}
+
diff --git a/tools/lv_props.h b/tools/lv_props.h
new file mode 100644
index 0000000..2925028
--- /dev/null
+++ b/tools/lv_props.h
@@ -0,0 +1,56 @@
+
+/*
+ * NULL in the last arg can be replaced with actual
+ * calls to the lv_is_prop() function when those
+ * become functions (are #define now), take uniform
+ * args (e.g. some take cmd others don't), and are
+ * exposed in tools.h
+ *
+ * Until then, the lv_is_prop() functions are
+ * called indirectly through _lv_is_prop().
+ */
+
+lvp(LVP_NONE, "", NULL) /* enum value 0 means none */
+lvp(is_locked_LVP, "lv_is_locked", NULL)
+lvp(is_partial_LVP, "lv_is_partial", NULL)
+lvp(is_virtual_LVP, "lv_is_virtual", NULL)
+lvp(is_merging_LVP, "lv_is_merging", NULL)
+lvp(is_merging_origin_LVP, "lv_is_merging_origin", NULL)
+lvp(is_converting_LVP, "lv_is_converting", NULL)
+lvp(is_external_origin_LVP, "lv_is_external_origin", NULL)
+lvp(is_virtual_origin_LVP, "lv_is_virtual_origin", NULL)
+lvp(is_not_synced_LVP, "lv_is_not_synced", NULL)
+lvp(is_pending_delete_LVP, "lv_is_pending_delete", NULL)
+lvp(is_error_when_full_LVP, "lv_is_error_when_full", NULL)
+lvp(is_pvmove_LVP, "lv_is_pvmove", NULL)
+lvp(is_removed_LVP, "lv_is_removed", NULL)
+lvp(is_vg_writable_LVP, "lv_is_vg_writable", NULL)
+
+/* kinds of sub LV */
+lvp(is_thinpool_data_LVP, "lv_is_thinpool_data", NULL)
+lvp(is_thinpool_metadata_LVP, "lv_is_thinpool_metadata", NULL)
+lvp(is_cachepool_data_LVP, "lv_is_cachepool_data", NULL)
+lvp(is_cachepool_metadata_LVP, "lv_is_cachepool_metadata", NULL)
+lvp(is_mirror_image_LVP, "lv_is_mirror_image", NULL)
+lvp(is_mirror_log_LVP, "lv_is_mirror_log", NULL)
+lvp(is_raid_image_LVP, "lv_is_raid_image", NULL)
+lvp(is_raid_metadata_LVP, "lv_is_raid_metadata", NULL)
+
+/*
+ * is_thick_origin should be used instead of is_origin
+ * is_thick_snapshot is generally used as LV_snapshot from lv_types.h
+ */
+lvp(is_origin_LVP, "lv_is_origin", NULL)
+lvp(is_thick_origin_LVP, "lv_is_thick_origin", NULL)
+lvp(is_thick_snapshot_LVP, "lv_is_thick_snapshot", NULL)
+lvp(is_thin_origin_LVP, "lv_is_thin_origin", NULL)
+lvp(is_thin_snapshot_LVP, "lv_is_thin_snapshot", NULL)
+
+lvp(is_cache_origin_LVP, "lv_is_cache_origin", NULL)
+lvp(is_merging_cow_LVP, "lv_is_merging_cow", NULL)
+lvp(is_cow_covering_origin_LVP, "lv_is_cow_covering_origin", NULL)
+lvp(is_visible_LVP, "lv_is_visible", NULL)
+lvp(is_historical_LVP, "lv_is_historical", NULL)
+lvp(is_raid_with_tracking_LVP, "lv_is_raid_with_tracking", NULL)
+lvp(LVP_COUNT, "", NULL)
+
diff --git a/tools/lv_types.h b/tools/lv_types.h
new file mode 100644
index 0000000..22d0522
--- /dev/null
+++ b/tools/lv_types.h
@@ -0,0 +1,34 @@
+
+
+/*
+ * LV types used in command definitions.  The type strings are used
+ * as LV suffixes, e.g. LV_type or LV_type1_type2.
+ *
+ * The final NULL arg can be replaced with lv_is_type() functions
+ * if the current lv_is_type #defines become functions and are
+ * moved to tools.h
+ *
+ * Until then, the lv_is_type() functions are called indirectly
+ * through _lv_is_type().
+ */
+
+lvt(LVT_NONE, "", NULL)
+lvt(linear_LVT, "linear", NULL)
+lvt(striped_LVT, "striped", NULL)
+lvt(snapshot_LVT, "snapshot", NULL) /* lv_is_cow, lv_is_thick_snapshot */
+lvt(thin_LVT, "thin", NULL)
+lvt(thinpool_LVT, "thinpool", NULL)
+lvt(cache_LVT, "cache", NULL)
+lvt(cachepool_LVT, "cachepool", NULL)
+lvt(mirror_LVT, "mirror", NULL)
+lvt(raid_LVT, "raid", NULL)
+lvt(raid0_LVT, "raid0", NULL)
+lvt(raid1_LVT, "raid1", NULL)
+lvt(raid4_LVT, "raid4", NULL)
+lvt(raid5_LVT, "raid5", NULL)
+lvt(raid6_LVT, "raid6", NULL)
+lvt(raid10_LVT, "raid10", NULL)
+lvt(error_LVT, "error", NULL)
+lvt(zero_LVT, "zero", NULL)
+lvt(LVT_COUNT, "", NULL)
+
diff --git a/tools/lvm.c b/tools/lvm.c
index b3af020..aae6da0 100644
--- a/tools/lvm.c
+++ b/tools/lvm.c
@@ -45,9 +45,9 @@ static char *_list_cmds(const char *text, int state)
 		len = strlen(text);
 	}
 
-	while (i < _cmdline->num_commands)
-		if (!strncmp(text, _cmdline->commands[i++].name, len))
-			return strdup(_cmdline->commands[i - 1].name);
+	while (i < _cmdline->num_command_names)
+		if (!strncmp(text, _cmdline->command_names[i++].name, len))
+			return strdup(_cmdline->command_names[i - 1].name);
 
 	return NULL;
 }
@@ -57,7 +57,7 @@ static char *_list_args(const char *text, int state)
 {
 	static int match_no = 0;
 	static size_t len = 0;
-	static struct command *com;
+	static struct command_name *cname;
 
 	/* Initialise if this is a new completion attempt */
 	if (!state) {
@@ -65,40 +65,40 @@ static char *_list_args(const char *text, int state)
 		int j;
 
 		match_no = 0;
-		com = NULL;
+		cname = NULL;
 		len = strlen(text);
 
 		/* Find start of first word in line buffer */
 		while (isspace(*s))
 			s++;
 
-		/* Look for word in list of commands */
-		for (j = 0; j < _cmdline->num_commands; j++) {
+		/* Look for word in list of command names */
+		for (j = 0; j < _cmdline->num_command_names; j++) {
 			const char *p;
 			char *q = s;
 
-			p = _cmdline->commands[j].name;
+			p = _cmdline->command_names[j].name;
 			while (*p == *q) {
 				p++;
 				q++;
 			}
 			if ((!*p) && *q == ' ') {
-				com = _cmdline->commands + j;
+				cname = _cmdline->command_names + j;
 				break;
 			}
 		}
 	}
 
-	if (!com)
+	if (!cname)
 		return NULL;
 
 	/* Short form arguments */
 	if (len < 3) {
-		while (match_no < com->num_args) {
+		while (match_no < cname->num_args) {
 			char s[3];
 			char c;
 			if (!(c = (_cmdline->arg_props +
-				   com->valid_args[match_no++])->short_arg))
+				   cname->valid_args[match_no++])->short_arg))
 				continue;
 
 			sprintf(s, "-%c", c);
@@ -108,13 +108,13 @@ static char *_list_args(const char *text, int state)
 	}
 
 	/* Long form arguments */
-	if (match_no < com->num_args)
-		match_no = com->num_args;
+	if (match_no < cname->num_args)
+		match_no = cname->num_args;
 
-	while (match_no - com->num_args < com->num_args) {
+	while (match_no - cname->num_args < cname->num_args) {
 		const char *l;
 		l = (_cmdline->arg_props +
-		     com->valid_args[match_no++ - com->num_args])->long_arg;
+		     cname->valid_args[match_no++ - cname->num_args])->long_arg;
 		if (*(l + 2) && !strncmp(text, l, len))
 			return strdup(l);
 	}
diff --git a/tools/lvm2cmdline.h b/tools/lvm2cmdline.h
index 80bd03e..9b75c36 100644
--- a/tools/lvm2cmdline.h
+++ b/tools/lvm2cmdline.h
@@ -19,10 +19,11 @@
 struct cmd_context;
 
 struct cmdline_context {
-        struct arg_props *arg_props;
-        struct command *commands;
-        int num_commands;
-        int commands_size;
+	struct arg_props *arg_props;
+	struct command *commands;
+	int num_commands;
+	struct command_name *command_names;
+	int num_command_names;
 };
 
 int lvm2_main(int argc, char **argv);
diff --git a/tools/lvmcmdlib.c b/tools/lvmcmdlib.c
index 64c0d8b..a1e938b 100644
--- a/tools/lvmcmdlib.c
+++ b/tools/lvmcmdlib.c
@@ -30,12 +30,12 @@ void *cmdlib_lvm2_init(unsigned static_compile)
 {
 	struct cmd_context *cmd;
 
-	lvm_register_commands();
-
 	init_is_static(static_compile);
 	if (!(cmd = init_lvm(1, 1)))
 		return NULL;
 
+	lvm_register_commands();
+
 	return (void *) cmd;
 }
 
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index ae26957..231ef68 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -49,21 +49,106 @@ extern char *optarg;
 #  define OPTIND_INIT 1
 #endif
 
+#include "command-lines-count.h"
+
+/*
+ * Table of valid --option values.
+ */
+static struct val_props _val_props[VAL_COUNT + 1] = {
+#define val(a, b, c, d) {a, b, c, d},
+#include "vals.h"
+#undef val
+};
+
 /*
- * Table of valid switches
+ * Table of valid --option's
  */
 static struct arg_props _arg_props[ARG_COUNT + 1] = {
-#define arg(a, b, c, d, e, f) {b, "", "--" c, d, e, f},
+#define arg(a, b, c, d, e, f) {a, b, "", "--" c, d, e, f},
 #include "args.h"
 #undef arg
 };
 
+/*
+ * Table of valid command names
+ */
+#define MAX_COMMAND_NAMES 64
+struct command_name command_names[MAX_COMMAND_NAMES] = {
+#define xx(a, b, c...) { # a, b, c },
+#include "commands.h"
+#undef xx
+};
+
+/*
+ * Table of LV properties
+ */
+static struct lv_props _lv_props[LVP_COUNT + 1] = {
+#define lvp(a, b, c) {a, b, c},
+#include "lv_props.h"
+#undef lvp
+};
+
+/*
+ * Table of LV types
+ */
+static struct lv_types _lv_types[LVT_COUNT + 1] = {
+#define lvt(a, b, c) {a, b, c},
+#include "lv_types.h"
+#undef lvt
+};
+
+
+/*
+ * Table of valid command lines
+ */
+static struct command commands[COMMAND_COUNT];
 static struct cmdline_context _cmdline;
 
+/*
+ * Table of command line functions
+ *
+ * This table could be auto-generated once all commands have been converted
+ * to use these functions instead of the old per-command-name function.
+ * For now, any command id not included here uses the old command fn.
+ */
+struct command_function command_functions[COMMAND_ID_COUNT] = {
+	{ lvmconfig_general_CMD, lvmconfig },
+};
+#if 0
+	/* all raid-related type conversions */
+
+	{ lvconvert_raid_types_CMD,			lvconvert_raid_types_fn },
+
+	/* raid-related utilities (move into lvconvert_raid_types?) */
+
+	{ lvconvert_split_mirror_images_CMD,		lvconvert_split_mirror_images_fn },
+	{ lvconvert_change_mirrorlog_CMD,		lvconvert_change_mirrorlog_fn },
+
+	/* utilities for creating/maintaining thin and cache objects. */
+
+	{ lvconvert_to_thin_with_external_CMD,		lvconvert_to_thin_with_external_fn },
+	{ lvconvert_to_cache_vol_CMD,			lvconvert_to_cache_vol_fn },
+	{ lvconvert_to_thinpool_CMD,			lvconvert_to_thinpool_fn },
+	{ lvconvert_to_cachepool_CMD,			lvconvert_to_cachepool_fn },
+	{ lvconvert_split_and_keep_cachepool_CMD,	lvconvert_split_and_keep_cachepool_fn },
+	{ lvconvert_split_and_delete_cachepool_CMD,	lvconvert_split_and_delete_cachepool_fn },
+	{ lvconvert_swap_pool_metadata_CMD,		lvconvert_swap_pool_metadata_fn },
+
+	/* utilities related to snapshots and repair. */
+
+	{ lvconvert_merge_CMD,				lvconvert_merge_fn },
+	{ lvconvert_combine_split_snapshot_CMD,		lvconvert_combine_split_snapshot_fn },
+	{ lvconvert_repair_pvs_or_thinpool_CMD,		lvconvert_repair_pvs_or_thinpool_fn },
+	{ lvconvert_replace_pv_CMD,			lvconvert_replace_pv_fn },
+	{ lvconvert_split_cow_snapshot_CMD,		lvconvert_split_cow_snapshot_fn },
+	{ lvconvert_poll_start_CMD,			lvconvert_poll_start_fn },
+
+#endif
+
 /* Command line args */
 unsigned arg_count(const struct cmd_context *cmd, int a)
 {
-	return cmd->arg_values ? cmd->arg_values[a].count : 0;
+	return cmd->opt_arg_values ? cmd->opt_arg_values[a].count : 0;
 }
 
 unsigned grouped_arg_count(const struct arg_values *av, int a)
@@ -182,12 +267,12 @@ const char *arg_long_option_name(int a)
 
 const char *arg_value(const struct cmd_context *cmd, int a)
 {
-	return cmd->arg_values ? cmd->arg_values[a].value : NULL;
+	return cmd->opt_arg_values ? cmd->opt_arg_values[a].value : NULL;
 }
 
 const char *arg_str_value(const struct cmd_context *cmd, int a, const char *def)
 {
-	return arg_is_set(cmd, a) ? cmd->arg_values[a].value : def;
+	return arg_is_set(cmd, a) ? cmd->opt_arg_values[a].value : def;
 }
 
 const char *grouped_arg_str_value(const struct arg_values *av, int a, const char *def)
@@ -217,44 +302,44 @@ int32_t first_grouped_arg_int_value(const struct cmd_context *cmd, int a, const
 int32_t arg_int_value(const struct cmd_context *cmd, int a, const int32_t def)
 {
 	return (_cmdline.arg_props[a].flags & ARG_GROUPABLE) ?
-		first_grouped_arg_int_value(cmd, a, def) : (arg_is_set(cmd, a) ? cmd->arg_values[a].i_value : def);
+		first_grouped_arg_int_value(cmd, a, def) : (arg_is_set(cmd, a) ? cmd->opt_arg_values[a].i_value : def);
 }
 
 uint32_t arg_uint_value(const struct cmd_context *cmd, int a, const uint32_t def)
 {
-	return arg_is_set(cmd, a) ? cmd->arg_values[a].ui_value : def;
+	return arg_is_set(cmd, a) ? cmd->opt_arg_values[a].ui_value : def;
 }
 
 int64_t arg_int64_value(const struct cmd_context *cmd, int a, const int64_t def)
 {
-	return arg_is_set(cmd, a) ? cmd->arg_values[a].i64_value : def;
+	return arg_is_set(cmd, a) ? cmd->opt_arg_values[a].i64_value : def;
 }
 
 uint64_t arg_uint64_value(const struct cmd_context *cmd, int a, const uint64_t def)
 {
-	return arg_is_set(cmd, a) ? cmd->arg_values[a].ui64_value : def;
+	return arg_is_set(cmd, a) ? cmd->opt_arg_values[a].ui64_value : def;
 }
 
 /* No longer used.
 const void *arg_ptr_value(struct cmd_context *cmd, int a, const void *def)
 {
-	return arg_is_set(cmd, a) ? cmd->arg_values[a].ptr : def;
+	return arg_is_set(cmd, a) ? cmd->opt_arg_values[a].ptr : def;
 }
 */
 
 sign_t arg_sign_value(const struct cmd_context *cmd, int a, const sign_t def)
 {
-	return arg_is_set(cmd, a) ? cmd->arg_values[a].sign : def;
+	return arg_is_set(cmd, a) ? cmd->opt_arg_values[a].sign : def;
 }
 
 percent_type_t arg_percent_value(const struct cmd_context *cmd, int a, const percent_type_t def)
 {
-	return arg_is_set(cmd, a) ? cmd->arg_values[a].percent : def;
+	return arg_is_set(cmd, a) ? cmd->opt_arg_values[a].percent : def;
 }
 
 int arg_count_increment(struct cmd_context *cmd, int a)
 {
-	return cmd->arg_values[a].count++;
+	return cmd->opt_arg_values[a].count++;
 }
 
 int yes_no_arg(struct cmd_context *cmd __attribute__((unused)), struct arg_values *av)
@@ -700,121 +785,987 @@ int readahead_arg(struct cmd_context *cmd __attribute__((unused)), struct arg_va
 /*
  * Non-zero, positive integer, "all", or "unmanaged"
  */
+int vgmetadatacopies_arg(struct cmd_context *cmd, struct arg_values *av)
+{
+	if (!strcasecmp(av->value, "all")) {
+		av->ui_value = VGMETADATACOPIES_ALL;
+		return 1;
+	}
+
+	if (!strcasecmp(av->value, "unmanaged")) {
+		av->ui_value = VGMETADATACOPIES_UNMANAGED;
+		return 1;
+	}
+
+	return int_arg(cmd, av);
+}
+
+int pvmetadatacopies_arg(struct cmd_context *cmd, struct arg_values *av)
+{
+	int num;
+
+	if (!int_arg(cmd, av))
+		return 0;
+
+	num = av->i_value;
+
+	if ((num != 0) && (num != 1) && (num != 2))
+		return 0;
+
+	return 1;
+}
+
 int metadatacopies_arg(struct cmd_context *cmd, struct arg_values *av)
 {
-	if (!strncmp(cmd->command->name, "vg", 2)) {
-		if (!strcasecmp(av->value, "all")) {
-			av->ui_value = VGMETADATACOPIES_ALL;
-			return 1;
+	if (!strncmp(cmd->name, "pv", 2))
+		return pvmetadatacopies_arg(cmd, av);
+	if (!strncmp(cmd->name, "vg", 2))
+		return vgmetadatacopies_arg(cmd, av);
+	return 0;
+}
+
+int polloperation_arg(struct cmd_context *cmd, struct arg_values *av)
+{
+	if (!strcmp(av->value, "pvmove") ||
+	    !strcmp(av->value, "convert") ||
+	    !strcmp(av->value, "merge") ||
+	    !strcmp(av->value, "merge_thin"))
+		return 1;
+	return 0;
+}
+
+int writemostly_arg(struct cmd_context *cmd, struct arg_values *av)
+{
+	/* Could we verify that a PV arg looks like /dev/foo ? */
+	return 1;
+}
+
+int syncaction_arg(struct cmd_context *cmd, struct arg_values *av)
+{
+	if (!strcmp(av->value, "check") ||
+	    !strcmp(av->value, "repair"))
+		return 1;
+	return 0;
+}
+
+int reportformat_arg(struct cmd_context *cmd, struct arg_values *av)
+{
+	if (!strcmp(av->value, "basic") ||
+	    !strcmp(av->value, "json"))
+		return 1;
+	return 0;
+}
+
+int configreport_arg(struct cmd_context *cmd, struct arg_values *av)
+{
+	if (!strcmp(av->value, "log") ||
+	    !strcmp(av->value, "vg") ||
+	    !strcmp(av->value, "lv") ||
+	    !strcmp(av->value, "pv") ||
+	    !strcmp(av->value, "pvseg") ||
+	    !strcmp(av->value, "seg"))
+		return 1;
+	return 0;
+}
+
+int configtype_arg(struct cmd_context *cmd, struct arg_values *av)
+{
+	if (!strcmp(av->value, "current") ||
+	    !strcmp(av->value, "default") ||
+	    !strcmp(av->value, "diff") ||
+	    !strcmp(av->value, "full") ||
+	    !strcmp(av->value, "list") ||
+	    !strcmp(av->value, "missing") ||
+	    !strcmp(av->value, "new") ||
+	    !strcmp(av->value, "profilable") ||
+	    !strcmp(av->value, "profilable-command") ||
+	    !strcmp(av->value, "profilable-metadata"))
+		return 1;
+	return 0;
+}
+
+/*
+ * FIXME: there's been a confusing mixup among:
+ * resizeable, resizable, allocatable, allocation.
+ *
+ * resizeable and allocatable are the preferred,
+ * standard option names.
+ *
+ * The dispreferred "resizable" is always translated
+ * to the preferred resizeable.
+ *
+ * But, the dispreferred "allocation" name seems
+ * to translate to either or both resizeable
+ * and allocatable, it's not clear which.
+ */
+
+static int _opt_standard_to_synonym(const char *cmd_name, int opt)
+{
+	switch (opt) {
+	case mirrorlog_ARG:
+		return corelog_ARG;
+	case resizeable_ARG:
+		return resizable_ARG;
+	case allocatable_ARG:
+		return allocation_ARG;
+	case activate_ARG:
+		return available_ARG;
+	case rebuild_ARG:
+		return raidrebuild_ARG;
+	case syncaction_ARG:
+		return raidsyncaction_ARG;
+	case writemostly_ARG:
+		return raidwritemostly_ARG;
+	case minrecoveryrate_ARG:
+		return raidminrecoveryrate_ARG;
+	case maxrecoveryrate_ARG:
+		return raidmaxrecoveryrate_ARG;
+	case writebehind_ARG:
+		return raidwritebehind_ARG;
+	case virtualsize_ARG:
+		return virtualoriginsize_ARG;
+	case pvmetadatacopies_ARG:
+		if (!strncmp(cmd_name, "pv", 2))
+			return metadatacopies_ARG;
+		return 0;
+	case vgmetadatacopies_ARG:
+		if (!strncmp(cmd_name, "vg", 2))
+			return metadatacopies_ARG;
+		return 0;
+	}
+	return 0;
+}
+
+static int _opt_synonym_to_standard(const char *cmd_name, int opt)
+{
+	switch (opt) {
+	case corelog_ARG:
+		return mirrorlog_ARG;
+	case resizable_ARG:
+		return resizeable_ARG;
+	case allocation_ARG:
+		return allocatable_ARG;
+	case available_ARG:
+		return activate_ARG;
+	case raidrebuild_ARG:
+		return rebuild_ARG;
+	case raidsyncaction_ARG:
+		return syncaction_ARG;
+	case raidwritemostly_ARG:
+		return writemostly_ARG;
+	case raidminrecoveryrate_ARG:
+		return minrecoveryrate_ARG;
+	case raidmaxrecoveryrate_ARG:
+		return maxrecoveryrate_ARG;
+	case raidwritebehind_ARG:
+		return writebehind_ARG;
+	case virtualoriginsize_ARG:
+		return virtualsize_ARG;
+	case metadatacopies_ARG:
+		if (!strncmp(cmd_name, "pv", 2))
+			return pvmetadatacopies_ARG;
+		if (!strncmp(cmd_name, "vg", 2))
+			return vgmetadatacopies_ARG;
+		return 0;
+	}
+	return 0;
+}
+
+static void _add_getopt_arg(int arg_enum, char **optstrp, struct option **longoptsp);
+
+/*
+ * The valid args for a command name in general is a union of
+ * required_opt_args and optional_opt_args for all commands[]
+ * with the given name.
+ */
+
+static void _set_valid_args_for_command_name(int ci)
+{
+	int all_args[ARG_COUNT] = { 0 };
+	int num_args = 0;
+	int opt_enum; /* foo_ARG from args.h */
+	int opt_syn;
+	int i, ro, oo;
+
+	/*
+	 * all_args is indexed by the foo_ARG enum vals
+	 */
+
+	for (i = 0; i < COMMAND_COUNT; i++) {
+		if (strcmp(commands[i].name, command_names[ci].name))
+			continue;
+
+		for (ro = 0; ro < commands[i].ro_count; ro++) {
+			opt_enum = commands[i].required_opt_args[ro].opt;
+			all_args[opt_enum] = 1;
+
 		}
+		for (oo = 0; oo < commands[i].oo_count; oo++) {
+			opt_enum = commands[i].optional_opt_args[oo].opt;
+			all_args[opt_enum] = 1;
+		}
+	}
 
-		if (!strcasecmp(av->value, "unmanaged")) {
-			av->ui_value = VGMETADATACOPIES_UNMANAGED;
-			return 1;
+	for (i = 0; i < ARG_COUNT; i++) {
+		if (all_args[i]) {
+			opt_enum = _cmdline.arg_props[i].arg_enum;
+
+			command_names[ci].valid_args[num_args] = opt_enum;
+			num_args++;
+
+			/* Automatically recognize --extents in addition to --size. */
+			if (opt_enum == size_ARG) {
+				command_names[ci].valid_args[num_args] = extents_ARG;
+				num_args++;
+			}
+
+			/* Recognize synonyms */
+			if ((opt_syn = _opt_standard_to_synonym(command_names[ci].name, opt_enum))) {
+				command_names[ci].valid_args[num_args] = opt_syn;
+				num_args++;
+			}
+
+			/*
+			 * "--allocation" is a weird option that seems to be
+			 * a synonym for either allocatable or resizeable,
+			 * each which already have their own other synonyms,
+			 * so just add allocation whenever either is seen.
+			 */
+			if ((opt_enum == allocatable_ARG) || (opt_enum == resizeable_ARG)) {
+				command_names[ci].valid_args[num_args] = allocation_ARG;
+				num_args++;
+			}
 		}
 	}
 
-	return int_arg(cmd, av);
+	command_names[ci].num_args = num_args;
+}
+
+static struct command_name *_find_command_name(const char *name)
+{
+	int i;
+	
+	for (i = 0; i < MAX_COMMAND_NAMES; i++) {
+		if (!command_names[i].name)
+			break;
+		if (!strcmp(command_names[i].name, name))
+			return &command_names[i];
+	}
+	return NULL;
+}
+
+static struct command_function *_find_command_function(int command_line_enum)
+{
+	int i;
+
+	if (!command_line_enum)
+		return NULL;
+
+	for (i = 0; i < COMMAND_ID_COUNT; i++) {
+		if (command_functions[i].command_line_enum == command_line_enum)
+			return &command_functions[i];
+	}
+	return NULL;
+}
+
+static void _define_commands(void)
+{
+/* command-lines.h defines command[] structs, generated from command-lines.in */
+#include "command-lines.h" /* generated from command-lines.in */
 }
 
-static void __alloc(int size)
+void lvm_register_commands(void)
 {
-	if (!(_cmdline.commands = dm_realloc(_cmdline.commands, sizeof(*_cmdline.commands) * size))) {
-		log_fatal("Couldn't allocate memory.");
-		exit(ECMD_FAILED);
+	struct command_name *cname;
+	int i;
+
+	memset(&commands, 0, sizeof(commands));
+
+	_define_commands();
+
+	_cmdline.commands = commands;
+	_cmdline.num_commands = COMMAND_COUNT;
+
+	for (i = 0; i < COMMAND_COUNT; i++) {
+		if (!(cname = _find_command_name(commands[i].name)))
+			log_error(INTERNAL_ERROR "Failed to find command name %s.", commands[i].name);
+		commands[i].cname = cname;
+		commands[i].flags = cname->flags;
+		commands[i].functions = _find_command_function(commands[i].command_line_enum);
+	}
+
+	_cmdline.command_names = command_names;
+
+	for (i = 0; i < MAX_COMMAND_NAMES; i++) {
+		if (!command_names[i].name)
+			break;
+		_cmdline.num_command_names++;
 	}
 
-	_cmdline.commands_size = size;
+	for (i = 0; i < _cmdline.num_command_names; i++)
+		_set_valid_args_for_command_name(i);
+}
+
+struct lv_props *get_lv_prop(int lvp_enum)
+{
+	if (!lvp_enum)
+		return NULL;
+	return &_lv_props[lvp_enum];
+}
+
+struct lv_types *get_lv_type(int lvt_enum)
+{
+	if (!lvt_enum)
+		return NULL;
+	return &_lv_types[lvt_enum];
 }
 
-static void _alloc_command(void)
+/*
+ * Also see merge_synonym().  The command definitions
+ * are written using just one variation of the option
+ * name (opt below).  This function checks if the user
+ * entered a synonym (arg_is_set).
+ */
+
+static int _opt_synonym_is_set(struct cmd_context *cmd, int opt_std)
 {
-	if (!_cmdline.commands_size)
-		__alloc(32);
+	int opt_syn = _opt_standard_to_synonym(cmd->name, opt_std);
 
-	if (_cmdline.commands_size <= _cmdline.num_commands)
-		__alloc(2 * _cmdline.commands_size);
+	return opt_syn && arg_is_set(cmd, opt_syn);
 }
 
-static void _create_new_command(const char *name, command_fn command,
-				unsigned flags,
-				const char *desc, const char *usagestr,
-				int nargs, int *args)
+static int _command_ignore_opt_matches(struct cmd_context *cmd, int ci, int io)
 {
-	struct command *nc;
+	int opt_enum = commands[ci].ignore_opt_args[io].opt;
 
-	_alloc_command();
+	if (val_bit_is_set(commands[ci].ignore_opt_args[io].def.val_bits, conststr_VAL)) {
+		if (!strcmp(commands[ci].ignore_opt_args[io].def.str, arg_str_value(cmd, opt_enum, "")))
+			return 1;
+		return 0;
+	}
 
-	nc = _cmdline.commands + _cmdline.num_commands++;
+	if (val_bit_is_set(commands[ci].ignore_opt_args[io].def.val_bits, constnum_VAL)) {
+		if (commands[ci].ignore_opt_args[io].def.num == arg_int_value(cmd, opt_enum, 0))
+			return 1;
+		return 0;
+	}
 
-	nc->name = name;
-	nc->desc = desc;
-	nc->usage = usagestr;
-	nc->fn = command;
-	nc->flags = flags;
-	nc->num_args = nargs;
-	nc->valid_args = args;
+	return 1;
 }
 
-static void _register_command(const char *name, command_fn fn, const char *desc,
-			      unsigned flags, const char *usagestr, ...)
+static int _command_required_opt_matches(struct cmd_context *cmd, int ci, int ro)
 {
-	int nargs = 0, i;
-	int *args;
-	va_list ap;
+	int opt_enum = commands[ci].required_opt_args[ro].opt;
 
-	/* count how many arguments we have */
-	va_start(ap, usagestr);
-	while (va_arg(ap, int) >= 0)
-		 nargs++;
-	va_end(ap);
+	if (arg_is_set(cmd, opt_enum) || _opt_synonym_is_set(cmd, opt_enum))
+		goto check_val;
 
-	/* allocate space for them */
-	if (!(args = dm_malloc(sizeof(*args) * nargs))) {
-		log_fatal("Out of memory.");
-		exit(ECMD_FAILED);
+	/*
+	 * For some commands, --size and --extents are interchangable,
+	 * but command[] definitions use only --size.
+	 */
+	if ((opt_enum == size_ARG) && arg_is_set(cmd, extents_ARG)) {
+		if (!strcmp(commands[ci].name, "lvcreate") ||
+		    !strcmp(commands[ci].name, "lvresize") ||
+		    !strcmp(commands[ci].name, "lvextend") ||
+		    !strcmp(commands[ci].name, "lvreduce"))
+			goto check_val;
 	}
 
-	/* fill them in */
-	va_start(ap, usagestr);
-	for (i = 0; i < nargs; i++)
-		args[i] = va_arg(ap, int);
-	va_end(ap);
+	return 0;
+
+	/*
+	 * If the definition requires a literal string or number, check
+	 * that the arg value matches.
+	 */
 
-	/* enter the command in the register */
-	_create_new_command(name, fn, flags, desc, usagestr, nargs, args);
+check_val:
+	if (val_bit_is_set(commands[ci].required_opt_args[ro].def.val_bits, conststr_VAL)) {
+		if (!strcmp(commands[ci].required_opt_args[ro].def.str, arg_str_value(cmd, opt_enum, "")))
+			return 1;
+
+		/* Special case: "raid0" (any raid<N>), matches command def "raid" */
+		if (!strcmp(commands[ci].required_opt_args[ro].def.str, "raid") &&
+		    !strncmp(arg_str_value(cmd, opt_enum, ""), "raid", 4))
+			return 1;
+
+		return 0;
+	}
+
+	if (val_bit_is_set(commands[ci].required_opt_args[ro].def.val_bits, constnum_VAL)) {
+		if (commands[ci].required_opt_args[ro].def.num == arg_int_value(cmd, opt_enum, 0))
+			return 1;
+		return 0;
+	}
+
+	return 1;
 }
 
-void lvm_register_commands(void)
+static int _command_required_pos_matches(struct cmd_context *cmd, int ci, int rp, char **argv)
 {
-#define xx(a, b, c, d...) _register_command(# a, a, b, c, ## d, \
-					    driverloaded_ARG, \
-					    debug_ARG, help_ARG, help2_ARG, \
-					    version_ARG, verbose_ARG, \
-					    yes_ARG, \
-					    quiet_ARG, config_ARG, \
-					    commandprofile_ARG, \
-					    profile_ARG, -1);
-#include "commands.h"
-#undef xx
+	const char *name;
+
+	/*
+	 * rp is the index in required_pos_args[] of the required positional arg.
+	 * The pos values begin with 1, so the first positional arg has
+	 * pos 1, rp 0.
+	 */
+	if (argv[rp]) {
+		/* FIXME: can we match object type better than just checking something exists? */
+		/* Some cases could be validated by looking at defs.types and at the value. */
+		return 1;
+	}
+
+	/*
+	 * If Select is specified as a pos arg, then that pos arg can be
+	 * empty if --select is used.
+	 */
+	if ((val_bit_is_set(commands[ci].required_pos_args[rp].def.val_bits, select_VAL)) &&
+	    arg_is_set(cmd, select_ARG))
+		return 1;
+
+	/*
+	 * For an lvcreate command with VG as the first required positional arg,
+	 * the VG position is allowed to be empty if --name VG/LV is used, or if the
+	 * LVM_VG_NAME env var is set.
+	 *
+	 * --thinpool VG/LV and --cachepool VG/LV can also function like --name 
+	 * to provide the VG name in place of the positional arg.
+	 */
+	if (!strcmp(cmd->name, "lvcreate") &&
+	    (rp == 0) &&
+	    val_bit_is_set(commands[ci].required_pos_args[rp].def.val_bits, vg_VAL) &&
+	    (arg_is_set(cmd, name_ARG) || arg_is_set(cmd, thinpool_ARG) || arg_is_set(cmd, cachepool_ARG))) {
+		if ((name = arg_str_value(cmd, name_ARG, NULL))) {
+			if (strstr(name, "/") || getenv("LVM_VG_NAME"))
+				return 1;
+		}
+
+		/* FIXME: does LVM_VG_NAME also work with --thinpool/--cachepool ? */
+
+		if ((name = arg_str_value(cmd, thinpool_ARG, NULL))) {
+			if (strstr(name, "/"))
+				return 1;
+		}
+
+		if ((name = arg_str_value(cmd, cachepool_ARG, NULL))) {
+			if (strstr(name, "/"))
+				return 1;
+		}
+	}
+
+	return 0;
 }
 
-static struct command *_find_command(const char *name)
+
+#define HELP_LINE_SIZE 1024
+
+static void _print_usage(const char *usage, int only_required)
 {
-	int i;
-	const char *base;
+	char buf[HELP_LINE_SIZE];
+	int optional_ui = 0;
+	int optional_pos_ui = 0;
+	int ui;
+	int bi;
 
-	base = last_path_component(name);
+	if (!usage || !strlen(usage))
+		return;
 
-	for (i = 0; i < _cmdline.num_commands; i++) {
-		if (!strcmp(base, _cmdline.commands[i].name))
+	/*
+	 * copy the required opt_args/pos_args
+	 *
+ 	 * The optional portions of the usage string are enclosed
+	 * in [] and follow the required portions.
+	 *
+	 * The optional portion begins with [ followed by a space,
+	 * i.e. "[ " to distinguish the option usage which may
+	 * include [ in cases like --option Number[units].
+	 */
+
+	memset(buf, 0, sizeof(buf));
+	bi = 0;
+
+	for (ui = 0; ui < strlen(usage); ui++) {
+		if (!bi && ((usage[ui] == ' ') || (usage[ui] == '\n')))
+			continue;
+
+		/* The first "[ " indicates the start of the optional opt_args. */
+		if ((usage[ui] == '[') && (usage[ui+1] == ' ')) {
+			optional_ui = ui;
+			break;
+		}
+
+		if (usage[ui] == '\0')
+			break;
+
+		if (usage[ui] == '(') {
+			buf[bi++] = '\n';
+			buf[bi++] = '\t';
+		}
+
+		buf[bi++] = usage[ui];
+
+		if (usage[ui] == ')') {
+			buf[bi++] = '\n';
+			buf[bi++] = '\t';
+		}
+
+		if (usage[ui] == ',') {
+			buf[bi++] = '\n';
+			buf[bi++] = '\t';
+			buf[bi++] = ' ';
+		}
+
+		if (bi == (HELP_LINE_SIZE - 1))
 			break;
 	}
 
-	if (i >= _cmdline.num_commands)
-		return 0;
+	/*
+	 * print the required opt_args/pos_args
+	 */
+
+	if (bi)
+		log_print("%s", buf);
+
+	if (only_required)
+		return;
+
+	/*
+	 * copy the optional opt_args
+	 */
+
+	if (!optional_ui)
+		goto out;
+
+	memset(buf, 0, sizeof(buf));
+	bi = 0;
+
+	for (ui = optional_ui; ui < strlen(usage); ui++) {
+
+		/* The second "[ " indicates the start of the optional pos_args. */
+		if ((ui > optional_ui) && (usage[ui] == '[') && (usage[ui+1] == ' ')) {
+			optional_pos_ui = ui;
+			break;
+		}
+
+		if (usage[ui] == '\0')
+			break;
+		if (usage[ui] == '\n')
+			break;
+
+		if (!bi)
+			buf[bi++] = '\t';
+
+		buf[bi++] = usage[ui];
+
+		if (usage[ui] == ',') {
+			buf[bi++] = '\n';
+			buf[bi++] = '\t';
+			buf[bi++] = ' ';
+		}
+
+		if (bi == (HELP_LINE_SIZE - 1))
+			break;
+	}
+
+	/*
+	 * print the optional opt_args
+	 */
+
+	if (bi)
+		log_print("%s", buf);
+
+	/*
+	 * copy the optional pos_args
+	 */
+
+	if (!optional_pos_ui)
+		goto out;
+
+	memset(buf, 0, sizeof(buf));
+	bi = 0;
+
+	for (ui = optional_pos_ui; ui < strlen(usage); ui++) {
+		if (usage[ui] == '\0')
+			break;
+		if (usage[ui] == '\n')
+			break;
 
-	return _cmdline.commands + i;
+		if (!bi)
+			buf[bi++] = '\t';
+
+		buf[bi++] = usage[ui];
+
+		if (bi == (HELP_LINE_SIZE - 1))
+			break;
+	}
+
+	/*
+	 * print the optional pos_args
+	 */
+
+	if (bi)
+		log_print("%s", buf);
+ out:
+	return;
+}
+
+static void _print_description(int ci)
+{
+	const char *desc = _cmdline.commands[ci].desc;
+	char buf[HELP_LINE_SIZE] = {0};
+	int di = 0;
+	int bi = 0;
+
+	for (di = 0; di < strlen(desc); di++) {
+		if (!strncmp(&desc[di], "DESC:", 5)) {
+			if (bi) {
+				buf[bi] = '\0';
+				log_print("%s", buf);
+				memset(buf, 0, sizeof(buf));
+				bi = 0;
+			}
+			/* skip DESC: */
+			di += 5;
+			continue;
+		}
+
+		if (!bi && desc[di] == ' ')
+			continue;
+
+		buf[bi++] = desc[di];
+
+		if (bi == (HELP_LINE_SIZE - 1))
+			break;
+	}
+
+	if (bi) {
+		buf[bi] = '\0';
+		log_print("%s", buf);
+	}
+}
+
+/*
+ * Match what the user typed with a one specific command definition/prototype
+ * from commands[].  If nothing matches, it's not a valid command.  The match
+ * is based on command name, required opt args and required pos args.
+ *
+ * Find an entry in the commands array that matches based the arg values.
+ *
+ * If the cmd has opt or pos args set that are not accepted by command,
+ * we can: silently ignore them, warn they are not being used, or fail.
+ * Default should probably be to warn and continue.
+ *
+ * For each command[i], check how many required opt/pos args cmd matches.
+ * Save the command[i] that matches the most.
+ *
+ * commands[i].cmd_flags & CMD_FLAG_ONE_REQUIRED_OPT means
+ * any one item from commands[i].required_opt_args needs to be
+ * set to match.
+ *
+ * required_pos_args[0].types & select_VAL means
+ * argv[] in that pos can be NULL if arg_is_set(select_ARG)
+ */
+
+/* The max number of unused options we keep track of to warn about */
+#define MAX_UNUSED_COUNT 8
+
+static struct command *_find_command(struct cmd_context *cmd, const char *path, int *argc, char **argv)
+{
+	const char *name;
+	char buf[64];
+	int match_required, match_ro, match_rp, match_type, match_unused, mismatch_required;
+	int best_i = 0, best_required = 0, best_type = 0, best_unused = 0;
+	int close_i = 0, close_ro = 0, close_type;
+	int temp_unused_options[MAX_UNUSED_COUNT];
+	int temp_unused_count;
+	int best_unused_options[MAX_UNUSED_COUNT] = { 0 };
+	int best_unused_count = 0;
+	int opts_match_count, opts_unmatch_count;
+	int ro, rp;
+	int i, j;
+	int opt_enum, opt_i;
+	int accepted, count;
+
+	name = last_path_component(path);
+
+	for (i = 0; i < COMMAND_COUNT; i++) {
+		if (strcmp(name, commands[i].name))
+			continue;
+
+		/* For help and version just return the first entry with matching name. */
+		if (arg_is_set(cmd, help_ARG) || arg_is_set(cmd, help2_ARG) || arg_is_set(cmd, version_ARG))
+			return &commands[i];
+
+		match_required = 0;    /* required parameters that match */
+		match_ro = 0;          /* required opt_args that match */
+		match_rp = 0;          /* required pos_args that match */
+		match_type = 0;        /* type arg matches */
+		match_unused = 0;      /* options set that are not accepted by command */
+		mismatch_required = 0; /* required parameters that do not match */
+		temp_unused_count = 0;
+		memset(&temp_unused_options, 0, sizeof(temp_unused_options));
+
+		/* if the command name alone is enough, then that's a match */
+
+		if (!commands[i].ro_count && !commands[i].rp_count)
+			match_required = 1;
+
+		/* match required_opt_args */
+
+		for (ro = 0; ro < commands[i].ro_count; ro++) {
+			if (_command_required_opt_matches(cmd, i, ro)) {
+				/* log_warn("match %d ro opt %d", i, commands[i].required_opt_args[ro].opt); */
+				match_required++;
+				match_ro++;
+
+				if (commands[i].required_opt_args[ro].opt == type_ARG)
+					match_type = 1;
+			} else {
+				/* cmd is missing a required opt arg */
+				/* log_warn("mismatch %d ro opt %d", i, commands[i].required_opt_args[ro].opt); */
+				mismatch_required++;
+			}
+		}
+
+		/*
+		 * Special case where missing required_opt_arg's does not matter
+		 * if one required_opt_arg did match.
+		 */
+		if (commands[i].cmd_flags & CMD_FLAG_ONE_REQUIRED_OPT) {
+			if (match_ro) {
+				/* one or more of the required_opt_args is used */
+				mismatch_required = 0;
+			} else {
+				/* not even one of the required_opt_args is used */
+				mismatch_required = 1;
+			}
+		}
+
+		/* match required_pos_args */
+
+		for (rp = 0; rp < commands[i].rp_count; rp++) {
+			if (_command_required_pos_matches(cmd, i, rp, argv)) {
+				/* log_warn("match %d rp %d", i, commands[i].required_pos_args[rp].pos); */
+				match_required++;
+				match_rp++;
+			} else {
+				/* cmd is missing a required pos arg */
+				/* log_warn("mismatch %d rp %d", i, commands[i].required_pos_args[rp].pos); */
+				mismatch_required++;
+			}
+		}
+
+		/* if cmd is missing any required opt/pos args, it can't be this command. */
+
+		if (mismatch_required) {
+			/* save "closest" command that doesn't match */
+			if ((match_type && !close_type) ||
+			    ((match_type == close_type) && (match_ro > close_ro))) {
+				close_i = i;
+				close_ro = match_ro;
+				close_type = match_type;
+			}
+			continue;
+		}
+
+		if (!match_required)
+			continue;
+
+		/* Count the command name as a match if all the required opt/pos args match. */
+
+		if ((commands[i].ro_count || commands[i].rp_count) && (match_ro || match_rp))
+			match_required++;
+
+		/* log_warn("command %d has match_required %d match_ro %d match_rp %d",
+			 i, match_required, match_ro, match_rp); */
+
+		/* Count how many options cmd has set that are not accepted by commands[i]. */
+		/* FIXME: also count unused positional args? */
+
+		for (opt_i = 0; opt_i < ARG_COUNT; opt_i++) {
+			if (!arg_is_set(cmd, opt_i))
+				continue;
+
+			if (!(opt_enum = _opt_synonym_to_standard(cmd->name, opt_i)))
+				opt_enum = opt_i;
+
+			/* extents are not used in command definitions */
+			if (opt_enum == extents_ARG)
+				continue;
+
+			accepted = 0;
+
+			/* NB in some cases required_opt_args are optional */
+			for (j = 0; j < commands[i].ro_count; j++) {
+				if (commands[i].required_opt_args[j].opt == opt_enum) {
+					accepted = 1;
+					break;
+				}
+			}
+
+			if (accepted)
+				continue;
+
+			for (j = 0; j < commands[i].oo_count; j++) {
+				if (commands[i].optional_opt_args[j].opt == opt_enum) {
+					accepted = 1;
+					break;
+				}
+			}
+
+			for (j = 0; j < commands[i].io_count; j++) {
+				if ((commands[i].ignore_opt_args[j].opt == opt_enum) &&
+				    _command_ignore_opt_matches(cmd, i, j)) {
+					accepted = 1;
+					break;
+				}
+			}
+
+			if (!accepted) {
+				match_unused++;
+				if (temp_unused_count < MAX_UNUSED_COUNT)
+					temp_unused_options[temp_unused_count++] = opt_enum;
+			}
+		}
+
+		/*
+		 * Choose the best match, which in general is the command with
+		 * the most matching required_{opt,pos}.
+		 *
+		 * A match is better if:
+		 * . more required opt/pos args match
+		 * . type arg matches when other doesn't
+		 * . those being equal, less unused options
+		 */
+
+		if (!best_required || (match_required > best_required) || (match_type > best_type) ||
+		    ((match_required == best_required) && (match_type == best_type) && (match_unused < best_unused))) {
+			/* log_warn("best %d has match_required %d match_ro %d match_rp %d",
+				 i, match_required, match_ro, match_rp); */
+			best_i = i;
+			best_required = match_required;
+			best_type = match_type;
+			best_unused = match_unused;
+			best_unused_count = temp_unused_count;
+			memcpy(&best_unused_options, &temp_unused_options, sizeof(best_unused_options));
+		}
+	}
+
+	if (!best_required) {
+		/* cmd did not have all the required opt/pos args of any command */
+		log_error("Failed to find a matching command definition.");
+		if (close_ro) {
+			log_warn("Closest command usage is:");
+			_print_usage(_cmdline.commands[close_i].usage, 1);
+		}
+		return NULL;
+	}
+
+	/*
+	 * If the user passed an option that is not accepted by the matched
+	 * command, then fail.
+	 *
+	 * FIXME: it might be nice to have a config setting that would turn
+	 * these into warnings, and just ignore the unused options.
+	 */
+
+	if (best_unused_count) {
+		for (i = 0; i < best_unused_count; i++) {
+			log_error("Invalid option for command (%s %d): %s.",
+				  commands[best_i].command_line_id, best_i,
+				  arg_long_option_name(best_unused_options[i]));
+		}
+		return NULL;
+	}
+
+	/*
+	 * If the user provided a positional arg that is not accepted by
+	 * the mached command, then fail.
+	 *
+	 * If the last required_pos_arg or the last optional_pos_arg may repeat,
+	 * then there won't be unused positional args.
+	 *
+	 * FIXME: same question as above, should there be a config setting
+	 * to just warn/ignore about unused positional args?
+	 */
+
+	count = commands[best_i].rp_count;
+	if (count && (commands[best_i].required_pos_args[count - 1].def.flags & ARG_DEF_FLAG_MAY_REPEAT))
+		goto out;
+
+	count = commands[best_i].op_count;
+	if (count && (commands[best_i].optional_pos_args[count - 1].def.flags & ARG_DEF_FLAG_MAY_REPEAT))
+		goto out;
+
+	for (count = 0; ; count++) {
+		if (!argv[count])
+			break;
+
+		if (count >= (commands[best_i].rp_count + commands[best_i].op_count)) {
+			log_error("Invalid positional argument for command (%s %d): %s.",
+				  commands[best_i].command_line_id, best_i, argv[count]);
+
+			/* FIXME: to warn/ignore, clear so it can't be used when processing. */
+			/*
+			argv[count] = NULL;
+			(*argc)--;
+			*/
+			return NULL;
+		}
+	}
+
+out:
+	/*
+	 * Check any rules related to option combinations.
+	 * Other rules are checked after VG is read.
+	 */
+
+	for (i = 0; i < commands[best_i].rule_count; i++) {
+		struct cmd_rule *rule;
+		rule = &commands[best_i].rules[i];
+
+		/*
+		 * The rule wants to validate options (check_opts). That can be
+		 * done here if the only qualification for the validation is
+		 * other options (and not specific LV type or LV property which
+		 * are not known here.)
+		 */
+
+		if (rule->check_opts_count && !rule->lvt_bits && !rule->lvp_bits) {
+			/*
+			 * When no opt is specified for applying the rule, then
+			 * the rule is always applied, otherwise the rule is
+			 * applied when the specific option is set.
+			 */
+			if (rule->opts_count &&
+			    !opt_in_list_is_set(cmd, rule->opts, rule->opts_count, NULL, NULL))
+				continue;
+
+			opt_in_list_is_set(cmd, rule->check_opts, rule->check_opts_count,
+					   &opts_match_count, &opts_unmatch_count);
+
+			if (opts_match_count && (rule->rule == RULE_INVALID)) {
+				memset(buf, 0, sizeof(buf));
+				opt_array_to_str(cmd, rule->check_opts, rule->check_opts_count, buf, sizeof(buf));
+				log_error("Invalid options for command (%s %d): %s",
+					  commands[best_i].command_line_id, best_i, buf);
+				return NULL;
+			}
+
+			if (opts_unmatch_count && (rule->rule == RULE_REQUIRE)) {
+				memset(buf, 0, sizeof(buf));
+				opt_array_to_str(cmd, rule->check_opts, rule->check_opts_count, buf, sizeof(buf));
+				log_error("Required options for command (%s %d): %s",
+					  commands[best_i].command_line_id, best_i, buf);
+				return NULL;
+			}
+		}
+	}
+
+	log_debug("command line id: %s %d", commands[best_i].command_line_id, best_i);
+
+	return &commands[best_i];
 }
 
 static void _short_usage(const char *name)
@@ -822,110 +1773,234 @@ static void _short_usage(const char *name)
 	log_error("Run `%s --help' for more information.", name);
 }
 
-static int _usage(const char *name)
+static int _usage(const char *name, int help_count)
 {
-	struct command *com = _find_command(name);
+	struct command_name *cname = _find_command_name(name);
+	const char *usage_common = NULL;
+	int i;
 
-	if (!com) {
+	if (!cname) {
 		log_print("%s: no such command.", name);
 		return 0;
 	}
 
-	log_print("%s: %s\n\n%s", com->name, com->desc, com->usage);
+	log_print("%s - %s\n", name, cname->desc);
+
+	for (i = 0; i < _cmdline.num_commands; i++) {
+		if (strcmp(_cmdline.commands[i].name, name))
+			continue;
+
+		if ((_cmdline.commands[i].cmd_flags & CMD_FLAG_SECONDARY_SYNTAX) && (help_count < 3))
+			continue;
+
+		if (strlen(_cmdline.commands[i].desc))
+			_print_description(i);
+
+		usage_common = _cmdline.commands[i].usage_common;
+
+		_print_usage(_cmdline.commands[i].usage, 0);
+		log_print(" "); /* for built-in \n */
+	}
+
+	/* Common options are printed once for all variants of a command name. */
+	if (usage_common) {
+		log_print("Common options:");
+		_print_usage(usage_common, 0);
+		log_print(" "); /* for built-in \n */
+	}
+
+	if (help_count > 1) {
+		/*
+		 * Excluding commonly understood syntax style like the meanings of:
+		 * [ ] for optional, ... for repeatable, | for one of the following,
+		 * -- for an option name, lower case strings and digits for literals.
+		 */
+		log_print("Usage notes:");
+		log_print(". Variable parameters are: Number, String, PV, VG, LV, Tag.");
+		log_print(". Select indicates that a required positional parameter can");
+		log_print("  be omitted if the --select option is used.");
+		log_print(". --size Number can be replaced with --extents NumberExtents.");
+		log_print(". When --name is omitted from lvcreate, a new LV name is");
+		log_print("  generated with the \"lvol\" prefix and a unique numeric suffix.");
+		log_print(". The required VG parameter in lvcreate may be omitted when");
+		log_print("  the VG name is included in another option, e.g. --name VG/LV.");
+		log_print(". For required options listed in parentheses, e.g. (--A, --B),");
+		log_print("  any one is required, after which the others are optional.");
+		log_print(". The _new suffix indicates the VG or LV must not yet exist.");
+		log_print(". LV followed by _<type> indicates that an LV of the given type");
+		log_print("  is required.  (raid represents any raid<N> type.)");
+		log_print(". Input units are always treated as base two values, regardless of");
+		log_print("  unit capitalization, e.g. 'k' and 'K' both refer to 1024.");
+		log_print(". The default input unit is specified by letter, followed by |unit");
+		log_print("  which represents other possible input units: bBsSkKmMgGtTpPeE.");
+		log_print(". Output units can be specified with the --units option, for which");
+		log_print("  lower/upper case letters refer to base 2/10 values.");
+		log_print(". Use --help --help --help to print secondary command syntax");
+		log_print("  formats that are recognized, e.g. for compatibility.");
+		log_print(". See man pages for short option equivalents of long option names,");
+		log_print("  and for more detailed descriptions of variable parameters.");
+	}
+
 	return 1;
 }
 
 /*
+ * Sets up the arguments to pass to getopt_long().
+ *
+ * getopt_long() takes a string of short option characters
+ * where the char is followed by ":" if the option takes an arg,
+ * e.g. "abc:d:"  This string is created in optstrp.
+ *
+ * getopt_long() also takes an array of struct option which
+ * has the name of the long option, if it takes an arg, etc,
+ * e.g.
+ *
+ * option long_options[] = {
+ * 	{ "foo", required_argument, 0,  0  },
+ * 	{ "bar", no_argument,       0, 'b' }
+ * };
+ *
+ * this array is created in longoptsp.
+ *
+ * Original comment:
  * Sets up the short and long argument.  If there
  * is no short argument then the index of the
  * argument in the the_args array is set as the
  * long opt value.  Yuck.  Of course this means we
  * can't have more than 'a' long arguments.
  */
-static void _add_getopt_arg(int arg, char **ptr, struct option **o)
+
+static void _add_getopt_arg(int arg_enum, char **optstrp, struct option **longoptsp)
 {
-	struct arg_props *a = _cmdline.arg_props + arg;
+	struct arg_props *a = _cmdline.arg_props + arg_enum;
 
 	if (a->short_arg) {
-		*(*ptr)++ = a->short_arg;
+		*(*optstrp)++ = a->short_arg;
 
-		if (a->fn)
-			*(*ptr)++ = ':';
+		if (a->val_enum)
+			*(*optstrp)++ = ':';
 	}
 #ifdef HAVE_GETOPTLONG
+	/* long_arg is "--foo", so +2 is the offset of the name after "--" */
+
 	if (*(a->long_arg + 2)) {
-		(*o)->name = a->long_arg + 2;
-		(*o)->has_arg = a->fn ? 1 : 0;
-		(*o)->flag = NULL;
+		(*longoptsp)->name = a->long_arg + 2;
+		(*longoptsp)->has_arg = a->val_enum ? 1 : 0;
+		(*longoptsp)->flag = NULL;
+
+		/*
+		 * When getopt_long() sees an option that has an associated
+		 * single letter, it returns the ascii value of that letter.
+		 * e.g. getopt_long() returns 100 for '-d' or '--debug'
+		 * (100 is the ascii value of 'd').
+		 *
+		 * When getopt_long() sees an option that does not have an
+		 * associated single letter, it returns the value of the
+		 * the enum for that long option name plus 128.
+		 * e.g. getopt_long() returns 139 for --cachepool
+		 * (11 is the enum value for --cachepool, so 11+128)
+		 */
+
 		if (a->short_arg)
-			(*o)->val = a->short_arg;
+			(*longoptsp)->val = a->short_arg;
 		else
-			(*o)->val = arg + 128;
-		(*o)++;
+			(*longoptsp)->val = arg_enum + 128;
+		(*longoptsp)++;
 	}
 #endif
 }
 
-static int _find_arg(struct command *com, int opt)
+/*
+ * getopt_long() has returned goval which indicates which option it's found.
+ * We need to translate that goval to an enum value from the args array.
+ * 
+ * For options with both long and short forms, goval is the character value
+ * of the short option.  For options with only a long form, goval is the
+ * corresponding enum value plus 128.
+ *
+ * The trick with character values is that different long options share the
+ * same single-letter short form.  So, we have to translate goval to an
+ * enum using only the set of valid options for the given command.  And,
+ * a command name is not allowed to use two different long options that
+ * have the same single-letter short form.
+ */
+
+static int _find_arg(const char *cmd_name, int goval)
 {
-	struct arg_props *a;
-	int i, arg;
+	struct command_name *cname;
+	int arg_enum;
+	int i;
 
-	for (i = 0; i < com->num_args; i++) {
-		arg = com->valid_args[i];
-		a = _cmdline.arg_props + arg;
+	if (!(cname = _find_command_name(cmd_name)))
+		return -1;
 
-		/*
-		 * opt should equal either the
-		 * short arg, or the index into
-		 * the_args.
-		 */
-		if ((a->short_arg && (opt == a->short_arg)) ||
-		    (!a->short_arg && (opt == (arg + 128))))
-			return arg;
+	for (i = 0; i < cname->num_args; i++) {
+		arg_enum = cname->valid_args[i];
+
+		/* assert arg_enum == _cmdline.arg_props[arg_enum].arg_enum */
+
+		/* the value returned by getopt matches the ascii value of single letter option */
+		if (_cmdline.arg_props[arg_enum].short_arg && (goval == _cmdline.arg_props[arg_enum].short_arg))
+			return arg_enum;
+
+		/* the value returned by getopt matches the enum value plus 128 */
+		if (!_cmdline.arg_props[arg_enum].short_arg && (goval == (arg_enum + 128)))
+			return arg_enum;
 	}
 
 	return -1;
 }
 
-static int _process_command_line(struct cmd_context *cmd, int *argc,
-				 char ***argv)
+static int _process_command_line(struct cmd_context *cmd, int *argc, char ***argv)
 {
-	int i, opt, arg;
 	char str[((ARG_COUNT + 1) * 2) + 1], *ptr = str;
 	struct option opts[ARG_COUNT + 1], *o = opts;
 	struct arg_props *a;
 	struct arg_values *av;
 	struct arg_value_group_list *current_group = NULL;
+	struct command_name *cname;
+	int arg_enum; /* e.g. foo_ARG */
+	int goval;    /* the number returned from getopt_long identifying what it found */
+	int i;
+
+	if (!(cname = _find_command_name(cmd->name)))
+		return_0;
 
-	if (!(cmd->arg_values = dm_pool_zalloc(cmd->mem, sizeof(*cmd->arg_values) * ARG_COUNT))) {
+	if (!(cmd->opt_arg_values = dm_pool_zalloc(cmd->mem, sizeof(*cmd->opt_arg_values) * ARG_COUNT))) {
 		log_fatal("Unable to allocate memory for command line arguments.");
 		return 0;
 	}
 
-	/* fill in the short and long opts */
-	for (i = 0; i < cmd->command->num_args; i++)
-		_add_getopt_arg(cmd->command->valid_args[i], &ptr, &o);
+	/*
+	 * create the short-form character array (str) and the long-form option
+	 * array (opts) to pass to the getopt_long() function.  IOW we generate
+	 * the arguments to pass to getopt_long() from the args.h/arg_props data.
+	 */
+	for (i = 0; i < cname->num_args; i++)
+		_add_getopt_arg(cname->valid_args[i], &ptr, &o);
 
 	*ptr = '\0';
 	memset(o, 0, sizeof(*o));
 
-	/* initialise getopt_long & scan for command line switches */
 	optarg = 0;
 	optind = OPTIND_INIT;
-	while ((opt = GETOPTLONG_FN(*argc, *argv, str, opts, NULL)) >= 0) {
+	while ((goval = GETOPTLONG_FN(*argc, *argv, str, opts, NULL)) >= 0) {
 
-		if (opt == '?')
+		if (goval == '?')
 			return 0;
 
-		if ((arg = _find_arg(cmd->command, opt)) < 0) {
+		/*
+		 * translate the option value used by getopt into the enum
+		 * value (e.g. foo_ARG) from the args array.
+		 */
+		if ((arg_enum = _find_arg(cmd->name, goval)) < 0) {
 			log_fatal("Unrecognised option.");
 			return 0;
 		}
 
-		a = _cmdline.arg_props + arg;
+		a = _cmdline.arg_props + arg_enum;
 
-		av = &cmd->arg_values[arg];
+		av = &cmd->opt_arg_values[arg_enum];
 
 		if (a->flags & ARG_GROUPABLE) {
 			/*
@@ -935,10 +2010,10 @@ static int _process_command_line(struct cmd_context *cmd, int *argc,
 			 *   - or if argument has higher priority than current group.
 			 */
 			if (!current_group ||
-			    (current_group->arg_values[arg].count && !(a->flags & ARG_COUNTABLE)) ||
+			    (current_group->arg_values[arg_enum].count && !(a->flags & ARG_COUNTABLE)) ||
 			    (current_group->prio < a->prio)) {
 				/* FIXME Reduce size including only groupable args */
-				if (!(current_group = dm_pool_zalloc(cmd->mem, sizeof(struct arg_value_group_list) + sizeof(*cmd->arg_values) * ARG_COUNT))) {
+				if (!(current_group = dm_pool_zalloc(cmd->mem, sizeof(struct arg_value_group_list) + sizeof(*cmd->opt_arg_values) * ARG_COUNT))) {
 					log_fatal("Unable to allocate memory for command line arguments.");
 					return 0;
 				}
@@ -948,7 +2023,7 @@ static int _process_command_line(struct cmd_context *cmd, int *argc,
 			}
 			/* Maintain total argument count as well as count within each group */
 			av->count++;
-			av = &current_group->arg_values[arg];
+			av = &current_group->arg_values[arg_enum];
 		}
 
 		if (av->count && !(a->flags & ARG_COUNTABLE)) {
@@ -960,7 +2035,7 @@ static int _process_command_line(struct cmd_context *cmd, int *argc,
 			return 0;
 		}
 
-		if (a->fn) {
+		if (a->val_enum) {
 			if (!optarg) {
 				log_error("Option requires argument.");
 				return 0;
@@ -968,7 +2043,7 @@ static int _process_command_line(struct cmd_context *cmd, int *argc,
 
 			av->value = optarg;
 
-			if (!a->fn(cmd, av)) {
+			if (!_val_props[a->val_enum].fn(cmd, av)) {
 				log_error("Invalid argument for %s: %s", a->long_arg, optarg);
 				return 0;
 			}
@@ -1010,12 +2085,12 @@ static int _merge_synonym(struct cmd_context *cmd, int oldarg, int newarg)
 	/* Not groupable? */
 	if (!(_cmdline.arg_props[oldarg].flags & ARG_GROUPABLE)) {
 		if (arg_is_set(cmd, oldarg))
-			_copy_arg_values(cmd->arg_values, oldarg, newarg);
+			_copy_arg_values(cmd->opt_arg_values, oldarg, newarg);
 		return 1;
 	}
 
 	if (arg_is_set(cmd, oldarg))
-		cmd->arg_values[newarg].count = cmd->arg_values[oldarg].count;
+		cmd->opt_arg_values[newarg].count = cmd->opt_arg_values[oldarg].count;
 
 	/* Groupable */
 	dm_list_iterate_items(current_group, &cmd->arg_value_groups) {
@@ -1052,15 +2127,10 @@ int version(struct cmd_context *cmd __attribute__((unused)),
 	return ECMD_PROCESSED;
 }
 
-static int _get_settings(struct cmd_context *cmd)
+static void _get_output_settings(struct cmd_context *cmd)
 {
-	const char *activation_mode;
-
-	cmd->current_settings = cmd->default_settings;
-
 	if (arg_is_set(cmd, debug_ARG))
-		cmd->current_settings.debug = _LOG_FATAL +
-		    (arg_count(cmd, debug_ARG) - 1);
+		cmd->current_settings.debug = _LOG_FATAL + (arg_count(cmd, debug_ARG) - 1);
 
 	if (arg_is_set(cmd, verbose_ARG))
 		cmd->current_settings.verbose = arg_count(cmd, verbose_ARG);
@@ -1070,6 +2140,19 @@ static int _get_settings(struct cmd_context *cmd)
 		cmd->current_settings.verbose = 0;
 		cmd->current_settings.silent = (arg_count(cmd, quiet_ARG) > 1) ? 1 : 0;
 	}
+}
+
+static void _apply_output_settings(struct cmd_context *cmd)
+{
+	init_debug(cmd->current_settings.debug);
+	init_debug_classes_logged(cmd->default_settings.debug_classes);
+	init_verbose(cmd->current_settings.verbose + VERBOSE_BASE_LEVEL);
+	init_silent(cmd->current_settings.silent);
+}
+
+static int _get_settings(struct cmd_context *cmd)
+{
+	const char *activation_mode;
 
 	if (arg_is_set(cmd, test_ARG))
 		cmd->current_settings.test = arg_is_set(cmd, test_ARG);
@@ -1183,9 +2266,9 @@ static int _get_settings(struct cmd_context *cmd)
 	    !_merge_synonym(cmd, raidwritebehind_ARG, writebehind_ARG))
 		return EINVALID_CMD_LINE;
 
-	if ((!strncmp(cmd->command->name, "pv", 2) &&
+	if ((!strncmp(cmd->name, "pv", 2) &&
 	    !_merge_synonym(cmd, metadatacopies_ARG, pvmetadatacopies_ARG)) ||
-	    (!strncmp(cmd->command->name, "vg", 2) &&
+	    (!strncmp(cmd->name, "vg", 2) &&
 	     !_merge_synonym(cmd, metadatacopies_ARG, vgmetadatacopies_ARG)))
 		return EINVALID_CMD_LINE;
 
@@ -1196,7 +2279,10 @@ static int _get_settings(struct cmd_context *cmd)
 static int _process_common_commands(struct cmd_context *cmd)
 {
 	if (arg_is_set(cmd, help_ARG) || arg_is_set(cmd, help2_ARG)) {
-		_usage(cmd->command->name);
+		_usage(cmd->name, arg_count(cmd, help_ARG));
+
+		if (arg_count(cmd, help_ARG) < 2)
+			log_print("(Use --help --help for usage notes.)");
 		return ECMD_PROCESSED;
 	}
 
@@ -1216,10 +2302,10 @@ static void _display_help(void)
 	log_error("Use 'lvm help <command>' for more information");
 	log_error(" ");
 
-	for (i = 0; i < _cmdline.num_commands; i++) {
-		struct command *com = _cmdline.commands + i;
+	for (i = 0; i < _cmdline.num_command_names; i++) {
+		struct command_name *cname = _cmdline.command_names + i;
 
-		log_error("%-16.16s%s", com->name, com->desc);
+		log_error("%-16.16s%s", cname->name, cname->desc);
 	}
 }
 
@@ -1232,7 +2318,7 @@ int help(struct cmd_context *cmd __attribute__((unused)), int argc, char **argv)
 	else {
 		int i;
 		for (i = 0; i < argc; i++)
-			if (!_usage(argv[i]))
+			if (!_usage(argv[i], 0))
 				ret = EINVALID_CMD_LINE;
 	}
 
@@ -1241,10 +2327,6 @@ int help(struct cmd_context *cmd __attribute__((unused)), int argc, char **argv)
 
 static void _apply_settings(struct cmd_context *cmd)
 {
-	init_debug(cmd->current_settings.debug);
-	init_debug_classes_logged(cmd->default_settings.debug_classes);
-	init_verbose(cmd->current_settings.verbose + VERBOSE_BASE_LEVEL);
-	init_silent(cmd->current_settings.silent);
 	init_test(cmd->current_settings.test);
 	init_full_scan_done(0);
 	init_mirror_in_sync(0);
@@ -1439,7 +2521,7 @@ static int _prepare_profiles(struct cmd_context *cmd)
 		log_debug(_setting_global_profile_msg, _command_profile_source_name, profile->name);
 		cmd->profile_params->global_command_profile = profile;
 
-		if (!cmd->arg_values)
+		if (!cmd->opt_arg_values)
 			cmd->profile_params->shell_profile = profile;
 	}
 
@@ -1523,6 +2605,8 @@ int lvm_run_command(struct cmd_context *cmd, int argc, char **argv)
 	/* each command should start out with sigint flag cleared */
 	sigint_clear();
 
+	cmd->name = strdup(argv[0]);
+
 	/* eliminate '-' from all options starting with -- */
 	for (i = 1; i < argc; i++) {
 
@@ -1556,20 +2640,36 @@ int lvm_run_command(struct cmd_context *cmd, int argc, char **argv)
 			*arg_new = '\0';
 	}
 
+	/* The cmd_line string is only used for logging, not processing. */
 	if (!(cmd->cmd_line = _copy_command_line(cmd, argc, argv)))
 		return_ECMD_FAILED;
 
-	log_debug("Parsing: %s", cmd->cmd_line);
-
-	if (!(cmd->command = _find_command(argv[0])))
-		return ENO_SUCH_CMD;
-
 	if (!_process_command_line(cmd, &argc, &argv)) {
 		log_error("Error during parsing of command line.");
 		return EINVALID_CMD_LINE;
 	}
 
-	set_cmd_name(cmd->command->name);
+	/*
+	 * log_debug() can be enabled now that we know the settings
+	 * from the command.  Previous calls to log_debug() will
+	 * do nothing.
+	 */
+	cmd->current_settings = cmd->default_settings;
+	_get_output_settings(cmd);
+	_apply_output_settings(cmd);
+
+	log_debug("Parsing: %s", cmd->cmd_line);
+
+	if (!(cmd->command = _find_command(cmd, cmd->name, &argc, argv)))
+		return EINVALID_CMD_LINE;
+
+	/*
+	 * Remaining position args after command name and --options are removed.
+	 */
+	cmd->position_argc = argc;
+	cmd->position_argv = argv;
+
+	set_cmd_name(cmd->name);
 
 	if (arg_is_set(cmd, backgroundfork_ARG)) {
 		if (!become_daemon(cmd, 1)) {
@@ -1725,10 +2825,12 @@ int lvm_run_command(struct cmd_context *cmd, int argc, char **argv)
 		}
 	}
 
-	/*
-	 * FIXME Break up into multiple functions.
-	 */
-	ret = cmd->command->fn(cmd, argc, argv);
+	if (cmd->command->functions)
+		/* A command-line--specific function is used */
+		ret = cmd->command->functions->fn(cmd, argc, argv);
+	else
+		/* The old style command-name function is used */
+		ret = cmd->command->fn(cmd, argc, argv);
 
 	lvmlockd_disconnect();
 	fin_locking();
@@ -2048,23 +3150,8 @@ struct cmd_context *init_lvm(unsigned set_connections, unsigned set_filters)
 	return cmd;
 }
 
-static void _fin_commands(void)
-{
-	int i;
-
-	for (i = 0; i < _cmdline.num_commands; i++)
-		dm_free(_cmdline.commands[i].valid_args);
-
-	dm_free(_cmdline.commands);
-
-	_cmdline.commands = NULL;
-	_cmdline.num_commands = 0;
-	_cmdline.commands_size = 0;
-}
-
 void lvm_fin(struct cmd_context *cmd)
 {
-	_fin_commands();
 	destroy_toolcontext(cmd);
 	udev_fin_library_context();
 }
@@ -2211,6 +3298,7 @@ int lvm2_main(int argc, char **argv)
 		return -1;
 
 	cmd->argv = argv;
+
 	lvm_register_commands();
 
 	if (_lvm1_fallback(cmd)) {
diff --git a/tools/toollib.c b/tools/toollib.c
index 5f3deb7..06d4066 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -800,10 +800,7 @@ int vgcreate_params_set_from_args(struct cmd_context *cmd,
 		return 0;
 	}
 
-	if (arg_is_set(cmd, metadatacopies_ARG))
-		vp_new->vgmetadatacopies = arg_int_value(cmd, metadatacopies_ARG,
-							DEFAULT_VGMETADATACOPIES);
-	else if (arg_is_set(cmd, vgmetadatacopies_ARG))
+	if (arg_is_set(cmd, vgmetadatacopies_ARG))
 		vp_new->vgmetadatacopies = arg_int_value(cmd, vgmetadatacopies_ARG,
 							DEFAULT_VGMETADATACOPIES);
 	else
@@ -2328,6 +2325,601 @@ static struct lv_segment _historical_lv_segment = {
 	.origin_list = DM_LIST_HEAD_INIT(_historical_lv_segment.origin_list),
 };
 
+int opt_in_list_is_set(struct cmd_context *cmd, int *opts, int count,
+		       int *match_count, int *unmatch_count)
+{
+	int match = 0;
+	int unmatch = 0;
+	int i;
+
+	for (i = 0; i < count; i++) {
+		if (arg_is_set(cmd, opts[i]))
+			match++;
+		else
+			unmatch++;
+	}
+
+	if (match_count)
+		*match_count = match;
+	if (unmatch_count)
+		*unmatch_count = unmatch;
+
+	return match ? 1 : 0;
+}
+      
+void opt_array_to_str(struct cmd_context *cmd, int *opts, int count,
+		      char *buf, int len)
+{
+	int pos = 0;
+	int ret;
+	int i;
+
+	for (i = 0; i < count; i++) {
+		ret = snprintf(buf + pos, len - pos, "%s ", arg_long_option_name(opts[i]));
+		if (ret >= len - pos)
+			break;
+		pos += ret;
+	}
+
+	buf[len - 1] = '\0';
+}
+
+static void lvp_bits_to_str(uint64_t bits, char *buf, int len)
+{
+	struct lv_props *prop;
+	int lvp_enum;
+	int pos = 0;
+	int ret;
+
+	for (lvp_enum = 0; lvp_enum < LVP_COUNT; lvp_enum++) {
+		if (!(prop = get_lv_prop(lvp_enum)))
+			continue;
+
+		if (lvp_bit_is_set(bits, lvp_enum)) {
+			ret = snprintf(buf + pos, len - pos, "%s ", prop->name);
+			if (ret >= len - pos)
+				break;
+			pos += ret;
+		}
+	}
+	buf[len - 1] = '\0';
+}
+
+static void lvt_bits_to_str(uint64_t bits, char *buf, int len)
+{
+	struct lv_types *type;
+	int lvt_enum;
+	int pos = 0;
+	int ret;
+
+	for (lvt_enum = 0; lvt_enum < LVT_COUNT; lvt_enum++) {
+		if (!(type = get_lv_type(lvt_enum)))
+			continue;
+
+		if (lvt_bit_is_set(bits, lvt_enum)) {
+			ret = snprintf(buf + pos, len - pos, "%s ", type->name);
+			if (ret >= len - pos)
+				break;
+			pos += ret;
+		}
+	}
+	buf[len - 1] = '\0';
+}
+
+/*
+ * This is the lv_prop function pointer used for lv_is_foo() #defines.
+ * Alternatively, lv_is_foo() could all be turned into functions.
+ */
+
+static int _lv_is_prop(struct cmd_context *cmd, struct logical_volume *lv, int lvp_enum)
+{
+	switch (lvp_enum) {
+	case is_locked_LVP:
+		return lv_is_locked(lv);
+	case is_partial_LVP:
+		return lv_is_partial(lv);
+	case is_virtual_LVP:
+		return lv_is_virtual(lv);
+	case is_merging_LVP:
+		return lv_is_merging(lv);
+	case is_merging_origin_LVP:
+		return lv_is_merging_origin(lv);
+	case is_converting_LVP:
+		return lv_is_converting(lv);
+	case is_external_origin_LVP:
+		return lv_is_external_origin(lv);
+	case is_virtual_origin_LVP:
+		return lv_is_virtual_origin(lv);
+	case is_not_synced_LVP:
+		return lv_is_not_synced(lv);
+	case is_pending_delete_LVP:
+		return lv_is_pending_delete(lv);
+	case is_error_when_full_LVP:
+		return lv_is_error_when_full(lv);
+	case is_pvmove_LVP:
+		return lv_is_pvmove(lv);
+	case is_removed_LVP:
+		return lv_is_removed(lv);
+	case is_vg_writable_LVP:
+		return (lv->vg->status & LVM_WRITE) ? 1 : 0;
+	case is_thinpool_data_LVP:
+		return lv_is_thin_pool_data(lv);
+	case is_thinpool_metadata_LVP:
+		return lv_is_thin_pool_metadata(lv);
+	case is_cachepool_data_LVP:
+		return lv_is_cache_pool_data(lv);
+	case is_cachepool_metadata_LVP:
+		return lv_is_cache_pool_metadata(lv);
+	case is_mirror_image_LVP:
+		return lv_is_mirror_image(lv);
+	case is_mirror_log_LVP:
+		return lv_is_mirror_log(lv);
+	case is_raid_image_LVP:
+		return lv_is_raid_image(lv);
+	case is_raid_metadata_LVP:
+		return lv_is_raid_metadata(lv);
+	case is_origin_LVP: /* use lv_is_thick_origin */
+		return lv_is_origin(lv);
+	case is_thick_origin_LVP:
+		return lv_is_thick_origin(lv);
+	case is_thick_snapshot_LVP:
+		return lv_is_thick_snapshot(lv);
+	case is_thin_origin_LVP:
+		return lv_is_thin_origin(lv, NULL);
+	case is_thin_snapshot_LVP:
+		return lv_is_thin_snapshot(lv);
+	case is_cache_origin_LVP:
+		return lv_is_cache_origin(lv);
+	case is_merging_cow_LVP:
+		return lv_is_merging_cow(lv);
+	case is_cow_covering_origin_LVP:
+		return lv_is_cow_covering_origin(lv);
+	case is_visible_LVP:
+		return lv_is_visible(lv);
+	case is_historical_LVP:
+		return lv_is_historical(lv);
+	case is_raid_with_tracking_LVP:
+		return lv_is_raid_with_tracking(lv);
+	default:
+		log_error(INTERNAL_ERROR "unknown lv property value lvp_enum %d", lvp_enum);
+	}
+
+	return 0;
+}
+
+/*
+ * Check if an LV matches a given LV type enum.
+ */
+
+static int _lv_is_type(struct cmd_context *cmd, struct logical_volume *lv, int lvt_enum)
+{
+	struct lv_segment *seg = first_seg(lv);
+
+	switch (lvt_enum) {
+	case striped_LVT:
+		return seg_is_striped(seg) && !lv_is_cow(lv);
+	case linear_LVT:
+		return seg_is_linear(seg) && !lv_is_cow(lv);
+	case snapshot_LVT:
+		return lv_is_cow(lv);
+	case thin_LVT:
+		return lv_is_thin_volume(lv);
+	case thinpool_LVT:
+		return lv_is_thin_pool(lv);
+	case cache_LVT:
+		return lv_is_cache(lv);
+	case cachepool_LVT:
+		return lv_is_cache_pool(lv);
+	case mirror_LVT:
+		return lv_is_mirror(lv);
+	case raid_LVT:
+		return lv_is_raid(lv);
+	case raid0_LVT:
+		return seg_is_raid0(seg);
+	case raid1_LVT:
+		return seg_is_raid1(seg);
+	case raid4_LVT:
+		return seg_is_raid4(seg);
+#if 0
+	case raid5_LVT:
+		return seg_is_raid5(seg);
+	case raid6_LVT:
+		return seg_is_raid6(seg);
+#endif
+	case raid10_LVT:
+		return seg_is_raid10(seg);
+	case error_LVT:
+		return !strcmp(seg->segtype->name, SEG_TYPE_NAME_ERROR);
+	case zero_LVT:
+		return !strcmp(seg->segtype->name, SEG_TYPE_NAME_ZERO);
+	default:
+		log_error(INTERNAL_ERROR "unknown lv type value lvt_enum %d", lvt_enum);
+	}
+
+	return 0;
+}
+
+static int _get_lvt_enum(struct logical_volume *lv)
+{
+	struct lv_segment *seg = first_seg(lv);
+
+	/*
+	 * The order these are checked is important, because a snapshot LV has
+	 * a linear seg type.
+	 */
+
+	if (lv_is_cow(lv))
+		return snapshot_LVT;
+	if (seg_is_linear(seg))
+		return linear_LVT;
+	if (seg_is_striped(seg))
+		return striped_LVT;
+	if (lv_is_thin_volume(lv))
+		return thin_LVT;
+	if (lv_is_thin_pool(lv))
+		return thinpool_LVT;
+	if (lv_is_cache(lv))
+		return cache_LVT;
+	if (lv_is_cache_pool(lv))
+		return cachepool_LVT;
+	if (lv_is_mirror(lv))
+		return mirror_LVT;
+	if (lv_is_raid(lv))
+		return raid_LVT;
+	if (seg_is_raid0(seg))
+		return raid0_LVT;
+	if (seg_is_raid1(seg))
+		return raid1_LVT;
+	if (seg_is_raid4(seg))
+		return raid4_LVT;
+#if 0
+	if (seg_is_raid5(seg))
+		return raid5_LVT;
+	if (seg_is_raid6(seg))
+		return raid6_LVT;
+#endif
+	if (seg_is_raid10(seg))
+		return raid10_LVT;
+
+	if (!strcmp(seg->segtype->name, SEG_TYPE_NAME_ERROR))
+		return error_LVT;
+	if (!strcmp(seg->segtype->name, SEG_TYPE_NAME_ZERO))
+		return zero_LVT;
+
+	return 0;
+}
+
+/*
+ * Call lv_is_<type> for each <type>_LVT bit set in lvt_bits.
+ * If lv matches one of the specified lv types, then return 1.
+ */
+
+static int _lv_types_match(struct cmd_context *cmd, struct logical_volume *lv, uint64_t lvt_bits,
+			   uint64_t *match_bits, uint64_t *unmatch_bits)
+{
+	struct lv_types *type;
+	int lvt_enum;
+	int found_a_match = 0;
+	int match;
+
+	if (match_bits)
+		*match_bits = 0;
+	if (unmatch_bits)
+		*unmatch_bits = 0;
+
+	for (lvt_enum = 1; lvt_enum < LVT_COUNT; lvt_enum++) {
+		if (!lvt_bit_is_set(lvt_bits, lvt_enum))
+			continue;
+
+		if (!(type = get_lv_type(lvt_enum)))
+			continue;
+
+		/*
+		 * All types are currently handled by _lv_is_type()
+		 * because lv_is_type() are #defines and not exposed
+		 * in tools.h
+		 */
+
+		if (!type->fn)
+			match = _lv_is_type(cmd, lv, lvt_enum);
+		else
+			match = type->fn(cmd, lv);
+
+		if (match)
+			found_a_match = 1;
+
+		if (match_bits && match)
+			*match_bits |= lvt_enum_to_bit(lvt_enum);
+
+		if (unmatch_bits && !match)
+			*unmatch_bits |= lvt_enum_to_bit(lvt_enum);
+	}
+
+	return found_a_match;
+}
+
+/*
+ * Call lv_is_<prop> for each <prop>_LVP bit set in lvp_bits.
+ * If lv matches all of the specified lv properties, then return 1.
+ */
+
+static int _lv_props_match(struct cmd_context *cmd, struct logical_volume *lv, uint64_t lvp_bits,
+			   uint64_t *match_bits, uint64_t *unmatch_bits)
+{
+	struct lv_props *prop;
+	int lvp_enum;
+	int found_a_mismatch = 0;
+	int match;
+
+	if (match_bits)
+		*match_bits = 0;
+	if (unmatch_bits)
+		*unmatch_bits = 0;
+
+	for (lvp_enum = 1; lvp_enum < LVP_COUNT; lvp_enum++) {
+		if (!lvp_bit_is_set(lvp_bits, lvp_enum))
+			continue;
+
+		if (!(prop = get_lv_prop(lvp_enum)))
+			continue;
+
+		if (!prop->fn)
+			match = _lv_is_prop(cmd, lv, lvp_enum);
+		else
+			match = prop->fn(cmd, lv);
+
+		if (!match)
+			found_a_mismatch = 1;
+
+		if (match_bits && match)
+			*match_bits |= lvp_enum_to_bit(lvp_enum);
+
+		if (unmatch_bits && !match)
+			*unmatch_bits |= lvp_enum_to_bit(lvp_enum);
+	}
+
+	return !found_a_mismatch;
+}
+
+static int _check_lv_types(struct cmd_context *cmd, struct logical_volume *lv, int pos)
+{
+	int ret = 1;
+
+	if (!pos)
+		return 1;
+
+	if (!cmd->command->required_pos_args[pos-1].def.lvt_bits)
+		return 1;
+
+	if (!val_bit_is_set(cmd->command->required_pos_args[pos-1].def.val_bits, lv_VAL)) {
+		log_error(INTERNAL_ERROR "Command (%s %d) arg position %d does not permit an LV (%llx)",
+			  cmd->command->command_line_id, cmd->command->command_line_enum,
+			  pos, (unsigned long long)cmd->command->required_pos_args[pos-1].def.val_bits);
+		return 0;
+	}
+
+	ret = _lv_types_match(cmd, lv, cmd->command->required_pos_args[pos-1].def.lvt_bits, NULL, NULL);
+	if (!ret) {
+		int lvt_enum = _get_lvt_enum(lv);
+		struct lv_types *type = get_lv_type(lvt_enum);
+		log_warn("Operation on LV %s which has invalid type %s.",
+			 display_lvname(lv), type ? type->name : "unknown");
+	}
+
+	return ret;
+}
+
+/* Check if LV passes each rule specified in command definition. */
+
+static int _check_lv_rules(struct cmd_context *cmd, struct logical_volume *lv)
+{
+	char buf[64];
+	struct cmd_rule *rule;
+	struct lv_types *lvtype = NULL;
+	uint64_t lv_props_match_bits, lv_props_unmatch_bits;
+	uint64_t lv_types_match_bits, lv_types_unmatch_bits;
+	int opts_match_count, opts_unmatch_count;
+	int lvt_enum;
+	int ret = 1;
+	int i;
+
+	lvt_enum = _get_lvt_enum(lv);
+	if (lvt_enum)
+		lvtype = get_lv_type(lvt_enum);
+
+	for (i = 0; i < cmd->command->rule_count; i++) {
+		rule = &cmd->command->rules[i];
+
+		/*
+		 * RULE: <conditions> INVALID|REQUIRE <checks>
+		 *
+		 * If all the conditions apply to the command+LV, then
+		 * the checks are performed.  If all conditions are zero
+		 * (!opts_count, !lvt_bits, !lvp_bits), then the check
+		 * is always performed.
+		 *
+		 * Conditions:
+		 *
+		 * 1. options (opts): if any of the specified options are set,
+		 *    then the checks may apply.
+		 *
+		 * 2. LV types (lvt_bits): if any of the specified LV types
+		 *    match the LV, then the checks may apply.
+		 *
+		 * 3. LV properties (lvp_bits): if all of the specified
+		 *    LV properties match the LV, then the checks may apply.
+		 *
+		 * If conditions 1, 2, 3 all pass, then the checks apply.
+		 *
+		 * Checks:
+		 *
+		 * 1. options (check_opts):
+		 *    INVALID: if any of the specified options are set,
+		 *    then the command fails.
+		 *    REQUIRE: if any of the specified options are not set,
+		 *    then the command fails.
+		 *
+		 * 2. LV types (check_lvt_bits):
+		 *    INVALID: if any of the specified LV types match the LV,
+		 *    then the command fails.
+		 *    REQUIRE: if none of the specified LV types match the LV,
+		 *    then the command fails.
+		 *
+		 * 3. LV properties (check_lvp_bits):
+		 *    INVALID: if any of the specified LV properties match
+		 *    the LV, then the command fails.
+		 *    REQUIRE: if any of the specified LV properties do not match
+		 *    the LV, then the command fails.
+		 */
+
+		if (rule->opts_count && !opt_in_list_is_set(cmd, rule->opts, rule->opts_count, NULL, NULL))
+			continue;
+
+		/* If LV matches one type in lvt_bits, this returns 1. */
+		if (rule->lvt_bits && !_lv_types_match(cmd, lv, rule->lvt_bits, NULL, NULL))
+			continue;
+
+		/* If LV matches all properties in lvp_bits, this returns 1. */
+		if (rule->lvp_bits && !_lv_props_match(cmd, lv, rule->lvp_bits, NULL, NULL))
+			continue;
+
+		/*
+		 * Check the options, LV types, LV properties.
+		 */
+
+		if (rule->check_opts)
+			opt_in_list_is_set(cmd, rule->check_opts, rule->check_opts_count,
+					   &opts_match_count, &opts_unmatch_count);
+
+		if (rule->check_lvt_bits)
+			_lv_types_match(cmd, lv, rule->check_lvt_bits,
+					&lv_types_match_bits, &lv_types_unmatch_bits);
+
+		if (rule->check_lvp_bits)
+			_lv_props_match(cmd, lv, rule->check_lvp_bits,
+					&lv_props_match_bits, &lv_props_unmatch_bits);
+		
+		/*
+		 * Evaluate if the check results pass based on the rule.
+		 * The options are checked again here because the previous
+		 * option validation (during command matching) does not cover
+		 * cases where the option is combined with conditions of LV types
+		 * or properties.
+		 */
+
+		/* Fail if any invalid options are set. */
+
+		if (rule->check_opts && (rule->rule == RULE_INVALID) && opts_match_count) {
+			memset(buf, 0, sizeof(buf));
+			opt_array_to_str(cmd, rule->check_opts, rule->check_opts_count, buf, sizeof(buf));
+			log_warn("An invalid option is set: %s", buf);
+			ret = 0;
+		}
+
+		/* Fail if any required options are not set. */
+
+		if (rule->check_opts && (rule->rule == RULE_REQUIRE) && opts_unmatch_count)  {
+			memset(buf, 0, sizeof(buf));
+			opt_array_to_str(cmd, rule->check_opts, rule->check_opts_count, buf, sizeof(buf));
+			log_warn("A required option is not set: %s", buf);
+			ret = 0;
+		}
+
+		/* Fail if the LV matches any of the invalid LV types. */
+
+		if (rule->check_lvt_bits && (rule->rule == RULE_INVALID) && lv_types_match_bits) {
+			log_warn("Command on LV %s with invalid type: %s",
+				 display_lvname(lv), lvtype ? lvtype->name : "unknown");
+			ret = 0;
+		}
+
+		/* Fail if the LV does not match any of the required LV types. */
+
+		if (rule->check_lvt_bits && (rule->rule == RULE_REQUIRE) && !lv_types_match_bits) {
+			memset(buf, 0, sizeof(buf));
+			lvt_bits_to_str(rule->check_lvt_bits, buf, sizeof(buf));
+			log_warn("Command on LV %s with type %s does not match required type: %s",
+				 display_lvname(lv), lvtype ? lvtype->name : "unknown", buf);
+			ret = 0;
+		}
+
+		/* Fail if the LV matches any of the invalid LV properties. */
+
+		if (rule->check_lvp_bits && (rule->rule == RULE_INVALID) && lv_props_match_bits) {
+			memset(buf, 0, sizeof(buf));
+			lvp_bits_to_str(lv_props_match_bits, buf, sizeof(buf));
+			log_warn("Command on LV %s with invalid properties: %s",
+				 display_lvname(lv), buf);
+			ret = 0;
+		}
+
+		/* Fail if the LV does not match any of the required LV properties. */
+
+		if (rule->check_lvp_bits && (rule->rule == RULE_REQUIRE) && lv_props_unmatch_bits) {
+			memset(buf, 0, sizeof(buf));
+			lvp_bits_to_str(lv_props_unmatch_bits, buf, sizeof(buf));
+			log_warn("Command on LV %s requires properties: %s",
+				 display_lvname(lv), buf);
+			ret = 0;
+		}
+	}
+
+	return ret;
+}
+
+/*
+ * Return which arg position the given LV is at,
+ * where 1 represents the first position arg.
+ * When the first position arg is repeatable,
+ * return 1 for all.
+ *
+ * Return 0 when the command has no required
+ * position args. (optional position args are
+ * not considered.)
+ */
+
+static int _find_lv_arg_position(struct cmd_context *cmd, struct logical_volume *lv)
+{
+	const char *sep, *lvname;
+	int i;
+
+	if (cmd->command->rp_count == 0)
+		return 0;
+
+	if (cmd->command->rp_count == 1)
+		return 1;
+
+	for (i = 0; i < cmd->position_argc; i++) {
+		if (i == cmd->command->rp_count)
+			break;
+
+		if (!val_bit_is_set(cmd->command->required_pos_args[i].def.val_bits, lv_VAL))
+			continue;
+
+		if ((sep = strstr(cmd->position_argv[i], "/")))
+			lvname = sep + 1;
+		else
+			lvname = cmd->position_argv[i];
+
+		if (!strcmp(lvname, lv->name))
+			return i + 1;
+	}
+
+	/*
+	 * If the last position arg is an LV and this
+	 * arg is beyond that position, then the last
+	 * LV position arg is repeatable, so return
+	 * that position.
+	 */
+	if (i == cmd->command->rp_count) {
+		int last_pos = cmd->command->rp_count;
+		if (val_bit_is_set(cmd->command->required_pos_args[last_pos-1].def.val_bits, lv_VAL))
+			return last_pos;
+	}
+
+	return 0;
+}
+
 int process_each_lv_in_vg(struct cmd_context *cmd, struct volume_group *vg,
 			  struct dm_list *arg_lvnames, const struct dm_list *tags_in,
 			  int stop_on_error,
@@ -2345,10 +2937,13 @@ int process_each_lv_in_vg(struct cmd_context *cmd, struct volume_group *vg,
 	unsigned process_all = 0;
 	unsigned tags_supplied = 0;
 	unsigned lvargs_supplied = 0;
+	int lv_is_named_arg;
+	int lv_arg_pos;
 	struct lv_list *lvl;
 	struct dm_str_list *sl;
 	struct dm_list final_lvs;
 	struct lv_list *final_lvl;
+	struct dm_list found_arg_lvnames;
 	struct glv_list *glvl, *tglvl;
 	int do_report_ret_code = 1;
 
@@ -2359,6 +2954,7 @@ int process_each_lv_in_vg(struct cmd_context *cmd, struct volume_group *vg,
 		stack;
 
 	dm_list_init(&final_lvs);
+	dm_list_init(&found_arg_lvnames);
 
 	if (!vg_check_status(vg, EXPORTED_VG)) {
 		ret_max = ECMD_FAILED;
@@ -2452,6 +3048,7 @@ int process_each_lv_in_vg(struct cmd_context *cmd, struct volume_group *vg,
 		if (lvargs_supplied && str_list_match_item(arg_lvnames, lvl->lv->name)) {
 			/* Remove LV from list of unprocessed LV names */
 			str_list_del(arg_lvnames, lvl->lv->name);
+			str_list_add(cmd->mem, &found_arg_lvnames, lvl->lv->name);
 			process_lv = 1;
 		}
 
@@ -2499,6 +3096,37 @@ int process_each_lv_in_vg(struct cmd_context *cmd, struct volume_group *vg,
 		if (lv_is_removed(lvl->lv))
 			continue;
 
+		lv_is_named_arg = str_list_match_item(&found_arg_lvnames, lvl->lv->name);
+
+		lv_arg_pos = _find_lv_arg_position(cmd, lvl->lv);
+
+		/*
+		 * The command definition may include restrictions on the
+		 * types and properties of LVs that can be processed.
+		 */
+
+		if (!_check_lv_types(cmd, lvl->lv, lv_arg_pos)) {
+			/* FIXME: include this result in report log? */
+			if (lv_is_named_arg) {
+				log_error("Operation not permitted (%s %d) on LV %s.",
+					  cmd->command->command_line_id, cmd->command->command_line_enum,
+					  display_lvname(lvl->lv));
+				ret_max = ECMD_FAILED;
+			}
+			continue;
+		}
+
+		if (!_check_lv_rules(cmd, lvl->lv)) {
+			/* FIXME: include this result in report log? */
+			if (lv_is_named_arg) {
+				log_error("Operation not permitted (%s %d) on LV %s.",
+					  cmd->command->command_line_id, cmd->command->command_line_enum,
+					  display_lvname(lvl->lv));
+				ret_max = ECMD_FAILED;
+			} 
+			continue;
+		}
+
 		log_very_verbose("Processing LV %s in VG %s.", lvl->lv->name, vg->name);
 
 		ret = process_single_lv(cmd, lvl->lv, handle);
@@ -3935,11 +4563,6 @@ int pvcreate_params_from_args(struct cmd_context *cmd, struct pvcreate_params *p
 	if (pp->pva.pvmetadatacopies < 0)
 		pp->pva.pvmetadatacopies = find_config_tree_int(cmd, metadata_pvmetadatacopies_CFG, NULL);
 
-	if (pp->pva.pvmetadatacopies > 2) {
-		log_error("Metadatacopies may only be 0, 1 or 2");
-		return 0;
-	}
-
 	pp->pva.ba_size = arg_uint64_value(cmd, bootloaderareasize_ARG, pp->pva.ba_size);
 
 	return 1;
diff --git a/tools/toollib.h b/tools/toollib.h
index 531f690..d44b825 100644
--- a/tools/toollib.h
+++ b/tools/toollib.h
@@ -159,6 +159,12 @@ const char *extract_vgname(struct cmd_context *cmd, const char *lv_name);
 const char *skip_dev_dir(struct cmd_context *cmd, const char *vg_name,
 			 unsigned *dev_dir_found);
 
+int opt_in_list_is_set(struct cmd_context *cmd, int *opts, int count,
+		       int *match_count, int *unmatch_count);
+
+void opt_array_to_str(struct cmd_context *cmd, int *opts, int count,
+		      char *buf, int len);
+
 int pvcreate_params_from_args(struct cmd_context *cmd, struct pvcreate_params *pp);
 int pvcreate_each_device(struct cmd_context *cmd, struct processing_handle *handle, struct pvcreate_params *pp);
 
diff --git a/tools/tools.h b/tools/tools.h
index 1419af9..dbf8a17 100644
--- a/tools/tools.h
+++ b/tools/tools.h
@@ -50,20 +50,41 @@
 #define CMD_LEN 256
 #define MAX_ARGS 64
 
-/* command functions */
-typedef int (*command_fn) (struct cmd_context * cmd, int argc, char **argv);
+/* define the enums for the values accepted by command line --options, foo_VAL */
+enum {
+#define val(a, b, c, d) a ,
+#include "vals.h"
+#undef val
+};
+
+/* define the enums for the command line --options, foo_ARG */
+enum {
+#define arg(a, b, c, d, e, f) a ,
+#include "args.h"
+#undef arg
+};
 
+/* command functions */
 #define xx(a, b...) int a(struct cmd_context *cmd, int argc, char **argv);
 #include "commands.h"
 #undef xx
 
-/* define the enums for the command line switches */
+/* define enums for LV properties, foo_LVP */
 enum {
-#define arg(a, b, c, d, e, f) a ,
-#include "args.h"
-#undef arg
+#define lvp(a, b, c) a ,
+#include "lv_props.h"
+#undef lvp
 };
 
+/* define enums for LV types, foo_LVT */
+enum {
+#define lvt(a, b, c) a ,
+#include "lv_types.h"
+#undef lvt
+};
+
+#include "command.h"
+
 #define ARG_COUNTABLE 0x00000001	/* E.g. -vvvv */
 #define ARG_GROUPABLE 0x00000002	/* E.g. --addtag */
 
@@ -79,13 +100,13 @@ struct arg_values {
 /*	void *ptr; // Currently not used. */
 };
 
-/* a global table of possible arguments */
+/* a global table of possible --option's */
 struct arg_props {
+	int arg_enum; /* foo_ARG from args.h */
 	const char short_arg;
 	char _padding[7];
 	const char *long_arg;
-
-	int (*fn) (struct cmd_context *cmd, struct arg_values *av);
+	int val_enum; /* foo_VAL from vals.h */
 	uint32_t flags;
 	uint32_t prio;
 };
@@ -96,6 +117,29 @@ struct arg_value_group_list {
 	uint32_t prio;
 };
 
+/* a global table of possible --option values */
+struct val_props {
+	int val_enum; /* foo_VAL from vals.h */
+	int (*fn) (struct cmd_context *cmd, struct arg_values *av);
+	const char *name;
+	const char *usage;
+};
+
+/* a global table of possible LV properties */
+struct lv_props {
+	int lvp_enum; /* is_foo_LVP from lv_props.h */
+	const char *name; /* "lv_is_foo" used in command-lines.in */
+	int (*fn) (struct cmd_context *cmd, struct logical_volume *lv); /* lv_is_foo() */
+};
+
+/* a global table of possible LV types */
+/* (as exposed externally in command line interface, not exactly as internal segtype is used) */
+struct lv_types {
+	int lvt_enum; /* is_foo_LVT from lv_types.h */
+	const char *name; /* "foo" used in command-lines.in, i.e. LV_foo */
+	int (*fn) (struct cmd_context *cmd, struct logical_volume *lv); /* lv_is_foo() */
+};
+
 #define CACHE_VGMETADATA	0x00000001
 #define PERMITTED_READ_ONLY 	0x00000002
 /* Process all VGs if none specified on the command line. */
@@ -118,19 +162,6 @@ struct arg_value_group_list {
 #define ENABLE_DUPLICATE_DEVS    0x00000400
 /* Command does not accept tags as args. */
 #define DISALLOW_TAG_ARGS        0x00000800
- 
-/* a register of the lvm commands */
-struct command {
-	const char *name;
-	const char *desc;
-	const char *usage;
-	command_fn fn;
-
-	unsigned flags;
-
-	int num_args;
-	int *valid_args;
-};
 
 void usage(const char *name);
 
@@ -158,7 +189,15 @@ int segtype_arg(struct cmd_context *cmd, struct arg_values *av);
 int alloc_arg(struct cmd_context *cmd, struct arg_values *av);
 int locktype_arg(struct cmd_context *cmd, struct arg_values *av);
 int readahead_arg(struct cmd_context *cmd, struct arg_values *av);
+int vgmetadatacopies_arg(struct cmd_context *cmd __attribute__((unused)), struct arg_values *av);
+int pvmetadatacopies_arg(struct cmd_context *cmd __attribute__((unused)), struct arg_values *av);
 int metadatacopies_arg(struct cmd_context *cmd __attribute__((unused)), struct arg_values *av);
+int polloperation_arg(struct cmd_context *cmd __attribute__((unused)), struct arg_values *av);
+int writemostly_arg(struct cmd_context *cmd __attribute__((unused)), struct arg_values *av);
+int syncaction_arg(struct cmd_context *cmd __attribute__((unused)), struct arg_values *av);
+int reportformat_arg(struct cmd_context *cmd __attribute__((unused)), struct arg_values *av);
+int configreport_arg(struct cmd_context *cmd __attribute__((unused)), struct arg_values *av);
+int configtype_arg(struct cmd_context *cmd __attribute__((unused)), struct arg_values *av);
 
 /* we use the enums to access the switches */
 unsigned arg_count(const struct cmd_context *cmd, int a);
@@ -200,4 +239,7 @@ int vgchange_activate(struct cmd_context *cmd, struct volume_group *vg,
 
 int vgchange_background_polling(struct cmd_context *cmd, struct volume_group *vg);
 
+struct lv_props *get_lv_prop(int lvp_enum);
+struct lv_types *get_lv_type(int lvt_enum);
+
 #endif
diff --git a/tools/vals.h b/tools/vals.h
new file mode 100644
index 0000000..c8c998f
--- /dev/null
+++ b/tools/vals.h
@@ -0,0 +1,136 @@
+
+/*
+ * Define value types which describe values accepted
+ * by the --option's in args.h, and can also describe
+ * the values accepted as positional args.
+ *
+ * Previously, accepted values were only "described"
+ * by identifying the parsing function to use.
+ *
+ * Some standard val types are used by many options,
+ * e.g. many options (aa_ARG, bb_ARG, cc_ARG) all
+ * accept a number_VAL.
+ *
+ * Other special val types are used by only one option,
+ * e.g. only mirrorlog_ARG accepts a mirrorlog_VAL.
+ * This typically means that there are some specific
+ * words that are recognized after the option.
+ *
+ * Some options currently take a standard val type,
+ * (esp string_VAL), but they could be given their
+ * own custom val type.  The advantage of using a
+ * custom val type is the possibility of validating
+ * the value when parsing it with a custom parsing
+ * function, and the possibility of displaying the
+ * actual accepted values in the command usage.
+ * Without a custom val type, the code must do ad hoc
+ * validation of the string values, and the usage
+ * output for the option will only say "String"
+ * rather than giving the accepted string values.
+ * Even without a custom parsing function, there is
+ * reason to define a custom x_VAL enum so that a
+ * more descriptive usage string can be specified
+ * as opposed to just "String".
+ *
+ * Most of the val types defined here are used after
+ * --option's, and are referenced in foo_ARG entries
+ * in args.h.  But, some val types are only used to
+ * represent positional values in command definitions,
+ * e.g. vg_VAL.
+ *
+ * val(a, b, c, d)
+ *
+ * a:  foo_VAL enums
+ * b:  the function to parse and set the value
+ * c:  the name used to reference this value in command defs
+ * d:  what to display in usage output for this value
+ *
+ * command defintions will use --option NAME, where NAME
+ * is shown in val() field c.  NAME will be translated to
+ * foo_VAL enum in field a, which is used in commands[]
+ * structs.
+ *
+ * option definitions (arg.h) will reference foo_VAL enum
+ * in field a.
+ *
+ * FIXME: for specialized val types, the set of recognized
+ * words is not defined or stored in a consistent way,
+ * but is just whatever the parsing function happens to look
+ * for, so adding a new accepted value for the val type is
+ * generally making the parsing function recognize a new
+ * word, and making the implementation code also recognize
+ * that word to do something different.  This new word should
+ * then also be added to the usage string for the val type here.
+ * It would be nice if the accepted values could be defined in a
+ * more consistent way, and perhaps in a single place, perhaps in
+ * struct val_props.
+ *
+ * The usage text for an option is not always the full
+ * set of words accepted for an option, but may be a
+ * subset.  i.e. an outdated word that no longer does
+ * anything may not be shown, but may still be recognized
+ * and ignored, or an option that shouldn't be used in
+ * general isn't shown to avoid suggesting it.
+ * e.g. for --activate we show the most common "y|n|ay"
+ * without showing the lvmlockd variations "ey|sy" which
+ * are not applicable in general.
+ *
+ * FIXME: are there some specialized or irrelevant
+ * options included in the usage text below that should
+ * be removed?  Should "lvm1" be removed?
+ *
+ * For Number args that take optional units, a full usage
+ * could be "Number[bBsSkKmMgGtTpPeE]" (with implied |),
+ * but repeating this full specification produces cluttered
+ * output, and doesn't indicate which unit is the default.
+ * "Number[units]" would be cleaner, as would a subset of
+ * common units, e.g. "Number[kmg...]", but neither helps
+ * with default.  "Number[k|unit]" and "Number[m|unit]" show
+ * the default, and "unit" indicates that other units
+ * are possible without listing them all.  This also
+ * suggests using the preferred lower case letters, because
+ * --size and other option args treat upper/lower letters
+ * the same, all as 1024 SI base.  For this reason, we
+ * should avoid suggesting the upper case letters.
+ */
+
+val(none_VAL, NULL, "None", "ERR")             /* unused, for enum value 0 */
+val(conststr_VAL, NULL, "ConstString", "ERR")  /* used only for command defs */
+val(constnum_VAL, NULL, "ConstNumber", "ERR")  /* used only for command defs */
+val(bool_VAL, yes_no_arg, "Bool", "y|n")
+val(number_VAL, int_arg, "Number", NULL)
+val(string_VAL, string_arg, "String", NULL)
+val(vg_VAL, string_arg, "VG", NULL)
+val(lv_VAL, string_arg, "LV", NULL)
+val(pv_VAL, string_arg, "PV", NULL)
+val(tag_VAL, tag_arg, "Tag", NULL)
+val(select_VAL, NULL, "Select", NULL)       /* used only for command defs */
+val(activationmode_VAL, string_arg, "ActivationMode", "partial|degraded|complete")
+val(activation_VAL, activation_arg, "Active", "y|n|ay")
+val(cachemode_VAL, cachemode_arg, "CacheMode", "writethrough|writeback")
+val(discards_VAL, discards_arg, "Discards", "passdown|nopassdown|ignore")
+val(mirrorlog_VAL, mirrorlog_arg, "MirrorLog", "core|disk")
+val(sizekb_VAL, size_kb_arg, "SizeKB", "Number[k|unit]")
+val(sizemb_VAL, size_mb_arg, "SizeMB", "Number[m|unit]")
+val(numsigned_VAL, int_arg_with_sign, "SNumber", "[+|-]Number")
+val(numsignedper_VAL, int_arg_with_sign_and_percent, "SNumberP", "[+|-]Number[%VG|%PVS|%FREE]")
+val(permission_VAL, permission_arg, "Permission", "rw|r")
+val(metadatatype_VAL, metadatatype_arg, "MetadataType", "lvm2|lvm1")
+val(units_VAL, string_arg, "Units", "hHbBsSkKmMgGtTpPeE")
+val(segtype_VAL, segtype_arg, "SegType", "linear|striped|snapshot|mirror|raid*|thin|cache|thin-pool|cache-pool")
+val(alloc_VAL, alloc_arg, "Alloc", "contiguous|cling|cling_by_tags|normal|anywhere|inherit")
+val(locktype_VAL, locktype_arg, "LockType", "sanlock|dlm|none")
+val(readahead_VAL, readahead_arg, "Readahead", "auto|none|NumberSectors")
+val(vgmetadatacopies_VAL, vgmetadatacopies_arg, "MetadataCopiesVG", "all|unmanaged|Number")
+val(pvmetadatacopies_VAL, pvmetadatacopies_arg, "MetadataCopiesPV", "0|1|2")
+val(metadatacopies_VAL, metadatacopies_arg, "unused", "unused")
+val(polloperation_VAL, polloperation_arg, "PollOp", "pvmove|convert|merge|merge_thin")
+val(writemostly_VAL, writemostly_arg, "WriteMostlyPV", "PV[:t|n|y]")
+val(syncaction_VAL, syncaction_arg, "SyncAction", "check|repair")
+val(reportformat_VAL, reportformat_arg, "ReportFmt", "basic|json")
+val(configreport_VAL, configreport_arg, "ConfigReport", "log|vg|lv|pv|pvseg|seg")
+val(configtype_VAL, configtype_arg, "ConfigType", "current|default|diff|full|list|missing|new|profilable|profilable-command|profilable-metadata")
+
+/* this should always be last */
+val(VAL_COUNT, NULL, NULL, NULL)
+
diff --git a/tools/vgchange.c b/tools/vgchange.c
index ca0f450..4cf8a3c 100644
--- a/tools/vgchange.c
+++ b/tools/vgchange.c
@@ -482,6 +482,9 @@ static int _vgchange_metadata_copies(struct cmd_context *cmd,
 {
 	uint32_t mda_copies = arg_uint_value(cmd, vgmetadatacopies_ARG, DEFAULT_VGMETADATACOPIES);
 
+	log_warn("vgchange_metadata_copies new %u vg_mda_copies %u D %u",
+		 mda_copies, vg_mda_copies(vg), DEFAULT_VGMETADATACOPIES);
+
 	if (mda_copies == vg_mda_copies(vg)) {
 		if (vg_mda_copies(vg) == VGMETADATACOPIES_UNMANAGED)
 			log_warn("Number of metadata copies for VG %s is already unmanaged.",
diff --git a/tools/vgconvert.c b/tools/vgconvert.c
index 2c0ac08..9f98048 100644
--- a/tools/vgconvert.c
+++ b/tools/vgconvert.c
@@ -157,24 +157,12 @@ int vgconvert(struct cmd_context *cmd, int argc, char **argv)
 		return EINVALID_CMD_LINE;
 	}
 
-	if (arg_is_set(cmd, metadatacopies_ARG)) {
-		log_error("Invalid option --metadatacopies, "
-			  "use --pvmetadatacopies instead.");
-		return EINVALID_CMD_LINE;
-	}
 	if (!(cmd->fmt->features & FMT_MDAS) &&
-	    (arg_is_set(cmd, pvmetadatacopies_ARG) ||
-	     arg_is_set(cmd, metadatasize_ARG))) {
+	    arg_is_set(cmd, pvmetadatacopies_ARG)) {
 		log_error("Metadata parameters only apply to text format");
 		return EINVALID_CMD_LINE;
 	}
 
-	if (arg_is_set(cmd, pvmetadatacopies_ARG) &&
-	    arg_int_value(cmd, pvmetadatacopies_ARG, -1) > 2) {
-		log_error("Metadatacopies may only be 0, 1 or 2");
-		return EINVALID_CMD_LINE;
-	}
-
 	if (!(cmd->fmt->features & FMT_BAS) &&
 		arg_is_set(cmd, bootloaderareasize_ARG)) {
 		log_error("Bootloader area parameters only apply to text format");
diff --git a/tools/vgextend.c b/tools/vgextend.c
index e16316f..35168e9 100644
--- a/tools/vgextend.c
+++ b/tools/vgextend.c
@@ -136,12 +136,6 @@ int vgextend(struct cmd_context *cmd, int argc, char **argv)
 		return EINVALID_CMD_LINE;
 	}
 
-	if (arg_is_set(cmd, metadatacopies_ARG)) {
-		log_error("Invalid option --metadatacopies, "
-			  "use --pvmetadatacopies instead.");
-		return EINVALID_CMD_LINE;
-	}
-
 	vg_name = skip_dev_dir(cmd, argv[0], NULL);
 	argc--;
 	argv++;


