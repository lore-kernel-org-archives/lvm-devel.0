From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 3 May 2019 07:18:26 -0400
Subject: master - cleanup: use unsigned type
Message-ID: <201905031118.x43BIQft028347@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=d60d59a5f30e7f324eed9605a8c1c925fbce63e1
Commit:        d60d59a5f30e7f324eed9605a8c1c925fbce63e1
Parent:        7a5ea681fb57cd4bb7ba9db50e57bf2ee4e9ed8c
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri May 3 12:36:16 2019 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri May 3 13:17:22 2019 +0200

cleanup: use unsigned type

---
 lib/metadata/raid_manip.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 349d926..183435b 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -6471,7 +6471,7 @@ int lv_raid_convert(struct logical_volume *lv,
 		return_0;
 
 	region_size = new_region_size ? : seg->region_size;
-	region_size = region_size ? : get_default_region_size(lv->vg->cmd);
+	region_size = region_size ? : (uint32_t)get_default_region_size(lv->vg->cmd);
 
 	/*
 	 * Check acceptible options mirrors, region_size,


