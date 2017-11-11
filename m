From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 10 Nov 2017 19:03:22 -0500
Subject: master - lv_lock_holder: unused cache-pool is not lock holder
Message-ID: <201711110003.vAB03MEC009602@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=dd06a0a4a68d5619050da76acdd508a89390d5f2
Commit:        dd06a0a4a68d5619050da76acdd508a89390d5f2
Parent:        52cee9dd83da0b9b6766a4b3ee6bdd3699bf4346
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Nov 11 00:18:22 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Nov 11 00:59:46 2017 +0100

lv_lock_holder: unused cache-pool is not lock holder

Unused cache-pool is only a constainer for data and metadata,
and does not present localble entity.
---
 lib/metadata/lv.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/lib/metadata/lv.c b/lib/metadata/lv.c
index e50b2bb..4d35efe 100644
--- a/lib/metadata/lv.c
+++ b/lib/metadata/lv.c
@@ -1613,6 +1613,9 @@ const struct logical_volume *lv_lock_holder(const struct logical_volume *lv)
 			continue; /* Skip thin snaphost */
 		if (lv_is_pending_delete(sl->seg->lv))
 			continue; /* Skip deleted LVs */
+		if (lv_is_cache_pool(sl->seg->lv) &&
+		    !lv_is_used_cache_pool(sl->seg->lv))
+			continue; /* Skip unused cache-pool */
 		return lv_lock_holder(sl->seg->lv);
 	}
 


