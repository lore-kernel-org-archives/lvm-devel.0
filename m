From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 19 Aug 2022 12:58:49 +0000 (GMT)
Subject: main - mm: remove libaio from being skipped
Message-ID: <20220819125849.97FCE3858CDA@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a3eb6ba425773224076c41aabc3c490a6a016ee6
Commit:        a3eb6ba425773224076c41aabc3c490a6a016ee6
Parent:        e26c21cb8d5841141dcfdfc77f46da1108a81255
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Aug 18 14:31:27 2022 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Aug 19 14:56:57 2022 +0200

mm: remove libaio from being skipped

Since libaio is now used also in critical section,
keep the libaio locked in memory.
---
 lib/mm/memlock.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/lib/mm/memlock.c b/lib/mm/memlock.c
index 3d1a3927c..f43bacdcd 100644
--- a/lib/mm/memlock.c
+++ b/lib/mm/memlock.c
@@ -105,7 +105,6 @@ static const char * const _blacklist_maps[] = {
 	"/LC_MESSAGES/",
 	"gconv/gconv-modules.cache",
 	"/ld-2.",		/* not using dlopen,dlsym during mlock */
-	"/libaio.so.",		/* not using aio during mlock */
 	"/libattr.so.",		/* not using during mlock (udev) */
 	"/libblkid.so.",	/* not using blkid during mlock (udev) */
 	"/libbz2.so.",		/* not using during mlock (udev) */

