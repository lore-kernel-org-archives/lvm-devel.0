From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 23 Feb 2016 11:26:02 +0000 (UTC)
Subject: master - cache: enforce header check
Message-ID: <20160223112602.657E460D10@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=293aabe4cd43a80fa94d7adb009fb8ab6c9d3641
Commit:        293aabe4cd43a80fa94d7adb009fb8ab6c9d3641
Parent:        f501f083bf1ea9f60a8b18aa9b5d59f3459ee4a6
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Feb 23 12:15:42 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Feb 23 12:25:25 2016 +0100

cache: enforce header check

Currently it's been checked for 'zero' header for thin-pool,
but lets use it always for cache as well - since it's relatively 'cheap'
detection of read 'error' problems as thin/cache tools
currently do not work fast enough in this case.
---
 WHATS_NEW                  |    1 +
 lib/activate/dev_manager.c |    2 +-
 2 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 355712c..8c11277 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.144 - 
 =====================================
+  Use uninitilized pool header detection in all cases.
   Fir read error detection when checking for uninitialized thin-pool header.
   Fix error path for internal error in lvmetad vg lookup code.
 
diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 15d6bb9..fbb0688 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -1916,7 +1916,7 @@ static int _pool_register_callback(struct dev_manager *dm,
 		data->global = "thin";
 	} else if (lv_is_cache(lv)) { /* cache pool */
 		data->pool_lv = first_seg(lv)->pool_lv;
-		data->skip_zero = dm->activation;
+		data->skip_zero = 1; /* cheap read-error detection */
 		data->exec = global_cache_check_executable_CFG;
 		data->opts = global_cache_check_options_CFG;
 		data->global = "cache";


