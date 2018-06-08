From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 8 Jun 2018 08:38:40 -0400
Subject: master - pvmove: improve lvs
Message-ID: <201806081238.w58CceOZ006018@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=0c62ae3f8920ebb53397b2a904aa2e3dd3e73bed
Commit:        0c62ae3f8920ebb53397b2a904aa2e3dd3e73bed
Parent:        b67ef90438052d3e01f563cdd25e2268f4e02c20
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Jun 4 11:05:28 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jun 8 14:35:42 2018 +0200

pvmove: improve lvs

When pvmoving LV - the target for LV is a mirror so the validation
that checked the type is matching was incorrect.

While we need a more generic enhancment of LVS output for pvmoved LVs,
for now at least stop showing internal errors and  'X' symbols in attrs.
---
 WHATS_NEW                  |    1 +
 lib/activate/dev_manager.c |    3 ++-
 2 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index d75ab1b..a727a40 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 3.0.0
 =============
+  Avoid showing internal error in lvs output or pvmoved LVs.
   Remove clvmd
   Remove lvmlib (api)
   lvconvert: provide possible layouts between linear and striped/raid
diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 5dd0e6f..2688bcf 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -178,7 +178,8 @@ static int _get_segment_status_from_target_params(const char *target_name,
 	}
 
 	/* Validate target_name segtype from DM table with lvm2 metadata segtype */
-	if (strcmp(segtype->name, target_name) &&
+	if (!lv_is_locked(seg->lv) &&
+	    strcmp(segtype->name, target_name) &&
 	    /* If kernel's type isn't an exact match is it compatible? */
 	    (!segtype->ops->target_status_compatible ||
 	     !segtype->ops->target_status_compatible(target_name))) {


