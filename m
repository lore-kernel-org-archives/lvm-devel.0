From: Alasdair Kergon <agk@fedoraproject.org>
Date: Mon,  9 Nov 2015 01:53:38 +0000 (UTC)
Subject: master - pre-release
Message-ID: <20151109015338.8621F60309@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a3f77ed4ba4b6d35638f81cf9f58db2a730246e7
Commit:        a3f77ed4ba4b6d35638f81cf9f58db2a730246e7
Parent:        b9341e36f1390c5aa4e79b2faee28a2aeabc64c5
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Mon Nov 9 01:45:22 2015 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Mon Nov 9 01:45:22 2015 +0000

pre-release

---
 VERSION      |    2 +-
 VERSION_DM   |    2 +-
 WHATS_NEW    |    4 +++-
 WHATS_NEW_DM |    3 ---
 4 files changed, 5 insertions(+), 6 deletions(-)

diff --git a/VERSION b/VERSION
index f36c01d..e7542bf 100644
--- a/VERSION
+++ b/VERSION
@@ -1 +1 @@
-2.02.134(2)-git (2015-10-30)
+2.02.134(2)-git (2015-11-09)
diff --git a/VERSION_DM b/VERSION_DM
index ebca82f..661545a 100644
--- a/VERSION_DM
+++ b/VERSION_DM
@@ -1 +1 @@
-1.02.111-git (2015-10-30)
+1.02.110-git (2015-11-09)
diff --git a/WHATS_NEW b/WHATS_NEW
index 015eba0..f414e92 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,7 @@
-Version 2.02.134 - 
+Version 2.02.134 - 9th November 2015
 ====================================
+  Refactor some lvmetad code and adjust some duplicate PV messages.
+  No longer repair/wipe VG/PVs if inaccessible because foreign or shared.
   Pass correct data size to mirror log calc so log can be bigger than 1 extent.
 
 Version 2.02.133 - 30th October 2015
diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 113a4bb..5004f84 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,6 +1,3 @@
-Version 1.02.111 - 
-====================================
-
 Version 1.02.110 - 30th October 2015
 ====================================
   Disable thin monitoring plugin when it fails too often (>10 times).


