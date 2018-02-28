From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 28 Feb 2018 15:22:17 -0500
Subject: master - io: keep 64b arithmetic
Message-ID: <201802282022.w1SKMHPS009751@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=6b48868cf0754b13e4efaaaec33cf8c9deba2d40
Commit:        6b48868cf0754b13e4efaaaec33cf8c9deba2d40
Parent:        261e6c3df69082490a685f0d0599e88139b9a927
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Feb 25 22:32:14 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Feb 28 21:05:18 2018 +0100

io: keep 64b arithmetic

Widen to 64b arithmetic from start.
---
 lib/device/dev-io.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/device/dev-io.c b/lib/device/dev-io.c
index 31506e8..50b1ba8 100644
--- a/lib/device/dev-io.c
+++ b/lib/device/dev-io.c
@@ -117,7 +117,7 @@ int dev_async_setup(struct cmd_context *cmd)
 	int r;
 
 	_aio_max = find_config_tree_int(cmd, devices_aio_max_CFG, NULL);
-	_aio_memory_max = find_config_tree_int(cmd, devices_aio_memory_CFG, NULL) * 1024 * 1024;
+	_aio_memory_max = find_config_tree_int(cmd, devices_aio_memory_CFG, NULL) * INT64_C(1024 * 1024);
 
 	/* Threshold is zero? */
 	if (!_aio_max || !_aio_memory_max) {


