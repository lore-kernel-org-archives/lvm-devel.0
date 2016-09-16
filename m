From: Bryn Reeves <bmr@fedoraproject.org>
Date: Fri, 16 Sep 2016 12:09:27 +0000 (UTC)
Subject: master - libdm: fix end-of-groups test in _stats_walk_end()
Message-ID: <20160916120927.54E7060F0C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c26cd4853668f1da94eb98e18d7a52c93fd21197
Commit:        c26cd4853668f1da94eb98e18d7a52c93fd21197
Parent:        9c8c8fb63abd1a36b9c448450c9cccfac4c0299e
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Fri Sep 16 13:08:30 2016 +0100
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Fri Sep 16 13:09:22 2016 +0100

libdm: fix end-of-groups test in _stats_walk_end()

---
 libdm/libdm-stats.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/libdm/libdm-stats.c b/libdm/libdm-stats.c
index 6932b28..ffd349c 100644
--- a/libdm/libdm-stats.c
+++ b/libdm/libdm-stats.c
@@ -1543,7 +1543,7 @@ static int _stats_walk_end(const struct dm_stats *dms, uint64_t *flags,
 	}
 
 	if (*flags & DM_STATS_WALK_GROUP) {
-		if (*cur_g < dms->max_region)
+		if (*cur_g <= dms->max_region)
 			goto out;
 		*flags &= ~DM_STATS_WALK_GROUP;
 	}


