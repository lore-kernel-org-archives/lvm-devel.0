From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Sat,  6 May 2023 20:46:06 +0000 (GMT)
Subject: main - cov: validata top_lv
Message-ID: <20230506204606.4EBC63858D35@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=242bf56413f67dc3dd16770d420ced06eed0c4be
Commit:        242bf56413f67dc3dd16770d420ced06eed0c4be
Parent:        fae0ed8f10bc5771423f2b7af63690800de1ce9f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Apr 26 13:44:52 2023 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat May 6 19:22:05 2023 +0200

cov: validata top_lv

Add explicit pointer check is never NULL.
---
 lib/metadata/lv_manip.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 2dfa3c77b..8975bf180 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -5951,6 +5951,11 @@ static void _setup_params_for_extend_metadata(struct logical_volume *lv,
 
 static int _lv_resize_check_used(struct logical_volume *lv)
 {
+	if (!lv) {
+		log_error(INTERNAL_ERROR "LV is not specified.");
+		return 0;
+	}
+
 	if (lv_is_locked(lv)) {
 		log_error("Can't resize locked logical volume %s.", display_lvname(lv));
 		return 0;

