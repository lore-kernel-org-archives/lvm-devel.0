From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 11 Jun 2014 09:11:34 +0000 (UTC)
Subject: master - man: use bullets
Message-ID: <20140611091134.809E660F96@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=49560910275696fa7dd149932fe9c4530667ecdd
Commit:        49560910275696fa7dd149932fe9c4530667ecdd
Parent:        d2b60c6e351df63b5bfc82cd27ac23dd8ffe89a9
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Jun 11 11:06:13 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Jun 11 11:10:55 2014 +0200

man: use bullets

---
 man/lvdisplay.8.in |   26 +++++++++++++-------------
 man/pvdisplay.8.in |   22 +++++++++++-----------
 2 files changed, 24 insertions(+), 24 deletions(-)

diff --git a/man/lvdisplay.8.in b/man/lvdisplay.8.in
index a9f3d49..bf9f544 100644
--- a/man/lvdisplay.8.in
+++ b/man/lvdisplay.8.in
@@ -81,19 +81,19 @@ N.B. \fBlvs\fP(8) provides considerably more control over the output.
 
 The values are:
 
-* logical volume name
-* volume group name
-* logical volume access
-* logical volume status
-* internal logical volume number
-* open count of logical volume
-* logical volume size in sectors
-* current logical extents associated to logical volume
-* allocated logical extents of logical volume
-* allocation policy of logical volume
-* read ahead sectors of logical volume
-* major device number of logical volume
-* minor device number of logical volume
+\(bu logical volume name
+\(bu volume group name
+\(bu logical volume access
+\(bu logical volume status
+\(bu internal logical volume number
+\(bu open count of logical volume
+\(bu logical volume size in sectors
+\(bu current logical extents associated to logical volume
+\(bu allocated logical extents of logical volume
+\(bu allocation policy of logical volume
+\(bu read ahead sectors of logical volume
+\(bu major device number of logical volume
+\(bu minor device number of logical volume
 
 .fi
 .TP
diff --git a/man/pvdisplay.8.in b/man/pvdisplay.8.in
index f317bcc..aab65ca 100644
--- a/man/pvdisplay.8.in
+++ b/man/pvdisplay.8.in
@@ -71,17 +71,17 @@ N.B. \fBpvs\fP(8) provides considerably more control over the output.
 
 The values are:
 
-* physical volume device name
-* volume group name
-* physical volume size in sectors
-* internal physical volume number (obsolete)
-* physical volume status
-* physical volume (not) allocatable
-* current number of logical volumes on this physical volume
-* physical extent size in kilobytes
-* total number of physical extents
-* free number of physical extents
-* allocated number of physical extents
+\(bu physical volume device name
+\(bu volume group name
+\(bu physical volume size in sectors
+\(bu internal physical volume number (obsolete)
+\(bu physical volume status
+\(bu physical volume (not) allocatable
+\(bu current number of logical volumes on this physical volume
+\(bu physical extent size in kilobytes
+\(bu total number of physical extents
+\(bu free number of physical extents
+\(bu allocated number of physical extents
 
 .fi
 .TP


