From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Thu, 30 Mar 2017 12:13:39 -0400
Subject: master - raid: favour dm_list_first()
Message-ID: <201703301613.v2UGDddB013423@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=c34ab29ec6c3e737b65a1b589ef4091944a5127d
Commit:        c34ab29ec6c3e737b65a1b589ef4091944a5127d
Parent:        2d75ef3b057fac5df66dee97b1cf93a582258582
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Thu Mar 30 18:13:27 2017 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Thu Mar 30 18:13:27 2017 +0200

raid: favour dm_list_first()

---
 lib/metadata/raid_manip.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index ed0f4c1..8e5b1a8 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -3091,8 +3091,7 @@ int lv_raid_split(struct logical_volume *lv, int yes, const char *split_name,
 	}
 
 	/* Get first item */
-	dm_list_iterate_items(lvl, &data_list)
-		break;
+	lvl = (struct lv_list *) dm_list_first(&data_list);
 
 	lvl->lv->name = split_name;
 


