From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 30 Jun 2017 15:13:50 -0400
Subject: master - raid: ensure enum is defined
Message-ID: <201706301913.v5UJDoFJ030818@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=ad286a32275283f018adabbf96d569d5c1fd065a
Commit:        ad286a32275283f018adabbf96d569d5c1fd065a
Parent:        c31614eccc41746734e712143d0f86c96f95dd4c
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jun 30 19:34:52 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jun 30 20:39:02 2017 +0200

raid: ensure enum is defined

Just making sure enum is always defined.

TODO: code path using this enum needs closer inspection.
---
 lib/metadata/raid_manip.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 110a7d3..df7e062 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -2232,7 +2232,7 @@ static int _raid_reshape(struct logical_volume *lv,
 	int force_repair = 0, r, too_few = 0;
 	unsigned devs_health, devs_in_sync;
 	uint32_t new_image_count, old_image_count;
-	enum alloc_where where_it_was;
+	enum alloc_where where_it_was = alloc_none;
 	struct lv_segment *seg = first_seg(lv);
 	struct dm_list removal_lvs;
 


