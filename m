From: Alasdair Kergon <agk@fedoraproject.org>
Date: Sat, 30 Apr 2016 00:15:12 +0000 (UTC)
Subject: master - post-release
Message-ID: <20160430001512.E5D3460F02@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=795e47cec572b13329eecbcfbbc0aa70f0bccc16
Commit:        795e47cec572b13329eecbcfbbc0aa70f0bccc16
Parent:        e53ecf91f7550b77d8b85545e49c5805332ddd8d
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Sat Apr 30 01:12:33 2016 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Sat Apr 30 01:12:33 2016 +0100

post-release

---
 VERSION      |    2 +-
 VERSION_DM   |    2 +-
 WHATS_NEW    |    3 +++
 WHATS_NEW_DM |    3 +++
 4 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/VERSION b/VERSION
index e3d1fb7..680848d 100644
--- a/VERSION
+++ b/VERSION
@@ -1 +1 @@
-2.02.152(2)-git (2016-04-30)
+2.02.153(2)-git (2016-04-30)
diff --git a/VERSION_DM b/VERSION_DM
index dc7dbb4..1eb63a8 100644
--- a/VERSION_DM
+++ b/VERSION_DM
@@ -1 +1 @@
-1.02.124-git (2016-04-30)
+1.02.125-git (2016-04-30)
diff --git a/WHATS_NEW b/WHATS_NEW
index c6fe1db..7291482 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,3 +1,6 @@
+Version 2.02.153 - 
+==================================
+
 Version 2.02.152 - 30th April 2016
 ==================================
   Use any inherited tags when wiping metadata sub LVs to ensure activation.
diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 24561d4..f6392ef 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,3 +1,6 @@
+Version 1.02.125 - 
+==================================
+
 Version 1.02.124 - 30th April 2016
 ==================================
   Add dm_udev_wait_immediate to libdevmapper for waiting outside the library.


