From: Alasdair Kergon <agk@fedoraproject.org>
Date: Sat, 26 Mar 2016 09:34:01 +0000 (UTC)
Subject: master - pre-release
Message-ID: <20160326093401.070FA601DD@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b9d07f7a12991ce7437630d2362fcc1a44a37e98
Commit:        b9d07f7a12991ce7437630d2362fcc1a44a37e98
Parent:        a5d53aec839e7fbe558b26e3195a8a18d3451ab5
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Sat Mar 26 09:04:50 2016 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Sat Mar 26 09:04:50 2016 +0000

pre-release

---
 VERSION      |    2 +-
 VERSION_DM   |    2 +-
 WHATS_NEW    |    3 ++-
 WHATS_NEW_DM |    3 ++-
 4 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/VERSION b/VERSION
index 5482ec4..6c9e9b0 100644
--- a/VERSION
+++ b/VERSION
@@ -1 +1 @@
-2.02.148(2)-git (2016-03-19)
+2.02.148(2)-git (2016-03-26)
diff --git a/VERSION_DM b/VERSION_DM
index 156b4b5..837c459 100644
--- a/VERSION_DM
+++ b/VERSION_DM
@@ -1 +1 @@
-1.02.121-git (2016-03-19)
+1.02.121-git (2016-03-26)
diff --git a/WHATS_NEW b/WHATS_NEW
index 32528a2..ad2dc98 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
-Version 2.02.148 - 
+Version 2.02.148 - 26th March 2016
 ==================================
+  Introduce TARGET_NAME and MODULE NAME macros.
   Replace hard-coded module and target names with macros.
   Add pv_major and pv_minor report fields.
   Detect and warn about mismatch between devices used and assumed for an LV.
diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 9ddf5e1..3f044da 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
-Version 1.02.121 - 
+Version 1.02.121 - 26th March 2016
 ==================================
+  Adjust raid status function.
 
 Version 1.02.120 - 11th March 2016
 ==================================


