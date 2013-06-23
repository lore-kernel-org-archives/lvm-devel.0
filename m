From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Sun, 23 Jun 2013 10:40:12 +0000 (UTC)
Subject: master - dev-type: dev_get_primary_dev: fix ret value if dev is a partition and we used sysfs
Message-ID: <20130623104012.EC1DB60295@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c9e8e7c235a14d8ada78b88d467f659b8e72554b
Commit:        c9e8e7c235a14d8ada78b88d467f659b8e72554b
Parent:        bdcfe8c6de26472562a8f907081e0eb94e038488
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Sun Jun 23 11:14:34 2013 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Sun Jun 23 12:39:35 2013 +0200

dev-type: dev_get_primary_dev: fix ret value if dev is a partition and we used sysfs

---
 lib/device/dev-type.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/device/dev-type.c b/lib/device/dev-type.c
index a8340b0..642ee27 100644
--- a/lib/device/dev-type.c
+++ b/lib/device/dev-type.c
@@ -434,7 +434,7 @@ int dev_get_primary_dev(struct dev_types *dt, struct device *dev, dev_t *result)
 		goto out;
 	}
 	*result = MKDEV((dev_t)major, minor);
-	ret = 1;
+	ret = 2;
 out:
 	if (fp && fclose(fp))
 		log_sys_error("fclose", path);


