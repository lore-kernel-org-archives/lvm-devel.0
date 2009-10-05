From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Mon,  5 Oct 2009 16:00:38 +0200
Subject: [PATCH 11/13] Replicator: add new options for replicator
In-Reply-To: <1254751240-17431-10-git-send-email-zkabelac@redhat.com>
References: <1254751240-17431-1-git-send-email-zkabelac@redhat.com>
	<1254751240-17431-2-git-send-email-zkabelac@redhat.com>
	<1254751240-17431-3-git-send-email-zkabelac@redhat.com>
	<1254751240-17431-4-git-send-email-zkabelac@redhat.com>
	<1254751240-17431-5-git-send-email-zkabelac@redhat.com>
	<1254751240-17431-6-git-send-email-zkabelac@redhat.com>
	<1254751240-17431-7-git-send-email-zkabelac@redhat.com>
	<1254751240-17431-8-git-send-email-zkabelac@redhat.com>
	<1254751240-17431-9-git-send-email-zkabelac@redhat.com>
	<1254751240-17431-10-git-send-email-zkabelac@redhat.com>
Message-ID: <1254751240-17431-11-git-send-email-zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

New options: addsite, delsite, replicator,
replicatorlog, replicatorlogtype

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 tools/args.h       |    5 +++++
 tools/commands.h   |   10 ++++++++--
 tools/lvcreate.c   |   17 +++++++++++++++++
 tools/lvmcmdline.c |   10 ++++++++++
 tools/tools.h      |    1 +
 5 files changed, 41 insertions(+), 2 deletions(-)

diff --git a/tools/args.h b/tools/args.h
index 1204683..f3b61b7 100644
--- a/tools/args.h
+++ b/tools/args.h
@@ -63,6 +63,11 @@ arg(dataalignmentoffset_ARG, '\0', "dataalignmentoffset", size_kb_arg, 0)
 arg(virtualoriginsize_ARG, '\0', "virtualoriginsize", size_mb_arg, 0)
 arg(virtualsize_ARG, '\0', "virtualsize", size_mb_arg, 0)
 arg(noudevsync_ARG, '\0', "noudevsync", NULL, 0)
+arg(replicator_ARG, '\0', "replicator", NULL, 0)
+arg(replicatorlog_ARG, '\0', "replicatorlog", NULL, 0)
+arg(replicatorlogtype_ARG, '\0', "replicatorlogtype", NULL, 0)
+arg(addsite_ARG, '\0', "addsite", site_arg, 0)
+arg(delsite_ARG, '\0', "delsite", site_arg, 0)
 
 /* Allow some variations */
 arg(resizable_ARG, '\0', "resizable", yes_no_arg, 0)
