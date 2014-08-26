From: Alasdair Kergon <agk@fedoraproject.org>
Date: Tue, 26 Aug 2014 15:41:58 +0000 (UTC)
Subject: master - post-release
Message-ID: <20140826154158.8306C60355@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=dd9700f1925dbe20e657765400a80b62a9d0adb3
Commit:        dd9700f1925dbe20e657765400a80b62a9d0adb3
Parent:        8b8d21f8733d800dd672bcc629b20d8585d2021a
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Tue Aug 26 16:41:18 2014 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Tue Aug 26 16:41:18 2014 +0100

post-release

---
 VERSION      |    2 +-
 VERSION_DM   |    2 +-
 WHATS_NEW    |    3 +++
 WHATS_NEW_DM |    3 +++
 4 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/VERSION b/VERSION
index 86bdbb0..234d9db 100644
--- a/VERSION
+++ b/VERSION
@@ -1 +1 @@
-2.02.110(2)-git (2014-08-26)
+2.02.111(2)-git (2014-08-26)
diff --git a/VERSION_DM b/VERSION_DM
index 27fe4c7..fe3203c 100644
--- a/VERSION_DM
+++ b/VERSION_DM
@@ -1 +1 @@
-1.02.89-git (2014-08-26)
+1.02.90-git (2014-08-26)
diff --git a/WHATS_NEW b/WHATS_NEW
index 1d82ed5..46d5791 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,3 +1,6 @@
+Version 2.02.111 - 
+===================================
+
 Version 2.02.110 - 26th August 2014
 ===================================
   Fix manipulation with thin-pools which are excluded via volume_list.
diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 83119f6..afdb1d0 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,3 +1,6 @@
+Version 1.02.90 - 
+==================================
+
 Version 1.02.89 - 26th August 2014
 ==================================
   Improve libdevmapper-event select() error handling.


