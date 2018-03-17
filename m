From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Sat, 17 Mar 2018 18:34:33 -0400
Subject: master - raid: fix version check of target
Message-ID: <201803172234.w2HMYXmN011131@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=67fbe980a710a790d6d1ea7f9cfaf9d8c6e50448
Commit:        67fbe980a710a790d6d1ea7f9cfaf9d8c6e50448
Parent:        689af32313ac120dd67a16d73e78ede5295e308c
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Mar 17 21:44:53 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Mar 17 23:30:14 2018 +0100

raid: fix version check of target

Comparision missed to check patch level for matching minor version.
Howerver since all checked patchlevels were 0 - the fix doesn't change result.
---
 WHATS_NEW       |    1 +
 lib/raid/raid.c |    2 +-
 2 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index a974a6c..5711f41 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.178 - 
 =====================================
+  Fix raid target version testing for supported features.
   Allow activation of pools when thin/cache_check tool is missing.
   Remove RaidLV on creation failure when rmeta devices can't be activated.
   Add prioritized_section() to restore cookie boundaries (2.02.177).
diff --git a/lib/raid/raid.c b/lib/raid/raid.c
index 269a30c..e926ae1 100644
--- a/lib/raid/raid.c
+++ b/lib/raid/raid.c
@@ -464,7 +464,7 @@ struct raid_feature {
 static int _check_feature(const struct raid_feature *feature, uint32_t maj, uint32_t min, uint32_t patchlevel)
 {
 	return (maj > feature->maj) ||
-	       (maj == feature->maj && min >= feature->min) ||
+	       (maj == feature->maj && min > feature->min) ||
 	       (maj == feature->maj && min == feature->min && patchlevel >= feature->patchlevel);
 }
 


