From: Dave Wysochanski <dwysocha@redhat.com>
Date: Fri, 24 Jul 2009 20:08:14 -0400
Subject: [PATCH 05/11] Comment lvcreate_params struct.
In-Reply-To: <1248480500-472-5-git-send-email-dwysocha@redhat.com>
References: <1248480500-472-1-git-send-email-dwysocha@redhat.com>
	<1248480500-472-2-git-send-email-dwysocha@redhat.com>
	<1248480500-472-3-git-send-email-dwysocha@redhat.com>
	<1248480500-472-4-git-send-email-dwysocha@redhat.com>
	<1248480500-472-5-git-send-email-dwysocha@redhat.com>
Message-ID: <1248480500-472-6-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 tools/lvcreate.c |   50 +++++++++++++++++++++++++-------------------------
 1 files changed, 25 insertions(+), 25 deletions(-)

diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index cca8fc8..b6558f8 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -26,39 +26,39 @@ struct lvcreate_cmdline_params {
 /* FIXME: refactor and reduce the size of this struct! */
 struct lvcreate_params {
 	/* flags */
-	int snapshot;
-	int zero;
-	int major;
-	int minor;
-	int corelog;
-	int nosync;
-
-	char *origin;
-	const char *vg_name;
-	const char *lv_name;
+	int snapshot; /* snap */
+	int zero; /* all */
+	int major; /* all */
+	int minor; /* all */
+	int corelog; /* mirror */
+	int nosync; /* mirror */
 
-	uint32_t stripes;
-	uint32_t stripe_size;
-	uint32_t chunk_size;
-	uint32_t region_size;
+	char *origin; /* snap */
+	const char *vg_name; /* all */
+	const char *lv_name; /* all */
 
-	uint32_t mirrors;
+	uint32_t stripes; /* striped */
+	uint32_t stripe_size; /* striped */
+	uint32_t chunk_size; /* snapshot */
+	uint32_t region_size; /* mirror */
 
-	const struct segment_type *segtype;
+	uint32_t mirrors; /* mirror */
+
+	const struct segment_type *segtype; /* all */
 
 	/* size */
-	uint32_t extents;
-	uint32_t voriginextents;
-	uint64_t voriginsize;
-	struct dm_list *pvh;
-
-	uint32_t permission;
-	uint32_t read_ahead;
-	alloc_policy_t alloc;
-
-	int pv_count;
-	char **pvs;
-	const char *tag;
+	uint32_t extents; /* all */
+	uint32_t voriginextents; /* snapshot */
+	uint64_t voriginsize; /* snapshot */
+	struct dm_list *pvh; /* all */
+
+	uint32_t permission; /* all */
+	uint32_t read_ahead; /* all */
+	alloc_policy_t alloc; /* all */
+
+	int pv_count; /* all; redundant? */
+	char **pvs; /* all; redundant? */
+	const char *tag; /* all */
 };
 
 static uint64_t _extents_from_size(struct cmd_context *cmd, uint64_t size,
-- 
1.6.0.6


