From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 22 Jun 2018 09:08:12 -0400
Subject: 2018-06-01-stable - cache: cleaner policy also uses fmt2
Message-ID: <201806221308.w5MD8CYV019689@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=39e3b5d8ac58dda328ddbc97daafb9800d7e954b
Commit:        39e3b5d8ac58dda328ddbc97daafb9800d7e954b
Parent:        39fc98d7314b8bf4b66118b7ae72674383209c1f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jun 8 12:37:07 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jun 22 15:00:10 2018 +0200

cache:  cleaner policy also uses fmt2

Format 2 is also with cleaner policy.
---
 WHATS_NEW                  |    1 +
 lib/metadata/cache_manip.c |    5 +++--
 2 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index d432cea..6560e57 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.180 - 
 =================================
+  Cache can uses metadata format 2 with cleaner policy.
   Avoid showing internal error in lvs output or pvmoved LVs.
   Fix check if resized PV can also fit metadata area.
   Reopen devices RDWR before writing to avoid udev issues.
diff --git a/lib/metadata/cache_manip.c b/lib/metadata/cache_manip.c
index 3ed8ce8..c15f117 100644
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


