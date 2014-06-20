From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 20 Jun 2014 09:38:48 +0000 (UTC)
Subject: master - lv: fix lv_is_raid
Message-ID: <20140620093848.D043E600E1@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f96a499c8d4ad784ccd7a15061e71b16342de104
Commit:        f96a499c8d4ad784ccd7a15061e71b16342de104
Parent:        93597bcbdc791daf7308c839f245f6951900d7a7
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jun 20 11:37:45 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jun 20 11:37:45 2014 +0200

lv: fix lv_is_raid

---
 lib/metadata/lv.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/metadata/lv.c b/lib/metadata/lv.c
index 6cbab19..f1d93a9 100644
--- a/lib/metadata/lv.c
+++ b/lib/metadata/lv.c
@@ -777,7 +777,7 @@ char *lv_host_dup(struct dm_pool *mem, const struct logical_volume *lv)
 static int _lv_is_exclusive(struct logical_volume *lv)
 {
 	/* Some devices require exlusiveness */
-	return lv_is_is_raid(lv) ||
+	return lv_is_raid(lv) ||
 		lv_is_origin(lv) ||
 		lv_is_thin_type(lv) ||
 		lv_is_cache_type(lv);


