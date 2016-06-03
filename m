From: Alasdair Kergon <agk@fedoraproject.org>
Date: Fri,  3 Jun 2016 22:43:22 +0000 (UTC)
Subject: master - pre-release
Message-ID: <20160603224322.B39E060CD2@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=767c9d653eb9c6deec576c23823781c6f184dea0
Commit:        767c9d653eb9c6deec576c23823781c6f184dea0
Parent:        b321d2b1b9a3b6a1f8d67888a04c7318aa3148c2
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Fri Jun 3 23:16:50 2016 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Fri Jun 3 23:16:50 2016 +0100

pre-release

---
 VERSION      |    2 +-
 VERSION_DM   |    2 +-
 WHATS_NEW    |    3 ++-
 WHATS_NEW_DM |    2 +-
 4 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/VERSION b/VERSION
index fc39fdb..c233b09 100644
--- a/VERSION
+++ b/VERSION
@@ -1 +1 @@
-2.02.155(2)-git (2016-05-14)
+2.02.155(2)-git (2016-06-03)
diff --git a/VERSION_DM b/VERSION_DM
index fbe453d..d4bffcd 100644
--- a/VERSION_DM
+++ b/VERSION_DM
@@ -1 +1 @@
-1.02.126-git (2016-05-14)
+1.02.126-git (2016-06-03)
diff --git a/WHATS_NEW b/WHATS_NEW
index 92b95c0..2484ab2 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
-Version 2.02.155 - 
+Version 2.02.155 - 3rd June 2016
 ================================
+  Reject PV tags on pvmove cmdline because only 1 PV is supported. (2.02.141)
   Fix compilation error when building with configure --disable-devmapper.
   Fix lvmconfig --type diff to display complete diff if config cascade used.
   Automatically filter out partitioned loop devices with partscan (losetup -P).
diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index d446997..a86940b 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,4 +1,4 @@
-Version 1.02.126 - 
+Version 1.02.126 - 3rd June 2016
 ================================
   Report passthrough caching mode when parsing cache mode.
 


