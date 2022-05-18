From: Marian Csontos <mcsontos@sourceware.org>
Date: Wed, 18 May 2022 16:25:52 +0000 (GMT)
Subject: main - pre-release
Message-ID: <20220518162552.EA6D33858406@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=6d1e894a867681af7a811ed63bc435f3aa55fec8
Commit:        6d1e894a867681af7a811ed63bc435f3aa55fec8
Parent:        9aa3ea1c9859aa6a1d8b9ac918fa47ae24927735
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Wed May 18 18:17:06 2022 +0200
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Wed May 18 18:17:06 2022 +0200

pre-release

---
 VERSION      |  2 +-
 VERSION_DM   |  2 +-
 WHATS_NEW    | 10 ++++++++--
 WHATS_NEW_DM |  4 ++--
 4 files changed, 12 insertions(+), 6 deletions(-)

diff --git a/VERSION b/VERSION
index fba090956..5b09a281e 100644
--- a/VERSION
+++ b/VERSION
@@ -1 +1 @@
-2.03.16(2)-git (2022-02-07)
+2.03.16(2) (2022-05-18)
diff --git a/VERSION_DM b/VERSION_DM
index d122183b2..c31ec0a43 100644
--- a/VERSION_DM
+++ b/VERSION_DM
@@ -1 +1 @@
-1.02.185-git (2022-02-07)
+1.02.185 (2022-05-18)
diff --git a/WHATS_NEW b/WHATS_NEW
index db8265a78..3a5e39c09 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,7 +1,13 @@
-Version 2.03.16 - 
-====================================
+Version 2.03.16 - 18th May 2022
+===============================
   Fix segfault when handling selection with historical LVs.
   Add support --vdosettings with lvcreate, lvconvert, lvchange.
+  Filtering multipath devices respects blacklist setting from multipath
+  configuration.
+  lvmdevices support for removing by device id using --deviceidtype and
+  --deldev.
+  Display writecache block size with lvs -o writecache_block_size.
+  Improve cachesettings description in man lvmcache.
   Fix lossing of delete message on thin-pool extension.
 
 Version 2.03.15 - 07th February 2022
diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index c63436221..9cb770879 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,5 @@
-Version 1.02.185 - 
-=====================================
+Version 1.02.185 - 18th May 2022
+================================
 
 Version 1.02.183 - 07th February 2022
 =====================================

