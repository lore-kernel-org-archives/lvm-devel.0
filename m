From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Sun, 18 Oct 2020 21:02:19 +0000 (GMT)
Subject: stable-2.02 - wipe: convert zero_value to uint8_t
Message-ID: <20201018210219.0F26D3857C6F@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=ba69c433c109298d4e54ebad1d5ad4ac87af09eb
Commit:        ba69c433c109298d4e54ebad1d5ad4ac87af09eb
Parent:        9bddffd7adf75d8f63041dfeb9b73a783757b43d
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Sep 15 16:40:53 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Oct 16 23:14:45 2020 +0200

wipe: convert zero_value to uint8_t

We always write this value as byte.
---
 lib/metadata/metadata-exported.h | 4 ++--
 lib/metadata/mirror.c            | 4 ++--
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 4833d59d1..f64f53f86 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -774,9 +774,9 @@ struct logical_volume *lv_create_empty(const char *name,
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
index 068ebd2c5..7cc786ac2 100644
--- a/lib/metadata/mirror.c
+++ b/lib/metadata/mirror.c
@@ -364,8 +364,8 @@ static int _init_mirror_log(struct cmd_context *cmd,
 
 	if (activation()) {
 		if (!wipe_lv(log_lv, (struct wipe_params)
-			     { .do_zero = 1, .zero_sectors = log_lv->size,
-			       .zero_value = in_sync ? -1 : 0 })) {
+			     { .zero_sectors = log_lv->size, .do_zero = 1,
+			       .zero_value = in_sync ? 0xff : 0 })) {
 			log_error("Aborting. Failed to wipe mirror log.");
 			goto deactivate_and_revert_new_lv;
 		}


