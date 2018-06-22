From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 22 Jun 2018 09:08:09 -0400
Subject: 2018-06-01-stable - pvmove: improve lvs
Message-ID: <201806221308.w5MD89sO019678@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=39fc98d7314b8bf4b66118b7ae72674383209c1f
Commit:        39fc98d7314b8bf4b66118b7ae72674383209c1f
Parent:        5503699c3701ed4875c274f12b8fdd6b099db71b
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Jun 4 11:05:28 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jun 22 12:37:59 2018 +0200

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
index fff7222..d432cea 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.180 - 
 =================================
+  Avoid showing internal error in lvs output or pvmoved LVs.
   Fix check if resized PV can also fit metadata area.
   Reopen devices RDWR before writing to avoid udev issues.
   Fix mem leak in clvmd.
diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index a7947d8..d281b60 100644
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


