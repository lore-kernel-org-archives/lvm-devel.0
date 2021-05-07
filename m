From: Marian Csontos <mcsontos@sourceware.org>
Date: Fri,  7 May 2021 15:40:15 +0000 (GMT)
Subject: stable-2.02 - pre-release
Message-ID: <20210507154015.EB9473857C71@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=cde814abc04c6724a1561fc9935ac6b986054404
Commit:        cde814abc04c6724a1561fc9935ac6b986054404
Parent:        844a075c01ad300439a46f2ef4c85482f83bf992
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Fri May 7 17:33:50 2021 +0200
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Fri May 7 17:33:50 2021 +0200

pre-release

---
 VERSION      | 2 +-
 VERSION_DM   | 2 +-
 WHATS_NEW    | 4 ++--
 WHATS_NEW_DM | 4 ++--
 4 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/VERSION b/VERSION
index 60ed5750e..542534973 100644
--- a/VERSION
+++ b/VERSION
@@ -1 +1 @@
-2.02.188(2)-git (2020-03-24)
+2.02.188(2) (2021-05-07)
diff --git a/VERSION_DM b/VERSION_DM
index cf4dff740..6c50cd9ef 100644
--- a/VERSION_DM
+++ b/VERSION_DM
@@ -1 +1 @@
-1.02.172-git (2020-03-24)
+1.02.172 (2021-05-07)
diff --git a/WHATS_NEW b/WHATS_NEW
index 14b6ec2b9..458236475 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,5 @@
-Version 2.02.188 - 
-==================================
+Version 2.02.188 - 07th May 2021
+================================
   Fix problem with unbound variable usage within fsadm.
   Avoid removing LVs on error path of lvconvert during creation volumes.
   Fix crashing lvdisplay when thin volume was waiting for merge.
diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 188ac8900..a74a05461 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,5 @@
-Version 1.02.172 - 
-==================================
+Version 1.02.172 - 07th May 2021
+================================
   Add dm_tree_node_add_thin_pool_target_v1 with crop_metadata support.
   Add support for VDO in blkdeactivate script.
   Try to remove all created devices on dm preload tree error path.


