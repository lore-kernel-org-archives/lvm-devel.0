From: Marian Csontos <mcsontos@sourceware.org>
Date: Wed, 31 Oct 2018 03:51:19 -0400
Subject: 2018-06-01-stable - post-release
Message-ID: <201810310751.w9V7pJm9003686@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=fa8d5e4e8132ec6d601a9642abfbdcc044880c27
Commit:        fa8d5e4e8132ec6d601a9642abfbdcc044880c27
Parent:        b93aded0212a903f8a1e9e897dada1f34aa3de43
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Mon Oct 29 18:40:19 2018 +0100
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Tue Oct 30 10:01:01 2018 +0100

post-release

---
 VERSION      |    2 +-
 VERSION_DM   |    2 +-
 WHATS_NEW    |    3 +++
 WHATS_NEW_DM |    3 +++
 4 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/VERSION b/VERSION
index 65f29e1..46e7b87 100644
--- a/VERSION
+++ b/VERSION
@@ -1 +1 @@
-2.02.182(2) (2018-10-30)
+2.02.183(2)-git (2018-10-30)
diff --git a/VERSION_DM b/VERSION_DM
index 798a0b9..9c3ba5f 100644
--- a/VERSION_DM
+++ b/VERSION_DM
@@ -1 +1 @@
-1.02.152 (2018-10-30)
+1.02.154-git (2018-10-30)
diff --git a/WHATS_NEW b/WHATS_NEW
index 09fc0a6..e3fcc6e 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,3 +1,6 @@
+Version 2.02.183 - 
+====================================
+
 Version 2.02.182 - 30th October 2018
 ====================================
   Fix possible write race between last metadata block and the first extent.
diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index b36e3cf..ee5bcfa 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,3 +1,6 @@
+Version 1.02.154 - 
+====================================
+
 Version 1.02.152 - 30th October 2018
 ====================================
   Add hot fix to avoiding locking collision when monitoring thin-pools.


