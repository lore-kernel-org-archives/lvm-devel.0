From: Heinz Mauelshagen <mauelsha@fedoraproject.org>
Date: Mon, 18 Jul 2016 18:17:05 +0000 (UTC)
Subject: master - lvconvert: raid0 replace attempt segfaults
Message-ID: <20160718181705.1930860C96@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=94207dfd68ca426d7cd4a8a0dc84e5a955d3a6d9
Commit:        94207dfd68ca426d7cd4a8a0dc84e5a955d3a6d9
Parent:        da49d4d54eac64a491b133bdb95e8dd04b6cde8f
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Mon Jul 18 20:16:40 2016 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Mon Jul 18 20:16:40 2016 +0200

lvconvert: raid0 replace attempt segfaults

Any failing stripes in raid0/raid0_meta type LVs cause data loss,
thus replacement via 'lvconvert --replace...' does not make sense.

Patch prohibits replacement on raid0/raid0_meta LVs.

- resolves rhbz1356734
---
 lib/metadata/raid_manip.c |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index feb8d6e..2dbbbe4 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -2829,6 +2829,12 @@ int lv_raid_replace(struct logical_volume *lv,
 	struct lv_list *lvl;
 	char *tmp_names[raid_seg->area_count * 2];
 
+	if (seg_is_any_raid0(raid_seg)) {
+		log_error("Can't replace any devices in %s LV %s",
+			  lvseg_name(raid_seg), display_lvname(lv));
+		return 0;
+	}
+
 	dm_list_init(&old_lvs);
 	dm_list_init(&new_meta_lvs);
 	dm_list_init(&new_data_lvs);


