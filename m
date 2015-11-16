From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 16 Nov 2015 00:17:12 +0000 (UTC)
Subject: master - cleanup: simplify dev_cache_exit
Message-ID: <20151116001712.7B905601DE@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=dccbc3b621cdac035802cb9f60438a389acadcad
Commit:        dccbc3b621cdac035802cb9f60438a389acadcad
Parent:        5a4676fea9808f348b9bbda46c03dce298eef6e5
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Dec 6 23:56:14 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Nov 16 01:16:11 2015 +0100

cleanup: simplify dev_cache_exit

Just set whole _cache struct into unitialized state just
like with lib init start usage.
Lists are initialized with dev_cache_init().
---
 lib/device/dev-cache.c |   16 +++-------------
 1 files changed, 3 insertions(+), 13 deletions(-)

diff --git a/lib/device/dev-cache.c b/lib/device/dev-cache.c
index 185b394..7626ceb 100644
--- a/lib/device/dev-cache.c
+++ b/lib/device/dev-cache.c
@@ -819,23 +819,13 @@ int dev_cache_exit(void)
 		if ((num_open = _check_for_open_devices(1)) > 0)
 			log_error(INTERNAL_ERROR "%d device(s) were left open and have been closed.", num_open);
 
-	if (_cache.preferred_names_matcher)
-		_cache.preferred_names_matcher = NULL;
-
-	if (_cache.mem) {
+	if (_cache.mem)
 		dm_pool_destroy(_cache.mem);
-		_cache.mem = NULL;
-	}
 
-	if (_cache.names) {
+	if (_cache.names)
 		dm_hash_destroy(_cache.names);
-		_cache.names = NULL;
-	}
 
-	_cache.devices = NULL;
-	_cache.has_scanned = 0;
-	dm_list_init(&_cache.dirs);
-	dm_list_init(&_cache.files);
+	memset(&_cache, 0, sizeof(_cache));
 
 	return (!num_open);
 }


