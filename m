From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 15 Sep 2020 21:21:18 +0000 (GMT)
Subject: master - wipe: convert zero_value to uint8_t
Message-ID: <20200915212118.77C8B3857828@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=d588de77aa720b31ea54594b75a1182b7e3a5255
Commit:        d588de77aa720b31ea54594b75a1182b7e3a5255
Parent:        ec4e8b5c0e33faed644e3a8b0f038181cfc69de3
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Sep 15 16:40:53 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Sep 15 22:52:25 2020 +0200

wipe: convert zero_value to uint8_t

We always write this value as byte.
---
 lib/metadata/metadata-exported.h | 4 ++--
 lib/metadata/mirror.c            | 4 ++--
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 670656a0f..b109d5b6d 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -797,9 +797,9 @@ struct logical_volume *lv_create_empty(const char *name,
 				       struct volume_group *vg);
 
 struct wipe_params {
-	int do_zero;		/* should we do zeroing of LV start? */
 	uint64_t zero_sectors;	/* sector count to zero */
-	int zero_value;		/* zero-out with this value */
+	uint8_t zero_value;	/* zero-out with this value */
+	int do_zero;		/* should we do zeroing of LV start? */
 	int do_wipe_signatures;	/* should we wipe known signatures found on LV? */
 	int yes;		/* answer yes automatically to all questions */
 	force_t force;		/* force mode */
diff --git a/lib/metadata/mirror.c b/lib/metadata/mirror.c
index d8803b3e3..c1934b5b7 100644
--- a/lib/metadata/mirror.c
+++ b/lib/metadata/mirror.c
@@ -325,8 +325,8 @@ static int _init_mirror_log(struct cmd_context *cmd,
 
 	if (activation()) {
 		if (!wipe_lv(log_lv, (struct wipe_params)
-			     { .do_zero = 1, .zero_sectors = log_lv->size,
-			       .zero_value = in_sync ? -1 : 0 })) {
+			     { .zero_sectors = log_lv->size, .do_zero = 1,
+			       .zero_value = in_sync ? 0xff : 0 })) {
 			log_error("Aborting. Failed to wipe mirror log.");
 			goto deactivate_and_revert_new_lv;
 		}


