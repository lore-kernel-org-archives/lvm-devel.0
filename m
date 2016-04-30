From: Alasdair Kergon <agk@fedoraproject.org>
Date: Sat, 30 Apr 2016 00:15:10 +0000 (UTC)
Subject: master - pre-release
Message-ID: <20160430001510.CEFFB60283@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e53ecf91f7550b77d8b85545e49c5805332ddd8d
Commit:        e53ecf91f7550b77d8b85545e49c5805332ddd8d
Parent:        c76df666c903b59f069292c4c1507b1ac37a5590
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Sat Apr 30 01:07:26 2016 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Sat Apr 30 01:07:26 2016 +0100

pre-release

---
 VERSION      |    2 +-
 VERSION_DM   |    2 +-
 WHATS_NEW    |    2 +-
 WHATS_NEW_DM |    2 +-
 4 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/VERSION b/VERSION
index a9bd406..e3d1fb7 100644
--- a/VERSION
+++ b/VERSION
@@ -1 +1 @@
-2.02.152(2)-git (2016-04-23)
+2.02.152(2)-git (2016-04-30)
diff --git a/VERSION_DM b/VERSION_DM
index da7e631..dc7dbb4 100644
--- a/VERSION_DM
+++ b/VERSION_DM
@@ -1 +1 @@
-1.02.124-git (2016-04-23)
+1.02.124-git (2016-04-30)
diff --git a/WHATS_NEW b/WHATS_NEW
index a712c5f..c6fe1db 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,4 +1,4 @@
-Version 2.02.152 - 
+Version 2.02.152 - 30th April 2016
 ==================================
   Use any inherited tags when wiping metadata sub LVs to ensure activation.
   Add str_list_wipe.
diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index b21d7d5..24561d4 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,4 +1,4 @@
-Version 1.02.124 - 
+Version 1.02.124 - 30th April 2016
 ==================================
   Add dm_udev_wait_immediate to libdevmapper for waiting outside the library.
 


