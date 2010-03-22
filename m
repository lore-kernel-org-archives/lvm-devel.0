From: Mikulas Patocka <mpatocka@redhat.com>
Date: Mon, 22 Mar 2010 04:02:02 -0400 (EDT)
Subject: [PATCH] A missing space in the error message.
Message-ID: <Pine.LNX.4.64.1003220401310.13822@hs20-bc2-1.build.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

A missing space in the error message.

Signed-off-by: Mikulas Patocka <mpatocka@redhat.com>

---
 lib/metadata/merge.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: LVM2.moje/lib/metadata/merge.c
===================================================================
--- LVM2.moje.orig/lib/metadata/merge.c	2010-03-22 08:59:51.000000000 +0100
+++ LVM2.moje/lib/metadata/merge.c	2010-03-22 09:00:06.000000000 +0100
@@ -233,7 +233,7 @@ int check_lv_segments(struct logical_vol
 			}
 		if (!seg_found) {
 			log_error("LV segment %s:%" PRIu32 "-%" PRIu32
-				  "is incorrectly listed as being used by LV %s",
+				  " is incorrectly listed as being used by LV %s",
 				  seg->lv->name, seg->le, seg->le + seg->len - 1,
 				  lv->name);
 			r = 0;


