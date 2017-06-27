From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 27 Jun 2017 06:20:28 -0400
Subject: master - coverity: model few more functions
Message-ID: <201706271020.v5RAKSnW003946@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=3fe67217d46d2bb496b5c09b0314c7260ed6c24f
Commit:        3fe67217d46d2bb496b5c09b0314c7260ed6c24f
Parent:        5ff6260071ef2465ba33ce6dd9b7c7b3168f4c88
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Jun 27 09:23:22 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Jun 27 12:17:16 2017 +0200

coverity: model few more functions

Reduce amount of FP.
---
 coverity/coverity_model.c |   13 +++++++++++++
 1 files changed, 13 insertions(+), 0 deletions(-)

diff --git a/coverity/coverity_model.c b/coverity/coverity_model.c
index 250aadf..24a6afe 100644
--- a/coverity/coverity_model.c
+++ b/coverity/coverity_model.c
@@ -41,6 +41,19 @@ struct lv_segment *last_seg(const struct logical_volume *lv)
 	return ((struct lv_segment **)lv)[0];
 }
 
+const char *find_config_tree_str(struct cmd_context *cmd, int id, struct profile *profile)
+{
+	return "STRING";
+}
+
+struct logical_volume *origin_from_cow(const struct logical_volume *lv)
+{
+	if (lv)
+		return lv;
+
+	__coverity_panic__();
+}
+
 /* simple_memccpy() from glibc */
 void *memccpy(void *dest, const void *src, int c, size_t n)
 {


