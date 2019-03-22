From: Marian Csontos <mcsontos@sourceware.org>
Date: Fri, 22 Mar 2019 06:17:14 -0400
Subject: stable-2.02 - post-release
Message-ID: <201903221017.x2MAHEIm011431@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=81d954df4ed844600c44b99ee68453e1e53fcf31
Commit:        81d954df4ed844600c44b99ee68453e1e53fcf31
Parent:        7cbee7e9cf5445ee5c50898e20536734cbb0f4a6
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Fri Mar 22 11:13:08 2019 +0100
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Fri Mar 22 11:13:08 2019 +0100

post-release

---
 VERSION      |    2 +-
 VERSION_DM   |    2 +-
 WHATS_NEW    |    3 +++
 WHATS_NEW_DM |    3 +++
 4 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/VERSION b/VERSION
index 37f89d5..b6970e5 100644
--- a/VERSION
+++ b/VERSION
@@ -1 +1 @@
-2.02.184(2) (2019-03-22)
+2.02.185(2)-git (2019-03-22)
diff --git a/VERSION_DM b/VERSION_DM
index f874e31..57cbc8d 100644
--- a/VERSION_DM
+++ b/VERSION_DM
@@ -1 +1 @@
-1.02.156 (2019-03-22)
+1.02.158-git (2019-03-22)
diff --git a/WHATS_NEW b/WHATS_NEW
index ffdd5aa..1d9032d 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,3 +1,6 @@
+Version 2.02.185 - 
+==================================
+
 Version 2.02.184 - 22nd March 2019
 ==================================
   Fix (de)activation of RaidLVs with visible SubLVs
diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 4e245fb..8258273 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,3 +1,6 @@
+Version 1.02.158 - 
+==================================
+
 Version 1.02.156 - 22nd March 2019
 ==================================
   Ensure migration_threshold for cache is at least 8 chunks.


