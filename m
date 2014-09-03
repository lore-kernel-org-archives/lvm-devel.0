From: Alasdair Kergon <agk@fedoraproject.org>
Date: Wed,  3 Sep 2014 23:25:59 +0000 (UTC)
Subject: master - pre-release
Message-ID: <20140903232559.3C6EE60F99@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=fcb433abec7c3ed7919fcc6688988e2225e83f40
Commit:        fcb433abec7c3ed7919fcc6688988e2225e83f40
Parent:        fa1a0d170ad7193e9d0c6fe828a5c5df24806a54
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Mon Sep 1 01:51:47 2014 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Mon Sep 1 01:51:47 2014 +0100

pre-release

---
 VERSION      |    2 +-
 VERSION_DM   |    2 +-
 WHATS_NEW    |    4 ++--
 WHATS_NEW_DM |    4 ++--
 4 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/VERSION b/VERSION
index 234d9db..b0c9ffc 100644
--- a/VERSION
+++ b/VERSION
@@ -1 +1 @@
-2.02.111(2)-git (2014-08-26)
+2.02.111(2)-git (2014-09-01)
diff --git a/VERSION_DM b/VERSION_DM
index fe3203c..1e954da 100644
--- a/VERSION_DM
+++ b/VERSION_DM
@@ -1 +1 @@
-1.02.90-git (2014-08-26)
+1.02.90-git (2014-09-01)
diff --git a/WHATS_NEW b/WHATS_NEW
index 6758389..e0e8773 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,5 @@
-Version 2.02.111 - 
-===================================
+Version 2.02.111 - 1st September 2014
+=====================================
   Pass properly sized char buffers for sscanf when initializing clvmd.
   Reinstate nosync logic when extending mirror. (2.02.110)
   Fix total area extent calculation when allocating cache pool. (2.02.110)
diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 3012ef1..f0e77b3 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,5 @@
-Version 1.02.90 - 
-==================================
+Version 1.02.90 - 1st September 2014
+====================================
   Restore proper buffer size for parsing mountinfo line (1.02.89)
 
 Version 1.02.89 - 26th August 2014


