From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 8 Jun 2018 08:38:50 -0400
Subject: master - cache: cleaner policy also uses fmt2
Message-ID: <201806081238.w58Ccolo006050@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=5cb4b2a42465f2430c98c8966adeacb0f6a26af3
Commit:        5cb4b2a42465f2430c98c8966adeacb0f6a26af3
Parent:        1f5f8382ae09e3ba95486903cf86b29641a0023d
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jun 8 12:37:07 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jun 8 14:37:29 2018 +0200

cache:  cleaner policy also uses fmt2

Format 2 is also with cleaner policy.
---
 WHATS_NEW                  |    1 +
 lib/metadata/cache_manip.c |    5 +++--
 2 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index a17902d..162b584 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 3.0.0
 =============
+  Cache can uses metadata format 2 with cleaner policy.
   Fix check if resized PV can also fit metadata area.
   Avoid showing internal error in lvs output or pvmoved LVs.
   Remove clvmd
diff --git a/lib/metadata/cache_manip.c b/lib/metadata/cache_manip.c
index fe91fee..c3bd2ec 100644
--- a/lib/metadata/cache_manip.c
+++ b/lib/metadata/cache_manip.c
@@ -843,12 +843,13 @@ int cache_set_metadata_format(struct lv_segment *seg, cache_metadata_format_t fo
 
 	/*
 	 * If policy is unselected, but format 2 is selected, policy smq is enforced.
-	 * ATM no other then smq policy is allowed to select format 2.
+	 * ATM no other then smq & cleaner policy is allowed to select format 2.
 	 */
 	if (!seg->policy_name) {
 		if (format == CACHE_METADATA_FORMAT_2)
 			seg->policy_name = "smq";
-	} else if (strcmp(seg->policy_name, "smq")) {
+	} else if (strcmp(seg->policy_name, "smq") &&
+		   strcmp(seg->policy_name, "cleaner")) {
 		seg->cache_metadata_format = CACHE_METADATA_FORMAT_1;
 		return 1;
 	}


