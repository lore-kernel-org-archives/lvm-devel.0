From: David Teigland <teigland@sourceware.org>
Date: Fri, 3 Mar 2017 12:16:20 -0500
Subject: master - args: in cachemode option fix passthrough value
Message-ID: <201703031716.v23HGKEK019839@int-mx14.intmail.prod.int.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=2a5e24580abbb103cddc4ec24fe9423e11be5e64
Commit:        2a5e24580abbb103cddc4ec24fe9423e11be5e64
Parent:        191a2517beb85fcb041ecb92fad3b45a8d008b0e
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Mar 3 10:53:18 2017 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Mar 3 10:53:18 2017 -0600

args: in cachemode option fix passthrough value

---
 tools/args.h |    4 ++--
 tools/vals.h |    2 +-
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/tools/args.h b/tools/args.h
index 53ff870..83700b3 100644
--- a/tools/args.h
+++ b/tools/args.h
@@ -109,10 +109,10 @@ arg(cachemode_ARG, '\0', "cachemode", cachemode_VAL, 0, 0,
     "been stored in both the cache pool and on the origin LV.\n"
     "While writethrough may be slower for writes, it is more\n"
     "resilient if something should happen to a device associated with the\n"
-    "cache pool LV. With writethrough, all reads are served\n"
+    "cache pool LV. With \\fBpassthrough\\fP, all reads are served\n"
     "from the origin LV (all reads miss the cache) and all writes are\n"
     "forwarded to the origin LV; additionally, write hits cause cache\n"
-    "block invalidates. See lvmcache(7) for more information.\n")
+    "block invalidates. See \\fBlvmcache\\fP(7) for more information.\n")
 
 arg(cachepool_ARG, '\0', "cachepool", lv_VAL, 0, 0,
     "The name of a cache pool LV.\n")
diff --git a/tools/vals.h b/tools/vals.h
index ab1b715..b946742 100644
--- a/tools/vals.h
+++ b/tools/vals.h
@@ -112,7 +112,7 @@ val(tag_VAL, tag_arg, "Tag", NULL)
 val(select_VAL, NULL, "Select", NULL)       /* used only for command defs */
 val(activationmode_VAL, string_arg, "ActivationMode", "partial|degraded|complete")
 val(activation_VAL, activation_arg, "Active", "y|n|ay")
-val(cachemode_VAL, cachemode_arg, "CacheMode", "writethrough|writeback")
+val(cachemode_VAL, cachemode_arg, "CacheMode", "writethrough|writeback|passthrough")
 val(discards_VAL, discards_arg, "Discards", "passdown|nopassdown|ignore")
 val(mirrorlog_VAL, mirrorlog_arg, "MirrorLog", "core|disk")
 val(sizekb_VAL, size_kb_arg, "SizeKB", "Size[k|UNIT]")


