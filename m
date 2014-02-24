From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 24 Feb 2014 20:17:14 +0000 (UTC)
Subject: master - cleanup: spelling
Message-ID: <20140224201714.989FF60FC0@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=0118d6aa48c5d69b7b5f264f6f93ddb51a4379ad
Commit:        0118d6aa48c5d69b7b5f264f6f93ddb51a4379ad
Parent:        710c0df68a74c8da03eba62b43ae9080dd4a6ffe
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Feb 22 00:23:59 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Feb 24 21:13:35 2014 +0100

cleanup: spelling

---
 lib/cache/lvmcache.c |    4 ++--
 tools/lvcreate.c     |    2 +-
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index ec8699b..d40bdce 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -264,9 +264,9 @@ static void _drop_metadata(const char *vgname, int drop_precommitted)
 }
 
 /*
- * Remote node uses this to upgrade precommited metadata to commited state
+ * Remote node uses this to upgrade precommitted metadata to commited state
  * when receives vg_commit notification.
- * (Note that devices can be suspended here, if so, precommited metadata are already read.)
+ * (Note that devices can be suspended here, if so, precommitted metadata are already read.)
  */
 void lvmcache_commit_metadata(const char *vgname)
 {
diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index 6da0d61..19df387 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -683,7 +683,7 @@ static int _read_raid_params(struct lvcreate_params *lp,
 
 	if (lp->max_recovery_rate &&
 	    (lp->max_recovery_rate < lp->min_recovery_rate)) {
-		log_error("Minumum recovery rate cannot be higher than maximum.");
+		log_error("Minimum recovery rate cannot be higher than maximum.");
 		return 0;
 	}
 	return 1;


