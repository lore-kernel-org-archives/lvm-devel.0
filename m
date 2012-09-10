From: Jonathan Brassow <jbrassow@fedoraproject.org>
Date: Mon, 10 Sep 2012 22:19:33 +0000 (UTC)
Subject: master - RAID: Disallow addition of RAID images while array is not in-sync
Message-ID: <20120910221933.BA04252C@hosted02.fedoraproject.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=cdb0339319c89b8d1e5611537e9775a8c3ce5844
Commit:        cdb0339319c89b8d1e5611537e9775a8c3ce5844
Parent:        b49b98d50c558a142d0a2ef55279eea00bd36eba
Author:        Jonathan Brassow <jbrassow@redhat.com>
AuthorDate:    Mon Sep 10 17:15:20 2012 -0500
Committer:     Jonathan Brassow <jbrassow@redhat.com>
CommitterDate: Mon Sep 10 17:15:20 2012 -0500

RAID:  Disallow addition of RAID images while array is not in-sync

We cannot add images to a RAID array while it is not in-sync.  The
kernel will simply reject the table, saying:
	'rebuild' specified while array is not in-sync
Now we check to ensure the LV is in-sync before attempting image
additions.
---
 lib/metadata/raid_manip.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index b5552cb..4eced6f 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -663,6 +663,10 @@ static int _raid_add_images(struct logical_volume *lv,
 		log_error("Unable to add RAID images to %s of segment type %s",
 			  lv->name, seg->segtype->ops->name(seg));
 		return 0;
+	} else if (!_raid_in_sync(lv)) {
+		log_error("Unable to add RAID images until %s is in-sync",
+			  lv->name);
+		return 0;
 	}
 
 	if (!_alloc_image_components(lv, pvs, count, &meta_lvs, &data_lvs)) {


