From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 19 Nov 2012 13:48:53 +0000 (UTC)
Subject: master - lvconvert: store target attributes
Message-ID: <20121119134853.562431698@hosted02.fedoraproject.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=cf5242a670010a7c0137090a330b78b3bf43a55b
Commit:        cf5242a670010a7c0137090a330b78b3bf43a55b
Parent:        2c3bbf0a6cf33de8f1b2a08fcb79da3f881d3472
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Nov 15 10:32:13 2012 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Nov 19 14:17:10 2012 +0100

lvconvert: store target attributes

Target tells us its version, and we may allow different set of options
to be supported with different version of driver.

Idea is to provide individual feature flags and later be
able to query for them.
---
 lib/metadata/metadata-exported.h |    1 +
 tools/lvconvert.c                |    3 ++-
 tools/lvcreate.c                 |    3 +--
 3 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 00be606..b586936 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -609,6 +609,7 @@ struct lvcreate_params {
 	uint32_t mirrors; /* mirror */
 
 	const struct segment_type *segtype; /* all */
+	unsigned target_attr; /* all */
 
 	/* size */
 	uint32_t extents; /* all */
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 27d8181..7d03a5f 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -41,6 +41,7 @@ struct lvconvert_params {
 	uint32_t stripe_size;
 
 	const struct segment_type *segtype;
+	unsigned target_attr;
 
 	alloc_policy_t alloc;
 
@@ -460,7 +461,7 @@ static int _read_params(struct lvconvert_params *lp, struct cmd_context *cmd,
 	}
 
 	if (activation() && lp->segtype && lp->segtype->ops->target_present &&
-	    !lp->segtype->ops->target_present(cmd, NULL, NULL)) {
+	    !lp->segtype->ops->target_present(cmd, NULL, &lp->target_attr)) {
 		log_error("%s: Required device-mapper target(s) not "
 			  "detected in your kernel", lp->segtype->name);
 		return 0;
diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index 5d687ac..dad0ba7 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -679,7 +679,6 @@ static int _lvcreate_params(struct lvcreate_params *lp,
 	struct arg_value_group_list *current_group;
 	const char *segtype_str;
 	const char *tag;
-	unsigned attr = 0;
 
 	memset(lp, 0, sizeof(*lp));
 	memset(lcp, 0, sizeof(*lcp));
@@ -796,7 +795,7 @@ static int _lvcreate_params(struct lvcreate_params *lp,
 	}
 
 	if (activation() && lp->segtype->ops->target_present &&
-	    !lp->segtype->ops->target_present(cmd, NULL, &attr)) {
+	    !lp->segtype->ops->target_present(cmd, NULL, &lp->target_attr)) {
 		log_error("%s: Required device-mapper target(s) not "
 			  "detected in your kernel", lp->segtype->name);
 		return 0;


