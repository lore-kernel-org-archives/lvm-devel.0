From: Mike Snitzer <snitzer@redhat.com>
Date: Tue,  2 Feb 2010 16:17:31 -0500
Subject: [PATCH] add %ORIGIN support to the --extents option
Message-ID: <1265145451-17708-1-git-send-email-snitzer@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Allow the number of logical extents to be expressed as a percentage of
the total space in the Origin Logical Volume with the suffix %ORIGIN.

Update the relevant man pages accordingly.  Eliminate inconsistencies
between the man pages and tools/commands.h

Signed-off-by: Mike Snitzer <snitzer@redhat.com>
---
 man/lvcreate.8.in  |   11 ++++++-----
 man/lvextend.8.in  |    9 +++++----
 man/lvreduce.8.in  |   16 +++++++++-------
 man/lvresize.8.in  |    9 +++++----
 tools/commands.h   |   10 +++++-----
 tools/lvcreate.c   |   10 ++++++++++
 tools/lvmcmdline.c |    3 +++
 tools/lvresize.c   |    7 +++++++
 tools/tools.h      |    3 ++-
 9 files changed, 52 insertions(+), 26 deletions(-)

diff --git a/man/lvcreate.8.in b/man/lvcreate.8.in
index 5041eab..7078e45 100644
--- a/man/lvcreate.8.in
+++ b/man/lvcreate.8.in
@@ -22,7 +22,7 @@ VolumeGroupName [PhysicalVolumePath[:PE[-PE]]...]
 
 .br
 .B lvcreate
