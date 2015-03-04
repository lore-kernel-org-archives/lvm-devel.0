From: Alasdair Kergon <agk@fedoraproject.org>
Date: Wed,  4 Mar 2015 14:11:23 +0000 (UTC)
Subject: master - pre-release
Message-ID: <20150304141123.58D4B60B69@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=930fa3290debbdecca44f334426d960e3160e7bf
Commit:        930fa3290debbdecca44f334426d960e3160e7bf
Parent:        a7bfc2cbb565eb668068a091d7c2a7a4f4f2ffcc
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Wed Mar 4 13:49:51 2015 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Wed Mar 4 13:49:51 2015 +0000

pre-release

---
 VERSION      |    2 +-
 VERSION_DM   |    2 +-
 WHATS_NEW    |   14 +++++++-------
 WHATS_NEW_DM |    4 ++--
 4 files changed, 11 insertions(+), 11 deletions(-)

diff --git a/VERSION b/VERSION
index 071f5f4..22c760d 100644
--- a/VERSION
+++ b/VERSION
@@ -1 +1 @@
-2.02.117(2)-git (2015-01-30)
+2.02.117(2)-git (2015-03-04)
diff --git a/VERSION_DM b/VERSION_DM
index dc719d2..4541e24 100644
--- a/VERSION_DM
+++ b/VERSION_DM
@@ -1 +1 @@
-1.02.94-git (2015-01-30)
+1.02.94-git (2015-03-04)
diff --git a/WHATS_NEW b/WHATS_NEW
index 9beb668..af5704a 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
-Version 2.02.117 - 
-====================================
+Version 2.02.117 - 4th March 2015
+=================================
+  Add CFG_DISABLED for new system ID config settings that must not yet be used.
   Set ACCESS_NEEDS_SYSTEM_ID VG status flag while system_id is set.
   Preserve original format type field when processing backup files.
   Implement status action for lvm2-monitor initscript to display monitored LVs.
@@ -12,14 +13,13 @@ Version 2.02.117 -
   Add NEEDS_FOREIGN_VGS flag to vgimport so --foreign is always supplied.
   Add --foreign to the 6 display and reporting tools and vgcfgbackup.
   Install /etc/lvm/lvmlocal.conf template with local section for systemid.
-  Record creation_host_system_id in lvm2 metadata.
+  Record creation_host_system_id in lvm2 metadata (never set yet).
   Reinstate recursive config file tag section processing. (2.02.99)
-  Add 'lvm systemid' to display the current system ID.
+  Add 'lvm systemid' to display the current system ID (never set yet).
   Fix configure to properly recognize --with-default-raid10-segtype option.
   Do not refresh filters/rescan if no signature is wiped during pvcreate.
   Enforce none external dev info for wiping during pvcreate to avoid races.
-  Add global/system_id_source and system_id_file to lvm.conf.
-  Add --systemid to vgcreate and vchange to set / change a system ID.
+  Add global/system_id_source and system_id_file to lvm.conf (disabled).
   Add support for VG system_id to control host access to VGs.
   Update vgextend to use process_each_vg.
   Add --ignoreskippedcluster to pvchange.
@@ -33,7 +33,7 @@ Version 2.02.117 -
   Add support for -S/--select to vgchange,lvchange and pvchange.
   Add infrastructure to support selection for non-reporting tools.
   Add LVM_COMMAND_PROFILE env var to set default command profile name to use.
-  set CLOEXEC flag on file descriptors originating in libdaemon
+  Set CLOEXEC flag on file descriptors originating in libdaemon.
 
 Version 2.02.116 - 30th January 2015
 ====================================
diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 183ef15..8816312 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,5 @@
-Version 1.02.94 - 
-===================================
+Version 1.02.94 - 4th March 2015
+================================
   Add dm_report_object_is_selected for generalized interface for report/select.
 
 Version 1.02.93 - 21st January 2015


