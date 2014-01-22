From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed, 22 Jan 2014 15:32:13 +0000 (UTC)
Subject: master - coverity: check return value of dev_close in dev_get_block_size()
Message-ID: <20140122153213.6F37B61673@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=cb595a5a13134cd3c12559e5e3b69f4ecf667c18
Commit:        cb595a5a13134cd3c12559e5e3b69f4ecf667c18
Parent:        34e6d59bba1507141a72c644d7d96e173b09fa19
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Jan 22 16:20:09 2014 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Jan 22 16:20:09 2014 +0100

coverity: check return value of dev_close in dev_get_block_size()

---
 lib/device/dev-io.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/lib/device/dev-io.c b/lib/device/dev-io.c
index 82cc2fc..6697456 100644
--- a/lib/device/dev-io.c
+++ b/lib/device/dev-io.c
@@ -178,8 +178,8 @@ int dev_get_block_size(struct device *dev, unsigned int *physical_block_size, un
 	*physical_block_size = (unsigned int) dev->phys_block_size;
 	*block_size = (unsigned int) dev->block_size;
 out:
-	if (needs_open)
-		dev_close(dev);
+	if (needs_open && !dev_close(dev))
+		stack;
 
 	return r;
 }


