From: David Teigland <teigland@sourceware.org>
Date: Mon, 30 Aug 2021 18:57:00 +0000 (GMT)
Subject: main - cov: lvmlockd read_adopt_file free structs on error path
Message-ID: <20210830185700.74B1B385842E@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=62c599f78151e65105c92c87ac406e3f3f360b1a
Commit:        62c599f78151e65105c92c87ac406e3f3f360b1a
Parent:        350f8845bd39dd7aaf5a52ad5deff6859fd06568
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Aug 30 13:48:42 2021 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Aug 30 13:48:42 2021 -0500

cov: lvmlockd read_adopt_file free structs on error path

---
 daemons/lvmlockd/lvmlockd-core.c | 11 +++++++++--
 1 file changed, 9 insertions(+), 2 deletions(-)

diff --git a/daemons/lvmlockd/lvmlockd-core.c b/daemons/lvmlockd/lvmlockd-core.c
index fef9589b9..c570b9d14 100644
--- a/daemons/lvmlockd/lvmlockd-core.c
+++ b/daemons/lvmlockd/lvmlockd-core.c
@@ -965,13 +965,16 @@ static int read_adopt_file(struct list_head *vg_lockd)
 
 			if (sscanf(adopt_line, "VG: %63s %64s %15s %64s",
 				   vg_uuid, ls->vg_name, lm_type_str, ls->vg_args) != 4) {
+				free(ls);
 				goto fail;
 			}
 
 			memcpy(ls->vg_uuid, vg_uuid, 64);
 
-			if ((ls->lm_type = str_to_lm(lm_type_str)) < 0)
+			if ((ls->lm_type = str_to_lm(lm_type_str)) < 0) {
+				free(ls);
 				goto fail;
+			}
 
 			list_add(&ls->list, vg_lockd);
 
@@ -986,11 +989,14 @@ static int read_adopt_file(struct list_head *vg_lockd)
 
 			if (sscanf(adopt_line, "LV: %64s %64s %s %7s %u",
 				   vg_uuid, r->name, r->lv_args, mode, &r->version) != 5) {
+				free_resource(r);
 				goto fail;
 			}
 
-			if ((r->adopt_mode = str_to_mode(mode)) == LD_LK_IV)
+			if ((r->adopt_mode = str_to_mode(mode)) == LD_LK_IV) {
+				free_resource(r);
 				goto fail;
+			}
 
 			if (ls && !memcmp(ls->vg_uuid, vg_uuid, 64)) {
 				list_add(&r->list, &ls->resources);
@@ -1007,6 +1013,7 @@ static int read_adopt_file(struct list_head *vg_lockd)
 
 			if (r) {
 				log_error("No lockspace found for resource %s vg_uuid %s", r->name, vg_uuid);
+				free_resource(r);
 				goto fail;
 			}
 		}


