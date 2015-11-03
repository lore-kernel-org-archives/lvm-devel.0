From: David Teigland <teigland@fedoraproject.org>
Date: Tue,  3 Nov 2015 19:39:41 +0000 (UTC)
Subject: master - lvmcache: change log_verbose to log_warn
Message-ID: <20151103193941.516C860D5E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=4103896ca02045d1ac13c788031a27e316b0c47a
Commit:        4103896ca02045d1ac13c788031a27e316b0c47a
Parent:        d30105f4712d83c89da2e82bb6f5d22dd599a94d
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Oct 15 16:35:40 2015 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Nov 3 13:37:31 2015 -0600

lvmcache: change log_verbose to log_warn

Without this, some cases miss printing a
warning for duplicate PVs.
---
 lib/cache/lvmcache.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index 31f2aa9..8ab1a31 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -1784,9 +1784,9 @@ struct lvmcache_info *lvmcache_add(struct labeller *labeller, const char *pvid,
 				 * been chosen during a previous populating of
 				 * lvmcache, so just use the existing preferences.
 				 */
-				log_verbose("Found duplicate PV %s: using existing dev %s",
-					    pvid_s,
-					    dev_name(existing->dev));
+				log_warn("Found duplicate PV %s: using existing dev %s",
+					 pvid_s,
+					 dev_name(existing->dev));
 				return NULL;
 			}
 


