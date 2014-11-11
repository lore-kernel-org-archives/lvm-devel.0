From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 11 Nov 2014 12:32:49 +0000 (UTC)
Subject: master - cache: no status for pending deleted cache
Message-ID: <20141111123249.CED19607BC@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=42a3305ec7aac3b1b75098c5d1ea7fa9b92a0477
Commit:        42a3305ec7aac3b1b75098c5d1ea7fa9b92a0477
Parent:        7fa7ac528d1dbbcaf424b422a462af437bcf56fb
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Nov 11 11:00:35 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Nov 11 13:32:41 2014 +0100

cache: no status for pending deleted cache

---
 lib/activate/activate.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index 2843e61..ddbebf7 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -1015,6 +1015,9 @@ int lv_cache_status(const struct logical_volume *cache_lv,
 		cache_lv = cache_seg->lv;
 	}
 
+	if (lv_is_pending_delete(cache_lv))
+		return 0;
+
 	if (!lv_info(cache_lv->vg->cmd, cache_lv, 0, NULL, 0, 0))
 		return 0;
 


