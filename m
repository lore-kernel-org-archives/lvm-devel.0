From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 15 Sep 2021 13:26:27 +0000 (GMT)
Subject: main - clang: keep metaname initialized
Message-ID: <20210915132627.9AA383858413@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=dd5f8b3f8c18ff57525ec5c5b35c6e1d218b1000
Commit:        dd5f8b3f8c18ff57525ec5c5b35c6e1d218b1000
Parent:        1a5c79d1d18cf887646edbdd7e798d93a2f9783f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Sep 15 14:07:19 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Sep 15 15:24:56 2021 +0200

clang: keep metaname initialized

Never access uninitialized metaname buffer.
---
 lib/metadata/integrity_manip.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/lib/metadata/integrity_manip.c b/lib/metadata/integrity_manip.c
index c2fd7504c..e053ac5f6 100644
--- a/lib/metadata/integrity_manip.c
+++ b/lib/metadata/integrity_manip.c
@@ -86,7 +86,7 @@ static int _lv_create_integrity_metadata(struct cmd_context *cmd,
 				struct lvcreate_params *lp,
 				struct logical_volume **meta_lv)
 {
-	char metaname[NAME_LEN];
+	char metaname[NAME_LEN] = { 0 };
 	uint64_t lv_size_bytes, meta_bytes, meta_sectors;
 	struct logical_volume *lv;
 	struct lvcreate_params lp_meta = {


