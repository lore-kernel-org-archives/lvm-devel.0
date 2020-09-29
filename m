From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 29 Sep 2020 08:45:28 +0000 (GMT)
Subject: master - debug: remove stacktrace on regular path
Message-ID: <20200929084528.9D770384B010@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=6728788bf5b7327a167675e99a1e00c168c6c563
Commit:        6728788bf5b7327a167675e99a1e00c168c6c563
Parent:        0c89c5a40f8aeda6939a9596615c5d5c1471f352
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Sep 26 14:52:27 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Sep 29 10:43:56 2020 +0200

debug: remove stacktrace on regular path

Here _insert is expected to also fail, so just regular 'return 0'.
---
 lib/device/dev-cache.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/lib/device/dev-cache.c b/lib/device/dev-cache.c
index 7f5e55e8c..84d65c4db 100644
--- a/lib/device/dev-cache.c
+++ b/lib/device/dev-cache.c
@@ -1158,13 +1158,13 @@ static int _insert(const char *path, const struct stat *info,
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


