From: Marian Csontos <mcsontos@sourceware.org>
Date: Tue, 5 Mar 2019 08:53:55 -0500
Subject: stable-2.02 - stats: initilize regions to NULL
Message-ID: <201903051353.x25Drt4B006817@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=167aa349268008b47e333ce9e5423e06bb29d95f
Commit:        167aa349268008b47e333ce9e5423e06bb29d95f
Parent:        8fc64c5ee67c90ac33df657ec514216ce2a804b9
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Dec 21 22:42:36 2018 +0100
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Tue Mar 5 12:57:50 2019 +0100

stats: initilize regions to NULL

Commit 3750b0cff5ab1c41076afdf8275e3fa20aa756d0 used bad: error
path in more occasions thus it now needs regions defined as NULL.

(cherry picked from commit 83c6f7e7e6e76199d836bf694266c78e3cbc12f1)
---
 libdm/libdm-stats.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/libdm/libdm-stats.c b/libdm/libdm-stats.c
index deb20c9..df4322a 100644
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


