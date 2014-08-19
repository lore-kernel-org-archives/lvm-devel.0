From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue, 19 Aug 2014 12:05:42 +0000 (UTC)
Subject: master - report: also display "mirror" keyword in lv_layout for mirrored mirror log and "cache" keyword in lv_layout for cached cache pool
Message-ID: <20140819120542.D1DC660FB8@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=aec4d0c939653cfc0dadcec43a9db98597154bcb
Commit:        aec4d0c939653cfc0dadcec43a9db98597154bcb
Parent:        b80683616412b29a1dbd80641cae175696a9a761
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Aug 19 13:58:32 2014 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Aug 19 13:58:32 2014 +0200

report: also display "mirror" keyword in lv_layout for mirrored mirror log and "cache" keyword in lv_layout for cached cache pool

$ lvs -a -o name,vg_name,attr,layout,type
  LV                    VG     Attr       Layout     Type
  lvol0                 vg     mwi-a-m--- mirror     mirror
  [lvol0_mimage_0]      vg     iwi-aom--- linear     image,mirror
  [lvol0_mimage_1]      vg     iwi-aom--- linear     image,mirror
  [lvol0_mlog]          vg     mwi-aom--- mirror     log,mirror
  [lvol0_mlog_mimage_0] vg     iwi-aom--- linear     image,mirror
  [lvol0_mlog_mimage_1] vg     iwi-aom--- linear     image,mirror

(lvol0_mlog properly displayed as "mirror" layout for mirrored mirror log)

$ lvs -a -o name,vg_name,attr,layout,type
  LV                  VG     Attr       Layout     Type
  lvol0               vg     Cwi---C--- cache,pool cache,pool
  [lvol0_cdata]       vg     Cwi------- linear     cache,data,pool
  [lvol0_cmeta]       vg     ewi------- linear     cache,metadata,pool
  [lvol1_pmspare]     vg     ewi------- linear     metadata,pool,spare
  lvol2               vg     Cwi---C--- cache,pool cache,pool
  [lvol2_cdata]       vg     Cwi---C--- cache      cache,data,pool
  [lvol2_cdata_corig] vg     owi---C--- linear     cache,origin
  [lvol2_cmeta]       vg     ewi------- linear     cache,metadata,pool

(lvol2_cdata properly displayed as cached cache pool data)
---
 lib/metadata/lv_manip.c |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index f7cbfe7..dd0ba33 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -170,6 +170,9 @@ static int _lv_type_list_mirror(struct dm_pool *mem,
 	} else if (lv_is_mirror_log(lv)) {
 		if (!str_list_add_no_dup_check(mem, type, _lv_type_names[LV_TYPE_LOG]))
 			goto_bad;
+		if (lv_is_mirrored(lv) &&
+		    !str_list_add_no_dup_check(mem, layout, _lv_type_names[LV_TYPE_MIRROR]))
+			goto_bad;
 		top_level = 0;
 	} else if (lv->status & PVMOVE) {
 		if (!str_list_add_no_dup_check(mem, type, _lv_type_names[LV_TYPE_PVMOVE]) ||
@@ -333,6 +336,9 @@ static int _lv_type_list_cache(struct dm_pool *mem,
 		if (!str_list_add_no_dup_check(mem, type, _lv_type_names[LV_TYPE_POOL]) ||
 		    !str_list_add_no_dup_check(mem, type, _lv_type_names[LV_TYPE_DATA]))
 			goto_bad;
+		if (lv_is_cache(lv) &&
+		    !str_list_add_no_dup_check(mem, layout, _lv_type_names[LV_TYPE_CACHE]))
+			goto_bad;
 		top_level = 0;
 	}
 


