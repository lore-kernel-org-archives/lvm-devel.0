From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 23 Apr 2021 21:05:55 +0000 (GMT)
Subject: main - cov: fix typo and reduce stack usage
Message-ID: <20210423210555.1F7B139450F4@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=86a3a0c76543d377194d4e86ea31a1a4184e0dc6
Commit:        86a3a0c76543d377194d4e86ea31a1a4184e0dc6
Parent:        e1287c3b711d9d77221b0114dbb5ebd84c09ca48
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Apr 22 15:27:58 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Apr 23 23:00:55 2021 +0200

cov: fix typo and reduce stack usage

Buffer on stack was for single LV name plus some  short text around.
Use of 50* was a typo so use correly 50+.
---
 lib/metadata/lv_manip.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index ff2a673eb..cb6f09362 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -6558,7 +6558,7 @@ static int _lv_remove_check_in_use(struct logical_volume *lv, force_t force)
 {
 	struct volume_group *vg = lv->vg;
 	const char *volume_type = "";
-	char buffer[50 * NAME_LEN * 2] = "";
+	char buffer[50 + NAME_LEN * 2] = "";
 	int active;
 	int issue_discards =
 		(vg->cmd->current_settings.issue_discards &&


