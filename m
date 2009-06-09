From: Mike Snitzer <snitzer@redhat.com>
Date: Tue,  9 Jun 2009 00:42:14 -0400
Subject: [PATCH 1/3] cmdline: support for bytes and sectors
In-Reply-To: <1244522536-2132-1-git-send-email-snitzer@redhat.com>
References: <1244522536-2132-1-git-send-email-snitzer@redhat.com>
Message-ID: <1244522536-2132-3-git-send-email-snitzer@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Allow specifying commandline sizes in terms of bytes and sectors.

Signed-off-by: Mike Snitzer <snitzer@redhat.com>
---
 WHATS_NEW          |    1 +
 tools/commands.h   |   26 +++++++++++++-------------
 tools/lvmcmdline.c |   20 ++++++++++++++------
 3 files changed, 28 insertions(+), 19 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index e745496..beb54a9 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.48 - 
 ===============================
+  Allow specifying commandline sizes in terms of bytes and sectors.
   Round up requested readahead to at least one page and print warning.
   Try to repair vg before actual vgremove when force flag provided.
   Fix possible double release of VG after recovery.
diff --git a/tools/commands.h b/tools/commands.h
index ee39bf9..1bfbf46 100644
--- a/tools/commands.h
+++ b/tools/commands.h
@@ -19,7 +19,7 @@ xx(e2fsadm,
    "e2fsadm "
    "[-d|--debug] " "[-h|--help] " "[-n|--nofsck]" "\n"
    "\t{[-l|--extents] [+|-]LogicalExtentsNumber |" "\n"
-   "\t [-L|--size] [+|-]LogicalVolumeSize[kKmMgGtTpPeE]}" "\n"
+   "\t [-L|--size] [+|-]LogicalVolumeSize[sSbBkKmMgGtTpPeE]}" "\n"
    "\t[-t|--test] "  "\n"
    "\t[-v|--verbose] "  "\n"
    "\t[--version] " "\n"
@@ -131,7 +131,7 @@ xx(lvcreate,
    "\t[-h|-?|--help]\n"
    "\t[-i|--stripes Stripes [-I|--stripesize StripeSize]]\n"
    "\t{-l|--extents LogicalExtentsNumber |\n"
-   "\t -L|--size LogicalVolumeSize[kKmMgGtTpPeE]}\n"
+   "\t -L|--size LogicalVolumeSize[sSbBkKmMgGtTpPeE]}\n"
    "\t[-M|--persistent {y|n}] [--major major] [--minor minor]\n"
    "\t[-m|--mirrors Mirrors [--nosync] [{--mirrorlog {disk|core}|--corelog}]]\n"
    "\t[-n|--name LogicalVolumeName]\n"
@@ -157,7 +157,7 @@ xx(lvcreate,
    "\t[-h|-?|--help]\n"
    "\t[-i|--stripes Stripes [-I|--stripesize StripeSize]]\n"
    "\t{-l|--extents LogicalExtentsNumber[%{VG|LV|PVS|FREE}] |\n"
-   "\t -L|--size LogicalVolumeSize[kKmMgGtTpPeE]}\n"
+   "\t -L|--size LogicalVolumeSize[sSbBkKmMgGtTpPeE]}\n"
    "\t[-M|--persistent {y|n}] [--major major] [--minor minor]\n"
    "\t[-n|--name LogicalVolumeName]\n"
    "\t[-p|--permission {r|rw}]\n"
@@ -226,7 +226,7 @@ xx(lvextend,
    "\t[-h|--help]\n"
    "\t[-i|--stripes Stripes [-I|--stripesize StripeSize]]\n"
    "\t{-l|--extents [+]LogicalExtentsNumber[%{VG|PVS|FREE}] |\n"
-   "\t -L|--size [+]LogicalVolumeSize[kKmMgGtTpPeE]}\n"
+   "\t -L|--size [+]LogicalVolumeSize[sSbBkKmMgGtTpPeE]}\n"
    "\t[-m|--mirrors Mirrors]\n"
    "\t[-n|--nofsck]\n"
    "\t[-r|--resizefs]\n"
@@ -296,7 +296,7 @@ xx(lvreduce,
    "\t[-f|--force]\n"
    "\t[-h|--help]\n"
    "\t{-l|--extents [-]LogicalExtentsNumber[%{VG|LV|FREE}] |\n"
-   "\t -L|--size [-]LogicalVolumeSize[kKmMgGtTpPeE]}\n"
+   "\t -L|--size [-]LogicalVolumeSize[sSbBkKmMgGtTpPeE]}\n"
    "\t[-n|--nofsck]\n"
    "\t[-r|--resizefs]\n"
    "\t[-t|--test]\n"
@@ -349,7 +349,7 @@ xx(lvresize,
    "\t[-h|--help]\n"
    "\t[-i|--stripes Stripes [-I|--stripesize StripeSize]]\n"
    "\t{-l|--extents [+|-]LogicalExtentsNumber[%{VG|LV|PVS|FREE}] |\n"
-   "\t -L|--size [+|-]LogicalVolumeSize[kKmMgGtTpPeE]}\n"
+   "\t -L|--size [+|-]LogicalVolumeSize[sSbBkKmMgGtTpPeE]}\n"
    "\t[-n|--nofsck]\n"
    "\t[-r|--resizefs]\n"
    "\t[-t|--test]\n"
@@ -434,7 +434,7 @@ xx(pvresize,
    "pvresize " "\n"
    "\t[-d|--debug]" "\n"
    "\t[-h|-?|--help] " "\n"
-   "\t[--setphysicalvolumesize PhysicalVolumeSize[kKmMgGtTpPeE]" "\n"
+   "\t[--setphysicalvolumesize PhysicalVolumeSize[sSbBkKmMgGtTpPeE]" "\n"
    "\t[-t|--test] " "\n"
    "\t[-v|--verbose] " "\n"
    "\t[--version] " "\n"
@@ -466,9 +466,9 @@ xx(pvcreate,
    "\t[--labelsector sector] " "\n"
    "\t[-M|--metadatatype 1|2]" "\n"
    "\t[--metadatacopies #copies]" "\n"
-   "\t[--metadatasize MetadataSize[kKmMgGtTpPeE]]" "\n"
-   "\t[--dataalignment Alignment[kKmMgGtTpPeE]]" "\n"
-   "\t[--setphysicalvolumesize PhysicalVolumeSize[kKmMgGtTpPeE]" "\n"
+   "\t[--metadatasize MetadataSize[sSbBkKmMgGtTpPeE]]" "\n"
+   "\t[--dataalignment Alignment[sSbBkKmMgGtTpPeE]]" "\n"
+   "\t[--setphysicalvolumesize PhysicalVolumeSize[sSbBkKmMgGtTpPeE]" "\n"
    "\t[-t|--test] " "\n"
    "\t[-u|--uuid uuid] " "\n"
    "\t[-v|--verbose] " "\n"
@@ -681,7 +681,7 @@ xx(vgchange,
    "\t -x|--resizeable {y|n} |" "\n"
    "\t -l|--logicalvolume MaxLogicalVolumes |" "\n"
    "\t -p|--maxphysicalvolumes MaxPhysicalVolumes |" "\n"
-   "\t -s|--physicalextentsize PhysicalExtentSize[kKmMgGtTpPeE] |" "\n"
+   "\t -s|--physicalextentsize PhysicalExtentSize[sSbBkKmMgGtTpPeE] |" "\n"
    "\t --addtag Tag |\n"
    "\t --deltag Tag}\n"
    "\t[VolumeGroupName...]\n",
@@ -711,7 +711,7 @@ xx(vgconvert,
    "\t[--labelsector sector] " "\n"
    "\t[-M|--metadatatype 1|2]" "\n"
    "\t[--metadatacopies #copies]" "\n"
-   "\t[--metadatasize MetadataSize[kKmMgGtTpPeE]]" "\n"
+   "\t[--metadatasize MetadataSize[sSbBkKmMgGtTpPeE]]" "\n"
    "\t[-t|--test] " "\n"
    "\t[-v|--verbose] " "\n"
    "\t[--version] " "\n"
@@ -733,7 +733,7 @@ xx(vgcreate,
    "\t[-l|--maxlogicalvolumes MaxLogicalVolumes]" "\n"
    "\t[-M|--metadatatype 1|2] " "\n"
    "\t[-p|--maxphysicalvolumes MaxPhysicalVolumes] " "\n"
-   "\t[-s|--physicalextentsize PhysicalExtentSize[kKmMgGtTpPeE]] " "\n"
+   "\t[-s|--physicalextentsize PhysicalExtentSize[sSbBkKmMgGtTpPeE]] " "\n"
    "\t[-t|--test] " "\n"
    "\t[-v|--verbose]" "\n"
    "\t[--version] " "\n"
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 0d4e230..b3a3986 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -239,7 +239,7 @@ static int _size_arg(struct cmd_context *cmd __attribute((unused)), struct arg *
 {
 	char *ptr;
 	int i;
-	static const char *suffixes = "kmgtpe";
+	static const char *suffixes = "kmgtpebs";
 	char *val;
 	double v;
 
@@ -274,11 +274,19 @@ static int _size_arg(struct cmd_context *cmd __attribute((unused)), struct arg *
 
 		if (i < 0)
 			return 0;
-
-		while (i-- > 0)
-			v *= 1024;
-
-		v *= 2;
+		else if (i == 7) {
+			/* sectors */
+			v = v;
+		} else if (i == 6) {
+			/* bytes */
+			if (v < 512)
+				return 0;
+			v /= 512;
+		} else {
+			while (i-- > 0)
+				v *= 1024;
+			v *= 2;
+		}
 	} else
 		v *= factor;
 
-- 
1.6.2.2


