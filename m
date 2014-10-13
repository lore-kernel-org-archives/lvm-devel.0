From: Alasdair Kergon <agk@fedoraproject.org>
Date: Mon, 13 Oct 2014 17:16:55 +0000 (UTC)
Subject: master - device: Fix BLKSSZGET definition check.
Message-ID: <20141013171655.2C77261102@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d1bcdd7338148a887aae44149e3ea756c1df17a3
Commit:        d1bcdd7338148a887aae44149e3ea756c1df17a3
Parent:        22a6b0e40b302b333f9bd995c0b81b0146e8232a
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Mon Oct 13 18:15:41 2014 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Mon Oct 13 18:15:41 2014 +0100

device: Fix BLKSSZGET definition check.

---
 lib/device/dev-io.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/device/dev-io.c b/lib/device/dev-io.c
index 0a75088..122b616 100644
--- a/lib/device/dev-io.c
+++ b/lib/device/dev-io.c
@@ -154,7 +154,7 @@ int dev_get_block_size(struct device *dev, unsigned int *physical_block_size, un
 		}
 		log_debug_devs("%s: physical block size is %u bytes", name, dev->phys_block_size);
 	}
-#elif BLKSSZGET
+#elif defined (BLKSSZGET)
 	/* if we can't get physical block size, just use logical block size instead */
 	if (dev->phys_block_size == -1) {
 		if (ioctl(dev_fd(dev), BLKSSZGET, &dev->phys_block_size) < 0) {


