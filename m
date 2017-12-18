From: Alasdair Kergon <agk@sourceware.org>
Date: Mon, 18 Dec 2017 15:53:19 -0500
Subject: master - pre-release
Message-ID: <201712182053.vBIKrJHF026316@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a1f7a483253b11e52ad5460b28cf0c75dba26659
Commit:        a1f7a483253b11e52ad5460b28cf0c75dba26659
Parent:        5f45cb90a7d6ca8ea3d0456c42d2fc4721cf5d79
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Mon Dec 18 20:36:10 2017 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Mon Dec 18 20:36:10 2017 +0000

pre-release

---
 VERSION      |    2 +-
 VERSION_DM   |    2 +-
 WHATS_NEW    |    4 ++--
 WHATS_NEW_DM |    4 ++--
 4 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/VERSION b/VERSION
index 282f6f9..414b4df 100644
--- a/VERSION
+++ b/VERSION
@@ -1 +1 @@
-2.02.177(2)-git (2017-11-03)
+2.02.177(2)-git (2017-12-18)
diff --git a/VERSION_DM b/VERSION_DM
index 7aab7d6..4c2ffa3 100644
--- a/VERSION_DM
+++ b/VERSION_DM
@@ -1 +1 @@
-1.02.146-git (2017-11-03)
+1.02.146-git (2017-12-18)
diff --git a/WHATS_NEW b/WHATS_NEW
index 5fc4cd3..2163a5e 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,5 @@
-Version 2.02.177 -
-====================================
+Version 2.02.177 - 18th December 2017
+=====================================
   When writing text metadata content, use complete 4096 byte blocks.
   Change text format metadata alignment from 512 to 4096 bytes.
   When writing metadata, consistently skip mdas marked as failed.
diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index d9503c2..8b304e6 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,5 @@
-Version 1.02.146 -
-====================================
+Version 1.02.146 - 18th December 2017
+=====================================
   Activation tree of thin pool skips duplicated check of pool status.
   Remove code supporting replicator target.
   Do not ignore failure of _info_by_dev().


