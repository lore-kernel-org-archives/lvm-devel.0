From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 28 Aug 2020 19:59:14 +0000 (GMT)
Subject: master - gcc: avoid stack alloc arithmetic
Message-ID: <20200828195914.3591B3948804@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=fd8d926fc52badc93f7985b5db2f4cb6a75e81e4
Commit:        fd8d926fc52badc93f7985b5db2f4cb6a75e81e4
Parent:        ce202c3b1c018a001015fa2ff69a01f06d84a6fa
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Aug 28 18:46:06 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Aug 28 21:43:02 2020 +0200

gcc: avoid stack alloc arithmetic

---
 tools/lvconvert.c | 9 +++------
 1 file changed, 3 insertions(+), 6 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 524ed5a33..afc581377 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -1161,6 +1161,8 @@ static int _lvconvert_validate_thin(struct logical_volume *lv,
 static int _raid_split_image_conversion(struct logical_volume *lv)
 {
 	const char *s;
+	char raidlv_name[NAME_LEN];
+	const struct logical_volume *tmp_lv;
 
 	if (lv_is_raid_with_tracking(lv)) {
 		log_error("Conversion of tracking raid1 LV %s is not supported.",
@@ -1170,12 +1172,7 @@ static int _raid_split_image_conversion(struct logical_volume *lv)
 
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


