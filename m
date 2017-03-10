From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 10 Mar 2017 13:36:42 -0500
Subject: master - libdm: passthrough checks traling space char
Message-ID: <201703101836.v2AIag62028587@int-mx10.intmail.prod.int.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=edf5e43f9ad6bdd5f3066f92e12a7f3c60dd656a
Commit:        edf5e43f9ad6bdd5f3066f92e12a7f3c60dd656a
Parent:        c717011f8eb8df047bf82065a1136f86595cfe72
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Feb 26 19:31:06 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Mar 10 19:33:01 2017 +0100

libdm: passthrough checks traling space char

When checking for passthrough length, check also for extra ' ' char
just like with other feature strings.
---
 WHATS_NEW_DM          |    1 +
 libdm/libdm-targets.c |    2 +-
 2 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index f11b28c..bfa6d55 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.138 - 
 =====================================
+  Cache status check for passthrough also require trailing space.
   Add extra memory page when limiting pthread stack size in dmeventd.
   Avoids immediate resume when preloaded device is smaller.
   Do not suppress kernel key description in dmsetup table output.
diff --git a/libdm/libdm-targets.c b/libdm/libdm-targets.c
index 6b83372..8c98790 100644
--- a/libdm/libdm-targets.c
+++ b/libdm/libdm-targets.c
@@ -274,7 +274,7 @@ int dm_get_status_cache(struct dm_pool *mem, const char *params,
 			s->feature_flags |= DM_CACHE_FEATURE_WRITETHROUGH;
 		else if (!strncmp(p, "writeback ", 10))
 			s->feature_flags |= DM_CACHE_FEATURE_WRITEBACK;
-		else if (!strncmp(p, "passthrough ", 11))
+		else if (!strncmp(p, "passthrough ", 12))
 			s->feature_flags |= DM_CACHE_FEATURE_PASSTHROUGH;
 		else
 			log_error("Unknown feature in status: %s", params);


