From: Petr Rockai <mornfall@fedoraproject.org>
Date: Wed, 26 Sep 2012 17:55:32 +0000 (UTC)
Subject: master - filters: Alwayz zalloc the filter struct.
Message-ID: <20120926175532.EE69FA33AB@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=012d273ede86f0e3e894b0e907f7f623c3dda7e0
Commit:        012d273ede86f0e3e894b0e907f7f623c3dda7e0
Parent:        376cb3fe64c4874fe4276722c4276521481dc80b
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Sat Aug 18 18:59:07 2012 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Wed Sep 26 12:23:34 2012 +0200

filters: Alwayz zalloc the filter struct.

Not all pointers need to be initialised explicitly that way.
---
 lib/filters/filter-composite.c  |    2 +-
 lib/filters/filter-md.c         |    2 +-
 lib/filters/filter-mpath.c      |    2 +-
 lib/filters/filter-persistent.c |    2 +-
 lib/filters/filter.c            |    2 +-
 5 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/lib/filters/filter-composite.c b/lib/filters/filter-composite.c
index 130490a..3ed8787 100644
--- a/lib/filters/filter-composite.c
+++ b/lib/filters/filter-composite.c
@@ -64,7 +64,7 @@ struct dev_filter *composite_filter_create(int n, struct dev_filter **filters)
 	memcpy(filters_copy, filters, sizeof(*filters) * n);
 	filters_copy[n] = NULL;
 
-	if (!(cft = dm_malloc(sizeof(*cft)))) {
+	if (!(cft = dm_zalloc(sizeof(*cft)))) {
 		log_error("compsoite filters allocation failed");
 		dm_free(filters_copy);
 		return NULL;
diff --git a/lib/filters/filter-md.c b/lib/filters/filter-md.c
index e3e88f1..d57489d 100644
--- a/lib/filters/filter-md.c
+++ b/lib/filters/filter-md.c
@@ -54,7 +54,7 @@ struct dev_filter *md_filter_create(void)
 {
 	struct dev_filter *f;
 
-	if (!(f = dm_malloc(sizeof(*f)))) {
+	if (!(f = dm_zalloc(sizeof(*f)))) {
 		log_error("md filter allocation failed");
 		return NULL;
 	}
diff --git a/lib/filters/filter-mpath.c b/lib/filters/filter-mpath.c
index 6d6353a..61a62d7 100644
--- a/lib/filters/filter-mpath.c
+++ b/lib/filters/filter-mpath.c
@@ -185,7 +185,7 @@ struct dev_filter *mpath_filter_create(const char *sysfs_dir)
 		return NULL;
 	}
 
-	if (!(f = dm_malloc(sizeof(*f)))) {
+	if (!(f = dm_zalloc(sizeof(*f)))) {
 		log_error("mpath filter allocation failed");
 		return NULL;
 	}
diff --git a/lib/filters/filter-persistent.c b/lib/filters/filter-persistent.c
index 3705804..79e40b8 100644
--- a/lib/filters/filter-persistent.c
+++ b/lib/filters/filter-persistent.c
@@ -355,7 +355,7 @@ struct dev_filter *persistent_filter_create(struct dev_filter *real,
 		goto bad;
 	}
 
-	if (!(f = dm_malloc(sizeof(*f)))) {
+	if (!(f = dm_zalloc(sizeof(*f)))) {
 		log_error("Allocation of device filter for persistent filter failed.");
 		goto bad;
 	}
diff --git a/lib/filters/filter.c b/lib/filters/filter.c
index dcb6c5e..e335045 100644
--- a/lib/filters/filter.c
+++ b/lib/filters/filter.c
@@ -325,7 +325,7 @@ struct dev_filter *lvm_type_filter_create(const char *proc,
 {
 	struct dev_filter *f;
 
-	if (!(f = dm_malloc(sizeof(struct dev_filter)))) {
+	if (!(f = dm_zalloc(sizeof(struct dev_filter)))) {
 		log_error("LVM type filter allocation failed");
 		return NULL;
 	}


