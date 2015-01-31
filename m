From: Heinz Mauelshagen <mauelsha@fedoraproject.org>
Date: Sat, 31 Jan 2015 14:10:41 +0000 (UTC)
Subject: dev-lvmguy-raid-takeover-reshape-resize - avoid debug printfs
Message-ID: <20150131141041.6D33960DBE@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=9bded3b386833360dff3a5bd9bba4de4297f1914
Commit:        9bded3b386833360dff3a5bd9bba4de4297f1914
Parent:        d8f933989c2fbd9fcedf511867f1d7a1c9e58145
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Fri Jan 30 18:16:20 2015 +0100
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Fri Jan 30 18:16:20 2015 +0100

avoid debug printfs

---
 lib/metadata/lv_manip.c   |    2 ++
 lib/metadata/raid_manip.c |    2 ++
 tools/lvconvert.c         |    1 +
 3 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index c4b9a16..e3408e3 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -31,6 +31,8 @@
 #include "lvm-signal.h"
 #include "memlock.h"
 
+#define printf(a ...)
+
 typedef enum {
 	PREFERRED,
 	USE_AREA,
diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index aac0e99..4781d97 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -26,6 +26,8 @@
 #include "dump.h"
 #endif
 
+#define printf(a ...)
+
 static void _ensure_min_region_size(struct logical_volume *lv)
 {
 	struct lv_segment *seg = first_seg(lv);
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index a8aee80..c72b73e 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -1900,6 +1900,7 @@ static int _lvconvert_raid(struct logical_volume *lv, struct lvconvert_params *l
 	struct lv_segment *seg = first_seg(lv);
 	dm_percent_t sync_percent;
 
+#define printf(a ...)
 printf("stripes_ARG=%u stripes_long_ARG=%u\n", arg_count(lv->vg->cmd, stripes_ARG), arg_count(lv->vg->cmd, stripes_long_ARG));
 	if (!arg_count(cmd, type_ARG))
 		lp->segtype = seg->segtype;


