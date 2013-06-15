From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sat, 15 Jun 2013 22:16:17 +0000 (UTC)
Subject: master - lvmetad: add some message for error path
Message-ID: <20130615221617.469F760D69@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=54e062265074766becc06d2fdb0020ade56cf95d
Commit:        54e062265074766becc06d2fdb0020ade56cf95d
Parent:        c2dc21d89fb1b60fd57fd471e3934132f4f53dc6
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jun 14 23:17:28 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun Jun 16 00:07:32 2013 +0200

lvmetad: add some message for error path

Do not leave replay uninitialized for internal error.
---
 lib/cache/lvmetad.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/lib/cache/lvmetad.c b/lib/cache/lvmetad.c
index 6c8b10b..a107047 100644
--- a/lib/cache/lvmetad.c
+++ b/lib/cache/lvmetad.c
@@ -345,6 +345,7 @@ struct volume_group *lvmetad_vg_lookup(struct cmd_context *cmd, const char *vgna
 	} else {
 		if (!vgname) {
 			log_error(INTERNAL_ERROR "VG name required (VGID not available)");
+			reply = _lvmetad_send("vg_lookup", "name = %s", "MISSING", NULL);
 			goto out;
 		}
 		log_debug_lvmetad("Asking lvmetad for VG %s", vgname);


