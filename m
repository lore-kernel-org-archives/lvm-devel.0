From: Alasdair Kergon <agk@fedoraproject.org>
Date: Tue, 24 Mar 2015 02:04:28 +0000 (UTC)
Subject: master - pre-release
Message-ID: <20150324020428.A510C60E0E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=8bb1dfdd323cb70160f37a2d3a4cba48d5243be7
Commit:        8bb1dfdd323cb70160f37a2d3a4cba48d5243be7
Parent:        192a83def3095b33b5590d0531d24a26588b4aef
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Tue Mar 24 01:59:35 2015 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Tue Mar 24 01:59:35 2015 +0000

pre-release

---
 VERSION      |    2 +-
 VERSION_DM   |    2 +-
 WHATS_NEW    |    8 +++++---
 WHATS_NEW_DM |    5 +++--
 4 files changed, 10 insertions(+), 7 deletions(-)

diff --git a/VERSION b/VERSION
index 4f24316..ef6bee0 100644
--- a/VERSION
+++ b/VERSION
@@ -1 +1 @@
-2.02.118(2)-git (2015-03-04)
+2.02.118(2)-git (2015-03-24)
diff --git a/VERSION_DM b/VERSION_DM
index 649324d..ca20a0d 100644
--- a/VERSION_DM
+++ b/VERSION_DM
@@ -1 +1 @@
-1.02.95-git (2015-03-04)
+1.02.95-git (2015-03-24)
diff --git a/WHATS_NEW b/WHATS_NEW
index c9242fe..558bdb5 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,5 @@
-Version 2.02.118 - 
-=================================
+Version 2.02.118 - 23rd March 2015
+==================================
   Store metadata size + checksum in lvmcache and add struct lvmcache_vgsummary.
   Remove inaccessible clustered PVs from 'pvs -a'.
   Don't invalidate cached orphan information while global lock is held.
@@ -14,11 +14,13 @@ Version 2.02.118 -
   Avoid reparsing same metadata when reading same metadata from multiple PVs.
   Save extra device open/close when scanning device for size.
   Fix seg_monitor field to report status also for mirrors and thick snapshots.
+  Replace LVM_WRITE with LVM_WRITE_LOCKED flags in metadata if system ID is set.
+  Remove ACCESS_NEEDS_SYSTEM_ID VG status flag. (2.02.117)
+  Enable system ID features.
 
 Version 2.02.117 - 4th March 2015
 =================================
   Add CFG_DISABLED for new system ID config settings that must not yet be used.
-  Set ACCESS_NEEDS_SYSTEM_ID VG status flag while system_id is set.
   Preserve original format type field when processing backup files.
   Implement status action for lvm2-monitor initscript to display monitored LVs.
   Allow lvchange -p to change kernel state only if metadata state differs.
diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 9286bc6..08975b6 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
-Version 1.02.95 - 
-================================
+Version 1.02.95 - 15th March 2015
+=================================
+  Makefile regenerated.
 
 Version 1.02.94 - 4th March 2015
 ================================


