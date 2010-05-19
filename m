From: Mikulas Patocka <mpatocka@redhat.com>
Date: Wed, 19 May 2010 11:56:48 -0400 (EDT)
Subject: [PATCH] If lv_info fails, don't report snapshot percentage
Message-ID: <Pine.LNX.4.64.1005191155540.16134@hs20-bc2-1.build.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

If lv_info fails, don't report snapshot percentage

We shouldn't report snapshot percentage if lv_info fails (i.e. returns zero)
or if the device is not loaded (info.exists is zero).

Previously, the logic in the code was to not report percentage if lv_info
succeeds and info.exists is zero.

This fixes a bug, when dm-mod is not loaded (and the kernel doesn't load it
automatically) "lvs" commands reports all snapshots as 100% full.

Signed-off-by: Mikulas Patocka <mpatocka@redhat.com>

---
 lib/report/report.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: LVM2.2.02.64/lib/report/report.c
===================================================================
--- LVM2.2.02.64.orig/lib/report/report.c	2010-05-19 17:53:54.000000000 +0200
+++ LVM2.2.02.64/lib/report/report.c	2010-05-19 17:54:16.000000000 +0200
@@ -1019,7 +1019,7 @@ static int _snpercent_disp(struct dm_rep
 	}
 
 	if ((!lv_is_cow(lv) && !lv_is_merging_origin(lv)) ||
-	    (lv_info(lv->vg->cmd, lv, &info, 0, 0) && !info.exists)) {
+	    !lv_info(lv->vg->cmd, lv, &info, 0, 0) || !info.exists) {
 		*sortval = UINT64_C(0);
 		dm_report_field_set_value(field, "", sortval);
 		return 1;


