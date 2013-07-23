From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 23 Jul 2013 12:58:58 +0000 (UTC)
Subject: master - thin: use 64bit arithmetic for checking meta size
Message-ID: <20130723125858.223F160E1D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6311be29e40af21a53ef2a09a99867fc4460a73e
Commit:        6311be29e40af21a53ef2a09a99867fc4460a73e
Parent:        e0856393c8a1c622871b07fb452fbbd7c0da537a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Jul 23 10:46:50 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Jul 23 14:58:07 2013 +0200

thin: use 64bit arithmetic for checking meta size

Avoid overflow since extents are just 32bit values.

(in release fix 87aca628)
---
 lib/metadata/lv_manip.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 8882a0a..9284c7b 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -3440,7 +3440,7 @@ static int _lvresize_poolmetadata(struct cmd_context *cmd, struct volume_group *
 		extents += lv->le_count;
 	}
 
-	if (extents * vg->extent_size > DM_THIN_MAX_METADATA_SIZE) {
+	if ((uint64_t)extents * vg->extent_size > DM_THIN_MAX_METADATA_SIZE) {
 		log_print_unless_silent("Rounding size to maximum supported size 16GiB "
 					"for metadata volume %s.", lv->name);
 		extents = (DM_THIN_MAX_METADATA_SIZE + vg->extent_size - 1) /


