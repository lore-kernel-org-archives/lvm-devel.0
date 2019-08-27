From: Marian Csontos <mcsontos@sourceware.org>
Date: Tue, 27 Aug 2019 11:37:34 -0400
Subject: stable-2.02 - pre-release
Message-ID: <201908271537.x7RFbYHx027850@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=4e5761487efcb33a47f8913f5302e36307604832
Commit:        4e5761487efcb33a47f8913f5302e36307604832
Parent:        3954034b1577c21be18acd2f8e1904c3181c6c19
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Tue Aug 27 17:20:17 2019 +0200
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Tue Aug 27 17:20:17 2019 +0200

pre-release

---
 VERSION      |    2 +-
 VERSION_DM   |    2 +-
 WHATS_NEW    |    4 ++--
 WHATS_NEW_DM |    4 ++--
 4 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/VERSION b/VERSION
index f68edcf..7f0e456 100644
--- a/VERSION
+++ b/VERSION
@@ -1 +1 @@
-2.02.186(2)-git (2019-05-13)
+2.02.186(2) (2019-08-27)
diff --git a/VERSION_DM b/VERSION_DM
index 88c14ba..864ceb8 100644
--- a/VERSION_DM
+++ b/VERSION_DM
@@ -1 +1 @@
-1.02.160-git (2019-05-13)
+1.02.164 (2019-08-27)
diff --git a/WHATS_NEW b/WHATS_NEW
index fa631ec..cf2ec3e 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,5 @@
-Version 2.02.186 - 
-================================
+Version 2.02.186 - 27th August 2019
+===================================
   Improve internal removal of cached devices.
   Synchronize with udev when dropping snapshot.
   Add missing device synchronization point before removing pvmove node.
diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 1dc18ec..5c2a436 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,5 @@
-Version 1.02.165 - 
-=================================
+Version 1.02.164 - 27th August 2019
+===================================
   Add debug of dmsetup udevcomplete with hexa print DM_COOKIE_COMPLETED.
   Fix versioning of dm_stats_create_region and dm_stats_create_region.
   Parsing of cache status understand no_discard_passdown.


