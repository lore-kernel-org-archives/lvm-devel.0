From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed, 12 Nov 2014 14:20:21 +0000 (UTC)
Subject: master - coverity: commit ba2302346 - report log_sys_error properly
Message-ID: <20141112142021.867F0609D3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=359dc6fa76f765a5503b3fda7a596984272a4a4e
Commit:        359dc6fa76f765a5503b3fda7a596984272a4a4e
Parent:        c03d8473ea9ad585f27207404a242b7b11caf74f
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Nov 12 15:16:54 2014 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Nov 12 15:16:54 2014 +0100

coverity: commit ba2302346 - report log_sys_error properly

log_sys_error uses errno, hence we need to report the first
failure before reporting another failure that uses errno as well.
---
 lib/activate/dev_manager.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index a17cd25..6e5b785 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -1873,9 +1873,9 @@ static int _pool_callback(struct dm_tree_node *node,
 		}
 		/* let's assume there is no problem to read 64 bytes */
 		if (read(fd, buf, sizeof(buf)) < sizeof(buf)) {
+			log_sys_error("read", argv[args]);
 			if (close(fd))
 				log_sys_error("close", argv[args]);
-			log_sys_error("read", argv[args]);
 			return 0;
 		}
 		for (ret = 0; ret < DM_ARRAY_SIZE(buf); ++ret)


