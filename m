From: Alasdair Kergon <agk@fedoraproject.org>
Date: Wed, 13 Nov 2013 14:11:32 +0000 (UTC)
Subject: master - release 2.02.104
Message-ID: <20131113141132.2DD6B60F88@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=77a1efeb8eb0fe73c858ade05b578c3cfe3ddd9f
Commit:        77a1efeb8eb0fe73c858ade05b578c3cfe3ddd9f
Parent:        527db4645fdbf10361797c871b9cadf6c5e73405
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Wed Nov 13 14:02:34 2013 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Wed Nov 13 14:02:34 2013 +0000

release 2.02.104

87 files changed, 1207 insertions(+), 294 deletions(-)
---
 VERSION      |    2 +-
 VERSION_DM   |    2 +-
 WHATS_NEW    |    7 +++----
 WHATS_NEW_DM |    6 ++++--
 4 files changed, 9 insertions(+), 8 deletions(-)

diff --git a/VERSION b/VERSION
index 8e798d0..576af30 100644
--- a/VERSION
+++ b/VERSION
@@ -1 +1 @@
-2.02.104(2)-git (2013-10-04)
+2.02.104(2)-git (2013-11-13)
diff --git a/VERSION_DM b/VERSION_DM
index 0e6eddb..89b02c3 100644
--- a/VERSION_DM
+++ b/VERSION_DM
@@ -1 +1 @@
-1.02.83-git (2013-10-04)
+1.02.83-git (2013-11-13)
diff --git a/WHATS_NEW b/WHATS_NEW
index ff6041d..475794e 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,5 @@
-Version 2.02.104 -
-===================================
+Version 2.02.104 - 13th November 2013
+=====================================
   Workaround VG refresh race during autoactivation by retrying the refresh.
   Handle failures in temporary mirror used when adding images to mirrors.
   Fix and improve logic for implicitely exclusive activations.
@@ -28,7 +28,6 @@ Version 2.02.104 -
   Move code to remove virtual snapshot from tools to lib for lvm2app.
   Fix possible race during daemon worker thread creation (lvmetad).
   Fix possible deadlock while clearing lvmetad cache for full rescan.
-  Fix possible race while creating/destroying memory pools.
   Recognise NVM Express devices in filter.
   Fix failing metadata repair when lvmetad is used.
   Fix incorrect memory handling when reading messages from lvmetad.
@@ -37,7 +36,7 @@ Version 2.02.104 -
   Add support for flagging an LV to skip udev scanning during activation.
   Improve message when unable to change discards setting on active thin pool.
   Run full scan before vgrename operation to avoid any cache name collision.
-  Fix lvconvert when converting to a thin pool and thin LV at once.
+  Fix lvconvert when converting to a thin pool and thin LV at once. (2.02.99)
 
 Version 2.02.103 - 4th October 2013
 ===================================
diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 0f905fd..1e8bae7 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,9 +1,11 @@
-Version 1.02.83
-==================================
+Version 1.02.83 - 13th November 2013
+====================================
   Consistently report on stderr when device is not found for dmsetup info.
   Skip race errors when non-udev dmsetup build runs on udev-enabled system.
   Skip error message when holders are not present in sysfs.
   Use __linux__ instead of linux define to make libdevmapper.h C compliant.
+  Use mutex to avoid possible race while creating/destroying memory pools.
+  Require libpthread to build now.
 
 Version 1.02.82 - 4th October 2013
 ==================================


