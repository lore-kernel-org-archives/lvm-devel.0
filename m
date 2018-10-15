From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 15 Oct 2018 11:55:17 -0400
Subject: master - cov: dmstats check for failing malloc
Message-ID: <201810151555.w9FFtH02020583@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=9b7121226258f7dfe759cc1f8625cbfb80fec161
Commit:        9b7121226258f7dfe759cc1f8625cbfb80fec161
Parent:        30b1b575067bcab27ab1788247754b183387f55e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Oct 15 14:58:24 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Oct 15 17:49:44 2018 +0200

cov: dmstats check for failing malloc

Add missing check for allocation success.
---
 libdm/dm-tools/dmsetup.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/libdm/dm-tools/dmsetup.c b/libdm/dm-tools/dmsetup.c
index fb1a574..835fdcd 100644
--- a/libdm/dm-tools/dmsetup.c
+++ b/libdm/dm-tools/dmsetup.c
@@ -5224,7 +5224,10 @@ static int _do_stats_create_regions(struct dm_stats *dms,
 	if (!segments || (info.target_count == 1))
 		region_ids = &region_id;
 	else
-		region_ids = malloc(info.target_count * sizeof(*region_ids));
+		if (!(region_ids = malloc(info.target_count * sizeof(*region_ids)))) {
+			log_error("Failed to allocated region IDs.");
+			goto out;
+		}
 
 	do {
 		uint64_t segment_start, segment_len;


