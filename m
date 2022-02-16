From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 16 Feb 2022 00:03:11 +0000 (GMT)
Subject: main - clang: add extra check
Message-ID: <20220216000311.2D38D3858C1F@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=d2e7a05573f54750d13c1154036ae2c67478539b
Commit:        d2e7a05573f54750d13c1154036ae2c67478539b
Parent:        c2679f76e5c1733451361b593fa45ba9545250b1
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Feb 8 19:17:30 2022 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Feb 16 01:00:36 2022 +0100

clang: add extra check

Make clang happier.
---
 lib/metadata/metadata.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index db0e511ec..1cda1888f 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -2197,7 +2197,7 @@ static int _validate_lock_args_chars(const char *lock_args)
 
 static int _validate_vg_lock_args(struct volume_group *vg)
 {
-	if (!_validate_lock_args_chars(vg->lock_args)) {
+	if (!vg->lock_args || !_validate_lock_args_chars(vg->lock_args)) {
 		log_error(INTERNAL_ERROR "VG %s has invalid lock_args chars", vg->name);
 		return 0;
 	}


