From: David Teigland <teigland@fedoraproject.org>
Date: Thu,  9 Jul 2015 20:29:42 +0000 (UTC)
Subject: master - pvcreate: remove recent warning message
Message-ID: <20150709202942.7C5C260EDB@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=074295245b3f57310a2688a4628f016b17ba2f5d
Commit:        074295245b3f57310a2688a4628f016b17ba2f5d
Parent:        cb14bbdbc93a129f0ef9cf37314691b7fe79050e
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Jul 9 15:26:32 2015 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Jul 9 15:26:32 2015 -0500

pvcreate: remove recent warning message

log_warn was added recently because no known code used
the given condition, but running pvcreate on an existing
PV uses this case, and should not produce a warning.
---
 lib/cache/lvmcache.c |   10 ++++------
 1 files changed, 4 insertions(+), 6 deletions(-)

diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index d44f9d4..9f5b83a 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -1856,14 +1856,12 @@ struct lvmcache_info *lvmcache_add(struct labeller *labeller, const char *pvid,
 		}
 
 		/*
-		 * FIXME: when could this ever happen?
-		 * If this does happen, identify when/why here, and
-		 * if not, remove this code.
+		 * This happens when running pvcreate on an existing PV.
 		 */
 		if (strcmp(pvid_s, existing->dev->pvid))  {
-			log_warn("Replacing dev %s pvid %s with dev %s pvid %s",
-				 dev_name(existing->dev), existing->dev->pvid,
-				 dev_name(dev), pvid_s);
+			log_verbose("Replacing dev %s pvid %s with dev %s pvid %s",
+				    dev_name(existing->dev), existing->dev->pvid,
+				    dev_name(dev), pvid_s);
 		}
 
 		/*


