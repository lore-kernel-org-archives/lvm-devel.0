From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 10 Sep 2015 15:30:00 +0000 (UTC)
Subject: master - cache: disallow stripes/size for cache pool
Message-ID: <20150910153000.1083960B43@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a631fa20d0f18d12a8dc564d9b2d53d38e2e4d43
Commit:        a631fa20d0f18d12a8dc564d9b2d53d38e2e4d43
Parent:        5911fa1d914220a182630a5f353b665478917df1
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Sep 10 16:33:11 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Sep 10 17:28:15 2015 +0200

cache: disallow stripes/size for cache pool

ATM allocation can't handle stripping and cache pool allocation.
It's not yet even clear what should be actually result.
Until resolved, disable this option (it's been coredumping
inside allocation anyway).
---
 WHATS_NEW        |    1 +
 tools/lvcreate.c |    5 ++++-
 2 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 3f897ce..6e23fcb 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.131 - 
 =====================================
+  Disallow usage of --stripe and --stripsize when creating cache pool.
   Warn user when caching raid or thin pool data LV.
   When layering LV, move LV flags with segments.
   Ignore persistent cache if configuration changed. (2.02.127)
diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index 364a16a..7bba761 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -770,7 +770,8 @@ static int _lvcreate_params(struct cmd_context *cmd,
 					    CACHE_POOL_ARGS,
 					    LVCREATE_ARGS,
 					    POOL_ARGS,
-					    SIZE_ARGS,
+					    extents_ARG,
+					    size_ARG,
 					    cache_ARG,
 					    chunksize_ARG,
 					    -1))
@@ -1096,6 +1097,8 @@ static int _determine_cache_argument(struct volume_group *vg,
 		}
 		/* FIXME How to handle skip flag? */
 		if (arg_from_list_is_set(cmd, "is unsupported with cache conversion",
+					 stripes_ARG,
+					 stripesize_ARG,
 					 setactivationskip_ARG,
 					 ignoreactivationskip_ARG,
 					 -1))


