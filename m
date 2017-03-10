From: Bryn Reeves <bmr@sourceware.org>
Date: Fri, 10 Mar 2017 06:47:41 -0500
Subject: master - libdm: move initialisation of group_id in _aggregate_histogram()
Message-ID: <201703101147.v2ABlflL021595@int-mx13.intmail.prod.int.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=146b2582b05b3b4b0f25296620ed2c2ca9e0f467
Commit:        146b2582b05b3b4b0f25296620ed2c2ca9e0f467
Parent:        97b6486b2703d8b4d7584caf24f16686dbb9dde2
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Fri Mar 10 11:45:08 2017 +0000
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Fri Mar 10 11:45:08 2017 +0000

libdm: move initialisation of group_id in _aggregate_histogram()

Older compilers are not able to determine that although group_id
is only assigned in one branch of a conditional, it is never used
used when the other branch is taken:

  libdm-stats.c:3319: warning: "group_id" may be used uninitialized in this function

Avoid this by always initialising the variable when it is
declared.
---
 libdm/libdm-stats.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/libdm/libdm-stats.c b/libdm/libdm-stats.c
index 616c6bb..cff23d8 100644
--- a/libdm/libdm-stats.c
+++ b/libdm/libdm-stats.c
@@ -3315,8 +3315,8 @@ static struct dm_histogram *_aggregate_histogram(const struct dm_stats *dms,
 						 uint64_t area_id)
 {
 	struct dm_histogram *dmh_aggr, *dmh_cur, **dmh_cachep;
+	uint64_t group_id = DM_STATS_GROUP_NOT_PRESENT;
 	int bin, nr_bins, group = 1;
-	uint64_t group_id;
 	size_t hist_size;
 
 	if (area_id == DM_STATS_WALK_REGION) {


