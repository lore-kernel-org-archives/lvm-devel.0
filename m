From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 11 Apr 2016 08:35:21 +0000 (UTC)
Subject: master - devcache: index devices also without udev
Message-ID: <20160411083521.A12F060F5C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=07a60b59f789e089761170f977defbd38defacef
Commit:        07a60b59f789e089761170f977defbd38defacef
Parent:        9e14abb887c5ac2a5a7446d08eb878a22eade051
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Apr 11 10:23:16 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Apr 11 10:32:19 2016 +0200

devcache: index devices also without udev

We have _insert_dirs() for  udev and non-udev compilation.
Compiling without udev missed to call dev_cache_index_devs().
Move the call after _insert_dirs() call so both compilation
gets it.
---
 WHATS_NEW              |    4 ++++
 lib/device/dev-cache.c |    4 ++--
 2 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index bf2972f..777c44e 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,3 +1,7 @@
+Version 2.02.151
+=================================
+  Detect device mismatch also when compiling without udev support.
+
 Version 2.02.150 - 9th April 2016
 =================================
   Avoid using flushing dm status ioctl when checking for usable DM device.
diff --git a/lib/device/dev-cache.c b/lib/device/dev-cache.c
index 8461f40..84471ab 100644
--- a/lib/device/dev-cache.c
+++ b/lib/device/dev-cache.c
@@ -999,8 +999,6 @@ static void _insert_dirs(struct dm_list *dirs)
 			log_debug_devs("%s: Failed to insert devices to "
 				       "device cache fully", dl->dir);
 	}
-
-	(void) dev_cache_index_devs();
 }
 
 #else	/* UDEV_SYNC_SUPPORT */
@@ -1074,6 +1072,8 @@ static void _full_scan(int dev_scan)
 
 	_insert_dirs(&_cache.dirs);
 
+	(void) dev_cache_index_devs();
+
 	dm_list_iterate_items(dl, &_cache.files)
 		_insert_file(dl->dir);
 


