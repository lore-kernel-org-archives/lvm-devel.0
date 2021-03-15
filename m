From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 15 Mar 2021 10:14:04 +0000 (GMT)
Subject: main - lv_info: missing check for info.exists
Message-ID: <20210315101404.A3F713858D29@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=5141a510bdfbf1ac8a64cc7ffd8c292c0c4b7a60
Commit:        5141a510bdfbf1ac8a64cc7ffd8c292c0c4b7a60
Parent:        3608e8aee74a5c771b96d768e6c32edc728dbca0
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Mar 11 20:38:51 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun Mar 14 16:34:38 2021 +0100

lv_info: missing check for info.exists

When &info is passed in, user needs to check for exists.
When there is NULL, return value includes check for exists.
---
 lib/mirror/mirrored.c | 4 ++--
 lib/raid/raid.c       | 5 ++---
 2 files changed, 4 insertions(+), 5 deletions(-)

diff --git a/lib/mirror/mirrored.c b/lib/mirror/mirrored.c
index 64b470a98..83f1bffcb 100644
--- a/lib/mirror/mirrored.c
+++ b/lib/mirror/mirrored.c
@@ -212,7 +212,7 @@ static int _mirrored_transient_status(struct dm_pool *mem, struct lv_segment *se
 
 	if (!strcmp(sm->log_type, "disk")) {
 		log = first_seg(lv)->log_lv;
-		if (!lv_info(lv->vg->cmd, log, 0, &info, 0, 0)) {
+		if (!lv_info(lv->vg->cmd, log, 0, &info, 0, 0) || !info.exists) {
 			log_error("Check for existence of mirror log %s failed.",
 				  display_lvname(log));
 			goto out;
@@ -235,7 +235,7 @@ static int _mirrored_transient_status(struct dm_pool *mem, struct lv_segment *se
 	}
 
 	for (i = 0; i < seg->area_count; ++i) {
-		if (!lv_info(lv->vg->cmd, seg_lv(seg, i), 0, &info, 0, 0)) {
+		if (!lv_info(lv->vg->cmd, seg_lv(seg, i), 0, &info, 0, 0) || !info.exists) {
 			log_error("Check for existence of mirror image %s failed.",
 				  seg_lv(seg, i)->name);
 			goto out;
diff --git a/lib/raid/raid.c b/lib/raid/raid.c
index a0f00637a..4bb21d758 100644
--- a/lib/raid/raid.c
+++ b/lib/raid/raid.c
@@ -402,7 +402,6 @@ static int _raid_transient_status(struct dm_pool *mem,
 {
 	int failed = 0, r = 0;
 	unsigned i;
-	struct lvinfo info;
 	struct logical_volume *lv;
 	struct dm_status_raid *sr;
 
@@ -421,7 +420,7 @@ static int _raid_transient_status(struct dm_pool *mem,
 	if (seg->meta_areas)
 		for (i = 0; i < seg->area_count; ++i) {
 			lv = seg_metalv(seg, i);
-			if (!lv_info(lv->vg->cmd, lv, 0, &info, 0, 0)) {
+			if (!lv_info(lv->vg->cmd, lv, 0, NULL, 0, 0)) {
 				log_error("Check for existence of raid meta %s failed.",
 					  display_lvname(lv));
 				goto out;
@@ -430,7 +429,7 @@ static int _raid_transient_status(struct dm_pool *mem,
 
 	for (i = 0; i < seg->area_count; ++i) {
 		lv = seg_lv(seg, i);
-		if (!lv_info(lv->vg->cmd, lv, 0, &info, 0, 0)) {
+		if (!lv_info(lv->vg->cmd, lv, 0, NULL, 0, 0)) {
 			log_error("Check for existence of raid image %s failed.",
 				  display_lvname(lv));
 			goto out;


