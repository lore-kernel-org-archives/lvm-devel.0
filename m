From: M. Mohan Kumar <mohan@in.ibm.com>
Date: Tue, 12 Feb 2013 22:54:36 +0530
Subject: [PATCH 2/2] master - thin: Add low water mark parameter to pool creation
In-Reply-To: <1360689876-13552-1-git-send-email-mohan@in.ibm.com>
References: <1360689876-13552-1-git-send-email-mohan@in.ibm.com>
Message-ID: <1360689876-13552-3-git-send-email-mohan@in.ibm.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

From: "M. Mohan Kumar" <mohan@in.ibm.com>

Add --lowwatermark parameter to thin-pool creation. It enables sending
dmevent when the percentage of free blocks in the pool reaches below this
percent

Signed-off-by: M. Mohan Kumar <mohan@in.ibm.com>
---
 man/lvcreate.8.in | 11 ++++++++++-
 tools/args.h      |  1 +
 tools/commands.h  |  6 ++++--
 tools/lvconvert.c |  1 +
 tools/lvcreate.c  |  7 ++++++-
 tools/toollib.c   | 11 +++++++++++
 tools/toollib.h   |  1 +
 7 files changed, 34 insertions(+), 4 deletions(-)

diff --git a/man/lvcreate.8.in b/man/lvcreate.8.in
index da4c1fe..6a6ebcc 100644
--- a/man/lvcreate.8.in
+++ b/man/lvcreate.8.in
@@ -57,7 +57,9 @@ lvcreate \- create a logical volume in an existing volume group
 .RB [ \-\-discards
 .RI { ignore | nopassdown | passdown }]
 .RB [ \-\-poolmetadatasize
-.IR ThinPoolMetadataSize [ bBsSkKmMgG ]]]
+.IR ThinPoolMetadataSize [ bBsSkKmMgG ]]
+.RB [ \-\-lowwatermark
+.IR ThinPoolLowWaterMarkThreshold in percentage ]]
 .RB [ \-\-thinpool
 .IR ThinPoolLogicalVolume { Name | Path }]
 .RB [ \-\-type
@@ -246,6 +248,13 @@ Supported value is in range between 2MiB and 16GiB.
 Default value is  (Pool_LV_size / Pool_LV_chunk_size * 64b).
 Default unit is megabytes.
 .TP
+.IR \fB\-\-lowwatermark " " ThinPoolLowWaterMarkThreshold in percentage
+Set the low water mark threshold of thin pool logical volume.
+Supported value is in range between 0 and 100.
+Default value is 0, meaning a dm event will be generated only when
+all blocks in the pool are consumed. A value of 25 means dm event will
+be generated when percentage of free blocks in the pool becomes <= 25%
+.TP
 .IR \fB\-r ", " \fB\-\-readahead " {" ReadAheadSectors | auto | none }
 Set read ahead sector count of this logical volume.
 For volume groups with metadata in lvm1 format, this must
diff --git a/tools/args.h b/tools/args.h
index d4d6c40..93657cc 100644
--- a/tools/args.h
+++ b/tools/args.h
@@ -77,6 +77,7 @@ arg(force_long_ARG, '\0', "force", NULL, ARG_COUNTABLE)
 arg(stripes_long_ARG, '\0', "stripes", int_arg, 0)
 arg(sysinit_ARG, '\0', "sysinit", NULL, 0)
 arg(thinpool_ARG, '\0', "thinpool", string_arg, 0)
+arg(lowwatermark_ARG, '\0', "lowwatermark", int_arg, 0)
 
 /* Allow some variations */
 arg(resizable_ARG, '\0', "resizable", yes_no_arg, 0)
