From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon, 17 Jun 2013 13:17:34 +0000 (UTC)
Subject: master - dev-type: add/fix references for dev_types in non-linux case
Message-ID: <20130617131734.943B660D1A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=21f1062ef883adeed2bad85bb61ad652b32029c7
Commit:        21f1062ef883adeed2bad85bb61ad652b32029c7
Parent:        d4308a558d93bf5ed4b61f65b12f4f0fdfc45102
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Mon Jun 17 15:17:15 2013 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Jun 17 15:17:15 2013 +0200

dev-type: add/fix references for dev_types in non-linux case

---
 lib/device/dev-type.c      |    2 +-
 lib/filters/filter-mpath.c |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/lib/device/dev-type.c b/lib/device/dev-type.c
index 39777f1..a8340b0 100644
--- a/lib/device/dev-type.c
+++ b/lib/device/dev-type.c
@@ -549,7 +549,7 @@ unsigned long dev_discard_granularity(struct dev_types *dt, struct device *dev)
 
 #else
 
-int get_primary_dev(struct device *dev, dev_t *result)
+int dev_get_primary_dev(struct dev_types *dt, struct device *dev, dev_t *result)
 {
 	return 0;
 }
diff --git a/lib/filters/filter-mpath.c b/lib/filters/filter-mpath.c
index 76d8a2d..2502f30 100644
--- a/lib/filters/filter-mpath.c
+++ b/lib/filters/filter-mpath.c
@@ -233,7 +233,7 @@ struct dev_filter *mpath_filter_create(struct dev_types *dt)
 
 #else
 
-struct dev_filter *mpath_filter_create(struct device_types *dt)
+struct dev_filter *mpath_filter_create(struct dev_types *dt)
 {
 	return NULL;
 }


