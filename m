From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue,  1 Apr 2014 19:30:37 +0000 (UTC)
Subject: master - cache: enforce local exlusive activation
Message-ID: <20140401193037.4FF8C60CB7@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c2876ee1c9086bd4c0a8e898e05919cfcb6aded7
Commit:        c2876ee1c9086bd4c0a8e898e05919cfcb6aded7
Parent:        c95d43b28c5f89e1d96f2b16805ecd74eb4b02fb
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Apr 1 21:29:28 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Apr 1 21:29:28 2014 +0200

cache: enforce local exlusive activation

For cache flushing local exlusive activation is needed.
---
 lib/metadata/cache_manip.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/lib/metadata/cache_manip.c b/lib/metadata/cache_manip.c
index b71e9e0..9a055e8 100644
--- a/lib/metadata/cache_manip.c
+++ b/lib/metadata/cache_manip.c
@@ -191,8 +191,9 @@ int lv_cache_remove(struct logical_volume *cache_lv)
 	}
 
 	/* Active volume is needed (writeback only?) */
-	if (!activate_lv(cache_lv->vg->cmd, cache_lv)) {
-		log_error("Failed to active cache %s.", cache_lv->name);
+	if (!lv_is_active_locally(cache_lv) &&
+	    !activate_lv_excl_local(cache_lv->vg->cmd, cache_lv)) {
+		log_error("Failed to active cache locally %s.", cache_lv->name);
 		return 0;
 	}
 


