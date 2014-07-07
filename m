From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon,  7 Jul 2014 14:53:33 +0000 (UTC)
Subject: master - WHATS_NEW: commits a473435..7021c8f1
Message-ID: <20140707145333.C18E660E52@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=4b65d7ec72869ba7e70a1c93567ef0f271ed395e
Commit:        4b65d7ec72869ba7e70a1c93567ef0f271ed395e
Parent:        9e1c4a3818fa2af76b7b7890939c9e7ec9cb6818
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Mon Jul 7 16:52:43 2014 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Jul 7 16:52:43 2014 +0200

WHATS_NEW: commits a473435..7021c8f1

---
 WHATS_NEW    |    5 +++++
 WHATS_NEW_DM |    1 +
 2 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index ab36cb3..d4649e4 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,10 @@
 Version 2.02.108 -
 =================================
+  Recognize "auto"/"unmanaged" values in selection for appropriate fields only.
+  Add report/binary_values_as_numeric lvm.conf option for binary values as 0/1.
+  Add --binary arg to pvs,vgs,lvs and {pv,vg,lv}display -C for 0/1 on reports.
+  Add separate reporting fields for each each {pv,vg,lv}_attr bit.
+  Separate LV device status reporting fields out of LV fields.
   Fix regression causing PVs not in VGs to be marked as allocatable (2.02.59).
   Fix VG component of lvid in vgsplit/vgmerge and check in vg_validate.
   Add lv_full_name, lv_parent and lv_dm_path fields to reports.
diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index f25fa92..852d313 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.87 -
 ================================
+  Add dm_report_field_reserved_value for per-field reserved value definition.
 
 Version 1.02.86 - 23rd June 2014
 ================================


