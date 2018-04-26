From: David Teigland <teigland@sourceware.org>
Date: Thu, 26 Apr 2018 15:58:14 -0400
Subject: master - scan: refresh filters before scan
Message-ID: <201804261958.w3QJwEcU022929@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=cdb8400de2d89e2e5901524acdd2178118d740b7
Commit:        cdb8400de2d89e2e5901524acdd2178118d740b7
Parent:        1c97fda42576367e263f8c928c060271787ad1c1
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Apr 26 14:48:13 2018 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Apr 26 14:48:13 2018 -0500

scan: refresh filters before scan

The filters save information about devices that should
be ignored, so if we need to repeat a scan  (unusual,
but happens in clvmd), we need to update the filters.
---
 lib/cache/lvmcache.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index 7534567..e88d350 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -1251,6 +1251,9 @@ int lvmcache_label_scan(struct cmd_context *cmd)
 		goto out;
 	}
 
+	if (!refresh_filters(cmd))
+		log_error("Scan failed to refresh device filter.");
+
 	/*
 	 * Duplicates found during this label scan are added to _found_duplicate_devs().
 	 */


