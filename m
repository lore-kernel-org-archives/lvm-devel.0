From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 16 Oct 2020 19:10:47 +0000 (GMT)
Subject: stable-2.02 - gcc: avoid stack alloc arithmetic
Message-ID: <20201016191047.2205138618E8@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=d48266b7fba54f7d57f233f51e9f084fbff69956
Commit:        d48266b7fba54f7d57f233f51e9f084fbff69956
Parent:        90a9a7785e7ad82f6878bb0520989b5b3df00f22
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Aug 28 18:46:06 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Oct 16 16:02:05 2020 +0200

gcc: avoid stack alloc arithmetic

---
 tools/lvconvert.c | 9 +++------
 1 file changed, 3 insertions(+), 6 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index fc740fb3e..014163f49 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -1173,6 +1173,8 @@ static int _lvconvert_validate_thin(struct logical_volume *lv,
 static int _raid_split_image_conversion(struct logical_volume *lv)
 {
 	const char *s;
+	char raidlv_name[NAME_LEN];
+	const struct logical_volume *tmp_lv;
 
 	if (lv_is_raid_with_tracking(lv)) {
 		log_error("Conversion of tracking raid1 LV %s is not supported.",
@@ -1182,12 +1184,7 @@ static int _raid_split_image_conversion(struct logical_volume *lv)
 
 	if (lv_is_raid_image(lv) &&
 	    (s = strstr(lv->name, "_rimage_"))) {
-		size_t len = s - lv->name;
-		char raidlv_name[len + 1];
-		const struct logical_volume *tmp_lv;
-
-		strncpy(raidlv_name, lv->name, len);
-		raidlv_name[len] = '\0';
+		(void) dm_strncpy(raidlv_name, lv->name, s - lv->name);
 
 		if (!(tmp_lv = find_lv(lv->vg, raidlv_name))) {
 			log_error(INTERNAL_ERROR "Failed to find RaidLV of RAID subvolume %s.",


