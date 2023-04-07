From: David Teigland <teigland@sourceware.org>
Date: Fri,  7 Apr 2023 20:58:57 +0000 (GMT)
Subject: main - remove extra change from support 16KB page size
Message-ID: <20230407205857.7076A3858D32@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=8458ff9ad18c518b774d16358e28a805057e4dc1
Commit:        8458ff9ad18c518b774d16358e28a805057e4dc1
Parent:        b443eac6efd29a72a4356f54c713cc9a0e0da866
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Apr 7 15:57:28 2023 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Apr 7 15:57:28 2023 -0500

remove extra change from support 16KB page size

---
 lib/config/config.c | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/lib/config/config.c b/lib/config/config.c
index 2bb55daeb..5986e64b1 100644
--- a/lib/config/config.c
+++ b/lib/config/config.c
@@ -540,9 +540,6 @@ int config_file_read_fd(struct dm_config_tree *cft, struct device *dev, dev_io_r
 				log_sys_error("read", dev_name(dev));
 				goto out;
 			}
-
-			if (!sz)
-				goto out;
 		}
 	} else {
 		if (!dev_read_bytes(dev, offset, size, buf))

