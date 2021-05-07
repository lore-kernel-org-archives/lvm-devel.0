From: Marian Csontos <mcsontos@sourceware.org>
Date: Fri,  7 May 2021 15:40:17 +0000 (GMT)
Subject: stable-2.02 - post-release
Message-ID: <20210507154017.1CA133853835@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=1afa67f4b9bdeb1e0da1cda17695d0aa58f7c3e3
Commit:        1afa67f4b9bdeb1e0da1cda17695d0aa58f7c3e3
Parent:        cde814abc04c6724a1561fc9935ac6b986054404
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Fri May 7 17:36:25 2021 +0200
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Fri May 7 17:36:25 2021 +0200

post-release

---
 VERSION      | 2 +-
 VERSION_DM   | 2 +-
 WHATS_NEW    | 3 +++
 WHATS_NEW_DM | 3 +++
 4 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/VERSION b/VERSION
index 542534973..f1cba5329 100644
--- a/VERSION
+++ b/VERSION
@@ -1 +1 @@
-2.02.188(2) (2021-05-07)
+2.02.189(2)-git (2021-05-07)
diff --git a/VERSION_DM b/VERSION_DM
index 6c50cd9ef..095ff82fb 100644
--- a/VERSION_DM
+++ b/VERSION_DM
@@ -1 +1 @@
-1.02.172 (2021-05-07)
+1.02.174-git (2021-05-07)
diff --git a/WHATS_NEW b/WHATS_NEW
index 458236475..03c58976d 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,3 +1,6 @@
+Version 2.02.189 - 
+================================
+
 Version 2.02.188 - 07th May 2021
 ================================
   Fix problem with unbound variable usage within fsadm.
diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index a74a05461..d515f6318 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,3 +1,6 @@
+Version 1.02.174 - 
+================================
+
 Version 1.02.172 - 07th May 2021
 ================================
   Add dm_tree_node_add_thin_pool_target_v1 with crop_metadata support.


