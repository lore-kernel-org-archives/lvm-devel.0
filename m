From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu,  3 Sep 2015 21:36:19 +0000 (UTC)
Subject: master - cleanup: show error message
Message-ID: <20150903213619.DD19D60F7F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=32d6ca9196591d7f4d820e373fd14fd0f2301914
Commit:        32d6ca9196591d7f4d820e373fd14fd0f2301914
Parent:        20e317cf92d0760c8e1052dc975a14645aecfd84
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Aug 26 14:14:44 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Sep 3 23:34:36 2015 +0200

cleanup: show error message

Add error message on error path.
---
 lib/metadata/raid_manip.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 8ecdc02..118bd06 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -397,8 +397,10 @@ static struct logical_volume *_alloc_image_component(struct logical_volume *lv,
 	}
 
 	if (dm_snprintf(img_name, sizeof(img_name), "%s_%s_%%d",
-			(alt_base_name) ? : lv->name, type_suffix) < 0)
-		return_0;
+			(alt_base_name) ? : lv->name, type_suffix) < 0) {
+		log_error("Component name for raid %s is too long.", lv->name);
+		return 0;
+	}
 
 	status = LVM_READ | LVM_WRITE | LV_REBUILD | type;
 	if (!(tmp_lv = lv_create_empty(img_name, NULL, status, ALLOC_INHERIT, lv->vg))) {


