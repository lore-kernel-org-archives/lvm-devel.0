From: Bryn Reeves <bmr@fedoraproject.org>
Date: Fri,  9 Dec 2016 16:04:28 +0000 (UTC)
Subject: master - libdm-stats: clear dms->groups in _stats_groups_destroy()
Message-ID: <20161209160428.749B760C9D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=7fd2fa22ddb3ed97283305100567cc4b5122ddb3
Commit:        7fd2fa22ddb3ed97283305100567cc4b5122ddb3
Parent:        cb8c04760f73b0376a909440da9c20f78694ea4e
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Fri Dec 9 15:49:06 2016 +0000
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Fri Dec 9 16:04:13 2016 +0000

libdm-stats: clear dms->groups in _stats_groups_destroy()

---
 libdm/libdm-stats.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/libdm/libdm-stats.c b/libdm/libdm-stats.c
index 41adf42..3900433 100644
--- a/libdm/libdm-stats.c
+++ b/libdm/libdm-stats.c
@@ -378,6 +378,7 @@ static void _stats_groups_destroy(struct dm_stats *dms)
 	for (i = dms->max_region; (i != DM_STATS_REGION_NOT_PRESENT); i--)
 		_stats_group_destroy(&dms->groups[i]);
 	dm_pool_free(dms->group_mem, dms->groups);
+	dms->groups = NULL;
 }
 
 static int _set_stats_device(struct dm_stats *dms, struct dm_task *dmt)


