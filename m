From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon,  6 Oct 2014 13:32:49 +0000 (UTC)
Subject: master - commands: support shortcut -H for cache objects
Message-ID: <20141006133249.4A587609E5@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=fc77e4291bdae39e1ea9dfdf0c8ef9af493df9cb
Commit:        fc77e4291bdae39e1ea9dfdf0c8ef9af493df9cb
Parent:        1a6c892864c409724bcc0fdd48e325ae1674ae8b
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Sep 29 20:43:11 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Oct 6 15:18:05 2014 +0200

commands: support shortcut -H for cache objects

Introduce cache_long_ARG for those instancies
where --cache is not related to caching LV.
(pvchange,vg|lv|pvscan).

cache_ARG is now with -H shortcut.
---
 WHATS_NEW        |    1 +
 tools/args.h     |    3 ++-
 tools/commands.h |    6 +++---
 tools/lvscan.c   |    4 ++--
 tools/pvscan.c   |    2 +-
 tools/vgscan.c   |    2 +-
 6 files changed, 10 insertions(+), 8 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 1ac7750..9847730 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.112 - 
 =====================================
+  Option --cache has also shortcut -H (i.e. lvcreate -H).
   Refactor lvcreate code and better preserve --type argument.
   Refactor process_each_vg in toollib.
   Pools cannot be used as external origin.
diff --git a/tools/args.h b/tools/args.h
index dc467d2..c1999bd 100644
--- a/tools/args.h
+++ b/tools/args.h
@@ -63,7 +63,7 @@ arg(merge_ARG, '\0', "merge", NULL, 0)
 arg(monitor_ARG, '\0', "monitor", yes_no_arg, 0)
 arg(config_ARG, '\0', "config", string_arg, 0)
 arg(trustcache_ARG, '\0', "trustcache", NULL, 0)
-arg(cache_ARG, '\0', "cache", NULL, 0)
+arg(cache_long_ARG, '\0', "cache", NULL, 0)
 arg(cachemode_ARG, '\0', "cachemode", string_arg, 0)
 arg(cachepool_ARG, '\0', "cachepool", string_arg, 0)
 arg(ignoremonitoring_ARG, '\0', "ignoremonitoring", NULL, 0)
@@ -140,6 +140,7 @@ arg(file_ARG, 'f', "file", string_arg, 0)
 arg(force_ARG, 'f', "force", NULL, ARG_COUNTABLE)
 arg(full_ARG, 'f', "full", NULL, 0)
 arg(help_ARG, 'h', "help", NULL, 0)
+arg(cache_ARG, 'H', "cache", NULL, 0)
 arg(help2_ARG, '?', "", NULL, 0)
 arg(stripesize_ARG, 'I', "stripesize", size_kb_arg, 0)
 arg(stripes_ARG, 'i', "stripes", int_arg, 0)
diff --git a/tools/commands.h b/tools/commands.h
index afdf4c3..1e3677e 100644
--- a/tools/commands.h
+++ b/tools/commands.h
@@ -592,7 +592,7 @@ xx(lvscan,
    "\t[--version]\n",
 
    all_ARG, blockdevice_ARG, ignorelockingfailure_ARG, partial_ARG,
-   readonly_ARG, cache_ARG)
+   readonly_ARG, cache_long_ARG)
 
 xx(pvchange,
    "Change attributes of physical volume(s)",
@@ -839,7 +839,7 @@ xx(pvscan,
    "\t[-v|--verbose] " "\n"
    "\t[--version]\n",
 
-   activate_ARG, available_ARG, backgroundfork_ARG, cache_ARG,
+   activate_ARG, available_ARG, backgroundfork_ARG, cache_long_ARG,
    exported_ARG, ignorelockingfailure_ARG, major_ARG, minor_ARG,
    novolumegroup_ARG, partial_ARG, readonly_ARG, short_ARG, uuid_ARG)
 
@@ -1227,7 +1227,7 @@ xx(vgscan,
    "\t[-v|--verbose]\n"
    "\t[--version]" "\n",
 
-   cache_ARG, ignorelockingfailure_ARG, mknodes_ARG, partial_ARG)
+   cache_long_ARG, ignorelockingfailure_ARG, mknodes_ARG, partial_ARG)
 
 xx(vgsplit,
    "Move physical volumes into a new or existing volume group",
diff --git a/tools/lvscan.c b/tools/lvscan.c
index f05fd50..2d7be07 100644
--- a/tools/lvscan.c
+++ b/tools/lvscan.c
@@ -56,7 +56,7 @@ static int lvscan_single(struct cmd_context *cmd, struct logical_volume *lv,
 
 	const char *active_str, *snapshot_str;
 
-	if (arg_count(cmd, cache_ARG))
+	if (arg_count(cmd, cache_long_ARG))
 		return _lvscan_single_lvmetad(cmd, lv);
 
 	if (!arg_count(cmd, all_ARG) && !lv_is_visible(lv))
@@ -93,7 +93,7 @@ static int lvscan_single(struct cmd_context *cmd, struct logical_volume *lv,
 
 int lvscan(struct cmd_context *cmd, int argc, char **argv)
 {
-	if (argc && !arg_count(cmd, cache_ARG)) {
+	if (argc && !arg_count(cmd, cache_long_ARG)) {
 		log_error("No additional command line arguments allowed");
 		return EINVALID_CMD_LINE;
 	}
diff --git a/tools/pvscan.c b/tools/pvscan.c
index 10e08ba..3eaf0bb 100644
--- a/tools/pvscan.c
+++ b/tools/pvscan.c
@@ -327,7 +327,7 @@ int pvscan(struct cmd_context *cmd, int argc, char **argv)
 	uint64_t size_new = 0;
 	unsigned len;
 
-	if (arg_count(cmd, cache_ARG))
+	if (arg_count(cmd, cache_long_ARG))
 		return _pvscan_lvmetad(cmd, argc, argv);
 
 	if (argc) {
diff --git a/tools/vgscan.c b/tools/vgscan.c
index fff0e89..bca98cc 100644
--- a/tools/vgscan.c
+++ b/tools/vgscan.c
@@ -46,7 +46,7 @@ int vgscan(struct cmd_context *cmd, int argc, char **argv)
 		cmd->filter->wipe(cmd->filter);
 	lvmcache_destroy(cmd, 1, 0);
 
-	if (arg_count(cmd, cache_ARG)) {
+	if (arg_count(cmd, cache_long_ARG)) {
 		if (lvmetad_active()) {
 			if (!lvmetad_pvscan_all_devs(cmd, NULL))
 				return ECMD_FAILED;


