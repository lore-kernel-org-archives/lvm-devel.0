From: Alasdair Kergon <agk@fedoraproject.org>
Date: Fri, 30 Oct 2015 15:45:35 +0000 (UTC)
Subject: master - pre-release
Message-ID: <20151030154535.3668560FBE@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=15a97cc610712efe818f96b9630b72de89a0cf57
Commit:        15a97cc610712efe818f96b9630b72de89a0cf57
Parent:        3f1c63c812ba5f79768f23b8d6d2e2965a458e0e
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Fri Oct 30 15:34:00 2015 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Fri Oct 30 15:34:00 2015 +0000

pre-release

---
 VERSION                               |    2 +-
 VERSION_DM                            |    2 +-
 WHATS_NEW                             |    4 ++--
 WHATS_NEW_DM                          |    4 ++--
 test/shell/snapshot-remove-dmsetup.sh |    2 +-
 5 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/VERSION b/VERSION
index 3d59279..20d1cc4 100644
--- a/VERSION
+++ b/VERSION
@@ -1 +1 @@
-2.02.133(2)-git (2015-09-22)
+2.02.133(2)-git (2015-10-30)
diff --git a/VERSION_DM b/VERSION_DM
index 0cc8062..ef5a8f8 100644
--- a/VERSION_DM
+++ b/VERSION_DM
@@ -1 +1 @@
-1.02.110-git (2015-09-22)
+1.02.110-git (2015-10-30)
diff --git a/WHATS_NEW b/WHATS_NEW
index 3808cb6..cfd0a1a 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,5 @@
-Version 2.02.133 - 
-======================================
+Version 2.02.133 - 30th October 2015
+====================================
   Support repeated -o|--options for reporting commands.
   Support -o- and -o# for reporting commands to remove and compact fields.
   Fix missing PVs from pvs output if vgremove is run concurrently.
diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 63cb2cc..5004f84 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,5 @@
-Version 1.02.110 - 
-======================================
+Version 1.02.110 - 30th October 2015
+====================================
   Disable thin monitoring plugin when it fails too often (>10 times).
   Fix/restore parsing of empty field '-' when processing dmeventd event.
   Enhance dm_tree_node_size_changed() to recognize size reduction.
diff --git a/test/shell/snapshot-remove-dmsetup.sh b/test/shell/snapshot-remove-dmsetup.sh
index 6a4f9d2..14023a0 100644
--- a/test/shell/snapshot-remove-dmsetup.sh
+++ b/test/shell/snapshot-remove-dmsetup.sh
@@ -36,7 +36,7 @@ mount -o errors=remount-ro "$DM_DEV_DIR/$vg1/snap" mnt
 
 sync
 
-# intentionally suspend layer bellow
+# intentionally suspend layer below
 dmsetup suspend $vg-$lv1
 
 # now this should pass without blocking


