From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 13 Sep 2021 10:36:01 +0000 (GMT)
Subject: main - filters: fix memleak on mpath filter destroy
Message-ID: <20210913103601.5387A3858002@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=30050769b1490e293d9e0f7ed37d83c3e56bb6b3
Commit:        30050769b1490e293d9e0f7ed37d83c3e56bb6b3
Parent:        3b24c0fe4e197383101eae53b14f19586cf2eda1
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Sep 12 16:13:27 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Sep 13 12:34:41 2021 +0200

filters: fix memleak on mpath filter destroy

Missing free() leaks filter structure.
---
 WHATS_NEW                  | 1 +
 lib/filters/filter-mpath.c | 2 ++
 2 files changed, 3 insertions(+)

diff --git a/WHATS_NEW b/WHATS_NEW
index 7d4cea1d6..9ff0be667 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.03.14 - 
 ==================================
+  Fix memleak in mpath filter.
   Support newer location for VDO statistics.
   Add support for VDO async-unsage write policy.
   Improve lvm_import_vdo script.
diff --git a/lib/filters/filter-mpath.c b/lib/filters/filter-mpath.c
index 982e23400..7644a5b0a 100644
--- a/lib/filters/filter-mpath.c
+++ b/lib/filters/filter-mpath.c
@@ -37,6 +37,8 @@ static void _destroy(struct dev_filter *f)
 {
 	if (f->use_count)
 		log_error(INTERNAL_ERROR "Destroying mpath filter while in use %u times.", f->use_count);
+
+	free(f);
 }
 
 struct dev_filter *mpath_filter_create(struct dev_types *dt)


