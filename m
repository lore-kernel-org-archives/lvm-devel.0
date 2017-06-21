From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 21 Jun 2017 06:36:50 -0400
Subject: master - raid: drop debug code
Message-ID: <201706211036.v5LAaoBa021036@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=31d153ced07dda004cff3a67a6e9a740b52253fd
Commit:        31d153ced07dda004cff3a67a6e9a740b52253fd
Parent:        49fa2bea1c82c4763fb87785683040fc0fe093d7
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Jun 21 11:09:47 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Jun 21 12:35:16 2017 +0200

raid: drop debug code

---
 lib/metadata/raid_manip.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index d3bbb60..ab89bdf 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -562,7 +562,6 @@ static int _lv_update_reload_fns_reset_eliminate_lvs(struct logical_volume *lv,
 				     display_lvname(lv), display_lvname(lock_lv));
 		origin_only = 0;
 	}
-	origin_only = 0;
 
 	/* TODO/FIXME:  this function should be simplified to just call
 	 * lv_update_and_reload() and cleanup of remained LVs */


