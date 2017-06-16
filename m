From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 16 Jun 2017 11:13:49 -0400
Subject: master - debug: passing non-raid seg would be internal error
Message-ID: <201706161513.v5GFDnjY011219@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=fbb3bffb221f3c0275bafef4f2cc7ea299214ef4
Commit:        fbb3bffb221f3c0275bafef4f2cc7ea299214ef4
Parent:        9e96f96a410c7ff977fa8593dff185fbe90615fe
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jun 16 16:24:38 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jun 16 17:04:02 2017 +0200

debug: passing non-raid seg would be internal error

---
 lib/metadata/lv.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/metadata/lv.c b/lib/metadata/lv.c
index 555df1a..c87bb6b 100644
--- a/lib/metadata/lv.c
+++ b/lib/metadata/lv.c
@@ -1096,7 +1096,7 @@ int lv_raid_healthy(const struct logical_volume *lv)
 	}
 
 	if (!seg_is_raid(raid_seg)) {
-		log_error("%s on %s is not a RAID segment",
+		log_error(INTERNAL_ERROR "%s on %s is not a RAID segment.",
 			  raid_seg->lv->name, lv->name);
 		return 0;
 	}