-{\-l|\-\-extents LogicalExtentsNumber[%{VG|FREE}] |
+{\-l|\-\-extents LogicalExtentsNumber[%{VG|FREE|ORIGIN}] |
  \-L|\-\-size LogicalVolumeSize[bBsSkKmMgGtTpPeE]}
 [\-c|\-\-chunksize ChunkSize]
 [\-\-noudevsync]
@@ -70,14 +70,15 @@ StripeSize must be 2^n (n = 2 to 9) for metadata in LVM1 format.
 For metadata in LVM2 format, the stripe size may be a larger
 power of 2 but must not exceed the physical extent size.
 .TP
-.I \-l, \-\-extents LogicalExtentsNumber[%{VG|PVS|FREE}]
+.I \-l, \-\-extents LogicalExtentsNumber[%{VG|PVS|FREE|ORIGIN}]
 Gives the number of logical extents to allocate for the new
 logical volume.
 This can also be expressed as a percentage of the total space
 in the Volume Group with the suffix %VG, of the remaining
-free space in the Volume Group with the suffix %FREE, or
-of the remaining free space for the specified PhysicalVolume(s)
-with the suffix %PVS,
+free space in the Volume Group with the suffix %FREE, of
+the remaining free space for the specified PhysicalVolume(s)
+with the suffix %PVS, or of the total space in the Origin Logical
+Volume with the suffix %ORIGIN.
 .TP
 .I \-L, \-\-size LogicalVolumeSize[bBsSkKmMgGtTpPeE]
 Gives the size to allocate for the new logical volume.
diff --git a/man/lvextend.8.in b/man/lvextend.8.in
index 032e390..4a3f7dc 100644
--- a/man/lvextend.8.in
+++ b/man/lvextend.8.in
@@ -7,7 +7,7 @@ lvextend \- extend the size of a logical volume
 [\-A|\-\-autobackup y|n] [\-d|\-\-debug] [\-h|\-?|\-\-help]
 [\-\-noudevsync]
 [\-i|\-\-stripes Stripes [\-I|\-\-stripesize StripeSize]]
-{\-l|\-\-extents [+]LogicalExtentsNumber[%{VG|LV|PVS|FREE}] |
+{\-l|\-\-extents [+]LogicalExtentsNumber[%{VG|LV|PVS|FREE|ORIGIN}] |
 \-L|\-\-size [+]LogicalVolumeSize[bBsSkKmMgGtTpPeE]}
 [\-t|\-\-test]
 [\-v|\-\-verbose] LogicalVolumePath [PhysicalVolumePath[:PE[-PE]]...]
@@ -29,7 +29,7 @@ It will continue irrespective of any possible udev processing
 in the background.  You should only use this if udev is not running
 or has rules that ignore the devices LVM2 creates.
 .TP
-.I \-l, \-\-extents [+]LogicalExtentsNumber[%{VG|LV|PVS|FREE}]
+.I \-l, \-\-extents [+]LogicalExtentsNumber[%{VG|LV|PVS|FREE|ORIGIN}]
 Extend or set the logical volume size in units of logical extents.
 With the + sign the value is added to the actual size
 of the logical volume and without it, the value is taken as an absolute one.
@@ -37,8 +37,9 @@ The number can also be expressed as a percentage of the total space
 in the Volume Group with the suffix %VG, relative to the existing
 size of the Logical Volume with the suffix %LV, of the remaining
 free space for the specified PhysicalVolume(s) with the suffix %PVS,
-or as a percentage of the remaining free space in the Volume Group
-with the suffix %FREE.
+as a percentage of the remaining free space in the Volume Group
+with the suffix %FREE, or as a percentage of the total space in the
+Origin Logical Volume with the suffix %ORIGIN.
 .TP
 .I \-L, \-\-size [+]LogicalVolumeSize[bBsSkKmMgGtTpPeE]
 Extend or set the logical volume size in units of megabytes.
diff --git a/man/lvreduce.8.in b/man/lvreduce.8.in
index 5c79617..27c2ec3 100644
--- a/man/lvreduce.8.in
+++ b/man/lvreduce.8.in
@@ -6,7 +6,7 @@ lvreduce \- reduce the size of a logical volume
 [\-A|\-\-autobackup y|n] [\-d|\-\-debug] [\-f|\-\-force]
 [\-h|\-?|\-\-help]
 [\-\-noudevsync]
-{\-l|\-\-extents [\-]LogicalExtentsNumber[%{VG|LV|FREE}] |
+{\-l|\-\-extents [\-]LogicalExtentsNumber[%{VG|LV|FREE|ORIGIN}] |
 \-L|\-\-size [\-]LogicalVolumeSize[bBsSkKmMgGtTpPeE]}
 [\-t|\-\-test]
 [\-v|\-\-verbose] LogicalVolume[Path]
@@ -44,15 +44,17 @@ It will continue irrespective of any possible udev processing
 in the background.  You should only use this if udev is not running
 or has rules that ignore the devices LVM2 creates.
 .TP
-.I \-l, \-\-extents [\-]LogicalExtentsNumber[%{VG|LV|FREE}]
+.I \-l, \-\-extents [\-]LogicalExtentsNumber[%{VG|LV|FREE|ORIGIN}]
 Reduce or set the logical volume size in units of logical extents.
 With the - sign the value will be subtracted from
-the logical volume's actual size and without it the will be taken as
-an absolute size.
+the logical volume's actual size and without it the value will be taken
+as an absolute size.
 The number can also be expressed as a percentage of the total space
-in the Volume Group with the suffix %VG or relative to the existing
-size of the Logical Volume with the suffix %LV or as a percentage of the remaining
-free space in the Volume Group with the suffix %FREE.
+in the Volume Group with the suffix %VG, relative to the existing
+size of the Logical Volume with the suffix %LV, as a percentage of the
+remaining free space in the Volume Group with the suffix %FREE, or as a
+percentage of the total space in the Origin Logical Volume with the
+suffix %ORIGIN.
 .TP
 .I \-L, \-\-size [\-]LogicalVolumeSize[bBsSkKmMgGtTpPeE]
 Reduce or set the logical volume size in units of megabytes.
diff --git a/man/lvresize.8.in b/man/lvresize.8.in
index a6561c2..7129d06 100644
--- a/man/lvresize.8.in
+++ b/man/lvresize.8.in
@@ -7,7 +7,7 @@ lvresize \- resize a logical volume
 [\-A|\-\-autobackup y|n] [\-d|\-\-debug] [\-h|\-?|\-\-help]
 [\-\-noudevsync]
 [\-i|\-\-stripes Stripes [\-I|\-\-stripesize StripeSize]]
-{\-l|\-\-extents [+]LogicalExtentsNumber[%{VG|LV|PVS|FREE}] |
+{\-l|\-\-extents [+]LogicalExtentsNumber[%{VG|LV|PVS|FREE|ORIGIN}] |
 \-L|\-\-size [+]LogicalVolumeSize[bBsSkKmMgGtTpPeE]}
 [\-t|\-\-test]
 [\-v|\-\-verbose] LogicalVolumePath [PhysicalVolumePath[:PE[-PE]]...]
@@ -33,7 +33,7 @@ It will continue irrespective of any possible udev processing
 in the background.  You should only use this if udev is not running
 or has rules that ignore the devices LVM2 creates.
 .TP
-.I \-l, \-\-extents [+|-]LogicalExtentsNumber[%{VG|LV|PVS|FREE}]
+.I \-l, \-\-extents [+|-]LogicalExtentsNumber[%{VG|LV|PVS|FREE|ORIGIN}]
 Change or set the logical volume size in units of logical extents.
 With the + or - sign the value is added to or subtracted from the actual size
 of the logical volume and without it, the value is taken as an absolute one.
@@ -41,8 +41,9 @@ The number can also be expressed as a percentage of the total space
 in the Volume Group with the suffix %VG, relative to the existing
 size of the Logical Volume with the suffix %LV, as a percentage of
 the remaining free space of the PhysicalVolumes on the command line with the
-suffix %PVS, or as a percentage of the remaining free space in the
-Volume Group with the suffix %FREE.
+suffix %PVS, as a percentage of the remaining free space in the
+Volume Group with the suffix %FREE, or as a percentage of the total
+space in the Origin Logical Volume with the suffix %ORIGIN.
 .TP
 .I \-L, \-\-size [+|-]LogicalVolumeSize[bBsSkKmMgGtTpPeE]
 Change or set the logical volume size in units of megabytes.
diff --git a/tools/commands.h b/tools/commands.h
index 72898a9..ad0b385 100644
--- a/tools/commands.h
+++ b/tools/commands.h
@@ -151,7 +151,7 @@ xx(lvcreate,
    "\t[-d|--debug]\n"
    "\t[-h|-?|--help]\n"
    "\t[-i|--stripes Stripes [-I|--stripesize StripeSize]]\n"
-   "\t{-l|--extents LogicalExtentsNumber |\n"
+   "\t{-l|--extents LogicalExtentsNumber[%{VG|PVS|FREE}] |\n"
    "\t -L|--size LogicalVolumeSize[bBsSkKmMgGtTpPeE]}\n"
    "\t[-M|--persistent {y|n}] [--major major] [--minor minor]\n"
    "\t[-m|--mirrors Mirrors [--nosync] [{--mirrorlog {disk|core}|--corelog}]]\n"
@@ -178,7 +178,7 @@ xx(lvcreate,
    "\t[-d|--debug]\n"
    "\t[-h|-?|--help]\n"
    "\t[-i|--stripes Stripes [-I|--stripesize StripeSize]]\n"
-   "\t{-l|--extents LogicalExtentsNumber[%{VG|LV|PVS|FREE}] |\n"
+   "\t{-l|--extents LogicalExtentsNumber[%{VG|FREE|ORIGIN}] |\n"
    "\t -L|--size LogicalVolumeSize[bBsSkKmMgGtTpPeE]}\n"
    "\t[-M|--persistent {y|n}] [--major major] [--minor minor]\n"
    "\t[-n|--name LogicalVolumeName]\n"
@@ -249,7 +249,7 @@ xx(lvextend,
    "\t[-f|--force]\n"
    "\t[-h|--help]\n"
    "\t[-i|--stripes Stripes [-I|--stripesize StripeSize]]\n"
-   "\t{-l|--extents [+]LogicalExtentsNumber[%{VG|PVS|FREE}] |\n"
+   "\t{-l|--extents [+]LogicalExtentsNumber[%{VG|LV|PVS|FREE|ORIGIN}] |\n"
    "\t -L|--size [+]LogicalVolumeSize[bBsSkKmMgGtTpPeE]}\n"
    "\t[-m|--mirrors Mirrors]\n"
    "\t[-n|--nofsck]\n"
@@ -320,7 +320,7 @@ xx(lvreduce,
    "\t[-d|--debug]\n"
    "\t[-f|--force]\n"
    "\t[-h|--help]\n"
-   "\t{-l|--extents [-]LogicalExtentsNumber[%{VG|LV|FREE}] |\n"
+   "\t{-l|--extents [-]LogicalExtentsNumber[%{VG|LV|FREE|ORIGIN}] |\n"
    "\t -L|--size [-]LogicalVolumeSize[bBsSkKmMgGtTpPeE]}\n"
    "\t[-n|--nofsck]\n"
    "\t[--noudevsync]\n"
@@ -376,7 +376,7 @@ xx(lvresize,
    "\t[-f|--force]\n"
    "\t[-h|--help]\n"
    "\t[-i|--stripes Stripes [-I|--stripesize StripeSize]]\n"
-   "\t{-l|--extents [+|-]LogicalExtentsNumber[%{VG|LV|PVS|FREE}] |\n"
+   "\t{-l|--extents [+|-]LogicalExtentsNumber[%{VG|LV|PVS|FREE|ORIGIN}] |\n"
    "\t -L|--size [+|-]LogicalVolumeSize[bBsSkKmMgGtTpPeE]}\n"
    "\t[-n|--nofsck]\n"
    "\t[--noudevsync]\n"
diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index 0cfd140..211cfeb 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -130,6 +130,7 @@ static int _update_extents_params(struct volume_group *vg,
 				  struct lvcreate_cmdline_params *lcp)
 {
 	uint32_t pv_extent_count;
+	struct logical_volume *origin = NULL;
 
 	if (lcp->size &&
 	    !(lp->extents = extents_from_size(vg->cmd, lcp->size,
@@ -171,6 +172,15 @@ static int _update_extents_params(struct volume_group *vg,
 			log_error("Please express size as %%VG, %%PVS, or "
 				  "%%FREE.");
 			return 0;
+		case PERCENT_ORIGIN:
+			if (lp->snapshot && lp->origin &&
+			    !(origin = find_lv(vg, lp->origin))) {
+				log_error("Couldn't find origin volume '%s'.",
+					  lp->origin);
+				return 0;
+			}
+			lp->extents = lp->extents * origin->le_count / 100;
+			break;
 		case PERCENT_NONE:
 			break;
 	}
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index ad1513d..85d6ce3 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -358,6 +358,9 @@ int int_arg_with_sign_and_percent(struct cmd_context *cmd __attribute((unused)),
 	else if (!strcasecmp(ptr, "F") || !strcasecmp(ptr, "FR") ||
 		 !strcasecmp(ptr, "FREE"))
 		a->percent = PERCENT_FREE;
+	else if (!strcasecmp(ptr, "O") || !strcasecmp(ptr, "OR") ||
+		 !strcasecmp(ptr, "ORIGIN"))
+		a->percent = PERCENT_ORIGIN;
 	else
 		return 0;
 
diff --git a/tools/lvresize.c b/tools/lvresize.c
index 395d105..849fd2e 100644
--- a/tools/lvresize.c
+++ b/tools/lvresize.c
@@ -373,6 +373,13 @@ static int _lvresize(struct cmd_context *cmd, struct volume_group *vg,
 			} else
 				lp->extents = lp->extents * vg->extent_count / 100;
 			break;
+		case PERCENT_ORIGIN:
+			if (!lv_is_cow(lv)) {
+				log_error("Specified LV does not have an origin LV.");
+				return EINVALID_CMD_LINE;
+			}
+			lp->extents = lp->extents * origin_from_cow(lv)->le_count / 100;
+			break;
 		case PERCENT_NONE:
 			break;
 	}
diff --git a/tools/tools.h b/tools/tools.h
index 578e32f..75575e7 100644
--- a/tools/tools.h
+++ b/tools/tools.h
@@ -83,7 +83,8 @@ typedef enum {
 	PERCENT_VG,
 	PERCENT_FREE,
 	PERCENT_LV,
-	PERCENT_PVS
+	PERCENT_PVS,
+	PERCENT_ORIGIN
 } percent_t;
 
 enum {


