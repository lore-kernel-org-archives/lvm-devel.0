From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 24 Oct 2014 14:41:01 +0000 (UTC)
Subject: master - lvcreate: handle linear segment
Message-ID: <20141024144101.C66F260CE2@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=dfcf03a9ce2fe9b618f44c5f99e13ff5610ffcc0
Commit:        dfcf03a9ce2fe9b618f44c5f99e13ff5610ffcc0
Parent:        7359a9df889a2ed8d6e6114ecc3f57438a75d9d7
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Oct 11 18:36:40 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Oct 24 16:39:32 2014 +0200

lvcreate: handle linear segment

Put in code to accept 'linear' segment type
(when specified stripes cannot be used)

Also report 'error' when unknown type is specified.
---
 WHATS_NEW          |    1 +
 tools/lvcreate.c   |   10 ++++++++++
 tools/lvmcmdline.c |    8 +++++++-
 3 files changed, 18 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 70b41bc..fa88ddc 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.112 - 
 =====================================
+  Support lvcreate --type linear.
   Improve _should_wipe_lv() to warn with message.
   Inform about temporarily created volumes only in verbose mode.
   Better support for --test mode with pool creation.
diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index 301bda6..b6907f5 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -714,6 +714,7 @@ static int _lvcreate_params(struct lvcreate_params *lp,
 	struct arg_value_group_list *current_group;
 	const char *segtype_str;
 	const char *tag;
+	int only_linear = 0;
 
 	memset(lcp, 0, sizeof(*lcp));
 	dm_list_init(&lp->tags);
@@ -745,6 +746,10 @@ static int _lvcreate_params(struct lvcreate_params *lp,
 		segtype_str = "striped";
 
 	segtype_str = arg_str_value(cmd, type_ARG, segtype_str);
+	if (!strcmp(segtype_str, "linear")) {
+		segtype_str = "striped";
+		only_linear = 1; /* User requested linear only target */
+	}
 
 	if (!(lp->segtype = get_segtype_from_string(cmd, segtype_str)))
 		return_0;
@@ -911,6 +916,11 @@ static int _lvcreate_params(struct lvcreate_params *lp,
 	    !_read_cache_pool_params(lp, cmd))
 		return_0;
 
+	if (only_linear && lp->stripes > 1) {
+		log_error("Cannot use stripes with linear type.");
+		return 0;
+	}
+
 	if (lp->snapshot && (lp->extents || lcp->size)) {
 		lp->chunk_size = arg_uint_value(cmd, chunksize_ARG, 8);
 		if (lp->chunk_size < 8 || lp->chunk_size > 1024 ||
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 6e13679..bbf0145 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -564,7 +564,13 @@ int alloc_arg(struct cmd_context *cmd __attribute__((unused)), struct arg_values
 
 int segtype_arg(struct cmd_context *cmd, struct arg_values *av)
 {
-	return get_segtype_from_string(cmd, av->value) ? 1 : 0;
+	struct segment_type *segtype;
+	const char *str = (!strcmp(av->value, "linear")) ? "striped" : av->value;
+
+	if (!(segtype = get_segtype_from_string(cmd, str)))
+		return_0;
+
+	return (!segtype_is_unknown(segtype)) ? 1 : 0;
 }
 
 /*


