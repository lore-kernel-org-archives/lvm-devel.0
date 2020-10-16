From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 16 Oct 2020 19:11:31 +0000 (GMT)
Subject: stable-2.02 - dev-cache: dev->bcache_fd default from 0 to -1
Message-ID: <20201016191131.84EA63857824@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=db7aef215afba518024aefea3e412f23cf7b80bd
Commit:        db7aef215afba518024aefea3e412f23cf7b80bd
Parent:        667cfeeacfae7941b662bffede86e38d425575c5
Author:        Zhao Heming <heming.zhao@suse.com>
AuthorDate:    Mon Jun 1 12:22:15 2020 -0500
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Oct 16 17:07:59 2020 +0200

dev-cache: dev->bcache_fd default from 0 to -1

This fix can avoid bcache_fd will mistakenly open/close in later.

Signed-off-by: Zhao Heming <heming.zhao@suse.com>
---
 lib/device/dev-cache.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/lib/device/dev-cache.c b/lib/device/dev-cache.c
index 1e7dfdea6..3e8105be7 100644
--- a/lib/device/dev-cache.c
+++ b/lib/device/dev-cache.c
@@ -66,6 +66,7 @@ static void _dev_init(struct device *dev, int max_error_count)
 	dev->phys_block_size = -1;
 	dev->block_size = -1;
 	dev->fd = -1;
+	dev->bcache_fd = -1;
 	dev->read_ahead = -1;
 	dev->max_error_count = max_error_count;
 


