From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 21 Dec 2018 17:27:00 -0500
Subject: master - stats: initilize regions to NULL
Message-ID: <201812212227.wBLMR05g004667@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=83c6f7e7e6e76199d836bf694266c78e3cbc12f1
Commit:        83c6f7e7e6e76199d836bf694266c78e3cbc12f1
Parent:        1fc5d8c4285fd42441a4f57e4c8fc242397b84f3
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Dec 21 22:42:36 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Dec 21 22:42:36 2018 +0100

stats: initilize regions to NULL

Commit 3750b0cff5ab1c41076afdf8275e3fa20aa756d0 used bad: error
path in more occasions thus it now needs regions defined as NULL.
---
 libdm/libdm-stats.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/libdm/libdm-stats.c b/libdm/libdm-stats.c
index 80cb42b..4c7fd46 100644
--- a/libdm/libdm-stats.c
+++ b/libdm/libdm-stats.c
@@ -4809,7 +4809,7 @@ uint64_t *dm_stats_update_regions_from_fd(struct dm_stats *dms, int fd,
 {
 	struct dm_histogram *bounds = NULL;
 	int nr_bins, precise, regroup;
-	uint64_t *regions, count = 0;
+	uint64_t *regions = NULL, count = 0;
 	const char *alias = NULL;
 
 	if (!dms->regions || !dm_stats_group_present(dms, group_id)) {


