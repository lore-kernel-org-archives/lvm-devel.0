From: Marian Csontos <mcsontos@sourceware.org>
Date: Wed, 20 Oct 2021 10:10:24 +0000 (GMT)
Subject: main - pre-release
Message-ID: <20211020101024.66AE03857C51@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=ef4521831d15a1785e034f6c6f536a03446f6e05
Commit:        ef4521831d15a1785e034f6c6f536a03446f6e05
Parent:        36be4d68f68d71173fed528f2f377c600f68f724
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Wed Oct 20 11:11:41 2021 +0200
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Wed Oct 20 11:12:39 2021 +0200

pre-release

---
 VERSION      | 2 +-
 VERSION_DM   | 2 +-
 WHATS_NEW    | 4 ++--
 WHATS_NEW_DM | 4 ++--
 4 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/VERSION b/VERSION
index b421d79ee..0a3618042 100644
--- a/VERSION
+++ b/VERSION
@@ -1 +1 @@
-2.03.14(2)-git (2021-08-11)
+2.03.14(2) (2021-10-20)
diff --git a/VERSION_DM b/VERSION_DM
index b8c51d0b6..52cb6225f 100644
--- a/VERSION_DM
+++ b/VERSION_DM
@@ -1 +1 @@
-1.02.181-git (2021-08-11)
+1.02.181 (2021-10-20)
diff --git a/WHATS_NEW b/WHATS_NEW
index 28e605280..240234e4d 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,5 @@
-Version 2.03.14 - 
-==================================
+Version 2.03.14 - 20th October 2021
+===================================
   Device scanning is skipping directories on different filesystems.
   Print info message with too many or too large archived files.
   Reduce metadata readings during scanning phase.
diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index c7029e437..adfff2142 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,5 @@
-Version 1.02.181 - 
-===================================
+Version 1.02.181 - 20th October 2021
+====================================
   Add IMA support with 'dmsetup measure' command.
   Add defines DM_NAME_LIST_FLAG_HAS_UUID, DM_NAME_LIST_FLAG_DOESNT_HAVE_UUID.
   Enhance tracking of activated devices when preloading dm tree.


