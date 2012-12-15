From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sat, 15 Dec 2012 16:25:47 +0000 (UTC)
Subject: master - pv_read: add missing check for valid info
Message-ID: <20121215162547.75D52A0C59@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=401c9aba4a1d37d2bb05467e8860876929db9a8c
Commit:        401c9aba4a1d37d2bb05467e8860876929db9a8c
Parent:        3e8dbfaecf5168ff8717e3eebabee06c27b44fe6
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Dec 14 14:06:33 2012 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Dec 15 17:23:27 2012 +0100

pv_read: add missing check for valid info

If the lvmcache_info_from_pvid() fails to find valid
info, invoke the lookup by dev, and only in this case
call lvmcache_info_from_pvid() again.

Also check for the result of info and return
error directly, so the NULL is not passed
to lvmcache_get_label().
---
 WHATS_NEW               |    1 +
 lib/metadata/metadata.c |    7 ++++++-
 2 files changed, 7 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index b9cdfa7..106bee4 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.99 - 
 ===================================
+  Check lvmcache_info_from_pvid and recall only when needed in _pv_read.
   Check for memory failure of dm_config_write_node() in lvmetad.
   Fix socket leak on error path in lvmetad's handle_connect.
   Check for failing id_read_format() in _pv_populate_lvmcache.
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 549a356..807d06a 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -3633,8 +3633,13 @@ static struct physical_volume *_pv_read(struct cmd_context *cmd,
 						  pv_name);
 				return NULL;
 			}
+			if (!(info = lvmcache_info_from_pvid(dev->pvid, 0))) {
+				if (warnings)
+					log_error("No cache info in lvmetad cache for %s.",
+						  pv_name);
+				return NULL;
+			}
 		}
-		info = lvmcache_info_from_pvid(dev->pvid, 0);
 		label = lvmcache_get_label(info);
 	} else {
 		if (!(label_read(dev, &label, UINT64_C(0)))) {


