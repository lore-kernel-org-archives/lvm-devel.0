From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 12 Dec 2013 13:31:03 +0000 (UTC)
Subject: master - cleanup: remove unused variable
Message-ID: <20131212133103.A60E360F9D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=fd0068a66ee8f8ad03ac0c86b9ab3f6a8a368ac9
Commit:        fd0068a66ee8f8ad03ac0c86b9ab3f6a8a368ac9
Parent:        aefab64e690cb5fbbd28a07d27a4f510d8aca32b
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Dec 12 13:59:39 2013 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Dec 12 13:59:39 2013 +0100

cleanup: remove unused variable

Recent commit made this variable unused
---
 lib/device/dev-cache.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/lib/device/dev-cache.c b/lib/device/dev-cache.c
index fabdcbb..5d26d41 100644
--- a/lib/device/dev-cache.c
+++ b/lib/device/dev-cache.c
@@ -594,7 +594,6 @@ static int _insert(const char *path, const struct stat *info,
 		   int rec, int check_with_udev_db)
 {
 	struct stat tinfo;
-	int r = 0;
 
 	if (!info) {
 		if (stat(path, &tinfo) < 0) {


