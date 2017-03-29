From: Bryn Reeves <bmr@sourceware.org>
Date: Wed, 29 Mar 2017 16:16:33 -0400
Subject: master - dmfilemapd: free region table at end of _update_regions() (coverity)
Message-ID: <201703292016.v2TKGXi6000829@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=13426092e9681d13acfa9eae505b20537c236340
Commit:        13426092e9681d13acfa9eae505b20537c236340
Parent:        f66bc3dab07f3394150536819943a5c31ce793bf
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Wed Mar 29 17:33:23 2017 +0100
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Wed Mar 29 18:34:24 2017 +0100

dmfilemapd: free region table at end of _update_regions() (coverity)

---
 daemons/dmfilemapd/dmfilemapd.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/daemons/dmfilemapd/dmfilemapd.c b/daemons/dmfilemapd/dmfilemapd.c
index 2fa51ee..dd1db03 100644
--- a/daemons/dmfilemapd/dmfilemapd.c
+++ b/daemons/dmfilemapd/dmfilemapd.c
@@ -687,7 +687,7 @@ static int _update_regions(struct dm_stats *dms, struct filemap_monitor *fm)
 			 fm->group_id, regions[0]);
 		fm->group_id = regions[0];
 	}
-
+	dm_free(regions);
 	fm->nr_regions = nr_regions;
 	return 1;
 }


