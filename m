From: Takahiro Yasui <tyasui@redhat.com>
Date: Thu, 02 Apr 2009 13:19:18 -0400
Subject: [RFC PATCH 2/7] rename _has_scanned to _need_scan
In-Reply-To: <49D3D9F5.902@redhat.com>
References: <49D3D9F5.902@redhat.com>
Message-ID: <49D4F396.5@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

When metadata cache is loaded into lvmcache, no device scan is necessary,
but it does not mean "has scanned". To tell lvmcache not to scan devices,
the variable name, _has_scanned, is renamed to _need_scan and its logic
is reversed.


Signed-off-by: Takahiro Yasui <tyasui@redhat.com>
---
 lib/cache/lvmcache.c |    8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

Index: LVM2.02.46-cvs-20090324/lib/cache/lvmcache.c
===================================================================
--- LVM2.02.46-cvs-20090324.orig/lib/cache/lvmcache.c
+++ LVM2.02.46-cvs-20090324/lib/cache/lvmcache.c
@@ -32,7 +32,7 @@ static struct dm_hash_table *_vgname_has
 static struct dm_hash_table *_lock_hash = NULL;
 static struct dm_list _vginfos;
 static int _scanning_in_progress = 0;
-static int _has_scanned = 0;
+static int _need_scan = 1;
 static int _vgs_locked = 0;
 static int _vg_global_lock_held = 0;	/* Global lock held when cache wiped? */
 
@@ -455,7 +455,7 @@ int lvmcache_label_scan(struct cmd_conte
 		goto out;
 	}
 
-	if (_has_scanned && !full_scan) {
+	if (!_need_scan && !full_scan) {
 		r = _scan_invalid();
 		goto out;
 	}
@@ -470,7 +470,7 @@ int lvmcache_label_scan(struct cmd_conte
 
 	dev_iter_destroy(iter);
 
-	_has_scanned = 1;
+	_need_scan = 0;
 
 	/* Perform any format-specific scanning e.g. text files */
 	dm_list_iterate_items(fmt, &cmd->formats) {
@@ -1239,7 +1239,7 @@ void lvmcache_destroy(struct cmd_context
 	struct dm_hash_node *n;
 	log_verbose("Wiping internal VG cache");
 
-	_has_scanned = 0;
+	_need_scan = 1;
 
 	if (_vgid_hash) {
 		dm_hash_destroy(_vgid_hash);







