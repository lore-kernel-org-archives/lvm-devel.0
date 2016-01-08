From: Alasdair Kergon <agk@fedoraproject.org>
Date: Fri,  8 Jan 2016 18:59:49 +0000 (UTC)
Subject: master - pre-release
Message-ID: <20160108185949.2E8B260068@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=04b82a81262c2da3b7254c884e6df46d59c69c4a
Commit:        04b82a81262c2da3b7254c884e6df46d59c69c4a
Parent:        580c67486fde1a382910b5694589536642346d22
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Fri Jan 8 18:46:41 2016 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Fri Jan 8 18:46:41 2016 +0000

pre-release

---
 VERSION      |    2 +-
 VERSION_DM   |    2 +-
 WHATS_NEW    |    4 ++--
 WHATS_NEW_DM |    3 ---
 4 files changed, 4 insertions(+), 7 deletions(-)

diff --git a/VERSION b/VERSION
index 9fd5423..0275d39 100644
--- a/VERSION
+++ b/VERSION
@@ -1 +1 @@
-2.02.139(2)-git (2015-12-14)
+2.02.139(2)-git (2016-01-08)
diff --git a/VERSION_DM b/VERSION_DM
index 16fb5cc..a564059 100644
--- a/VERSION_DM
+++ b/VERSION_DM
@@ -1 +1 @@
-1.02.115-git (2015-12-14)
+1.02.114-git (2016-01-08)
diff --git a/WHATS_NEW b/WHATS_NEW
index 515f6ce..d9e9775 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,5 @@
-Version 2.02.139 - 
-=====================================
+Version 2.02.139 - 8th January 2016
+===================================
   Update lvmlockd with the new VG seqno before devices are suspended.
   Rework vgrename to use the common processing code in toollib.
   Make pvs show new devices on the system since the last .cache update.
diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index f9c808f..4ab492a 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,6 +1,3 @@
-Version 1.02.115 - 
-=====================================
-
 Version 1.02.114 - 14th December 2015
 =====================================
   Better support for dmsetup static linkage.