diff --git a/tools/commands.h b/tools/commands.h
index 73ebd0b..fbf59b2 100644
--- a/tools/commands.h
+++ b/tools/commands.h
@@ -63,10 +63,12 @@ xx(lvchange,
    "\t[-A|--autobackup y|n]\n"
    "\t[-a|--available [e|l]y|n]\n"
    "\t[--addtag Tag]\n"
+   "\t[--addsite Site]\n"
    "\t[--alloc AllocationPolicy]\n"
    "\t[-C|--contiguous y|n]\n"
    "\t[-d|--debug]\n"
    "\t[--deltag Tag]\n"
+   "\t[--delsite Site]\n"
    "\t[-f|--force]\n"
    "\t[-h|--help]\n"
    "\t[--ignorelockingfailure]\n"
@@ -89,7 +91,7 @@ xx(lvchange,
    ignorelockingfailure_ARG, ignoremonitoring_ARG, major_ARG, minor_ARG,
    monitor_ARG, noudevsync_ARG, partial_ARG, permission_ARG, persistent_ARG,
    readahead_ARG, resync_ARG, refresh_ARG, addtag_ARG, deltag_ARG, test_ARG,
-   yes_ARG)
+   addsite_ARG, delsite_ARG, yes_ARG)
 
 xx(lvconvert,
    "Change logical volume layout",
@@ -145,6 +147,9 @@ xx(lvcreate,
    "\t[-p|--permission {r|rw}]\n"
    "\t[-r|--readahead ReadAheadSectors|auto|none]\n"
    "\t[-R|--regionsize MirrorLogRegionSize]\n"
+   "\t[--replicator]\n"
+   "\t[--replicatorlog LogicalVolumeName]\n"
+   "\t[--replicatorlogtype ringbuffer]\n"
    "\t[-t|--test]\n"
    "\t[--type VolumeType]\n"
    "\t[-v|--verbose]\n"
@@ -179,7 +184,8 @@ xx(lvcreate,
    addtag_ARG, alloc_ARG, autobackup_ARG, chunksize_ARG, contiguous_ARG,
    corelog_ARG, extents_ARG, major_ARG, minor_ARG, mirrorlog_ARG, mirrors_ARG,
    name_ARG, nosync_ARG, noudevsync_ARG, permission_ARG, persistent_ARG,
-   readahead_ARG, regionsize_ARG, size_ARG, snapshot_ARG, stripes_ARG,
+   readahead_ARG, regionsize_ARG, replicator_ARG, replicatorlog_ARG,
+   replicatorlogtype_ARG, size_ARG, snapshot_ARG, stripes_ARG,
    stripesize_ARG, test_ARG, type_ARG, virtualoriginsize_ARG, virtualsize_ARG,
    zero_ARG)
 
diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index be6b5cc..c655a2b 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -405,6 +405,9 @@ static int _lvcreate_params(struct lvcreate_params *lp,
 	if (seg_is_mirrored(lp))
 		lp->mirrors = 2;
 
+	if (seg_is_replicator(lp) || arg_count(cmd, replicator_ARG))
+		lp->replicator = 1;
+
 	if (arg_count(cmd, mirrors_ARG)) {
 		lp->mirrors = arg_uint_value(cmd, mirrors_ARG, 0) + 1;
 		if (lp->mirrors == 1)
@@ -469,6 +472,20 @@ static int _lvcreate_params(struct lvcreate_params *lp,
 		}
 	}
 
+	if (lp->replicator) {
+		log_error("--replicator for replicators");
+
+	} else {
+		if (arg_count(cmd, replicatorlog_ARG)) {
+			log_error("--replicatorlog is only available with replicators");
+			return 0;
+		}
+		if (arg_count(cmd, replicatorlogtype_ARG)) {
+			log_error("--replicatorlogtype is only available with replicators");
+			return 0;
+		}
+	}
+
 	if (activation() && lp->segtype->ops->target_present &&
 	    !lp->segtype->ops->target_present(cmd, NULL, NULL)) {
 		log_error("%s: Required device-mapper target(s) not "
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 80c1a46..f3c0e21 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -483,6 +483,16 @@ int readahead_arg(struct cmd_context *cmd __attribute((unused)), struct arg *a)
 	return 1;
 }
 
+int site_arg(struct cmd_context *cmd __attribute((unused)), struct arg *a)
+{
+	char *pos = a->value;
+	if (!validate_name(pos))
+		return 0;
+
+	return 1;
+}
+
+
 static void __alloc(int size)
 {
 	if (!(_cmdline.commands = dm_realloc(_cmdline.commands, sizeof(*_cmdline.commands) * size))) {
diff --git a/tools/tools.h b/tools/tools.h
index 3afa1a1..67b2178 100644
--- a/tools/tools.h
+++ b/tools/tools.h
@@ -151,6 +151,7 @@ int units_arg(struct cmd_context *cmd, struct arg *a);
 int segtype_arg(struct cmd_context *cmd, struct arg *a);
 int alloc_arg(struct cmd_context *cmd, struct arg *a);
 int readahead_arg(struct cmd_context *cmd, struct arg *a);
+int site_arg(struct cmd_context *cmd, struct arg *a);
 
 /* we use the enums to access the switches */
 unsigned int arg_count(const struct cmd_context *cmd, int a);
-- 
1.6.5.rc2


