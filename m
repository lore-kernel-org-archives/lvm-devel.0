From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 10 Mar 2021 00:36:46 +0000 (GMT)
Subject: main - cov: ensure settings is set
Message-ID: <20210310003646.CD1433858038@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a66380ea3ebcdb21e5b63f5991810e421092b245
Commit:        a66380ea3ebcdb21e5b63f5991810e421092b245
Parent:        f7912635a0698b73120adf499f335145506a8b9e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Mar 9 16:32:36 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Mar 10 01:35:02 2021 +0100

cov: ensure settings is set

---
 lib/report/properties.c | 17 ++++++++++-------
 lib/report/report.c     |  9 +++++----
 2 files changed, 15 insertions(+), 11 deletions(-)

diff --git a/lib/report/properties.c b/lib/report/properties.c
index 82a6a7856..f2174b83c 100644
--- a/lib/report/properties.c
+++ b/lib/report/properties.c
@@ -93,23 +93,26 @@ static uint32_t _raidmaxrecoveryrate(const struct logical_volume *lv)
 
 static const char *_raidintegritymode(const struct logical_volume *lv)
 {
-	struct integrity_settings *settings;
+	struct integrity_settings *settings = NULL;
 
 	if (lv_raid_has_integrity((struct logical_volume *)lv))
 		lv_get_raid_integrity_settings((struct logical_volume *)lv, &settings);
 	else if (lv_is_integrity(lv))
 		settings = &first_seg(lv)->integrity_settings;
 
-	if (settings->mode[0] == 'B')
-		return "bitmap";
-	if (settings->mode[0] == 'J')
-		return "journal";
+	if (settings) {
+		switch (settings->mode[0]) {
+		case 'B': return "bitmap";
+		case 'J': return "journal";
+		}
+	}
+
 	return "unknown";
 }
 
 static uint32_t _raidintegrityblocksize(const struct logical_volume *lv)
 {
-	struct integrity_settings *settings;
+	struct integrity_settings *settings = NULL;
 
 	if (lv_raid_has_integrity((struct logical_volume *)lv))
 		lv_get_raid_integrity_settings((struct logical_volume *)lv, &settings);
@@ -118,7 +121,7 @@ static uint32_t _raidintegrityblocksize(const struct logical_volume *lv)
 	else
 		return 0;
 
-	return settings->block_size;
+	return (settings) ? settings->block_size : 0;
 }
 
 static uint64_t _integritymismatches(const struct logical_volume *lv)
diff --git a/lib/report/report.c b/lib/report/report.c
index 80fae2147..2f5811a96 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -3278,7 +3278,7 @@ static int _raidintegritymode_disp(struct dm_report *rh __attribute__((unused)),
 				   void *private __attribute__((unused)))
 {
 	struct logical_volume *lv = (struct logical_volume *) data;
-	struct integrity_settings *settings;
+	struct integrity_settings *settings = NULL;
 	const char *mode = NULL;
 	char *repstr;
 
@@ -3289,7 +3289,7 @@ static int _raidintegritymode_disp(struct dm_report *rh __attribute__((unused)),
 	else
 		goto out;
 
-	if (settings->mode[0]) {
+	if (settings && settings->mode[0]) {
 		if (settings->mode[0] == 'B')
 			mode = "bitmap";
 		else if (settings->mode[0] == 'J')
@@ -3314,13 +3314,14 @@ static int _raidintegrityblocksize_disp(struct dm_report *rh __attribute__((unus
 				   void *private __attribute__((unused)))
 {
 	struct logical_volume *lv = (struct logical_volume *) data;
-	struct integrity_settings *settings;
+	struct integrity_settings *settings = NULL;
 
 	if (lv_raid_has_integrity(lv))
 		lv_get_raid_integrity_settings(lv, &settings);
 	else if (lv_is_integrity(lv))
 		settings = &first_seg(lv)->integrity_settings;
-	else
+
+	if (!settings)
 		return dm_report_field_int32(rh, field, &GET_TYPE_RESERVED_VALUE(num_undef_32));
 
 	return dm_report_field_uint32(rh, field, &settings->block_size);


