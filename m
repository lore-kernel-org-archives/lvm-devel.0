From: Alasdair Kergon <agk@fedoraproject.org>
Date: Fri, 12 Jun 2015 20:46:21 +0000 (UTC)
Subject: master - post-release
Message-ID: <20150612204621.CE45C60B44@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f715fefe314288a3200d60afd71991e86f3a098f
Commit:        f715fefe314288a3200d60afd71991e86f3a098f
Parent:        2c64762a40dba77a52de8a3459d68a740a5da1c7
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Fri Jun 12 21:42:57 2015 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Fri Jun 12 21:42:57 2015 +0100

post-release

---
 VERSION      |    2 +-
 VERSION_DM   |    2 +-
 WHATS_NEW    |    3 +++
 WHATS_NEW_DM |    3 +++
 4 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/VERSION b/VERSION
index 1797821..ac44695 100644
--- a/VERSION
+++ b/VERSION
@@ -1 +1 @@
-2.02.121(2)-git (2015-06-12)
+2.02.122(2)-git (2015-06-12)
diff --git a/VERSION_DM b/VERSION_DM
index 8ef64ac..eb763e0 100644
--- a/VERSION_DM
+++ b/VERSION_DM
@@ -1 +1 @@
-1.02.98-git (2015-06-12)
+1.02.99-git (2015-06-12)
diff --git a/WHATS_NEW b/WHATS_NEW
index 652572f..007ee0a 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,3 +1,6 @@
+Version 2.02.122 - 
+=================================
+
 Version 2.02.121 - 12th June 2015
 =================================
   Distinguish between on-disk and lvmetad versions of text metadata.
diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 9d5a619..724b1c7 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,3 +1,6 @@
+Version 1.02.99 - 
+================================
+
 Version 1.02.98 - 12th June 2015
 ================================
   Add dm_task_get_errno() to return any unexpected errno from a dm ioctl call.


