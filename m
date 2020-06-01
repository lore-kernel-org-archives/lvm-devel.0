From: David Teigland <teigland@sourceware.org>
Date: Mon,  1 Jun 2020 21:08:08 +0000 (GMT)
Subject: master - Change dev->bcache_fd default value from 0 to -1
Message-ID: <20200601210808.BDED43851C37@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b59127a8386a407407a0361b9bcad028ce31a733
Commit:        b59127a8386a407407a0361b9bcad028ce31a733
Parent:        d14a8040d4a2b264130cdb730cead935b0bf19f0
Author:        Zhao Heming <heming.zhao@suse.com>
AuthorDate:    Mon Jun 1 12:22:15 2020 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Jun 1 12:22:15 2020 -0500

Change dev->bcache_fd default value from 0 to -1

This fix can avoid bcache_fd will mistakenly open/close in later.

Signed-off-by: Zhao Heming <heming.zhao@suse.com>
---
 lib/device/dev-cache.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/lib/device/dev-cache.c b/lib/device/dev-cache.c
index 6af559cab..c3f7c49be 100644
--- a/lib/device/dev-cache.c
+++ b/lib/device/dev-cache.c
@@ -65,6 +65,7 @@ static int _insert(const char *path, const struct stat *info,
 static void _dev_init(struct device *dev)
 {
 	dev->fd = -1;
+	dev->bcache_fd = -1;
 	dev->read_ahead = -1;
 
 	dev->ext.enabled = 0;


