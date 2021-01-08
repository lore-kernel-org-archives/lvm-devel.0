From: David Teigland <teigland@sourceware.org>
Date: Fri,  8 Jan 2021 18:13:20 +0000 (GMT)
Subject: main - lvmlockd: sscanf buffer size warnings
Message-ID: <20210108181320.91C1038438A3@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a4c56a3bc342ab42fdfc9c9538b3fa7feba49412
Commit:        a4c56a3bc342ab42fdfc9c9538b3fa7feba49412
Parent:        6308365d485a741d36c98060a00e95892fc3d21f
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Jan 8 11:59:28 2021 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Jan 8 12:13:05 2021 -0600

lvmlockd: sscanf buffer size warnings

---
 daemons/lvmlockd/lvmlockd-core.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/daemons/lvmlockd/lvmlockd-core.c b/daemons/lvmlockd/lvmlockd-core.c
index fea8ee6cf..c4abf66be 100644
--- a/daemons/lvmlockd/lvmlockd-core.c
+++ b/daemons/lvmlockd/lvmlockd-core.c
@@ -896,8 +896,9 @@ static int read_adopt_file(struct list_head *vg_lockd)
 				goto fail;
 
 			memset(vg_uuid, 0, sizeof(vg_uuid));
+			memset(lm_type_str, 0, sizeof(lm_type_str));
 
-			if (sscanf(adopt_line, "VG: %63s %64s %16s %64s",
+			if (sscanf(adopt_line, "VG: %63s %64s %15s %64s",
 				   vg_uuid, ls->vg_name, lm_type_str, ls->vg_args) != 4) {
 				goto fail;
 			}
@@ -916,8 +917,9 @@ static int read_adopt_file(struct list_head *vg_lockd)
 			r->type = LD_RT_LV;
 
 			memset(vg_uuid, 0, sizeof(vg_uuid));
+			memset(mode, 0, sizeof(mode));
 
-			if (sscanf(adopt_line, "LV: %64s %64s %s %8s %u",
+			if (sscanf(adopt_line, "LV: %64s %64s %s %7s %u",
 				   vg_uuid, r->name, r->lv_args, mode, &r->version) != 5) {
 				goto fail;
 			}


