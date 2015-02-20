From: David Teigland <teigland@fedoraproject.org>
Date: Fri, 20 Feb 2015 20:58:56 +0000 (UTC)
Subject: master - man: systemid option for vgcreate and vgchange
Message-ID: <20150220205856.A1BAC6011F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=3361e662f4b05096ca6cae9f4d96bbeec8ec4862
Commit:        3361e662f4b05096ca6cae9f4d96bbeec8ec4862
Parent:        55dd45239a52a7349f8a2380b3e29dc3beee39f5
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Feb 20 14:58:01 2015 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Feb 20 14:58:01 2015 -0600

man: systemid option for vgcreate and vgchange

---
 man/vgchange.8.in |    8 ++++++++
 man/vgcreate.8.in |   13 ++++++++++++-
 2 files changed, 20 insertions(+), 1 deletions(-)

diff --git a/man/vgchange.8.in b/man/vgchange.8.in
index 5014300..e6e850a 100644
--- a/man/vgchange.8.in
+++ b/man/vgchange.8.in
@@ -47,6 +47,8 @@ vgchange \(em change attributes of a volume group
 .IR PhysicalExtentSize [ bBsSkKmMgGtTpPeE ]]
 .RB [ \-S | \-\-select
 .IR Selection ]
+.RB [ \-\-systemid
+.IR SystemID ]
 .RB [ \-\-refresh ]
 .RB [ \-t | \-\-test ]
 .RB [ \-v | \-\-verbose ]
@@ -243,6 +245,12 @@ impact on I/O performance to the logical volume.  The smallest PE is 1KiB.
 
 The 2.4 kernel has a limitation of 2TiB per block device.
 .TP
+.BR \-\-systemid " " \fISystemID
+Changes the system ID of the VG.  Using this option requires caution
+because the VG may become foreign to the host running the command,
+leaving the host unable to access it.  See
+.BR lvmsystemid (7).
+.TP
 .BR \-\-refresh
 If any logical volume in the volume group is active, reload its metadata.
 This is not necessary in normal operation, but may be useful
diff --git a/man/vgcreate.8.in b/man/vgcreate.8.in
index d850659..c55dbfe 100644
--- a/man/vgcreate.8.in
+++ b/man/vgcreate.8.in
@@ -27,6 +27,8 @@ vgcreate \(em create a volume group
 .IR NumberOfCopies | unmanaged | all ]
 .RB [ \-s | \-\-physicalextentsize
 .IR PhysicalExtentSize [ bBsSkKmMgGtTpPeE ]]
+.RB [ \-\-systemid
+.IR SystemID ]
 .RB [ \-t | \-\-test ]
 .RB [ \-v | \-\-verbose ]
 .RB [ \-\-version ]
@@ -110,7 +112,6 @@ power of 2 of at least 1 sector (where the sector size is the largest sector
 size of the PVs currently used in the VG) or, if not a power of 2, at least
 128KiB.  For the older LVM1 format, it must be a power of 2 of at least 8KiB.
 The default is 4 MiB.
-
 Once this value has been set, it is difficult to change it without recreating
 the volume group which would involve backing up and restoring data on any
 logical volumes.  However, if no extents need moving for the new
@@ -126,6 +127,16 @@ impact on I/O performance to the logical volume.  The smallest PE is 1KiB
 
 The 2.4 kernel has a limitation of 2TiB per block device.
 
+.TP
+.BR \-\-systemid " " \fISystemID
+Specifies the system ID that will be given to the new VG, overriding the
+system ID of the host running the command.  A VG is normally created
+without this option, in which case the new VG is given the system ID of
+the host creating it.  Using this option requires caution because the
+system ID of the new VG may not match the system ID of the host running
+the command, leaving the VG inaccessible to the host.  See
+.BR lvmsystemid (7).
+
 .SH PHYSICAL DEVICE OPTIONS
 The following options are available for initializing physical devices in the
 volume group.  These options are further described in the \fBpvcreate\fP(8)


