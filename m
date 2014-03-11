From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 11 Mar 2014 23:34:25 +0000 (UTC)
Subject: master - thin: add pool uuid suffix for pool volume
Message-ID: <20140311233425.2B60960EDF@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=4cc5c689b8600fa8490b2f1d60e483362b10c700
Commit:        4cc5c689b8600fa8490b2f1d60e483362b10c700
Parent:        8a60cbcf45c553dfc168552cf9af3059359ec95d
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Mar 11 17:14:01 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Mar 12 00:16:27 2014 +0100

thin: add pool uuid suffix for pool volume

Even though we make pool volume as a public visible LV,
we still do not want tools to look at this volume.

While we do not create /dev/vg/lv link, device is still
accessible via /dev/mapper/vg-lv and there is no easy
way to recognize it's private without lvm2 metadata.

Enhance UUID with -pool suffix and directly skip
any LV with a suffix in  device_is_usable() call.

TODO: enhance other targets with this logic.
blkid may probably use same simple logic.
---
 lib/activate/dev_manager.c |    6 ++++++
 lib/misc/lvm-string.c      |    3 +++
 2 files changed, 9 insertions(+), 0 deletions(-)

diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index e9729d4..c723a61 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -446,6 +446,12 @@ static int _device_is_usable(struct device *dev, int check_lv_names)
 		    !dm_split_lvm_name(NULL, NULL, &vgname, &lvname, &layer))
 			goto_out;
 
+		if (strlen(uuid) > 68) {
+			log_debug_activation("%s: Reserved uuid %s on internal LV device %s/%s%s%s not usable.",
+					     dev_name(dev), uuid, vgname, lvname, *layer ? "-" : "", layer);
+			goto out;
+		}
+
 		if (lvname && (is_reserved_lvname(lvname) || *layer)) {
 			log_debug_activation("%s: Reserved internal LV device %s/%s%s%s not usable.",
 					     dev_name(dev), vgname, lvname, *layer ? "-" : "", layer);
diff --git a/lib/misc/lvm-string.c b/lib/misc/lvm-string.c
index 329dee5..b96b5cc 100644
--- a/lib/misc/lvm-string.c
+++ b/lib/misc/lvm-string.c
@@ -166,5 +166,8 @@ char *build_dm_uuid(struct dm_pool *mem, const struct logical_volume *lv,
 {
 	const char *lvid = lv->lvid.s;
 
+	if (!layer && lv_is_thin_pool(lv))
+		layer = "pool";
+
 	return dm_build_dm_uuid(mem, UUID_PREFIX, lvid, layer);
 }


