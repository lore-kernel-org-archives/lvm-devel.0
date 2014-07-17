From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 17 Jul 2014 14:29:17 +0000 (UTC)
Subject: master - raid: support lvdisplay --maps
Message-ID: <20140717142917.A170960DBB@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=321592af71686b8963a6bae276533f4f19946578
Commit:        321592af71686b8963a6bae276533f4f19946578
Parent:        cac0722cacaac06ac1211194f1d6c21572a32998
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Jul 16 23:55:46 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jul 17 16:18:34 2014 +0200

raid: support lvdisplay --maps

Add legs printing for --maps
Somewhat similar to mirror support - maybe there are more things to
show...
---
 lib/raid/raid.c |   16 ++++++++++++++++
 1 files changed, 16 insertions(+), 0 deletions(-)

diff --git a/lib/raid/raid.c b/lib/raid/raid.c
index 33ba5b7..c3f5c3f 100644
--- a/lib/raid/raid.c
+++ b/lib/raid/raid.c
@@ -30,6 +30,21 @@ static const char *_raid_name(const struct lv_segment *seg)
 	return seg->segtype->name;
 }
 
+static void _raid_display(const struct lv_segment *seg)
+{
+	unsigned s;
+
+	for (s = 0; s < seg->area_count; ++s) {
+		log_print("  Raid Data LV%2d", s);
+		display_stripe(seg, s, "    ");
+	}
+
+	for (s = 0; s < seg->area_count; ++s)
+		log_print("  Raid Metadata LV%2d\t%s", s, seg_metalv(seg, s)->name);
+
+	log_print(" ");
+}
+
 static int _raid_text_import_area_count(const struct dm_config_node *sn,
 					uint32_t *area_count)
 {
@@ -404,6 +419,7 @@ static int _raid_target_unmonitor_events(struct lv_segment *seg, int events)
 
 static struct segtype_handler _raid_ops = {
 	.name = _raid_name,
+	.display = _raid_display,
 	.text_import_area_count = _raid_text_import_area_count,
 	.text_import = _raid_text_import,
 	.text_export = _raid_text_export,


