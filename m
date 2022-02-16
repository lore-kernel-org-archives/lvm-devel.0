From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 16 Feb 2022 00:03:10 +0000 (GMT)
Subject: main - dev_manager: failing status is not internal error
Message-ID: <20220216000310.0D3683858C2D@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=c2679f76e5c1733451361b593fa45ba9545250b1
Commit:        c2679f76e5c1733451361b593fa45ba9545250b1
Parent:        6ffb150f3075da69597e6f3e84d7533f2d8a36fa
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Feb 15 21:16:10 2022 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Feb 16 01:00:36 2022 +0100

dev_manager: failing status is not internal error

Different target type for LV it's not an internal error.
i.e.  when target type is replaced with 'error' type - it should be
reported as regular warning and not cause interruption of command with
internall error.
---
 lib/activate/dev_manager.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 3fd6aaff7..4d18d9838 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -204,7 +204,7 @@ static int _get_segment_status_from_target_params(const char *target_name,
 	    /* If kernel's type isn't an exact match is it compatible? */
 	    (!segtype->ops->target_status_compatible ||
 	     !segtype->ops->target_status_compatible(target_name))) {
-		log_warn(INTERNAL_ERROR "WARNING: Segment type %s found does not match expected type %s for %s.",
+		log_warn("WARNING: Detected %s segment type does not match expected type %s for %s.",
 			 target_name, segtype->name, display_lvname(seg_status->seg->lv));
 		return 0;
 	}


