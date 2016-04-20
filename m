From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 20 Apr 2016 22:35:56 +0000 (UTC)
Subject: master - lvmetad: fix compilation without lvmetad#
Message-ID: <20160420223556.2CB5C61027@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=2763b928de9b79ed9e144950446e59c0cac36a03
Commit:        2763b928de9b79ed9e144950446e59c0cac36a03
Parent:        7ce486e881a96db24a1f46a99110b0eb7009b0de
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Apr 21 00:16:17 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Apr 21 00:34:01 2016 +0200

lvmetad: fix compilation without lvmetad#

---
 lib/cache/lvmetad.h |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/lib/cache/lvmetad.h b/lib/cache/lvmetad.h
index 82371d9..699c9a4 100644
--- a/lib/cache/lvmetad.h
+++ b/lib/cache/lvmetad.h
@@ -154,8 +154,8 @@ void lvmetad_clear_disabled(struct cmd_context *cmd);
 #  else		/* LVMETAD_SUPPORT */
 
 #    define lvmetad_disconnect()	do { } while (0)
-#    define lvmetad_connect(cmd)	do { } while (0)
-#    define lvmetad_make_unused()	do { } while (0)
+#    define lvmetad_connect(cmd)	(0)
+#    define lvmetad_make_unused(cmd)	do { } while (0)
 #    define lvmetad_used()		(0)
 #    define lvmetad_set_socket(a)	do { } while (0)
 #    define lvmetad_socket_present()	(0)
@@ -175,7 +175,7 @@ void lvmetad_clear_disabled(struct cmd_context *cmd);
 #    define lvmetad_pvscan_single(cmd, dev, handler, ignore_obsolete)	(0)
 #    define lvmetad_pvscan_all_devs(cmd, handler, do_wait)	(0)
 #    define lvmetad_pvscan_foreign_vgs(cmd, handler)	(0)
-#    define lvmetad_vg_clear_outdated_pvs(vg)           (1)
+#    define lvmetad_vg_clear_outdated_pvs(vg)           do { } while (0)
 #    define lvmetad_validate_global_cache(cmd, force)	do { } while (0)
 #    define lvmetad_vg_is_foreign(cmd, vgname, vgid) (0)
 #    define lvmetad_token_matches(cmd) (1)


