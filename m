From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 16 Oct 2020 19:12:06 +0000 (GMT)
Subject: stable-2.02 - debug: remove stacktrace on regular path
Message-ID: <20201016191206.F379F396ECA3@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=03bddd7d41bc644dfe6498c3b2d0d412190f2e5e
Commit:        03bddd7d41bc644dfe6498c3b2d0d412190f2e5e
Parent:        e8df5038853b927fefc83e4ae75a38411cc2d865
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Sep 26 14:52:27 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Oct 16 18:09:55 2020 +0200

debug: remove stacktrace on regular path

Here _insert is expected to also fail, so just regular 'return 0'.
---
 lib/device/dev-cache.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/lib/device/dev-cache.c b/lib/device/dev-cache.c
index 3e8105be7..de4ec65aa 100644
--- a/lib/device/dev-cache.c
+++ b/lib/device/dev-cache.c
@@ -1193,13 +1193,13 @@ static int _insert(const char *path, const struct stat *info,
 		}
 
 		if (rec && !_insert_dir(path))
-			return_0;
+			return 0;
 	} else {		/* add a device */
 		if (!S_ISBLK(info->st_mode))
 			return 1;
 
 		if (!_insert_dev(path, info->st_rdev))
-			return_0;
+			return 0;
 	}
 
 	return 1;


