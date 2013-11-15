From: Peter Rajnoha <prajnoha@redhat.com>
Date: Fri, 15 Nov 2013 16:00:49 +0100
Subject: [PATCH 2/6] lvcreate: recognize --wipesignatures arg
Message-ID: <52863721.3050500@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Recognize the new --wipesignatures arg in lvcreate that is supposed
to wipe known signatures if found on newly created LV.
---
 lib/metadata/metadata-exported.h |  1 +
 liblvm/lvm_lv.c                  |  1 +
 tools/args.h                     |  1 +
 tools/commands.h                 |  4 +++-
 tools/lvcreate.c                 | 13 ++++++++-----
 5 files changed, 14 insertions(+), 6 deletions(-)

diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index c00e4e5..52c04d9 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -721,6 +721,7 @@ struct lvcreate_params {
 	int thin; /* thin */
 	int create_thin_pool; /* thin */
 	int zero; /* all */
+	int wipe_signatures; /* all */
 	int major; /* all */
 	int minor; /* all */
 	int log_count; /* mirror */
diff --git a/liblvm/lvm_lv.c b/liblvm/lvm_lv.c
index 46399e4..5d1bb24 100644
--- a/liblvm/lvm_lv.c
+++ b/liblvm/lvm_lv.c
@@ -129,6 +129,7 @@ static void _lv_set_default_params(struct lvcreate_params *lp,
 				   uint64_t extents)
 {
 	lp->zero = 1;
+	lp->wipe_signatures = 0;
 	lp->major = -1;
 	lp->minor = -1;
 	lp->activate = CHANGE_AY;
diff --git a/tools/args.h b/tools/args.h
index 27b97eb..8ca73a3 100644
--- a/tools/args.h
+++ b/tools/args.h
@@ -176,6 +176,7 @@ arg(uuidlist_ARG, 'U', "uuidlist", NULL, 0)
 arg(verbose_ARG, 'v', "verbose", NULL, ARG_COUNTABLE)
 arg(volumegroup_ARG, 'V', "volumegroup", NULL, 0)
 arg(virtualsize_ARG, 'V', "virtualsize", size_mb_arg, 0)
+arg(wipesignatures_ARG, 'W', "wipesignatures", yes_no_arg, 0)
 arg(allocatable_ARG, 'x', "allocatable", yes_no_arg, 0)
 arg(resizeable_ARG, 'x', "resizeable", yes_no_arg, 0)
 arg(yes_ARG, 'y', "yes", NULL, 0)
diff --git a/tools/commands.h b/tools/commands.h
index c299276..c54e812 100644
--- a/tools/commands.h
+++ b/tools/commands.h
@@ -248,6 +248,7 @@ xx(lvcreate,
    "\t[-t|--test]\n"
    "\t[--type VolumeType]\n"
    "\t[-v|--verbose]\n"
+   "\t[-W|--wipesignatures {y|n}]\n"
    "\t[-Z|--zero {y|n}]\n"
    "\t[--version]\n"
    "\tVolumeGroupName [PhysicalVolumePath...]\n\n"
@@ -294,7 +295,8 @@ xx(lvcreate,
    raidminrecoveryrate_ARG, raidmaxrecoveryrate_ARG, readahead_ARG,
    regionsize_ARG, setactivationskip_ARG, size_ARG, snapshot_ARG, stripes_ARG,
    stripesize_ARG, test_ARG, thin_ARG, thinpool_ARG,
-   type_ARG, virtualoriginsize_ARG, virtualsize_ARG, zero_ARG)
+   type_ARG, virtualoriginsize_ARG, virtualsize_ARG,
+   wipesignatures_ARG, zero_ARG)
 
 xx(lvdisplay,
    "Display information about a logical volume",
diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index 4850872..8184024 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -614,8 +614,8 @@ static int _read_activation_params(struct lvcreate_params *lp, struct cmd_contex
 			return 0;
 		}
 	} else if (lp->activate == CHANGE_AAY) {
-		if (arg_count(cmd, zero_ARG)) {
-			log_error("-Z is incompatible with --activate a");
+		if (arg_count(cmd, zero_ARG) || arg_count(cmd, wipesignatures_ARG)) {
+			log_error("-Z and -W is incompatible with --activate a");
 			return 0;
 		}
 		lp->zero = 0;
@@ -644,9 +644,11 @@ static int _read_activation_params(struct lvcreate_params *lp, struct cmd_contex
 	lp->permission = arg_uint_value(cmd, permission_ARG,
 					LVM_READ | LVM_WRITE);
 
-	/* Must not zero read only volume */
-	if (!(lp->permission & LVM_WRITE))
+	/* Must not zero/wipe read only volume */
+	if (!(lp->permission & LVM_WRITE)) {
 		lp->zero = 0;
+		lp->wipe_signatures = 0;
+	}
 
 	if (arg_count(cmd, major_ARG) > 1) {
 		log_error("Option -j/--major may not be repeated.");
@@ -867,10 +869,11 @@ static int _lvcreate_params(struct lvcreate_params *lp,
 	}
 
 	/*
-	 * Should we zero the lv.
+	 * Should we zero/wipe signatures on the lv.
 	 */
 	lp->zero = strcmp(arg_str_value(cmd, zero_ARG,
 		(lp->segtype->flags & SEG_CANNOT_BE_ZEROED) ? "n" : "y"), "n");
+	lp->wipe_signatures = strcmp(arg_str_value(cmd, wipesignatures_ARG, "n"), "n");
 
 	if (!_lvcreate_name_params(lp, cmd, &argc, &argv) ||
 	    !_read_size_params(lp, lcp, cmd) ||
-- 
1.8.4.2


