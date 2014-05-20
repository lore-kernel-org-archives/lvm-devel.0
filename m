From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 20 May 2014 19:53:47 +0000 (UTC)
Subject: master - man: cleanup style
Message-ID: <20140520195347.01ED160190@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=65b3fe9b058862c09994b98c246faaf7e0c0e0aa
Commit:        65b3fe9b058862c09994b98c246faaf7e0c0e0aa
Parent:        9fd0be2a8507e1134bf1f5d0e84dd80b765a6b19
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue May 20 12:54:19 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue May 20 21:50:28 2014 +0200

man: cleanup style

---
 man/lvconvert.8.in |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/man/lvconvert.8.in b/man/lvconvert.8.in
index 8c3479f..91c5bee 100644
--- a/man/lvconvert.8.in
+++ b/man/lvconvert.8.in
@@ -227,7 +227,7 @@ in the background.  You should only use this if udev is not running
 or has rules that ignore the devices LVM2 creates.
 .TP
 .B \-\-splitmirrors \fIImages
-The number of redundant Images of a mirror to be split off and used
+The number of redundant \fIImages\fP of a mirror to be split off and used
 to form a new logical volume.  A name must be supplied for the
 newly-split-off logical volume using the \fB\-\-name\fP argument, unless
 the \fB\-\-trackchanges\fP argument is given.
@@ -246,11 +246,11 @@ Please note that this feature is only supported with the new md-based mirror
 implementation and not with the original device-mapper mirror implementation.
 .TP
 .B \-\-splitsnapshot
-Separates SnapshotLogicalVolume from its origin.
+Separates \fISnapshotLogicalVolume\fP from its origin.
 The volume that is split off contains the chunks that differ from the origin
 along with the metadata describing them.  This volume can be wiped and then
 destroyed with lvremove.
-The inverse of \-\-snapshot.
+The inverse of \fB\-\-snapshot\fP.
 .TP
 .B \-s, \-\-snapshot
 Recreates a snapshot from constituent logical volumes (or copies of them) after


