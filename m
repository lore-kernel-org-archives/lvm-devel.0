From: Dave Wysochanski <dwysocha@redhat.com>
Date: Tue,  9 Feb 2010 17:32:17 -0500
Subject: [PATCH 14/21] Add metadata balance arguments, update vgcreate man page and help.
In-Reply-To: <1265754744-17319-14-git-send-email-dwysocha@redhat.com>
References: <1265754744-17319-1-git-send-email-dwysocha@redhat.com>
	<1265754744-17319-2-git-send-email-dwysocha@redhat.com>
	<1265754744-17319-3-git-send-email-dwysocha@redhat.com>
	<1265754744-17319-4-git-send-email-dwysocha@redhat.com>
	<1265754744-17319-5-git-send-email-dwysocha@redhat.com>
	<1265754744-17319-6-git-send-email-dwysocha@redhat.com>
	<1265754744-17319-7-git-send-email-dwysocha@redhat.com>
	<1265754744-17319-8-git-send-email-dwysocha@redhat.com>
	<1265754744-17319-9-git-send-email-dwysocha@redhat.com>
	<1265754744-17319-10-git-send-email-dwysocha@redhat.com>
	<1265754744-17319-11-git-send-email-dwysocha@redhat.com>
	<1265754744-17319-12-git-send-email-dwysocha@redhat.com>
	<1265754744-17319-13-git-send-email-dwysocha@redhat.com>
	<1265754744-17319-14-git-send-email-dwysocha@redhat.com>
Message-ID: <1265754744-17319-15-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

The 3 parameters for metadata balancing are added here.  We really only
need the 'min' and 'max' values, since the defaults are really what LVM
does today (you must have metadata on at least on PV, and by default we
read/write from all PVs that have metadatacopies != 0).  The only question
is how to explain this properly, so for now I've left the main 'enable'
parameter.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 man/vgcreate.8.in |   24 ++++++++++++++++++++++++
 tools/args.h      |    3 +++
 tools/commands.h  |    8 ++++++--
 3 files changed, 33 insertions(+), 2 deletions(-)

diff --git a/man/vgcreate.8.in b/man/vgcreate.8.in
index 24d1642..66429f7 100644
--- a/man/vgcreate.8.in
+++ b/man/vgcreate.8.in
@@ -14,6 +14,11 @@ vgcreate \- create a volume group
 .RB [ \-l | \-\-maxlogicalvolumes
 .IR MaxLogicalVolumes ]
 .RB [ -M | \-\-metadatatype type]
+.RB [ \-\-metadatabalance " {" y | n } ]
+.RB [ \-\-metadatabalancemin
+.IR NumberOfPhysicalVolumes ]
+.RB [ \-\-metadatabalancemax
+.IR NumberOfPhysicalVolumes ]
 .RB [ -p | \-\-maxphysicalvolumes
 .IR MaxPhysicalVolumes ]
 .RB [ \-s | \-\-physicalextentsize
@@ -94,6 +99,25 @@ but having a large number of extents will slow down the tools but have no
 impact on I/O performance to the logical volume.  The smallest PE is 1KB.
 
 The 2.4 kernel has a limitation of 2TB per block device.
+.TP
+.BR \-\-metadatabalance " " { y | n }
+Enables automatic metadata balancing on physical volumes in the volume group.
+If set to \fBy\fP, LVM will use the values of \fBmetadatabalancmin\fP and
+\fBmetadatabalancemax\fP to determine the set of physical volumes to read and
+write metadata.  Only physical volumes created with a non-zero value of
+\fBmetadatacopies\fP are used.  This option is useful for volume groups
+containing large numbers of physical volumes.  The option is set to \fBn\fP
+by default, and all physical volumes created with non-zero \fBmetadatacopies\fP
+will contain metadata.
+.TP
+.BR \-\-metadatabalancemin " " \fIMinPhysicalVolumes\fR
+Sets the minimum number of physical volumes that should contain metadata.
+Default is 1.
+.TP
+.BR \-\-metadatabalancemax " " \fIMaxPhysicalVolumes\fR
+Sets the maximum number of physical volumes that should contain metadata.
+Default is all physical volumes.
+\fB
 .SH PHYSICAL DEVICE OPTIONS
 The following options are available for initializing physical devices in the
 volume group.  These options are further described in the pvcreate man page.
diff --git a/tools/args.h b/tools/args.h
index f41fbf5..3a48d75 100644
--- a/tools/args.h
+++ b/tools/args.h
@@ -24,6 +24,9 @@ arg(physicalvolumesize_ARG, '\0', "setphysicalvolumesize", size_mb_arg, 0)
 arg(ignorelockingfailure_ARG, '\0', "ignorelockingfailure", NULL, 0)
 arg(nolocking_ARG, '\0', "nolocking", NULL, 0)
 arg(pvmetadatacopies_ARG, '\0', "pvmetadatacopies", int_arg, 0)
+arg(metadatabalance_ARG, '\0', "metadatabalance", yes_no_arg, 0)
+arg(metadatabalancemin_ARG, '\0', "metadatabalancemin", int_arg, 0)
+arg(metadatabalancemax_ARG, '\0', "metadatabalancemax", int_arg, 0)
 arg(metadatacopies_ARG, '\0', "metadatacopies", int_arg, 0)
 arg(metadatasize_ARG, '\0', "metadatasize", size_mb_arg, 0)
 arg(metadatadisable_ARG, '\0', "metadatadisable", yes_no_arg, 0)
diff --git a/tools/commands.h b/tools/commands.h
index 66727d9..f04680a 100644
--- a/tools/commands.h
+++ b/tools/commands.h
@@ -766,6 +766,9 @@ xx(vgcreate,
    "\t[-d|--debug]" "\n"
    "\t[-h|--help]" "\n"
    "\t[-l|--maxlogicalvolumes MaxLogicalVolumes]" "\n"
+   "\t[--metadatabalance {y|n}] " "\n"
+   "\t[--metadatabalancemin NumberOfPhysicalVolumes] " "\n"
+   "\t[--metadatabalancemax NumberOfPhysicalVolumes] " "\n"
    "\t[-M|--metadatatype 1|2] " "\n"
    "\t[-p|--maxphysicalvolumes MaxPhysicalVolumes] " "\n"
    "\t[-s|--physicalextentsize PhysicalExtentSize[bBsSkKmMgGtTpPeE]] " "\n"
@@ -778,8 +781,9 @@ xx(vgcreate,
    addtag_ARG, alloc_ARG, autobackup_ARG, clustered_ARG, maxlogicalvolumes_ARG,
    maxphysicalvolumes_ARG, metadatatype_ARG, physicalextentsize_ARG, test_ARG,
    force_ARG, yes_ARG, zero_ARG, labelsector_ARG, metadatasize_ARG,
-   pvmetadatacopies_ARG, metadatacopies_ARG, dataalignment_ARG,
-   dataalignmentoffset_ARG)
+   pvmetadatacopies_ARG, metadatacopies_ARG,
+   metadatabalance_ARG, metadatabalancemin_ARG, metadatabalancemax_ARG,
+   dataalignment_ARG, dataalignmentoffset_ARG)
 
 xx(vgdisplay,
    "Display volume group information",
-- 
1.6.0.6


