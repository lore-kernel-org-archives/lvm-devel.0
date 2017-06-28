From: Alasdair Kergon <agk@sourceware.org>
Date: Wed, 28 Jun 2017 12:01:20 -0400
Subject: master - post-release
Message-ID: <201706281601.v5SG1KiT008082@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=0021d707fb93a98526bd02c2192d0c1b4ec9cfa1
Commit:        0021d707fb93a98526bd02c2192d0c1b4ec9cfa1
Parent:        08ce545449a7076965e153e6a9df1c49f833d33e
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Wed Jun 28 17:00:49 2017 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Wed Jun 28 17:00:49 2017 +0100

post-release

---
 VERSION      |    2 +-
 VERSION_DM   |    2 +-
 WHATS_NEW    |    3 +++
 WHATS_NEW_DM |    3 +++
 4 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/VERSION b/VERSION
index 1774a41..e9822e0 100644
--- a/VERSION
+++ b/VERSION
@@ -1 +1 @@
-2.02.172(2)-git (2017-06-28)
+2.02.173(2)-git (2017-06-28)
diff --git a/VERSION_DM b/VERSION_DM
index 0f1b1a3..d398102 100644
--- a/VERSION_DM
+++ b/VERSION_DM
@@ -1 +1 @@
-1.02.141-git (2017-06-28)
+1.02.142-git (2017-06-28)
diff --git a/WHATS_NEW b/WHATS_NEW
index 895e29c..f1ded2d 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,3 +1,6 @@
+Version 2.02.173 - 
+=================================
+
 Version 2.02.172 - 28th June 2017
 =================================
   Add missing NULL to argv array when spliting cmdline arguments.
diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 44d548a..923f25d 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,3 +1,6 @@
+Version 1.02.142 -
+=================================
+
 Version 1.02.141 - 28th June 2017
 =================================
   Fix reusing of dm_task structure for status reading (used by dmeventd).


