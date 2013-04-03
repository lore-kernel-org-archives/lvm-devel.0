From: Petr Rockai <mornfall@fedoraproject.org>
Date: Wed,  3 Apr 2013 09:42:04 +0000 (UTC)
Subject: master - lvmetad: Mark PVs visible to lvmetad but not to us as MISSING.
Message-ID: <20130403094204.1D0363721@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=00ed6759c8cbf2f4497fa0d5f7df69780159539a
Commit:        00ed6759c8cbf2f4497fa0d5f7df69780159539a
Parent:        6ac4cba276e8d7842e4efedc117f4b9aafa90c71
Author:        Petr Rockai <me@mornfall.net>
AuthorDate:    Wed Apr 3 11:10:52 2013 +0200
Committer:     Petr Rockai <me@mornfall.net>
CommitterDate: Wed Apr 3 11:40:29 2013 +0200

lvmetad: Mark PVs visible to lvmetad but not to us as MISSING.

---
 lib/cache/lvmetad.c            |    6 +++++-
 test/shell/lvcreate-missing.sh |   19 +++++++++++++++++++
 2 files changed, 24 insertions(+), 1 deletions(-)

diff --git a/lib/cache/lvmetad.c b/lib/cache/lvmetad.c
index 3cde71e..a7354a7 100644
--- a/lib/cache/lvmetad.c
+++ b/lib/cache/lvmetad.c
@@ -387,14 +387,18 @@ struct volume_group *lvmetad_vg_lookup(struct cmd_context *cmd, const char *vgna
 			if ((info = lvmcache_info_from_pvid((const char *)&pvl->pv->id, 0))) {
 				pvl->pv->label_sector = lvmcache_get_label(info)->sector;
 				pvl->pv->dev = lvmcache_device(info);
+				if (!pvl->pv->dev)
+					pvl->pv->status |= MISSING_PV;
 				if (!lvmcache_fid_add_mdas_pv(info, fid)) {
 					vg = NULL;
 					goto_out;	/* FIXME error path */
 				}
-			} /* else probably missing */
+			} else
+				pvl->pv->status |= MISSING_PV; /* probably missing */
 		}
 
 		lvmcache_update_vg(vg, 0);
+		vg_mark_partial_lvs(vg, 1);
 	}
 
 out:
diff --git a/test/shell/lvcreate-missing.sh b/test/shell/lvcreate-missing.sh
new file mode 100644
index 0000000..63471c3
--- /dev/null
+++ b/test/shell/lvcreate-missing.sh
@@ -0,0 +1,19 @@
+#!/bin/sh
+# Copyright (C) 2013 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+. lib/test
+
+aux prepare_vg 2
+init_udev_transaction
+dmsetup remove -f "$dev1" || true
+finish_udev_transaction
+
+not lvcreate -n "foo" $vg -l 1


