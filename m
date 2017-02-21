From: David Teigland <teigland@fedoraproject.org>
Date: Tue, 21 Feb 2017 18:28:12 +0000 (UTC)
Subject: master - man lvm: update see also list
Message-ID: <20170221182812.76A7C6103B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=7e411b111f4d87a1f342a016299fe90c2d64ec2d
Commit:        7e411b111f4d87a1f342a016299fe90c2d64ec2d
Parent:        f80d37375354b9b9cab5326d9d03e036012a824e
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Feb 21 11:13:23 2017 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Feb 21 12:27:51 2017 -0600

man lvm: update see also list

add several missing references
remove references to lvmdiskscan lvmchange
---
 man/lvm.8.in |  108 +++++++++++++++++++++++++++++++++++-----------------------
 1 files changed, 65 insertions(+), 43 deletions(-)

diff --git a/man/lvm.8.in b/man/lvm.8.in
index 0a64e4f..1f3247a 100644
--- a/man/lvm.8.in
+++ b/man/lvm.8.in
@@ -484,48 +484,70 @@ directly.
 .SH SEE ALSO
 .
 .nh
-.BR lvm.conf (5),
-.BR lvmcache (7),
-.BR lvmreport(7),
-.BR lvmthin (7),
-.BR clvmd (8),
+.BR lvm (8)
+.BR lvm.conf (5)
+.BR lvmconfig (8)
+
+.BR pvchange (8)
+.BR pvck (8)
+.BR pvcreate (8)
+.BR pvdisplay (8)
+.BR pvmove (8)
+.BR pvremove (8)
+.BR pvresize (8)
+.BR pvs (8)
+.BR pvscan (8) 
+
+.BR vgcfgbackup (8)
+.BR vgcfgrestore (8)
+.BR vgchange (8)
+.BR vgck (8)
+.BR vgcreate (8)
+.BR vgconvert (8)
+.BR vgdisplay (8)
+.BR vgexport (8)
+.BR vgextend (8)
+.BR vgimport (8)
+.BR vgimportclone (8)
+.BR vgmerge (8)
+.BR vgmknodes (8)
+.BR vgreduce (8)
+.BR vgremove (8)
+.BR vgrename (8)
+.BR vgs (8)
+.BR vgscan (8)
+.BR vgsplit (8) 
+
+.BR lvcreate (8)
+.BR lvchange (8)
+.BR lvconvert (8)
+.BR lvdisplay (8)
+.BR lvextend (8)
+.BR lvreduce (8)
+.BR lvremove (8)
+.BR lvrename (8)
+.BR lvresize (8)
+.BR lvs (8)
+.BR lvscan (8)
+
+.BR lvm2-activation-generator (8)
+.BR blkdeactivate (8)
+.BR lvmdump (8)
+
+.BR dmeventd (8)
+.BR lvmetad (8)
+.BR lvmpolld (8)
+.BR lvmlockd (8)
+.BR lvmlockctl (8)
+.BR clvmd (8)
+.BR cmirrord (8)
+.BR lvmdbusd (8)
+
+.BR lvmsystemid (7)
+.BR lvmreport (7)
+.BR lvmraid (7)
+.BR lvmthin (7)
+.BR lvmcache (7)
+
 .BR dmsetup (8),
-.BR lvchange (8),
-.BR lvcreate (8),
-.BR lvdisplay (8),
-.BR lvextend (8),
-.BR lvmchange (8),
-.BR lvmconfig (8),
-.BR lvmdiskscan (8),
-.BR lvreduce (8),
-.BR lvremove (8),
-.BR lvrename (8),
-.BR lvresize (8),
-.BR lvs (8),
-.BR lvscan (8),
-.BR pvchange (8),
-.BR pvck (8),
-.BR pvcreate (8),
-.BR pvdisplay (8),
-.BR pvmove (8),
-.BR pvremove (8),
-.BR pvs (8),
-.BR pvscan (8),
-.BR vgcfgbackup (8),
-.BR vgchange  (8),
-.BR vgck (8),
-.BR vgconvert (8),
-.BR vgcreate (8),
-.BR vgdisplay (8),
-.BR vgextend (8),
-.BR vgimport (8),
-.BR vgimportclone (8),
-.BR vgmerge (8),
-.BR vgmknodes (8),
-.BR vgreduce (8),
-.BR vgremove (8),
-.BR vgrename (8),
-.BR vgs (8),
-.BR vgscan (8),
-.BR vgsplit (8),
 .BR readline (3)


