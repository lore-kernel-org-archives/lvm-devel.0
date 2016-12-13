From: Bryn Reeves <bmr@fedoraproject.org>
Date: Tue, 13 Dec 2016 20:31:57 +0000 (UTC)
Subject: master - libdm: fix dm_stats_foreach_group() macro
Message-ID: <20161213203157.18B0260659@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ea9af3e290879403d99dd602153ff9d0ad0de8de
Commit:        ea9af3e290879403d99dd602153ff9d0ad0de8de
Parent:        8e339728283d3b83222a25c7bf12b79a944c6ef5
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Tue Dec 13 15:32:34 2016 +0000
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Tue Dec 13 20:01:00 2016 +0000

libdm: fix dm_stats_foreach_group() macro

---
 libdm/libdevmapper.h |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index fe2e410..ab69a56 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -1138,9 +1138,9 @@ for (dm_stats_walk_init((dms), DM_STATS_WALK_AREA),		\
  */
 #define dm_stats_foreach_group(dms)				\
 for (dm_stats_walk_init((dms), DM_STATS_WALK_GROUP),		\
-     dm_stats_group_walk_start(dms);				\
-     !dm_stats_group_walk_end(dms);				\
-     dm_stats_group_walk_next(dms))
+     dm_stats_walk_start(dms);					\
+     !dm_stats_walk_end(dms);					\
+     dm_stats_walk_next(dms))
 
 /*
  * Start a walk iterating over the regions contained in dm_stats handle


