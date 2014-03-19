From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 19 Mar 2014 00:02:02 +0000 (UTC)
Subject: master - file_locking: use PATH_MAX for dir name
Message-ID: <20140319000202.26CDF61095@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a6b159e99c18905370c6cfed316f3fa1b189c7ae
Commit:        a6b159e99c18905370c6cfed316f3fa1b189c7ae
Parent:        08018a5345c98b91ce43eb55f4110485df9eb3aa
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Mar 19 00:22:18 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Mar 19 00:46:28 2014 +0100

file_locking: use PATH_MAX for dir name

Using just 128 chars for locking dir may wail if longer
dir entry is used, swich to default linux max path.
---
 WHATS_NEW                  |    1 +
 lib/locking/file_locking.c |    2 +-
 2 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index e2c196a..bbc2298 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.106 - 
 ====================================
+  Use correct PATH_MAX for locking dir path.
   Do not check for backups when when its creation is disabled.
   Don't allow --mergedconfig without --type current in dumpconfig. Fix memleak.
   Make global/lvdisplay_shows_full_device_path lvm.conf setting profilable.
diff --git a/lib/locking/file_locking.c b/lib/locking/file_locking.c
index fb84c5b..734e0b4 100644
--- a/lib/locking/file_locking.c
+++ b/lib/locking/file_locking.c
@@ -37,7 +37,7 @@ struct lock_list {
 };
 
 static struct dm_list _lock_list;
-static char _lock_dir[NAME_LEN];
+static char _lock_dir[PATH_MAX];
 static int _prioritise_write_locks;
 
 static sig_t _oldhandler;


