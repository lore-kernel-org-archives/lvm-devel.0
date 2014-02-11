From: Jonathan Brassow <jbrassow@fedoraproject.org>
Date: Tue, 11 Feb 2014 19:49:02 +0000 (UTC)
Subject: master - cache: lv_cache_create returns LV ptr, so return NULL not 0 on error
Message-ID: <20140211194902.8A8FB6133C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=48aef76ec5e4eecfce4d0926ab60317bac763eb5
Commit:        48aef76ec5e4eecfce4d0926ab60317bac763eb5
Parent:        d68e5d5ab9a27fd2dcc70097e0764d335a6e1b90
Author:        Jonathan Brassow <jbrassow@redhat.com>
AuthorDate:    Tue Feb 11 13:47:26 2014 -0600
Committer:     Jonathan Brassow <jbrassow@redhat.com>
CommitterDate: Tue Feb 11 13:47:26 2014 -0600

cache: lv_cache_create returns LV ptr, so return NULL not 0 on error

---
 lib/metadata/cache_manip.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/metadata/cache_manip.c b/lib/metadata/cache_manip.c
index a3a3608..f7518b0 100644
--- a/lib/metadata/cache_manip.c
+++ b/lib/metadata/cache_manip.c
@@ -129,7 +129,7 @@ struct logical_volume *lv_cache_create(struct logical_volume *pool,
 	seg->segtype = segtype;
 
 	if (!attach_pool_lv(seg, pool, NULL, NULL))
-		return_0;
+		return_NULL;
 
 	return cache_lv;
 }


