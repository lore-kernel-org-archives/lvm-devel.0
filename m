From: Alasdair Kergon <agk@fedoraproject.org>
Date: Wed, 13 Nov 2013 14:11:34 +0000 (UTC)
Subject: master - post-release
Message-ID: <20131113141134.4080A60F88@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=322e7b3060e79e62708f7936f140386d64704878
Commit:        322e7b3060e79e62708f7936f140386d64704878
Parent:        77a1efeb8eb0fe73c858ade05b578c3cfe3ddd9f
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Wed Nov 13 14:11:11 2013 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Wed Nov 13 14:11:11 2013 +0000

post-release

---
 VERSION      |    2 +-
 VERSION_DM   |    2 +-
 WHATS_NEW    |    3 +++
 WHATS_NEW_DM |    3 +++
 4 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/VERSION b/VERSION
index 576af30..8594917 100644
--- a/VERSION
+++ b/VERSION
@@ -1 +1 @@
-2.02.104(2)-git (2013-11-13)
+2.02.105(2)-git (2013-11-13)
diff --git a/VERSION_DM b/VERSION_DM
index 89b02c3..d36b815 100644
--- a/VERSION_DM
+++ b/VERSION_DM
@@ -1 +1 @@
-1.02.83-git (2013-11-13)
+1.02.84-git (2013-11-13)
diff --git a/WHATS_NEW b/WHATS_NEW
index 475794e..b6f51e1 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,3 +1,6 @@
+Version 2.02.105 -
+=====================================
+
 Version 2.02.104 - 13th November 2013
 =====================================
   Workaround VG refresh race during autoactivation by retrying the refresh.
diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 1e8bae7..e3953e4 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,3 +1,6 @@
+Version 1.02.84 -
+====================================
+
 Version 1.02.83 - 13th November 2013
 ====================================
   Consistently report on stderr when device is not found for dmsetup info.


