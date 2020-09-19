From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Sat, 19 Sep 2020 22:38:57 +0000 (GMT)
Subject: master - bache: fix error return value
Message-ID: <20200919223857.D729B3857C6B@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=6c769eb460c70556ba4bf2b3e6801fc846b2d4dd
Commit:        6c769eb460c70556ba4bf2b3e6801fc846b2d4dd
Parent:        6b168afcadd6ce1880223bc94829a2acac34c850
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Sep 19 23:00:50 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Sep 19 23:00:50 2020 +0200

bache: fix error return value

Return 0 as failure (as checked for).
Also add INTERNAL_ERROR if  'DI' would be -1.
---
 lib/device/bcache.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/lib/device/bcache.c b/lib/device/bcache.c
index c78445d99..fd18eef6e 100644
--- a/lib/device/bcache.c
+++ b/lib/device/bcache.c
@@ -1514,7 +1514,11 @@ void bcache_clear_fd(int di)
 int bcache_change_fd(int di, int fd)
 {
 	if (di >= _fd_table_size)
-		return -1;
+		return 0;
+	if (di < 0) {
+		log_error(INTERNAL_ERROR "Cannot change not openned DI with FD:%d", fd);
+		return 0;
+	}
 	_fd_table[di] = fd;
 	return 1;
 }


