From: Alasdair Kergon <agk@fedoraproject.org>
Date: Fri, 17 Jun 2016 13:19:59 +0000 (UTC)
Subject: master - post-release
Message-ID: <20160617131959.A049160DC8@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ab7ade40957812b948a63527d1023747f8336e56
Commit:        ab7ade40957812b948a63527d1023747f8336e56
Parent:        38cc03605ceff43a8a7733b72ed9da94f9598e00
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Fri Jun 17 13:57:33 2016 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Fri Jun 17 14:10:20 2016 +0100

post-release

---
 VERSION      |    2 +-
 VERSION_DM   |    2 +-
 WHATS_NEW    |    3 +++
 WHATS_NEW_DM |    3 +++
 4 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/VERSION b/VERSION
index e066ad7..34e00b1 100644
--- a/VERSION
+++ b/VERSION
@@ -1 +1 @@
-2.02.157(2)-git (2016-06-17)
+2.02.158(2)-git (2016-06-17)
diff --git a/VERSION_DM b/VERSION_DM
index 82641c6..dd57819 100644
--- a/VERSION_DM
+++ b/VERSION_DM
@@ -1 +1 @@
-1.02.127-git (2016-06-17)
+1.02.128-git (2016-06-17)
diff --git a/WHATS_NEW b/WHATS_NEW
index 4880a0e..c91e28d 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,3 +1,6 @@
+Version 2.02.158 - 
+=================================
+
 Version 2.02.157 - 17th June 2016
 =================================
   Change pvscan --cache -aay to scan locally if lvmetad fails.
diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 1135a62..6fb1745 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,3 +1,6 @@
+Version 1.02.128 -
+=================================
+
 Version 1.02.127 - 11th June 2016
 =================================
  Fix blkdeactivate regression causing skipping of dm + md devices. (1.02.126)


