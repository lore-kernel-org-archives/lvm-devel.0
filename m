From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 26 Aug 2019 09:39:55 -0400
Subject: stable-2.02 - cache: improve vgremove loop
Message-ID: <201908261339.x7QDdtnt005658@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=c4a6b9ded02ffe682285ec4c2706114f6f2bd481
Commit:        c4a6b9ded02ffe682285ec4c2706114f6f2bd481
Parent:        4743c4900ddf0558f5949d7d113be9525bf67785
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Aug 26 13:28:00 2019 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Aug 26 15:36:41 2019 +0200

cache: improve vgremove loop

Support internal removal of 'cache origin' volume - which we
do not normally expose to a user - however internal processing
loops may hit this condition (depending on order of list LVs).

So when this operation is internally requested - we automatically
try to remove it's 'holding' LV (cache LV) - which will also
remove the origin.
---
 WHATS_NEW               |    1 +
 lib/metadata/lv_manip.c |    7 +++++++
 2 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 549366c..fa631ec 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.186 - 
 ================================
+  Improve internal removal of cached devices.
   Synchronize with udev when dropping snapshot.
   Add missing device synchronization point before removing pvmove node.
   Correctly set read_ahead for LVs when pvmove is finished.
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 9e7eff9..87c81c3 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -6362,6 +6362,13 @@ int lv_remove_with_dependencies(struct cmd_context *cmd, struct logical_volume *
 		return 0;
 	}
 
+	if (lv_is_cache_origin(lv)) {
+		if (!_lv_remove_segs_using_this_lv(cmd, lv, force, level, "cache origin"))
+			return_0;
+		/* Removal of cache LV also removes caching origin */
+		return 1;
+	}
+
 	if (lv_is_external_origin(lv) &&
 	    !_lv_remove_segs_using_this_lv(cmd, lv, force, level, "external origin"))
 		return_0;


