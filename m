From: Dave Wysochanski <dwysocha@redhat.com>
Date: Tue,  9 Feb 2010 17:32:22 -0500
Subject: [PATCH 19/21] Add vg metadata balance parameters to vgchange man page and help.
In-Reply-To: <1265754744-17319-19-git-send-email-dwysocha@redhat.com>
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
	<1265754744-17319-15-git-send-email-dwysocha@redhat.com>
	<1265754744-17319-16-git-send-email-dwysocha@redhat.com>
	<1265754744-17319-17-git-send-email-dwysocha@redhat.com>
	<1265754744-17319-18-git-send-email-dwysocha@redhat.com>
	<1265754744-17319-19-git-send-email-dwysocha@redhat.com>
Message-ID: <1265754744-17319-20-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 man/vgchange.8.in |   23 +++++++++++++++++++++++
 tools/commands.h  |    4 ++++
 2 files changed, 27 insertions(+), 0 deletions(-)

diff --git a/man/vgchange.8.in b/man/vgchange.8.in
index 5013c1e..b23f3b8 100644
--- a/man/vgchange.8.in
+++ b/man/vgchange.8.in
@@ -24,6 +24,11 @@ vgchange \- change attributes of a volume group
 .IR MaxLogicalVolumes ]
 .RB [ -p | \-\-maxphysicalvolumes
 .IR MaxPhysicalVolumes ]
+.RB [ \-\-metadatabalance " {" y | n } ]
+.RB [ \-\-metadatabalancemin
+.IR NumberOfPhysicalVolumes ]
+.RB [ \-\-metadatabalancemax
+.IR NumberOfPhysicalVolumes ]
 .RB [ \-P | \-\-partial]
 .RB [ \-s | \-\-physicalextentsize
 .IR PhysicalExtentSize [ \fBbBsSkKmMgGtTpPeE\fR ]]
@@ -155,6 +160,24 @@ manually without a clustered lock manager.
 .BR \-x ", " \-\-resizeable " " { y | n }
 Enables or disables the extension/reduction of this volume group
 with/by physical volumes.
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
 .SH EXAMPLES
 To activate all known volume groups in the system:
 .nf
diff --git a/tools/commands.h b/tools/commands.h
index f04680a..dc268a7 100644
--- a/tools/commands.h
+++ b/tools/commands.h
@@ -717,6 +717,9 @@ xx(vgchange,
    "\t -l|--logicalvolume MaxLogicalVolumes |" "\n"
    "\t -p|--maxphysicalvolumes MaxPhysicalVolumes |" "\n"
    "\t -s|--physicalextentsize PhysicalExtentSize[bBsSkKmMgGtTpPeE] |" "\n"
+   "\t[--metadatabalance {y|n}] " "\n"
+   "\t[--metadatabalancemin NumberOfPhysicalVolumes] " "\n"
+   "\t[--metadatabalancemax NumberOfPhysicalVolumes] " "\n"
    "\t --addtag Tag |\n"
    "\t --deltag Tag}\n"
    "\t[VolumeGroupName...]\n",
@@ -724,6 +727,7 @@ xx(vgchange,
    addtag_ARG, alloc_ARG, allocation_ARG, autobackup_ARG, available_ARG,
    clustered_ARG, deltag_ARG, ignorelockingfailure_ARG, ignoremonitoring_ARG,
    logicalvolume_ARG, maxphysicalvolumes_ARG, monitor_ARG, noudevsync_ARG,
+   metadatabalance_ARG, metadatabalancemin_ARG, metadatabalancemax_ARG,
    partial_ARG, physicalextentsize_ARG, poll_ARG, refresh_ARG, resizeable_ARG,
    resizable_ARG, test_ARG, uuid_ARG)
 
-- 
1.6.0.6


