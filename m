From: Bryn Reeves <bmr@fedoraproject.org>
Date: Sat, 15 Aug 2015 17:35:57 +0000 (UTC)
Subject: master - dmstats: fix --length argument
Message-ID: <20150815173557.66CE560EE4@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=4a6d5e2012cbcf40842b5ef051347694bbf5ca04
Commit:        4a6d5e2012cbcf40842b5ef051347694bbf5ca04
Parent:        9d5cd4ca14a94d83bf7b3c0b73896abc4ff8926c
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Sat Aug 15 16:51:31 2015 +0100
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Sat Aug 15 18:35:10 2015 +0100

dmstats: fix --length argument

Commit f10ad95 introduced a regression causing the size of regions
passed in on the command line to be truncated to zero. Initialise
the 'this_len' variable to the supplied length to correct this.
---
 tools/dmsetup.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index ee1e1fe..097f1fd 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -4456,7 +4456,7 @@ static int _do_stats_create_regions(struct dm_stats *dms,
 				    const char *program_id,
 				    const char *aux_data)
 {
-	uint64_t this_start = 0, this_len = 0, region_id = UINT64_C(0);
+	uint64_t this_start = 0, this_len = len, region_id = UINT64_C(0);
 	char *target_type, *params; /* unused */
 	struct dm_task *dmt;
 	struct dm_info info;


