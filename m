From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 11 Jun 2014 09:11:32 +0000 (UTC)
Subject: master - man: advertise lvmcache, lvmthin
Message-ID: <20140611091132.6099060F96@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d2b60c6e351df63b5bfc82cd27ac23dd8ffe89a9
Commit:        d2b60c6e351df63b5bfc82cd27ac23dd8ffe89a9
Parent:        6766cdc8a1a0fb2cd041f629d8c2b6adbaca0ff0
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Jun 10 11:05:51 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Jun 11 11:10:54 2014 +0200

man: advertise  lvmcache, lvmthin

Add references to new man pages so they get known.
---
 man/lvchange.8.in  |    2 ++
 man/lvconvert.8.in |    5 +++++
 man/lvcreate.8.in  |    4 ++++
 3 files changed, 11 insertions(+), 0 deletions(-)

diff --git a/man/lvchange.8.in b/man/lvchange.8.in
index 09f54e6..27f81aa 100644
--- a/man/lvchange.8.in
+++ b/man/lvchange.8.in
@@ -256,5 +256,7 @@ Changes the permission on volume lvol1 in volume group vg00 to be read-only:
 .B lvchange -pr vg00/lvol1
 .SH SEE ALSO
 .BR lvm (8),
+.BR lvmcache (7),
+.BR lvmthin (7),
 .BR lvcreate (8),
 .BR vgchange (8)
diff --git a/man/lvconvert.8.in b/man/lvconvert.8.in
index 2833f20..44a3dbe 100644
--- a/man/lvconvert.8.in
+++ b/man/lvconvert.8.in
@@ -235,6 +235,8 @@ or
 When converting a logical volume to a cache LV, the
 .B \-\-cachepool
 argument is required.
+See \fBlvmcache\fP(7) for more info about caching support
+and \fBlvmthin\fP(7) for thin provisioning support.
 .TP
 .BR \-i ", " \-\-interval " " \fISeconds
 Report progress as a percentage at regular intervals.
@@ -413,6 +415,7 @@ Switches logical volume into a thin pool's data volume.
 Content of converted volume is lost.
 Thin pool's metadata logical volume can be specified with the option
 \fB\-\-poolmetadata\fP or allocated with \fB\-\-poolmetadatasize\fP.
+See \fBlvmthin\fP(7) for more info about thin provisioning support.
 
 .SH Examples
 Converts the linear logical volume "vg00/lvol1" to a two-way mirror
@@ -528,6 +531,8 @@ cache pool LV.
 .SH SEE ALSO
 .BR lvm (8),
 .BR lvm.conf (5),
+.BR lvmcache (7),
+.BR lvmthin (7),
 .BR lvdisplay (8),
 .BR lvextend (8),
 .BR lvreduce (8),
diff --git a/man/lvcreate.8.in b/man/lvcreate.8.in
index ee50587..164ca27 100644
--- a/man/lvcreate.8.in
+++ b/man/lvcreate.8.in
@@ -403,6 +403,7 @@ Specifying the optional argument \fB\-\-virtualsize\fP will cause
 the creation of the thin logical volume from given thin pool volume.
 Specifying both arguments will cause the creation of both
 thin pool and thin volume using this pool.
+See \fBlvmthin\fP(7) for more info about thin provisioning support.
 Requires device mapper kernel driver for thin provisioning
 from kernel 3.2 or newer.
 .TP
@@ -430,6 +431,7 @@ as is the case with
 .IR raid10
 or
 .IR zero .
+See \fBlvmcache\fP(7) for more info about caching support.
 Note that the cache segment type requires a dm-cache kernel module version
 1.3.0 or greater.
 
@@ -568,6 +570,8 @@ volume (i.e. the origin LV), creating a cache LV.
 .SH SEE ALSO
 .BR lvm (8),
 .BR lvm.conf (5),
+.BR lvmcache (7),
+.BR lvmthin (7),
 .BR lvconvert (8),
 .BR lvchange (8),
 .BR lvextend (8),


