From: Marian Csontos <mcsontos@sourceware.org>
Date: Mon, 13 May 2019 03:58:30 -0400
Subject: stable-2.02 - pre-release
Message-ID: <201905130758.x4D7wUxN013904@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=3aeff09bd7db18e4cb83c44b52eae0acac755201
Commit:        3aeff09bd7db18e4cb83c44b52eae0acac755201
Parent:        d5a5792b30c74b9b4d839b5a33c466c2ac012d0c
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Mon May 13 09:45:25 2019 +0200
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Mon May 13 09:51:28 2019 +0200

pre-release

---
 VERSION      |    2 +-
 VERSION_DM   |    2 +-
 WHATS_NEW    |    6 +++---
 WHATS_NEW_DM |    4 ++--
 4 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/VERSION b/VERSION
index b6970e5..583267e 100644
--- a/VERSION
+++ b/VERSION
@@ -1 +1 @@
-2.02.185(2)-git (2019-03-22)
+2.02.185(2) (2019-05-13)
diff --git a/VERSION_DM b/VERSION_DM
index 57cbc8d..8c4af2c 100644
--- a/VERSION_DM
+++ b/VERSION_DM
@@ -1 +1 @@
-1.02.158-git (2019-03-22)
+1.02.158 (2019-05-13)
diff --git a/WHATS_NEW b/WHATS_NEW
index 4b7be7c..4e75c6a 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,9 +1,9 @@
-Version 2.02.185 - 
-==================================
+Version 2.02.185 - 13th May 2019
+================================
   Fix change of monitoring in clustered volumes.
   Improve -lXXX%VG modifier which improves cache segment estimation.
   Add synchronization with udev before removing cached devices.
-  Fix missing growth of _pmsmare volume when extending _tmeta volume.
+  Fix missing growth of _pmspare volume when extending _tmeta volume.
   Automatically grow thin metadata, when thin data gets too big.
   Add support for vgsplit with cached devices.
   Fix signal delivery checking race in libdaemon (lvmetad).
diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 8258273..7c74bfe 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,5 @@
-Version 1.02.158 - 
-==================================
+Version 1.02.158 - 13th May 2019
+================================
 
 Version 1.02.156 - 22nd March 2019
 ==================================


