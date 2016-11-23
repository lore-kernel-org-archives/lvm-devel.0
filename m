From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 23 Nov 2016 16:56:03 +0000 (UTC)
Subject: master - cleanup: use predefined macro for tmp image name
Message-ID: <20161123165603.4560B60F9E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d05668c587348461b1fe86858a7b7044ccf687b1
Commit:        d05668c587348461b1fe86858a7b7044ccf687b1
Parent:        c621bc3d36ee4a9fff18e7e83c5c5ac3c1e09d4f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Nov 23 10:39:59 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Nov 23 17:55:03 2016 +0100

cleanup: use predefined macro for tmp image name

---
 lib/metadata/lv_manip.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 8c8888e..2a02ad2 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -6574,7 +6574,7 @@ struct logical_volume *insert_layer_for_lv(struct cmd_context *cmd,
 	if (lv_is_active_exclusive_locally(lv_where))
 		exclusive = 1;
 
-	if (lv_is_active(lv_where) && strstr(name, "_mimagetmp")) {
+	if (lv_is_active(lv_where) && strstr(name, MIRROR_SYNC_LAYER)) {
 		log_very_verbose("Creating transient LV %s for mirror conversion in VG %s.", name, lv_where->vg->name);
 
 		segtype = get_segtype_from_string(cmd, SEG_TYPE_NAME_ERROR);


