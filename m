From: Alasdair Kergon <agk@fedoraproject.org>
Date: Wed,  3 Sep 2014 23:26:01 +0000 (UTC)
Subject: master - post-release
Message-ID: <20140903232601.53CBB6109C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b25e0086b6738ad1e25480571af58807c12df57c
Commit:        b25e0086b6738ad1e25480571af58807c12df57c
Parent:        fcb433abec7c3ed7919fcc6688988e2225e83f40
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Mon Sep 1 01:53:44 2014 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Mon Sep 1 01:53:44 2014 +0100

post-release

---
 VERSION      |    2 +-
 VERSION_DM   |    2 +-
 WHATS_NEW    |    3 +++
 WHATS_NEW_DM |    3 +++
 4 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/VERSION b/VERSION
index b0c9ffc..061e5da 100644
--- a/VERSION
+++ b/VERSION
@@ -1 +1 @@
-2.02.111(2)-git (2014-09-01)
+2.02.112(2)-git (2014-09-01)
diff --git a/VERSION_DM b/VERSION_DM
index 1e954da..d021c49 100644
--- a/VERSION_DM
+++ b/VERSION_DM
@@ -1 +1 @@
-1.02.90-git (2014-09-01)
+1.02.91-git (2014-09-01)
diff --git a/WHATS_NEW b/WHATS_NEW
index e0e8773..70df450 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,3 +1,6 @@
+Version 2.02.112 - 
+=====================================
+
 Version 2.02.111 - 1st September 2014
 =====================================
   Pass properly sized char buffers for sscanf when initializing clvmd.
diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index f0e77b3..4effe09 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,3 +1,6 @@
+Version 1.02.91 - 
+====================================
+
 Version 1.02.90 - 1st September 2014
 ====================================
   Restore proper buffer size for parsing mountinfo line (1.02.89)


