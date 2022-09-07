From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed,  7 Sep 2022 13:04:48 +0000 (GMT)
Subject: main - gcc: eliminate warnings
Message-ID: <20220907130448.4CD58385841A@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=e757965222607a21a240139d1696780c389b798d
Commit:        e757965222607a21a240139d1696780c389b798d
Parent:        973d0bd5b7110ad16fe26362c2586c961591ba4a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Sep 5 16:22:32 2022 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Sep 7 14:58:01 2022 +0200

gcc: eliminate warnings

Gcc starts to show new warning - although unlikely to be able to hit
initialize variables to 0.
---
 lib/config/config.c | 2 +-
 tools/lvcreate.c    | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/lib/config/config.c b/lib/config/config.c
index 230ec3225..5986e64b1 100644
--- a/lib/config/config.c
+++ b/lib/config/config.c
@@ -1830,7 +1830,7 @@ static int _out_line_fn(const struct dm_config_node *cn, const char *line, void
 	char summary[MAX_COMMENT_LINE+1];
 	char version[9];
 	int pos = 0;
-	int space_prefix_len;
+	int space_prefix_len = 0;
 	const char *p;
 	size_t len;
 
diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index 9bf5f4821..670c52913 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -252,7 +252,7 @@ static int _update_extents_params(struct volume_group *vg,
 	uint32_t size_rest;
 	uint32_t stripesize_extents;
 	uint32_t extents;
-	uint32_t base_calc_extents;
+	uint32_t base_calc_extents = 0;
 	uint32_t vdo_pool_max_extents;
 
 	if (lcp->size &&

