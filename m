From: Bryn Reeves <bmr@fedoraproject.org>
Date: Fri,  9 Dec 2016 16:04:26 +0000 (UTC)
Subject: master - libdm-stats: clear dms->regions in _stats_regions_destroy()
Message-ID: <20161209160426.5E97660C9D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=cb8c04760f73b0376a909440da9c20f78694ea4e
Commit:        cb8c04760f73b0376a909440da9c20f78694ea4e
Parent:        900d203586faf1fef447002aa2e784cfc9575ad1
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Fri Dec 9 15:47:55 2016 +0000
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Fri Dec 9 16:04:13 2016 +0000

libdm-stats: clear dms->regions in _stats_regions_destroy()

---
 libdm/libdm-stats.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/libdm/libdm-stats.c b/libdm/libdm-stats.c
index 411fd80..41adf42 100644
--- a/libdm/libdm-stats.c
+++ b/libdm/libdm-stats.c
@@ -347,6 +347,7 @@ static void _stats_regions_destroy(struct dm_stats *dms)
 	}
 
 	dm_pool_free(mem, dms->regions);
+	dms->regions = NULL;
 }
 
 static void _stats_group_destroy(struct dm_stats_group *group)


