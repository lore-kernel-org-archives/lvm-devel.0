From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri,  4 Mar 2016 11:08:26 +0000 (UTC)
Subject: master - WHATS_NEW: historical LVs
Message-ID: <20160304110826.94A65603B4@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=418b7c6be8e553c04eeeb8a96d6b3d4b1da1bb9a
Commit:        418b7c6be8e553c04eeeb8a96d6b3d4b1da1bb9a
Parent:        e447ab87e904799dac89f70d32733d4368563d91
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Fri Mar 4 12:08:02 2016 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri Mar 4 12:08:02 2016 +0100

WHATS_NEW: historical LVs

---
 WHATS_NEW |   13 +++++++++++++
 1 files changed, 13 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index f623226..cbdd14f 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,18 @@
 Version 2.02.145 - 
 =====================================
+  Make it possible to use lvremove and lvrename on historical LVs.
+  For historical LVs, report 'none' for lv_layout and 'history' for lv_role.
+  Add full_{ancestors,descendants} fields to report LV ancestry with history.
+  Report (h)istorical state within 5th bit (State) of the lv_attr field.
+  Add lv_historical reporting field to report if LV is historical or not.
+  Add lv_time_removed reporting field to display removal time for hist. LVs.
+  Report lv_name, lv_uuid, vg_name, lv_time for historical LVs.
+  Add --nohistory switch to lvremove to disable history recording on demand.
+  Add -H|--history switch to lvs and lvdisplay to include historical LVs.
+  Create historical LVs out of removed thin snapshot LVs and record in history.
+  Add metadata/lvs_history_retention_time for automatic removal of hist. LVs.
+  Add metadata/record_lvs_history config for switching LV history recording.
+  Add support and infrastructure for tracking historical LVs.
   Improve lvconvert man page.
   Add kernel_cache_policy lvs field.
   Display [unknown] instead of 'unknown device' in pvs output.


