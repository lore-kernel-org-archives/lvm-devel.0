From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue, 19 Aug 2014 07:44:35 +0000 (UTC)
Subject: master - report: also display "mirror" keyword in lv_type for pvmove LV and display "multiple" for external origin used for more than one thin snapshot
Message-ID: <20140819074435.43A926100F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b80683616412b29a1dbd80641cae175696a9a761
Commit:        b80683616412b29a1dbd80641cae175696a9a761
Parent:        90c47a49686431a097809d1d133a071a95a14e68
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Aug 19 09:41:41 2014 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Aug 19 09:41:41 2014 +0200

report: also display "mirror" keyword in lv_type for pvmove LV and display "multiple" for external origin used for more than one thin snapshot

$ lvs -a -o name,vg_name,attr,layout,type
  LV        VG     Attr       Layout     Type
  lvol0     vg     -wI-a----- linear     linear
  [pvmove0] vg     p-C-aom--- mirror     mirror,pvmove

(added "mirror" for pvmove LV)

$ lvs -a -o name,vg_name,attr,layout,type
  LV              VG     Attr       Layout     Type
  lvol0           vg     ori------- linear     external,multiple,origin,thin
  [lvol1_pmspare] vg     ewi------- linear     metadata,pool,spare
  lvol2           vg     Vwi-a-tz-- thin       snapshot,thin
  lvol3           vg     Vwi-a-tz-- thin       snapshot,thin
  pool            vg     twi-a-tz-- pool,thin  pool,thin
  [pool_tdata]    vg     Twi-ao---- linear     data,pool,thin
  [pool_tmeta]    vg     ewi-ao---- linear     metadata,pool,thin

(added "multiple" for external origin used for more than one
thin snapshot - lvol0 in the example above)
---
 lib/metadata/lv_manip.c |    6 +++++-
 1 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 81001fd..f7cbfe7 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -172,7 +172,8 @@ static int _lv_type_list_mirror(struct dm_pool *mem,
 			goto_bad;
 		top_level = 0;
 	} else if (lv->status & PVMOVE) {
-		if (!str_list_add_no_dup_check(mem, type, _lv_type_names[LV_TYPE_PVMOVE]))
+		if (!str_list_add_no_dup_check(mem, type, _lv_type_names[LV_TYPE_PVMOVE]) ||
+		    !str_list_add_no_dup_check(mem, type, _lv_type_names[LV_TYPE_MIRROR]))
 			goto_bad;
 	}
 
@@ -384,6 +385,9 @@ int lv_layout_and_type(struct dm_pool *mem, const struct logical_volume *lv,
 		if (!str_list_add_no_dup_check(mem, *type, _lv_type_names[LV_TYPE_ORIGIN]) ||
 		    !str_list_add_no_dup_check(mem, *type, _lv_type_names[LV_TYPE_EXTERNAL]))
 			goto_bad;
+		if (lv->external_count > 1 &&
+		    !str_list_add_no_dup_check(mem, *type, _lv_type_names[LV_TYPE_MULTIPLE]))
+			goto_bad;
 		if (!lv_is_thin_volume(lv) &&
 		    !str_list_add_no_dup_check(mem, *type, _lv_type_names[LV_TYPE_THIN]))
 			goto_bad;


