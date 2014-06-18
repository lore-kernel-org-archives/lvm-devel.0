From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed, 18 Jun 2014 08:52:43 +0000 (UTC)
Subject: master - WHATS_NEW: commits 7dbbc05a69c4cb9756464720cad29e3c1ed971c3..b16f5633ab199dedfd25f08562f686a6fb4aba9d
Message-ID: <20140618085243.3D23C610D1@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=63f5be01702f3344fe2e95eea74c5149bab2d78d
Commit:        63f5be01702f3344fe2e95eea74c5149bab2d78d
Parent:        5ebff6cc9f631b7409d99b72fa0b39ccec30bf1f
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Jun 18 10:48:53 2014 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Jun 18 10:48:53 2014 +0200

WHATS_NEW: commits 7dbbc05a69c4cb9756464720cad29e3c1ed971c3..b16f5633ab199dedfd25f08562f686a6fb4aba9d

Report selection support...
---
 WHATS_NEW    |    5 +++++
 WHATS_NEW_DM |   13 +++++++++++++
 2 files changed, 18 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 5a9a498..5d59845 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,10 @@
 Version 2.02.107 - 
 ==================================
+  Update pvs,vgs,lvs and lvm man page for selection support.
+  Add -S/--select to lvm devtypes for report selection.
+  Add -S/--select to pvs,vgs,lvs and {pv,vg,lv}display -C for report selection.
+  Use dm_report_init_with_selection now, implicit "selected" field appears.
+  Make use of libdm's DM_REPORT_FIELD_TYPE{SIZE,PERCENT,STRING_LIST} for fields.
   Add support for all-or-nothing (atomic) pvmove.
   Automatically add snapshot metadata size for -l %ORIGIN calculation.
   When converting RAID origin to cache LV, properly rename sub-LVs.
diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 90dd5f5..d1b05cb 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,18 @@
 Version 1.02.88 - 
 =================================
+  Recognize implicit "selected" field if using dm_report_init_with_selection.
+  Add support for implicit reporting fields which are predefined in libdm.
+  Add DM_REPORT_FIELD_TYPE_PERCENT: separate number and percent fields.
+  Add dm_percent_range_t,dm_percent_to_float,dm_make_percent to libdm for reuse.
+  Add dm_report_reserved_value to libdevmapper for reserved value definition.
+  Also display field types when listing all fields in selection help.
+  Recognize "help" keyword in selection string to show brief help for selection.
+  Add dm_report_field_string_list to libdevmapper for direct string list report.
+  Add DM_REPORT_FIELD_TYPE_STRING_LIST: separate string and string list fields.
+  Add dm_str_list to libdevmapper for string list type definition and its reuse.
+  Add dmsetup -S/--select to define selection criteria for dmsetup reports.
+  Add dm_report_init_with_selection to intialize report with selection criteria.
+  Add DM_REPORT_FIELD_TYPE_SIZE: separate number and size reporting fields.
   Use RemoveOnStop for dm-event.socket systemd unit.
   Document env var 'DM_DEFAULT_NAME_MANGLING_MODE' in dmsetup man page.
   Warn user about incorrect use of cookie with 'dmsetup remove --force'.


