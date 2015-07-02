From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu,  2 Jul 2015 09:34:45 +0000 (UTC)
Subject: master - report: fix regression while selecting string fields using synonyms
Message-ID: <20150702093445.732906134F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=454782f1a3cf41148711773ae820e646bd2fd95f
Commit:        454782f1a3cf41148711773ae820e646bd2fd95f
Parent:        7f63fff9c4a4e82925227e94d1fa4ba4500ebc2b
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Jul 2 11:31:54 2015 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Jul 2 11:31:54 2015 +0200

report: fix regression while selecting string fields using synonyms

$ lvs -o name,cache_policy vg/lvol0
  LV    Cache Policy
  lvol0

Before this patch:
$ lvs -o name,cache_policy -S 'cache_policy=undefined' vg/lvol0
  (no match)

With this patch applied:
$ lvs -o name,cache_policy -S 'cache_policy=undefined' vg/lvol0
  LV    Cache Policy
  lvol0
---
 WHATS_NEW            |    1 +
 libdm/libdm-report.c |    4 ++--
 2 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 1b5b097..6c822c4 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.124 -
 =================================
+  Fix regression in select to match string fields if using synonyms (2.02.123).
   Fix regression when printing more lv names via display_lvname (2.02.122).
   Add missing error logging to unlock_vg and sync_local_dev_names callers.
 
diff --git a/libdm/libdm-report.c b/libdm/libdm-report.c
index 18710d3..3f68a9e 100644
--- a/libdm/libdm-report.c
+++ b/libdm/libdm-report.c
@@ -1505,9 +1505,9 @@ static int _cmp_field_string(struct dm_report *rh __attribute__((unused)),
 
 	switch (fs->flags & FLD_CMP_MASK) {
 		case FLD_CMP_EQUAL:
-			return _check_value_is_strictly_reserved(rh, field_num, DM_REPORT_FIELD_TYPE_STRING, val, fs) ? 0 : !strcmp(val, sel);
+			return !strcmp(val, sel);
 		case FLD_CMP_NOT|FLD_CMP_EQUAL:
-			return _check_value_is_strictly_reserved(rh, field_num, DM_REPORT_FIELD_TYPE_STRING, val, fs) ? 0 : strcmp(val, sel);
+			return strcmp(val, sel);
 		default:
 			log_error(INTERNAL_ERROR "_cmp_field_string: unsupported string "
 				  "comparison type for selection field %s", field_id);


