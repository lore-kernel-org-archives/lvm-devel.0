From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri, 30 Jan 2015 12:31:55 +0000 (UTC)
Subject: master - filter-composite: add external device info hooks
Message-ID: <20150130123155.4460D61152@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c50a90c9e6084350682a315ed1732c2a54a3a828
Commit:        c50a90c9e6084350682a315ed1732c2a54a3a828
Parent:        fbfde21e7cdc770f0a1189d40f983aa046d605bb
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Mon Dec 15 15:12:42 2014 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri Jan 30 13:01:12 2015 +0100

filter-composite: add external device info hooks

Composite filter is a filter that can put several filters in one set.
This patch adds a switch when creating the composite filter which will
enable or disable external device info handles for all the filters
the composite filter encompasses.

We want to use this external device info for majority of the filters
which are in the "lvmetad filter chain" (or the respective part if
we're not using lvmetad).

Following patches will use the enabled external device handle in
concrete filters from the composite filter...
---
 lib/commands/toolcontext.c     |    6 +++---
 lib/filters/filter-composite.c |   15 +++++++++++++--
 lib/filters/filter.h           |    3 ++-
 3 files changed, 18 insertions(+), 6 deletions(-)

diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index 3900179..83238fb 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -905,7 +905,7 @@ static struct dev_filter *_init_lvmetad_filter_chain(struct cmd_context *cmd)
 			nr_filt++;
 	}
 
-	if (!(composite = composite_filter_create(nr_filt, filters)))
+	if (!(composite = composite_filter_create(nr_filt, 1, filters)))
 		goto_bad;
 
 	return composite;
@@ -985,7 +985,7 @@ static int _init_filters(struct cmd_context *cmd, unsigned load_persistent_cache
 		if (!(filter_components[1] = regex_filter_create(cn->v)))
 			goto_bad;
 		/* we have two filter components - create composite filter */
-		if (!(filter = composite_filter_create(2, filter_components)))
+		if (!(filter = composite_filter_create(2, 0, filter_components)))
 			goto_bad;
 	} else
 		/* we have only one filter component - no need to create composite filter */
@@ -1004,7 +1004,7 @@ static int _init_filters(struct cmd_context *cmd, unsigned load_persistent_cache
 	if (lvmetad_used()) {
 		filter_components[0] = cmd->lvmetad_filter;
 		filter_components[1] = cmd->filter;
-		if (!(cmd->full_filter = composite_filter_create(2, filter_components)))
+		if (!(cmd->full_filter = composite_filter_create(2, 0, filter_components)))
 			goto_bad;
 	} else
 		cmd->full_filter = filter;
diff --git a/lib/filters/filter-composite.c b/lib/filters/filter-composite.c
index a6ba71a..950705b 100644
--- a/lib/filters/filter-composite.c
+++ b/lib/filters/filter-composite.c
@@ -27,6 +27,17 @@ static int _and_p(struct dev_filter *f, struct device *dev)
 	return 1;
 }
 
+static int _and_p_with_dev_ext_info(struct dev_filter *f, struct device *dev)
+{
+	int r;
+
+	dev_ext_enable(dev, DEV_EXT_NONE);
+	r = _and_p(f, dev);
+	dev_ext_disable(dev);
+
+	return r;
+}
+
 static void _composite_destroy(struct dev_filter *f)
 {
 	struct dev_filter **filters;
@@ -62,7 +73,7 @@ static void _wipe(struct dev_filter *f)
 			(*filters)->wipe(*filters);
 }
 
-struct dev_filter *composite_filter_create(int n, struct dev_filter **filters)
+struct dev_filter *composite_filter_create(int n, int use_dev_ext_info, struct dev_filter **filters)
 {
 	struct dev_filter **filters_copy, *cft;
 
@@ -83,7 +94,7 @@ struct dev_filter *composite_filter_create(int n, struct dev_filter **filters)
 		return NULL;
 	}
 
-	cft->passes_filter = _and_p;
+	cft->passes_filter = use_dev_ext_info ? _and_p_with_dev_ext_info : _and_p;
 	cft->destroy = _composite_destroy;
 	cft->dump = _dump;
 	cft->wipe = _wipe;
diff --git a/lib/filters/filter.h b/lib/filters/filter.h
index 0519439..e73cf9c 100644
--- a/lib/filters/filter.h
+++ b/lib/filters/filter.h
@@ -20,7 +20,8 @@
 #include "dev-cache.h"
 #include "dev-type.h"
 
-struct dev_filter *composite_filter_create(int n, struct dev_filter **filters);
+struct dev_filter *composite_filter_create(int n, int use_dev_ext_info, struct dev_filter **filters);
+
 struct dev_filter *lvm_type_filter_create(struct dev_types *dt);
 struct dev_filter *md_filter_create(struct dev_types *dt);
 struct dev_filter *mpath_filter_create(struct dev_types *dt);


