From: Alasdair Kergon <agk@fedoraproject.org>
Date: Fri,  6 May 2016 23:58:11 +0000 (UTC)
Subject: master - pre-release
Message-ID: <20160506235811.E3E58607AE@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e4caf0beebd3718bf77a04905ed2f65712707a5d
Commit:        e4caf0beebd3718bf77a04905ed2f65712707a5d
Parent:        1202713f94cb2b0f6f5160d49615f4b839a862a7
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Sat May 7 00:36:59 2016 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Sat May 7 00:36:59 2016 +0100

pre-release

---
 VERSION              |    2 +-
 VERSION_DM           |    2 +-
 WHATS_NEW            |    4 ++--
 WHATS_NEW_DM         |    3 ---
 conf/example.conf.in |   13 +++++++++++++
 5 files changed, 17 insertions(+), 7 deletions(-)

diff --git a/VERSION b/VERSION
index 680848d..7909645 100644
--- a/VERSION
+++ b/VERSION
@@ -1 +1 @@
-2.02.153(2)-git (2016-04-30)
+2.02.153(2)-git (2016-05-07)
diff --git a/VERSION_DM b/VERSION_DM
index 1eb63a8..17bcab0 100644
--- a/VERSION_DM
+++ b/VERSION_DM
@@ -1 +1 @@
-1.02.125-git (2016-04-30)
+1.02.124-git (2016-05-07)
diff --git a/WHATS_NEW b/WHATS_NEW
index c8cee76..721d8b7 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,5 @@
-Version 2.02.153 - 
-==================================
+Version 2.02.153 - 7th May 2016
+===============================
   Change warning messages related to duplicate PVs.
   A named device is always processed itself, not switched for a duplicate.
   Add PV attr "d" and report field "duplicate" for duplicate PVs.
diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index f6392ef..24561d4 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,6 +1,3 @@
-Version 1.02.125 - 
-==================================
-
 Version 1.02.124 - 30th April 2016
 ==================================
   Add dm_udev_wait_immediate to libdevmapper for waiting outside the library.
diff --git a/conf/example.conf.in b/conf/example.conf.in
index a6a6762..c34481e 100644
--- a/conf/example.conf.in
+++ b/conf/example.conf.in
@@ -299,6 +299,19 @@ devices {
 	# generally do. If enabled, discards will only be issued if both the
 	# storage and kernel provide support.
 	issue_discards = 0
+
+	# Configuration option devices/allow_changes_with_duplicate_pvs.
+	# Allow VG modification while a PV appears on multiple devices.
+	# When a PV appears on multiple devices, LVM attempts to choose the
+	# best device to use for the PV. If the devices represent the same
+	# underlying storage, the choice has minimal consequence. If the
+	# devices represent different underlying storage, the wrong choice
+	# can result in data loss if the VG is modified. Disabling this
+	# setting is the safest option because it prevents modifying a VG
+	# or activating LVs in it while a PV appears on multiple devices.
+	# Enabling this setting allows the VG to be used as usual even with
+	# uncertain devices.
+	allow_changes_with_duplicate_pvs = 0
 }
 
 # Configuration section allocation.


