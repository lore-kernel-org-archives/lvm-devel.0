From: Alasdair Kergon <agk@fedoraproject.org>
Date: Fri, 22 Apr 2016 23:47:33 +0000 (UTC)
Subject: master - post-release
Message-ID: <20160422234733.1AC0C60DE4@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=eb8edccd58a4ac2b313800f4d1839df336e3cab9
Commit:        eb8edccd58a4ac2b313800f4d1839df336e3cab9
Parent:        546b2006dd4bc888a08631d6cb66245b0374eab2
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Sat Apr 23 00:43:13 2016 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Sat Apr 23 00:43:13 2016 +0100

post-release

---
 VERSION      |    2 +-
 VERSION_DM   |    2 +-
 WHATS_NEW    |    3 +++
 WHATS_NEW_DM |    3 +++
 4 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/VERSION b/VERSION
index 3af3f8c..a9bd406 100644
--- a/VERSION
+++ b/VERSION
@@ -1 +1 @@
-2.02.151(2)-git (2016-04-23)
+2.02.152(2)-git (2016-04-23)
diff --git a/VERSION_DM b/VERSION_DM
index 74d6f61..da7e631 100644
--- a/VERSION_DM
+++ b/VERSION_DM
@@ -1 +1 @@
-1.02.123-git (2016-04-23)
+1.02.124-git (2016-04-23)
diff --git a/WHATS_NEW b/WHATS_NEW
index bf72aaa..961bae7 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,3 +1,6 @@
+Version 2.02.152 - 
+==================================
+
 Version 2.02.151 - 23rd April 2016
 ==================================
   Fix error path after reusing of _setup_task (2.02.150).
diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 3c1ca53..7460a94 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,3 +1,6 @@
+Version 1.02.124 - 
+==================================
+
 Version 1.02.123 - 23rd April 2016
 ==================================
   Do not strip LVM- when debug reporting not found uuid.


