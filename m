From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 12 Apr 2021 07:55:52 +0000 (GMT)
Subject: main - WHATS_NEW: updates
Message-ID: <20210412075552.8BEF93835429@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a5f83cb612497c76a5a0e9a69cddea531af4688f
Commit:        a5f83cb612497c76a5a0e9a69cddea531af4688f
Parent:        151377dd50b7ba84894f799d9e0957898748f882
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Apr 12 09:49:23 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Apr 12 09:54:16 2021 +0200

WHATS_NEW: updates

---
 WHATS_NEW    | 4 ++++
 WHATS_NEW_DM | 1 +
 2 files changed, 5 insertions(+)

diff --git a/WHATS_NEW b/WHATS_NEW
index c2676c820..8a89516d7 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,9 @@
 Version 2.03.12 - 
 ===================================
+  Better hyphenation usage in man pages.
+  Replace use of deprecated security_context_t with char*.
+  Configure supports AIO_LIBS and AIO_CFLAGS.
+  Improve build process for static builds.
   Improve signal handling with lvmpolld.
   Signal handler can interrupt command also for SIGTERM.
   Lvreduce --yes support.
diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 822ca14eb..8d070ed1f 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.177 - 
 ====================================
+  Configure proceeds without libaio to allow build of device-mapper only.
   Fix symbol versioning build with -O2 -flto.
   Add dm_tree_node_add_thin_pool_target_v1 with crop_metadata support.
 


