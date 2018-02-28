From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 28 Feb 2018 15:22:39 -0500
Subject: master - debug: change message severity
Message-ID: <201802282022.w1SKMduA009833@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=6ba94fdd816a70f084ea86ec0a3ff2243daae158
Commit:        6ba94fdd816a70f084ea86ec0a3ff2243daae158
Parent:        cc4855acbe98cea36228afeeaa6ce7f800459308
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Feb 21 14:08:17 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Feb 28 21:15:55 2018 +0100

debug: change message severity

Although it's internal issue - in this case command continue without
any reported error - thus hide this internal error into debug.
---
 lib/metadata/cache_manip.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/metadata/cache_manip.c b/lib/metadata/cache_manip.c
index 97a3339..c46266b 100644
--- a/lib/metadata/cache_manip.c
+++ b/lib/metadata/cache_manip.c
@@ -540,7 +540,7 @@ int lv_cache_remove(struct logical_volume *cache_lv)
 	}
 
 	if (lv_is_pending_delete(cache_lv)) {
-		log_error(INTERNAL_ERROR "LV %s is already dropped cache volume.",
+		log_debug(INTERNAL_ERROR "LV %s is already dropped cache volume.",
 			  display_lvname(cache_lv));
 		goto remove;  /* Already dropped */
 	}


