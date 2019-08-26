From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 26 Aug 2019 09:34:18 -0400
Subject: master - cache: improve vgremove loop
Message-ID: <201908261334.x7QDYI96005496@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=c98e34e4d0edbcb2594e93f06183838de0c6e2bc
Commit:        c98e34e4d0edbcb2594e93f06183838de0c6e2bc
Parent:        af0b84ccc850d619eddef5112753731abce099ed
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Aug 26 13:28:00 2019 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Aug 26 15:32:12 2019 +0200

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
index 0b48e03..cb93bbe 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.03.06 - 
 ================================
+  Improve internal removal of cached devices.
   Synchronize with udev when dropping snapshot.
   Add missing device synchronization point before removing pvmove node.
   Correctly set read_ahead for LVs when pvmove is finished.
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 6aee947..af3a16f 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -6544,6 +6544,13 @@ int lv_remove_with_dependencies(struct cmd_context *cmd, struct logical_volume *
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


