From: tasleson <tasleson@fedoraproject.org>
Date: Thu, 28 Jul 2016 16:19:01 +0000 (UTC)
Subject: master - lvmdbusd: Add '-y' to lvconvert for lv cache create
Message-ID: <20160728161901.60E2560B3D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=4bc351d65879f319cf94cc59ff781ca3d649060f
Commit:        4bc351d65879f319cf94cc59ff781ca3d649060f
Parent:        20b21f4fd85532bd63a699aac4fc34f5786cf96d
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Wed Jul 27 18:43:27 2016 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Thu Jul 28 11:13:29 2016 -0500

lvmdbusd: Add '-y' to lvconvert for lv cache create

When converting to a cache lv, tests were hanging with a prompt for
"Do you want wipe existing metadata of cache pool volume
To preserve cache metadata add option "--zero n".
WARNING: Reusing mismatched cache pool metadata MAY DESTROY YOUR DATA!"

This is new.
---
 daemons/lvmdbusd/cmdhandler.py |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/daemons/lvmdbusd/cmdhandler.py b/daemons/lvmdbusd/cmdhandler.py
index 391757d..fac582c 100644
--- a/daemons/lvmdbusd/cmdhandler.py
+++ b/daemons/lvmdbusd/cmdhandler.py
@@ -411,7 +411,7 @@ def lv_cache_lv(cache_pool_full_name, lv_full_name, cache_options):
 	# lvconvert --type cache --cachepool VG/CachePoolLV VG/OriginLV
 	cmd = ['lvconvert']
 	cmd.extend(options_to_cli_args(cache_options))
-	cmd.extend(['--type', 'cache', '--cachepool',
+	cmd.extend(['-y', '--type', 'cache', '--cachepool',
 				cache_pool_full_name, lv_full_name])
 	return call(cmd)
 


