From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Fri, 30 Apr 2010 11:07:21 +0200
Subject: [PATCH 3/3] Fix internal error for errornous regex insert
In-Reply-To: <cover.1272618315.git.zkabelac@redhat.com>
References: <cover.1272618315.git.zkabelac@redhat.com>
Message-ID: <0d6e9e51fc54fe270335af224c85ffb8d7dd53c6.1272618315.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Fix error message shown for incorrect regex in config file:

'Internal error: _vginfos list should be empty'

When regex parser fails lvmcache_init() is not invoked - thus
_vginfos list is not initiliased.

To fix this problem  '_vgname_hash' pointer is reused as a sign of properly
processed initializion and only in this case list is checked for
being empty and updated error message is printed in this case.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/cache/lvmcache.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index 73102ec..2c81e18 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -1356,6 +1356,10 @@ void lvmcache_destroy(struct cmd_context *cmd, int retain_orphans)
 		_pvid_hash = NULL;
 	}
 
+	if (_vgname_hash && !dm_list_empty(&_vginfos))
+		log_error(INTERNAL_ERROR "List _vginfos should be empty.");
+	dm_list_init(&_vginfos);
+
 	if (_vgname_hash) {
 		dm_hash_iter(_vgname_hash,
 			  (dm_hash_iterate_fn) _lvmcache_destroy_vgnamelist);
@@ -1370,10 +1374,6 @@ void lvmcache_destroy(struct cmd_context *cmd, int retain_orphans)
 		_lock_hash = NULL;
 	}
 
-	if (!dm_list_empty(&_vginfos))
-		log_error(INTERNAL_ERROR "_vginfos list should be empty");
-	dm_list_init(&_vginfos);
-
 	if (retain_orphans)
 		init_lvmcache_orphans(cmd);
 }
-- 
1.7.0.1


