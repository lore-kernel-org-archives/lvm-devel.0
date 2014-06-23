From: Alasdair Kergon <agk@fedoraproject.org>
Date: Mon, 23 Jun 2014 13:03:44 +0000 (UTC)
Subject: master - pre-release
Message-ID: <20140623130344.82CC160E90@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=8d27f8e00392e3bd748cf7ba743a8652e6e7b2f1
Commit:        8d27f8e00392e3bd748cf7ba743a8652e6e7b2f1
Parent:        867b92b031b4913213c335bd0bf7363e934f379d
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Mon Jun 23 14:03:32 2014 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Mon Jun 23 14:03:32 2014 +0100

pre-release

---
 VERSION      |    2 +-
 VERSION_DM   |    2 +-
 WHATS_NEW    |   12 ++++++++----
 WHATS_NEW_DM |    4 ++--
 4 files changed, 12 insertions(+), 8 deletions(-)

diff --git a/VERSION b/VERSION
index bcbb09e..59da36c 100644
--- a/VERSION
+++ b/VERSION
@@ -1 +1 @@
-2.02.107(2)-git (2014-04-10)
+2.02.107(2)-git (2014-06-23)
diff --git a/VERSION_DM b/VERSION_DM
index 8b95ed0..d519151 100644
--- a/VERSION_DM
+++ b/VERSION_DM
@@ -1 +1 @@
-1.02.86-git (2014-04-10)
+1.02.86-git (2014-06-23)
diff --git a/WHATS_NEW b/WHATS_NEW
index c2b443c..7ab7422 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,5 @@
-Version 2.02.107 - 
-==================================
+Version 2.02.107 - 23rd June 2014
+=================================
   Introduce LCK_ACTIVATION to avoid concurrent activation of basic LV types.
   Fix open_count test for lvchange --refresh or mirrors and raids.
   Update pvs,vgs,lvs and lvm man page for selection support.
@@ -12,8 +12,12 @@ Version 2.02.107 -
   When converting RAID origin to cache LV, properly rename sub-LVs.
   Use RemoveOnStop for lvm2-lvmetad.socket systemd unit.
   Add thin-generic configuration profile for generic thin settings.
-  Fix crash when reporting of empty labels on pvs.
+  Fix crash when reporting empty labels on pvs.
   Use retry_deactivation also when cleaning orphan devices.
+  Wait for client threads when shutting down lvmetad.
+  Remove PV from cache on pvremove.
+  Avoid repeatedly reporting of failure to connect to lvmetad.
+  Introduce MDA_FAILED to permit metadata updates even if some mdas are missing.
   Prompt when setting the VG cluster attr if the cluster is not setup.
   Allow --yes to skip prompt in vgextend (worked only with -f).
   Don't use name mangling for LVM - it never uses dm names with wrong char set.
@@ -27,7 +31,7 @@ Version 2.02.107 -
   Strictly separate command profiles and per-VG/LV profiles referenced in mda.
   Fix dumpconfig --type diff when run as second and later cmd in lvm shell.
   Fix wrong profile reuse from previous run if another cmd is run in lvm shell.
-  Move cache description from lvm(8) to lvmcache(7) man page.
+  Move cache description from lvm(8) to new lvmcache(7) man page.
   Display skipped prompt in silent mode.
   Make reporting commands show help about possible sort keys on '-O help'.
   Add metadata_percent to lvs_cols.
diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 119016a..fddc996 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,5 @@
-Version 1.02.88 - 
-=================================
+Version 1.02.88 - 23rd June 2014
+================================
   Make "help" and "?" reporting fields implicit.
   Recognize implicit "selected" field if using dm_report_init_with_selection.
   Add support for implicit reporting fields which are predefined in libdm.


