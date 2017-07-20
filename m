From: Alasdair Kergon <agk@sourceware.org>
Date: Thu, 20 Jul 2017 12:19:46 -0400
Subject: master - pre-release
Message-ID: <201707201619.v6KGJkfw014165@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=88f15659374042f7657d73393f73e267d752b4e1
Commit:        88f15659374042f7657d73393f73e267d752b4e1
Parent:        7ba0017468d977cf51bfce0e708317ab84bc04e7
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Thu Jul 20 16:57:27 2017 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Thu Jul 20 16:57:27 2017 +0100

pre-release

---
 VERSION      |    2 +-
 VERSION_DM   |    2 +-
 WHATS_NEW    |    8 +++++---
 WHATS_NEW_DM |    2 +-
 4 files changed, 8 insertions(+), 6 deletions(-)

diff --git a/VERSION b/VERSION
index e9822e0..44639a1 100644
--- a/VERSION
+++ b/VERSION
@@ -1 +1 @@
-2.02.173(2)-git (2017-06-28)
+2.02.173(2)-git (2017-07-20)
diff --git a/VERSION_DM b/VERSION_DM
index d398102..5123a72 100644
--- a/VERSION_DM
+++ b/VERSION_DM
@@ -1 +1 @@
-1.02.142-git (2017-06-28)
+1.02.142-git (2017-07-20)
diff --git a/WHATS_NEW b/WHATS_NEW
index c587a9c..4215069 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,10 +1,12 @@
-Version 2.02.173 - 
+Version 2.02.173 - 20th July 2017
 =================================
-  Add synchornization points with udev during conversion of raid LVs.
+  Add synchronization points with udev during conversion of raid LVs.
   Improve --size args validation and report more detailed error message.
   Initialize debugging mutex before any debug message in clvmd.
-  Log error instad of warn when noticing connection problem with lvmetad.
+  Log error instead of warn when noticing connection problem with lvmetad.
   Fix memory leak in lvmetad when working with duplicates.
+  Remove restrictions on reshaping open and clustered raid devices.
+  Add incompatible data_offset to raid metadata to fix reshape activation.
   Accept 'lvm -h' and 'lvm --help' as well as 'lvm help' for help.
   Suppress error message from accept() on clean lvmetad shutdown.
   Tidy clvmd client list processing and fix segfaults.
diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 40fb4f4..c39929a 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,4 +1,4 @@
-Version 1.02.142 -
+Version 1.02.142 - 20th July 2017
 =================================
   Create /dev/disk/by-part{uuid,label} and gpt-auto-root symlinks with udev.
 


