From: Alasdair Kergon <agk@fedoraproject.org>
Date: Fri, 17 Jun 2016 13:19:57 +0000 (UTC)
Subject: master - pre-release
Message-ID: <20160617131957.7B99460DC8@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=38cc03605ceff43a8a7733b72ed9da94f9598e00
Commit:        38cc03605ceff43a8a7733b72ed9da94f9598e00
Parent:        a23655ab3bea4dfe9409c8c6b238787da9b457e1
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Fri Jun 17 13:48:39 2016 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Fri Jun 17 14:10:20 2016 +0100

pre-release

---
 VERSION      |    2 +-
 VERSION_DM   |    2 +-
 WHATS_NEW    |    3 ++-
 WHATS_NEW_DM |    3 ---
 4 files changed, 4 insertions(+), 6 deletions(-)

diff --git a/VERSION b/VERSION
index a7628a4..e066ad7 100644
--- a/VERSION
+++ b/VERSION
@@ -1 +1 @@
-2.02.157(2)-git (2016-06-11)
+2.02.157(2)-git (2016-06-17)
diff --git a/VERSION_DM b/VERSION_DM
index a1416c0..82641c6 100644
--- a/VERSION_DM
+++ b/VERSION_DM
@@ -1 +1 @@
-1.02.128-git (2016-06-11)
+1.02.127-git (2016-06-17)
diff --git a/WHATS_NEW b/WHATS_NEW
index 61b58b4..4880a0e 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
-Version 2.02.157 - 
+Version 2.02.157 - 17th June 2016
 =================================
+  Change pvscan --cache -aay to scan locally if lvmetad fails.
 
 Version 2.02.156 - 11th June 2016
 =================================
diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index bd17f1b..1135a62 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,6 +1,3 @@
-Version 1.02.128 - 
-=================================
-
 Version 1.02.127 - 11th June 2016
 =================================
  Fix blkdeactivate regression causing skipping of dm + md devices. (1.02.126)


