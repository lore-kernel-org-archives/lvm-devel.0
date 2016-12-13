From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 13 Dec 2016 21:09:49 +0000 (UTC)
Subject: master - cleanup: allocate NAME_LEN size for lv name
Message-ID: <20161213210949.CD32660C42@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=47b96c3537968caf0cfb8ffa3874d64944715bec
Commit:        47b96c3537968caf0cfb8ffa3874d64944715bec
Parent:        d0fe3ec0c58ccd5dfcc4f5fd40ddabab0c9defe5
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Dec 13 00:09:38 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Dec 13 22:07:52 2016 +0100

cleanup: allocate NAME_LEN size for lv name

---
 lib/metadata/raid_manip.c |   18 ++++++++++--------
 1 files changed, 10 insertions(+), 8 deletions(-)

diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index c70ce3e..b8a47c0 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -548,18 +548,15 @@ static char *_generate_raid_name(struct logical_volume *lv,
 				 const char *suffix, int count)
 {
 	const char *format = (count >= 0) ? "%s_%s_%u" : "%s_%s";
-	size_t len = strlen(lv->name) + strlen(suffix) + ((count >= 0) ? 5 : 2);
-	char *name;
+	char name[NAME_LEN], *lvname;
 	int historical;
 
-	if (!(name = dm_pool_alloc(lv->vg->vgmem, len))) {
-		log_error("Failed to allocate new name.");
+	if (dm_snprintf(name, sizeof(name), format, lv->name, suffix, count) < 0) {
+		log_error("Failed to new raid name for %s.",
+			  display_lvname(lv));
 		return NULL;
 	}
 
-	if (dm_snprintf(name, len, format, lv->name, suffix, count) < 0)
-		return_NULL;
-
 	if (!validate_name(name)) {
 		log_error("New logical volume name \"%s\" is not valid.", name);
 		return NULL;
@@ -571,7 +568,12 @@ static char *_generate_raid_name(struct logical_volume *lv,
 		return NULL;
 	}
 
-	return name;
+	if (!(lvname = dm_pool_strdup(lv->vg->vgmem, name))) {
+		log_error("Failed to allocate new name.");
+		return NULL;
+	}
+
+	return lvname;
 }
 /*
  * Create an LV of specified type.  Set visible after creation.


