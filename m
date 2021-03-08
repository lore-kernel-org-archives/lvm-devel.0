From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon,  8 Mar 2021 14:47:00 +0000 (GMT)
Subject: main - WHATS_NEW: updates
Message-ID: <20210308144700.4C9DD395200F@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=3cbb751815ed545df905d49716444314beb5996c
Commit:        3cbb751815ed545df905d49716444314beb5996c
Parent:        6d6e1ae8873cc4b91425e8f2edeba88cf79d8321
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Mar 8 15:41:19 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Mar 8 15:43:27 2021 +0100

WHATS_NEW: updates

---
 WHATS_NEW | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/WHATS_NEW b/WHATS_NEW
index cbd542fed..568a7df90 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,9 @@
 Version 2.03.12 - 
 ===================================
+  Improve hash function with less collisions and make it faster.
+  Reduce ioctl count when deactivating volumes.
+  Reduce number of metadata parsing.
+  Enhance performance of lvremove and vgremove commands.
   Support interruption when taking archive and backup.
   Accelerate large lvremoves.
   Speedup search for cached device nodes.


