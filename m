From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 26 Oct 2020 14:21:25 +0000 (GMT)
Subject: master - gcc: cleanup warns from older gcc
Message-ID: <20201026142125.95567385703B@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=7bafae48bb7b7bf1e7adc420bf83d0c5acaf0aac
Commit:        7bafae48bb7b7bf1e7adc420bf83d0c5acaf0aac
Parent:        e793f34eb73bd4be5a37ed641f9fe11ad1a6d578
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Oct 25 21:56:02 2020 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Oct 26 13:06:53 2020 +0100

gcc: cleanup warns from older gcc

---
 lib/display/display.c   | 4 ++--
 lib/metadata/lv_manip.c | 2 +-
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/lib/display/display.c b/lib/display/display.c
index 6ef46f1e8..c0224edfb 100644
--- a/lib/display/display.c
+++ b/lib/display/display.c
@@ -407,9 +407,9 @@ int lvdisplay_full(struct cmd_context *cmd,
 	int lvm1compat;
 	dm_percent_t snap_percent;
 	int thin_pool_active = 0;
-	dm_percent_t thin_data_percent, thin_metadata_percent;
+	dm_percent_t thin_data_percent = 0, thin_metadata_percent = 0;
 	int thin_active = 0;
-	dm_percent_t thin_percent;
+	dm_percent_t thin_percent = 0;
 	struct lv_status_thin *thin_status = NULL;
 	struct lv_status_thin_pool *thin_pool_status = NULL;
 	struct lv_status_cache *cache_status = NULL;
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index e66342022..70464362e 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -8022,7 +8022,7 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 	struct logical_volume *lv, *origin_lv = NULL;
 	struct logical_volume *pool_lv = NULL;
 	struct logical_volume *tmp_lv;
-	struct lv_segment *seg, *pool_seg;
+	struct lv_segment *seg = NULL, *pool_seg;
 	int thin_pool_was_active = -1; /* not scanned, inactive, active */
 	int historical;
 	uint64_t transaction_id;


