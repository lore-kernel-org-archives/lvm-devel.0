From: Alasdair Kergon <agk@fedoraproject.org>
Date: Fri, 28 Nov 2014 23:11:07 +0000 (UTC)
Subject: master - pre-release
Message-ID: <20141128231107.822F5606D7@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e492861749195311cc71910aaacb084110a9ddbb
Commit:        e492861749195311cc71910aaacb084110a9ddbb
Parent:        6521c4b2156597a36a986def85449be734336c72
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Fri Nov 28 23:06:07 2014 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Fri Nov 28 23:06:07 2014 +0000

pre-release

---
 VERSION      |    2 +-
 VERSION_DM   |    2 +-
 WHATS_NEW    |    6 +++---
 WHATS_NEW_DM |    3 ---
 4 files changed, 5 insertions(+), 8 deletions(-)

diff --git a/VERSION b/VERSION
index 0f1a69f..851b30d 100644
--- a/VERSION
+++ b/VERSION
@@ -1 +1 @@
-2.02.114(2)-git (2014-11-24)
+2.02.114(2)-git (2014-11-28)
diff --git a/VERSION_DM b/VERSION_DM
index 13ce0a0..b4b6b50 100644
--- a/VERSION_DM
+++ b/VERSION_DM
@@ -1 +1 @@
-1.02.93-git (2014-11-24)
+1.02.92-git (2014-11-28)
diff --git a/WHATS_NEW b/WHATS_NEW
index b1cce84..a23f766 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,10 +1,10 @@
-Version 2.02.114 - 
+Version 2.02.114 - 28th November 2014
 =====================================
-  Release socket in daemon_close and protocol string in a daemon_open error path.
+  Release socket in daemon_close and protocol string in daemon_open error path.
   Add --cachepolicy and --cachesettings to lvcreate.
   Fix regression when parsing /dev/mapper dir (2.02.112).
   Fix missing rounding to 64KB when estimating optimal thin pool chunk size.
-  Fix typo in clvmd initscript causing CLVMD_STOP_TIMEOUT variable to be ignored.
+  Fix typo in clvmd initscript causing CLVMD_STOP_TIMEOUT var to be ignored.
   Fix size in pvresize "Resizing to ..." verbose msg to show proper result size.
 
 Version 2.02.113 - 24th November 2014
diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 6eafed6..45d3ece 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,6 +1,3 @@
-Version 1.02.93 - 
-====================================
-
 Version 1.02.92 - 24th November 2014
 ====================================
   Fix memory corruption with sorting empty string lists (1.02.86).


