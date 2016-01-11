From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon, 11 Jan 2016 14:39:51 +0000 (UTC)
Subject: master - report: use brackets to signify LVs which are not visible when reporting lv_parent
Message-ID: <20160111143951.1C67B60E55@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d6cf83968cb0d397faec30ce54839a679e89dd14
Commit:        d6cf83968cb0d397faec30ce54839a679e89dd14
Parent:        f03a21f5b81dae3a1280fdd3704950e90eff13b2
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Mon Jan 11 15:34:35 2016 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Jan 11 15:34:35 2016 +0100

report: use brackets to signify LVs which are not visible when reporting lv_parent

Use common _lvname_disp to report lv_parent. The _lvname_disp
takes care of properly marking LVs which are not visible - such
LVs are always enclosed in brackets when reported within any
other field.

For example, thin pool over RAID.

Before:

$ lvs -a -o name,lv_parent,data_lv,metadata_lv vg
  LV                          Parent           Data               Meta
  cache_pool                                   [cache_pool_tdata] [cache_pool_tmeta]
  [cache_pool_tdata]          cache_pool
  [cache_pool_tdata_rimage_0] cache_pool_tdata
  [cache_pool_tdata_rimage_1] cache_pool_tdata
  [cache_pool_tdata_rmeta_0]  cache_pool_tdata
  [cache_pool_tdata_rmeta_1]  cache_pool_tdata
  [cache_pool_tmeta]          cache_pool
  [cache_pool_tmeta_rimage_0] cache_pool_tmeta
  [cache_pool_tmeta_rimage_1] cache_pool_tmeta
  [cache_pool_tmeta_rmeta_0]  cache_pool_tmeta
  [cache_pool_tmeta_rmeta_1]  cache_pool_tmeta
  [lvol0_pmspare]

With this patch applied:

$ lvs -a -o name,lv_parent,data_lv,metadata_lv vg
  LV                          Parent             Data               Meta
  cache_pool                                     [cache_pool_tdata] [cache_pool_tmeta]
  [cache_pool_tdata]          cache_pool
  [cache_pool_tdata_rimage_0] [cache_pool_tdata]
  [cache_pool_tdata_rimage_1] [cache_pool_tdata]
  [cache_pool_tdata_rmeta_0]  [cache_pool_tdata]
  [cache_pool_tdata_rmeta_1]  [cache_pool_tdata]
  [cache_pool_tmeta]          cache_pool
  [cache_pool_tmeta_rimage_0] [cache_pool_tmeta]
  [cache_pool_tmeta_rimage_1] [cache_pool_tmeta]
  [cache_pool_tmeta_rmeta_0]  [cache_pool_tmeta]
  [cache_pool_tmeta_rmeta_1]  [cache_pool_tmeta]
  [lvol0_pmspare]
---
 WHATS_NEW           |    1 +
 lib/report/report.c |   10 +++++-----
 2 files changed, 6 insertions(+), 5 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index d622c9f..f316054 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.140 -
 ===================================
+  Use brackets to signify LVs which are not visible when reporting lv_parent.
   Fix invalid memory read when reporting cache LV policy_name (2.02.126).
 
 Version 2.02.139 - 8th January 2016
diff --git a/lib/report/report.c b/lib/report/report.c
index bb2736f..17aa5c0 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -1655,15 +1655,15 @@ static int _lvfullname_disp(struct dm_report *rh, struct dm_pool *mem,
 
 static int _lvparent_disp(struct dm_report *rh, struct dm_pool *mem,
 			  struct dm_report_field *field,
-			  const void *data, void *private __attribute__((unused)))
+			  const void *data, void *private)
 {
 	const struct logical_volume *lv = (const struct logical_volume *) data;
-	char *repstr;
+	struct logical_volume *parent_lv = lv_parent(lv);
 
-	if (!(repstr = lv_parent_dup(mem, lv)))
-		return_0;
+	if (!parent_lv)
+		return _field_set_value(field, "", NULL);
 
-	return _field_set_value(field, repstr, NULL);
+	return _lvname_disp(rh, mem, field, parent_lv, private);
 }
 
 static int _do_datalv_disp(struct dm_report *rh, struct dm_pool *mem __attribute__((unused)),


