From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri, 19 Jul 2013 13:27:13 +0000 (UTC)
Subject: master - dev-type: dev_get_primary_dev default error code 0, not -1
Message-ID: <20130719132713.295D760E97@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f0ab6c33a9475502ea8af1cf54addba68f97428f
Commit:        f0ab6c33a9475502ea8af1cf54addba68f97428f
Parent:        da79fe4c1db8936667954403e6f690df464fc638
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Fri Jul 19 15:26:53 2013 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri Jul 19 15:26:53 2013 +0200

dev-type: dev_get_primary_dev default error code 0, not -1

---
 lib/device/dev-type.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/lib/device/dev-type.c b/lib/device/dev-type.c
index 642ee27..11f0407 100644
--- a/lib/device/dev-type.c
+++ b/lib/device/dev-type.c
@@ -349,7 +349,7 @@ int dev_get_primary_dev(struct dev_types *dt, struct device *dev, dev_t *result)
 	char buffer[64];
 	struct stat info;
 	FILE *fp = NULL;
-	int parts, residue, size, ret = -1;
+	int parts, residue, size, ret = 0;
 
 	/*
 	 * Try to get the primary dev out of the
@@ -384,7 +384,8 @@ int dev_get_primary_dev(struct dev_types *dt, struct device *dev, dev_t *result)
 		if (errno != ENOENT)
 			log_sys_error("stat", path);
 		*result = dev->dev;
-		ret = 1; goto out; /* dev is not a partition! */
+		ret = 1;
+		goto out; /* dev is not a partition! */
 
 	}
 


