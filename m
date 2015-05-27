From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 27 May 2015 09:59:51 +0000 (UTC)
Subject: master - lvmetad: missing wrapper for lvmetad less compilation
Message-ID: <20150527095951.30CFC60BAB@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6e4c04b1becf171d6c337771839cf5a82bd901c0
Commit:        6e4c04b1becf171d6c337771839cf5a82bd901c0
Parent:        d3abc25e76d351b1269f55ff524368eb4ddf00b1
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed May 27 11:44:33 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed May 27 11:44:33 2015 +0200

lvmetad: missing wrapper for lvmetad less compilation

---
 lib/cache/lvmetad.h |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/lib/cache/lvmetad.h b/lib/cache/lvmetad.h
index 4ee07bb..6769f76 100644
--- a/lib/cache/lvmetad.h
+++ b/lib/cache/lvmetad.h
@@ -185,6 +185,7 @@ int lvmetad_pvscan_foreign_vgs(struct cmd_context *cmd, activation_handler handl
 #    define lvmetad_pv_lookup(cmd, pvid, found)	(0)
 #    define lvmetad_pv_lookup_by_dev(cmd, dev, found)	(0)
 #    define lvmetad_vg_list_to_lvmcache(cmd)	(1)
+#    define lvmetad_get_vgnameids(cmd, vgnameids)       do { } while (0)
 #    define lvmetad_vg_lookup(cmd, vgname, vgid)	(NULL)
 #    define lvmetad_pvscan_single(cmd, dev, handler, ignore_obsolete)	(0)
 #    define lvmetad_pvscan_all_devs(cmd, handler)	(0)


