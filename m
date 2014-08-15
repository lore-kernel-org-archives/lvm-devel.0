From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 15 Aug 2014 13:07:35 +0000 (UTC)
Subject: master - man: show lv name for lvs
Message-ID: <20140815130735.BBCD960319@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=630fcab420ce791612bbeed3e30db4c5371803e5
Commit:        630fcab420ce791612bbeed3e30db4c5371803e5
Parent:        7f4b1e7411d7ff59abe2063db7273fd600e2bf72
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Aug 14 11:09:30 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Aug 15 15:06:44 2014 +0200

man: show lv name for lvs

Make it more obvious that either just vg name or lv name or path could
be passed as an argument.
---
 man/lvdisplay.8.in |   12 ++++++------
 man/lvs.8.in       |    4 ++--
 2 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/man/lvdisplay.8.in b/man/lvdisplay.8.in
index ed113dd..3232853 100644
--- a/man/lvdisplay.8.in
+++ b/man/lvdisplay.8.in
@@ -18,8 +18,8 @@ lvdisplay \(em display attributes of a logical volume
 .IR hHbBsSkKmMgGtTpPeE ]
 .RB [ \-v | \-\-verbose ]
 .RB [ \-\-version ]
-.RI [ LogicalVolumePath
-.RI [ LogicalVolumePath ...]]
+.RI [ VolumeGroupName | LogicalVolume { Name | Path }
+.RI [ VolumeGroupName | LogicalVolume { Name | Path }\ ...]]
 .br
 
 .B lvdisplay
@@ -50,8 +50,8 @@ lvdisplay \(em display attributes of a logical volume
 .IR hHbBsSkKmMgGtTpPeE ]
 .RB [ \-v | \-\-verbose ]
 .RB [ \-\-version ]
-.RI [ LogicalVolumePath
-.RI [ LogicalVolumePath ...]]
+.RI [ VolumeGroupName | LogicalVolume { Name | Path }
+.RI [ VolumeGroupName | LogicalVolume { Name | Path }\ ...]]
 .SH DESCRIPTION
 lvdisplay allows you to see the attributes of a logical volume
 like size, read/write status, snapshot information etc.
@@ -111,12 +111,12 @@ logical volumes have been created for this original logical volume,
 this command shows a list of all snapshot logical volumes and their
 status (active or inactive) as well:
 .sp
-.B lvdisplay \-v /dev/vg00/lvol2
+.B lvdisplay \-v vg00/lvol2
 
 Shows the attributes of this snapshot logical volume and also which
 original logical volume it is associated with:
 .sp
-.B lvdisplay /dev/vg00/snapshot
+.B lvdisplay vg00/snapshot
 
 .SH SEE ALSO
 .BR lvm (8),
diff --git a/man/lvs.8.in b/man/lvs.8.in
index b7e3ecc..3ab4120 100644
--- a/man/lvs.8.in
+++ b/man/lvs.8.in
@@ -32,8 +32,8 @@ lvs \(em report information about logical volumes
 .RB [ \-\-unquoted ]
 .RB [ \-v | \-\-verbose ]
 .RB [ \-\-version ]
-.RI [ VolumeGroupName
-.RI [ VolumeGroupName ...]]
+.RI [ VolumeGroupName | LogicalVolume { Name | Path }
+.RI [ VolumeGroupName | LogicalVolume { Name | Path }\ ...]]
 
 .SH DESCRIPTION
 lvs produces formatted output about logical volumes.


