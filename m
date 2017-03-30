From: Bryn Reeves <bmr@sourceware.org>
Date: Thu, 30 Mar 2017 05:04:32 -0400
Subject: master - libdm: use size_t for buflen in _stats_group_file_regions()
Message-ID: <201703300904.v2U94WxR019985@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b823646aced03e49eb7f42aa9872d7e31f3fa1a4
Commit:        b823646aced03e49eb7f42aa9872d7e31f3fa1a4
Parent:        833b02106d448dcec7a3e9ff23a8ec2cdc5bb3ab
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Wed Mar 29 20:46:21 2017 +0100
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Thu Mar 30 10:02:45 2017 +0100

libdm: use size_t for buflen in _stats_group_file_regions()

---
 libdm/libdm-stats.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/libdm/libdm-stats.c b/libdm/libdm-stats.c
index 2e6022d..2a6c343 100644
--- a/libdm/libdm-stats.c
+++ b/libdm/libdm-stats.c
@@ -4219,7 +4219,7 @@ static int _stats_group_file_regions(struct dm_stats *dms, uint64_t *region_ids,
 	dm_bitset_t regions = dm_bitset_create(NULL, dms->nr_regions);
 	uint64_t i, group_id = DM_STATS_GROUP_NOT_PRESENT;
 	char *members = NULL;
-	int buflen;
+	size_t buflen;
 
 	if (!regions) {
 		log_error("Cannot map file: failed to allocate group bitmap.");


