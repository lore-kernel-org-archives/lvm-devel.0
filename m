From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 10 Mar 2017 13:34:58 -0500
Subject: master - cache: properly translate DM_THIN_DISCARDS
Message-ID: <201703101834.v2AIYw9g020296@int-mx13.intmail.prod.int.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=50441f243387bb5fb0e27ebc7a859f5bdcbc4c60
Commit:        50441f243387bb5fb0e27ebc7a859f5bdcbc4c60
Parent:        f221ba97c99c4369714755d636093aa9c6276791
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Mar 7 23:55:08 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Mar 10 19:33:00 2017 +0100

cache: properly translate DM_THIN_DISCARDS

DM status uses DM defines which need to be translated to LVM enum.
---
 lib/metadata/lv.c |   17 ++++++++++++++---
 1 files changed, 14 insertions(+), 3 deletions(-)

diff --git a/lib/metadata/lv.c b/lib/metadata/lv.c
index a7e1dcd..8c33a5e 100644
--- a/lib/metadata/lv.c
+++ b/lib/metadata/lv.c
@@ -227,12 +227,23 @@ char *lvseg_kernel_discards_dup_with_info_and_seg_status(struct dm_pool *mem, co
 {
 	const char *s = "";
 	char *ret;
+	thin_discards_t d;
 
-	if (lvdm->seg_status.type == SEG_STATUS_THIN_POOL)
-		s = get_pool_discards_name(lvdm->seg_status.thin_pool->discards);
+	if (lvdm->seg_status.type == SEG_STATUS_THIN_POOL) {
+		switch (lvdm->seg_status.thin_pool->discards) {
+		case DM_THIN_DISCARDS_IGNORE: d = THIN_DISCARDS_IGNORE; break;
+		case DM_THIN_DISCARDS_NO_PASSDOWN: d = THIN_DISCARDS_NO_PASSDOWN; break;
+		case DM_THIN_DISCARDS_PASSDOWN: d = THIN_DISCARDS_PASSDOWN; break;
+		default:
+			log_error("Kernel reports unknown discards status %u.",
+				  lvdm->seg_status.thin_pool->discards);
+			return 0;
+		}
+		s = get_pool_discards_name(d);
+	}
 
 	if (!(ret = dm_pool_strdup(mem, s))) {
-		log_error("lvseg_kernel_discards_dup_with_info_and_seg_status: dm_pool_strdup failed");
+		log_error("lvseg_kernel_discards_dup_with_info_and_seg_status: dm_pool_strdup failed.");
 		return NULL;
 	}
 


