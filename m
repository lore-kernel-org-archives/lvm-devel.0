From: David Teigland <teigland@fedoraproject.org>
Date: Mon, 22 Sep 2014 15:37:51 +0000 (UTC)
Subject: dev-dct-process-latest - raid: add function for name creation
Message-ID: <20140922153751.2056960EE6@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=2db0312455260cda6f45ee8d3814a00f3f297af0
Commit:        2db0312455260cda6f45ee8d3814a00f3f297af0
Parent:        40b7b107b186e1680db05dcb05230b978852d010
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Sep 12 11:30:00 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Sep 12 13:51:29 2014 +0200

raid: add function for name creation

Add name for construction and validation of raid subvolume
name with a given suffix.

TODO: check if reusable for mirrors as well.
---
 lib/metadata/raid_manip.c |   29 +++++++++++++++++++++++++++++
 1 files changed, 29 insertions(+), 0 deletions(-)

diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index b7ba464..bff6e59 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -320,6 +320,35 @@ static int _shift_and_rename_image_components(struct lv_segment *seg)
 	return 1;
 }
 
+/* Generate raid subvolume name and validate it */
+static char *_generate_raid_name(struct logical_volume *lv,
+				 const char *suffix, int count)
+{
+	const char *format = (count >= 0) ? "%s_%s_%u" : "%s_%s";
+	size_t len = strlen(lv->name) + strlen(suffix) + ((count >= 0) ? 5 : 2);
+	char *name;
+
+	if (!(name = dm_pool_alloc(lv->vg->vgmem, len))) {
+		log_error("Failed to allocate new name.");
+		return NULL;
+	}
+
+	if (dm_snprintf(name, len, format, lv->name, suffix, count) < 0)
+		return_NULL;
+
+	if (!validate_name(name)) {
+		log_error("New logical volume name \"%s\" is not valid.", name);
+		return NULL;
+	}
+
+	if (find_lv_in_vg(lv->vg, name)) {
+		log_error("Logical volume %s already exists in volume group %s.",
+			  name, lv->vg->name);
+		return NULL;
+	}
+
+	return name;
+}
 /*
  * Create an LV of specified type.  Set visible after creation.
  * This function does not make metadata changes.