diff --git a/tools/commands.h b/tools/commands.h
index 986539e..0a5972b 100644
--- a/tools/commands.h
+++ b/tools/commands.h
@@ -185,7 +185,8 @@ xx(lvcreate,
    "\t[-r|--readahead ReadAheadSectors|auto|none]\n"
    "\t[-R|--regionsize MirrorLogRegionSize]\n"
    "\t[-T|--thin  [-c|--chunksize  ChunkSize]\n"
-   "\t  [--discards {ignore|nopassdown|passdown}]\n"
+   "\t  [--discards {ignore|nopassdown|passdown}] \n"
+   "\t  [--lowwatermark low_water_mark threshold in percentage of total number of blocks] \n"
    "\t  [--poolmetadatasize MetadataSize[bBsSkKmMgG]]]\n"
    "\t[--thinpool ThinPoolLogicalVolume{Name|Path}]\n"
    "\t[-t|--test]\n"
@@ -232,7 +233,8 @@ xx(lvcreate,
    monitor_ARG, name_ARG, nosync_ARG, noudevsync_ARG, permission_ARG,
    persistent_ARG, readahead_ARG, regionsize_ARG, size_ARG, snapshot_ARG,
    stripes_ARG, stripesize_ARG, test_ARG, thin_ARG, thinpool_ARG, type_ARG,
-   virtualoriginsize_ARG, poolmetadatasize_ARG, virtualsize_ARG, zero_ARG)
+   virtualoriginsize_ARG, poolmetadatasize_ARG, virtualsize_ARG, zero_ARG,
+   lowwatermark_ARG)
 
 xx(lvdisplay,
    "Display information about a logical volume",
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 5bda00f..9c0ed99 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -352,6 +352,7 @@ static int _read_params(struct lvconvert_params *lp, struct cmd_context *cmd,
 				     &lp->chunk_size,
 				     &lp->discards,
 				     &lp->poolmetadata_size,
+				     NULL,
 				     &lp->zero))
 			return_0;
 
diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index 78292f7..41358f8 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -799,7 +799,8 @@ static int _lvcreate_params(struct lvcreate_params *lp,
 	    !get_stripe_params(cmd, &lp->stripes, &lp->stripe_size) ||
 	    (lp->create_thin_pool &&
 	     !get_pool_params(cmd, &lp->chunk_size, &lp->discards,
-			      &lp->poolmetadatasize, &lp->zero)) ||
+			      &lp->poolmetadatasize, &lp->low_water_mark,
+			      &lp->zero)) ||
 	    !_read_mirror_params(lp, cmd) ||
 	    !_read_raid_params(lp, cmd))
 		return_0;
@@ -926,6 +927,10 @@ static int _check_thin_parameters(struct volume_group *vg, struct lvcreate_param
 			log_error("--zero may only be specified when allocating the thin pool.");
 			return 0;
 		}
+		if (arg_count(vg->cmd, lowwatermark_ARG)) {
+			log_error("--lowwatermark may only be specified when allocating the thin pool.");
+			return 0;
+		}
 	}
 
 	if (lp->create_thin_pool && lp->pool) {
diff --git a/tools/toollib.c b/tools/toollib.c
index 669d772..627c2ec 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -1525,9 +1525,11 @@ int get_pool_params(struct cmd_context *cmd,
 		    uint32_t *chunk_size,
 		    thin_discards_t *discards,
 		    uint64_t *pool_metadata_size,
+		    uint64_t *lowwatermark,
 		    int *zero)
 {
 	const char *dstr;
+	int lwm;
 
 	if (arg_count(cmd, zero_ARG)) {
 		*zero = strcmp(arg_str_value(cmd, zero_ARG, "y"), "n");
@@ -1577,6 +1579,15 @@ int get_pool_params(struct cmd_context *cmd,
 	}
 	*pool_metadata_size = arg_uint64_value(cmd, poolmetadatasize_ARG, UINT64_C(0));
 
+	if (lowwatermark) {
+		if (arg_sign_value(cmd, lowwatermark_ARG, SIGN_NONE) == SIGN_MINUS) {
+			log_error("Negative low water mark threshold is invalid.");
+			return 0;
+		}
+
+		lwm = arg_uint_value(cmd, lowwatermark_ARG, UINT32_C(0));
+		*lowwatermark = *pool_metadata_size / *chunk_size * lwm * 100;
+	}
 	return 1;
 }
 
diff --git a/tools/toollib.h b/tools/toollib.h
index 80c01fd..1b7a03e 100644
--- a/tools/toollib.h
+++ b/tools/toollib.h
@@ -115,6 +115,7 @@ int get_pool_params(struct cmd_context *cmd,
 		    uint32_t *chunk_size,
 		    thin_discards_t *discards,
 		    uint64_t *pool_metadata_size,
+		    uint64_t *lowwatermark,
 		    int *zero);
 int update_pool_params(struct cmd_context *cmd, unsigned attr,
 		       uint32_t data_extents, uint32_t extent_size,
-- 
1.7.11.7


