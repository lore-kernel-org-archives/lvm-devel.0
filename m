From: Alasdair Kergon <agk@sourceware.org>
Date: Mon, 22 May 2017 20:52:05 -0400
Subject: master - raid: Drop unnecessary/incorrect use of dm_pool_free
Message-ID: <201705230052.v4N0q5HB021949@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=57492a609410c39809960a6f32bf67e1eddb7064
Commit:        57492a609410c39809960a6f32bf67e1eddb7064
Parent:        fbe7464df5018d8ab85dd312fae8c13796eca59d
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Tue May 23 01:51:04 2017 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Tue May 23 01:51:04 2017 +0100

raid: Drop unnecessary/incorrect use of dm_pool_free

---
 lib/metadata/raid_manip.c |    3 ---
 1 files changed, 0 insertions(+), 3 deletions(-)

diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 005075c..e0e988c 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -4781,9 +4781,6 @@ static int _rename_area_lvs(struct logical_volume *lv, const char *suffix)
 			return_0;
 	}
 
-	for (s = 0; s < SLV_COUNT; s++)
-		dm_pool_free(lv->vg->cmd->mem, sfx[s]);
-
 	return 1;
 }
 


