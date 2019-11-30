From: Marian Csontos <mcsontos@sourceware.org>
Date: Sat, 30 Nov 2019 08:58:28 -0500
Subject: master - pre-release
Message-ID: <48109.119113008582400577@us-mta-111.us.mimecast.lan>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=3d7f755674c651a012f7dc6c10e67bdd330a33ae
Commit:        3d7f755674c651a012f7dc6c10e67bdd330a33ae
Parent:        0a7495e6808473ee60385d3a4b6f48ac2240da72
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Sat Nov 30 14:45:51 2019 +0100
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Sat Nov 30 14:45:51 2019 +0100

pre-release

---
 VERSION      |    2 +-
 VERSION_DM   |    2 +-
 WHATS_NEW    |    6 ++++--
 WHATS_NEW_DM |    4 ++--
 4 files changed, 8 insertions(+), 6 deletions(-)

diff --git a/VERSION b/VERSION
index 720a8c8..717c4cf 100644
--- a/VERSION
+++ b/VERSION
@@ -1 +1 @@
-2.03.07(2)-git (2019-10-23)
+2.03.07(2) (2019-11-30)
diff --git a/VERSION_DM b/VERSION_DM
index 3045b1d..a230ed0 100644
--- a/VERSION_DM
+++ b/VERSION_DM
@@ -1 +1 @@
-1.02.167-git (2019-10-23)
+1.02.167 (2019-11-30)
diff --git a/WHATS_NEW b/WHATS_NEW
index 41d0e56..4adcfb3 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,8 +1,10 @@
-Version 2.03.07 - 
-===================================
+Version 2.03.07 - 30th November 2019
+====================================
+  Subcommand in vgck for repairing headers and metadata.
   Ensure minimum required region size on striped RaidLV creation.
   Fix resize of thin-pool with data and metadata of different segtype.
   Improve mirror type leg splitting.
+  Improve error path handling in daemons on shutdown.
   Fix activation order when removing merged snapshot.
   Experimental VDO support for lvmdbusd.
 
diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 6fc70ca..663f461 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,5 @@
-Version 1.02.167 - 
-====================================
+Version 1.02.167 - 30th November 2019
+=====================================
 
 Version 1.02.165 - 23rd October 2019
 ====================================



