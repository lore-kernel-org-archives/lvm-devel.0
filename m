From: Alasdair Kergon <agk@fedoraproject.org>
Date: Tue, 22 Sep 2015 15:06:36 +0000 (UTC)
Subject: master - post-release
Message-ID: <20150922150636.7618560CB7@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=3a8a37187d65e2c84f98d39e06bdee7000e34875
Commit:        3a8a37187d65e2c84f98d39e06bdee7000e34875
Parent:        629398d0f275e6ee5abf7929bc80e671e9f141c7
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Tue Sep 22 16:06:07 2015 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Tue Sep 22 16:06:07 2015 +0100

post-release

---
 VERSION      |    2 +-
 VERSION_DM   |    2 +-
 WHATS_NEW    |    3 +++
 WHATS_NEW_DM |    3 +++
 4 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/VERSION b/VERSION
index 407d6c3..3d59279 100644
--- a/VERSION
+++ b/VERSION
@@ -1 +1 @@
-2.02.132(2)-git (2015-09-22)
+2.02.133(2)-git (2015-09-22)
diff --git a/VERSION_DM b/VERSION_DM
index 60f6390..0cc8062 100644
--- a/VERSION_DM
+++ b/VERSION_DM
@@ -1 +1 @@
-1.02.109-git (2015-09-22)
+1.02.110-git (2015-09-22)
diff --git a/WHATS_NEW b/WHATS_NEW
index 53940a3..6a97dc4 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,3 +1,6 @@
+Version 2.02.133 - 
+======================================
+
 Version 2.02.132 - 22nd September 2015
 ======================================
   Fix lvmconf to set locking_type=2 if external locking library is requested.
diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 83cfdff..51e1be6 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,3 +1,6 @@
+Version 1.02.110 - 
+======================================
+
 Version 1.02.109 - 22nd September 2016
 ======================================
   Update man pages for dmsetup and dmstats.


