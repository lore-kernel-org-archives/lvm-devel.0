From: Marian Csontos <mcsontos@sourceware.org>
Date: Tue, 31 Jul 2018 12:46:54 -0400
Subject: 2018-06-01-stable - build: make generate
Message-ID: <201807311646.w6VGks1j005246@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=12dfd0ed02e003e21072798d17dcec4a80fc466d
Commit:        12dfd0ed02e003e21072798d17dcec4a80fc466d
Parent:        ad10d426711b06dab4e5fda3538fb3a7a1ade30d
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Tue Jul 31 17:36:04 2018 +0200
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Tue Jul 31 17:41:35 2018 +0200

build: make generate

---
 man/lvconvert.8_pregen |   14 +++++++++-----
 1 files changed, 9 insertions(+), 5 deletions(-)

diff --git a/man/lvconvert.8_pregen b/man/lvconvert.8_pregen
index 91691a3..a47127b 100644
--- a/man/lvconvert.8_pregen
+++ b/man/lvconvert.8_pregen
@@ -475,7 +475,7 @@ Split images from a raid1 or mirror LV and use them to create a new LV.
 .RE
 -
 
-Split images from a raid1 LV and track changes to origin.
+Split images from a raid1 LV and track changes to origin for later merge.
 .br
 .P
 \fBlvconvert\fP \fB--splitmirrors\fP \fINumber\fP \fB--trackchanges\fP \fILV\fP\fI_cache_raid1\fP
@@ -1281,6 +1281,8 @@ Before the separation, the cache is flushed. Also see --uncache.
 Splits the specified number of images from a raid1 or mirror LV
 and uses them to create a new LV. If --trackchanges is also specified,
 changes to the raid1 LV are tracked while the split LV remains detached.
+If --name is specified, then the images are permanently split from the
+original LV and changes are not tracked.
 .ad b
 .HP
 .ad l
@@ -1354,10 +1356,12 @@ The name of a thin pool LV.
 .br
 Can be used with --splitmirrors on a raid1 LV. This causes
 changes to the original raid1 LV to be tracked while the split images
-remain detached. This allows the read-only detached image(s) to be
-merged efficiently back into the raid1 LV later. Only the regions with
-changed data are resynchronized during merge. (This option only applies
-when using the raid1 LV type.)
+remain detached. This is a temporary state that allows the read-only
+detached image to be merged efficiently back into the raid1 LV later.
+Only the regions with changed data are resynchronized during merge.
+While a raid1 LV is tracking changes, operations on it are limited to
+merging the split image (see --mergemirrors) or permanently splitting
+the image (see --splitmirrors with --name.
 .ad b
 .HP
 .ad l


