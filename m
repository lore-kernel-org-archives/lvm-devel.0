From: Alasdair Kergon <agk@fedoraproject.org>
Date: Sat,  5 Dec 2015 15:57:10 +0000 (UTC)
Subject: master - post-release
Message-ID: <20151205155710.3C2146072D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=00bab9d9cd8581e905634658a6cda33d998b1b85
Commit:        00bab9d9cd8581e905634658a6cda33d998b1b85
Parent:        063b353b286652d5ccc692cf636824b9b3270fe9
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Sat Dec 5 15:36:22 2015 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Sat Dec 5 15:36:22 2015 +0000

post-release

---
 VERSION      |    2 +-
 VERSION_DM   |    2 +-
 WHATS_NEW    |    3 +++
 WHATS_NEW_DM |    3 +++
 4 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/VERSION b/VERSION
index a504b04..3216252 100644
--- a/VERSION
+++ b/VERSION
@@ -1 +1 @@
-2.02.137(2)-git (2015-12-05)
+2.02.138(2)-git (2015-12-05)
diff --git a/VERSION_DM b/VERSION_DM
index 27520ef..d28d68b 100644
--- a/VERSION_DM
+++ b/VERSION_DM
@@ -1 +1 @@
-1.02.113-git (2015-12-05)
+1.02.114-git (2015-12-05)
diff --git a/WHATS_NEW b/WHATS_NEW
index 95839a2..3bc9397 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,3 +1,6 @@
+Version 2.02.138 -
+====================================
+
 Version 2.02.137 - 5th December 2015
 ====================================
   Restore archiving before changing metadata in vgextend (2.02.117).
diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 4b119af..9dd51aa 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,3 +1,6 @@
+Version 1.02.114 -
+====================================
+
 Version 1.02.113 - 5th December 2015
 ====================================
   Mirror plugin in dmeventd uses dm_get_status_mirror().


