From: Petr Rockai <mornfall@fedoraproject.org>
Date: Wed,  5 Jun 2013 12:05:46 +0000 (UTC)
Subject: dev-mornfall-lvmcache - cleanup: code update and typo fix
Message-ID: <20130605120546.E146560F90@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=803b7af70660332ce001c55fb9bc9e8511985421
Commit:        803b7af70660332ce001c55fb9bc9e8511985421
Parent:        f05c5a97c35f4a01b20cb3b31003b53348ce81d9
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Jun 3 08:38:07 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jun 3 08:42:33 2013 +0200

cleanup: code update and typo fix

Use the same style of loop for all filter functions.
Fix type compsoite -> Composite.
---
 lib/filters/filter-composite.c |   20 ++++++++------------
 1 files changed, 8 insertions(+), 12 deletions(-)

diff --git a/lib/filters/filter-composite.c b/lib/filters/filter-composite.c
index 1229460..c2b103d 100644
--- a/lib/filters/filter-composite.c
+++ b/lib/filters/filter-composite.c
@@ -20,13 +20,11 @@
 
 static int _and_p(struct dev_filter *f, struct device *dev)
 {
-	struct dev_filter **filters = (struct dev_filter **) f->private;
+	struct dev_filter **filters;
 
-	while (*filters) {
+	for (filters = (struct dev_filter **) f->private; *filters; ++filters)
 		if (!(*filters)->passes_filter(*filters, dev))
-			return 0;
-		filters++;
-	}
+			return_0;
 
 	log_debug_devs("Using %s", dev_name(dev));
 
@@ -35,15 +33,13 @@ static int _and_p(struct dev_filter *f, struct device *dev)
 
 static void _composite_destroy(struct dev_filter *f)
 {
-	struct dev_filter **filters = (struct dev_filter **) f->private;
+	struct dev_filter **filters;
 
 	if (f->use_count)
 		log_error(INTERNAL_ERROR "Destroying composite filter while in use %u times.", f->use_count);
 
-	while (*filters) {
+	for (filters = (struct dev_filter **) f->private; *filters; ++filters)
 		(*filters)->destroy(*filters);
-		filters++;
-	}
 
 	dm_free(f->private);
 	dm_free(f);
@@ -65,7 +61,7 @@ static void _wipe(struct dev_filter *f)
 {
 	struct dev_filter **filters;
 
-	for (filters = (struct dev_filter **) f->private; *filters; filters++)
+	for (filters = (struct dev_filter **) f->private; *filters; ++filters)
 		if ((*filters)->wipe)
 			(*filters)->wipe(*filters);
 }
@@ -78,7 +74,7 @@ struct dev_filter *composite_filter_create(int n, struct dev_filter **filters)
 		return_NULL;
 
 	if (!(filters_copy = dm_malloc(sizeof(*filters) * (n + 1)))) {
-		log_error("composite filters allocation failed");
+		log_error("Composite filters allocation failed.");
 		return NULL;
 	}
 
@@ -86,7 +82,7 @@ struct dev_filter *composite_filter_create(int n, struct dev_filter **filters)
 	filters_copy[n] = NULL;
 
 	if (!(cft = dm_zalloc(sizeof(*cft)))) {
-		log_error("compsoite filters allocation failed");
+		log_error("Composite filters allocation failed.");
 		dm_free(filters_copy);
 		return NULL;
 	}


