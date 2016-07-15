From: Alasdair Kergon <agk@fedoraproject.org>
Date: Fri, 15 Jul 2016 21:02:57 +0000 (UTC)
Subject: master - post-release
Message-ID: <20160715210257.60C4F60F8C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=9c6a26f50ac6be27b6e8d8405fc980c8515e9e8c
Commit:        9c6a26f50ac6be27b6e8d8405fc980c8515e9e8c
Parent:        3d717b52c144699ec1ad096f71088b455cd87faf
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Fri Jul 15 22:02:58 2016 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Fri Jul 15 22:02:58 2016 +0100

post-release

---
 VERSION      |    2 +-
 VERSION_DM   |    2 +-
 WHATS_NEW    |    3 +++
 WHATS_NEW_DM |    3 +++
 4 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/VERSION b/VERSION
index 2468807..297fa86 100644
--- a/VERSION
+++ b/VERSION
@@ -1 +1 @@
-2.02.161(2)-git (2016-07-15)
+2.02.162(2)-git (2016-07-15)
diff --git a/VERSION_DM b/VERSION_DM
index 4cdbea7..79d0cc5 100644
--- a/VERSION_DM
+++ b/VERSION_DM
@@ -1 +1 @@
-1.02.131-git (2016-07-15)
+1.02.132-git (2016-07-15)
diff --git a/WHATS_NEW b/WHATS_NEW
index cbd0ceb..ba1a58b 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,3 +1,6 @@
+Version 2.02.162 - 
+=================================
+
 Version 2.02.161 - 15th July 2016
 =================================
   Prohibit some lvchange/lvresize that were failing on raid0 volumes.
diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index c02cb3f..53d0388 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,3 +1,6 @@
+Version 1.02.132 - 
+=================================
+
 Version 1.02.131 - 15th July 2016
 =================================
   Disable queueing on mpath devs in blk-availability systemd service/initscript.


