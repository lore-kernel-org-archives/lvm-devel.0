From: Petr Rockai <mornfall@fedoraproject.org>
Date: Mon,  9 Jun 2014 00:35:26 +0000 (UTC)
Subject: master - pvremove: Update lvmcache => avoid spurious error messages.
Message-ID: <20140609003526.8A91760DC3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ee200ddfc376bbfb332439f64ced54ce450535dd
Commit:        ee200ddfc376bbfb332439f64ced54ce450535dd
Parent:        02e1bf406b2fc9731b2f67c273acd8f21df64714
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Sun Jun 8 22:57:04 2014 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Sun Jun 8 22:57:04 2014 +0200

pvremove: Update lvmcache => avoid spurious error messages.

---
 lib/cache/lvmcache.c            |    5 ++---
 lib/metadata/pv_manip.c         |    6 ++++++
 test/shell/pvremove-warnings.sh |   16 ++++++++++++++++
 3 files changed, 24 insertions(+), 3 deletions(-)

diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index c61bb77..3244205 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -1062,7 +1062,6 @@ static int _drop_vginfo(struct lvmcache_info *info, struct lvmcache_vginfo *vgin
 	return 1;
 }
 
-/* Unused
 void lvmcache_del(struct lvmcache_info *info)
 {
 	if (info->dev->pvid[0] && _pvid_hash)
@@ -1071,11 +1070,11 @@ void lvmcache_del(struct lvmcache_info *info)
 	_drop_vginfo(info, info->vginfo);
 
 	info->label->labeller->ops->destroy_label(info->label->labeller,
-						info->label);
+						  info->label);
 	dm_free(info);
 
 	return;
-} */
+}
 
 static int _lvmcache_update_pvid(struct lvmcache_info *info, const char *pvid)
 {
diff --git a/lib/metadata/pv_manip.c b/lib/metadata/pv_manip.c
index 3613515..2717031 100644
--- a/lib/metadata/pv_manip.c
+++ b/lib/metadata/pv_manip.c
@@ -733,6 +733,7 @@ int pvremove_single(struct cmd_context *cmd, const char *pv_name,
 	            unsigned prompt)
 {
 	struct device *dev;
+	struct lvmcache_info *info;
 	int r = 0;
 
 	if (!lock_vol(cmd, VG_ORPHANS, LCK_VG_WRITE, NULL)) {
@@ -749,6 +750,8 @@ int pvremove_single(struct cmd_context *cmd, const char *pv_name,
 		goto out;
 	}
 
+	info = lvmcache_info_from_pvid(dev->pvid, 1);
+
 	if (!dev_test_excl(dev)) {
 		/* FIXME Detect whether device-mapper is still using the device */
 		log_error("Can't open %s exclusively - not removing. "
@@ -762,6 +765,9 @@ int pvremove_single(struct cmd_context *cmd, const char *pv_name,
 		goto out;
 	}
 
+	if (info)
+		lvmcache_del(info);
+
 	if (!lvmetad_pv_gone_by_dev(dev, NULL))
 		goto_out;
 
diff --git a/test/shell/pvremove-warnings.sh b/test/shell/pvremove-warnings.sh
new file mode 100644
index 0000000..c9b7c6a
--- /dev/null
+++ b/test/shell/pvremove-warnings.sh
@@ -0,0 +1,16 @@
+# Copyright (C) 2014 Red Hat, Inc. All rights reserved.
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
+aux prepare_devs 2
+pvcreate "$dev1" "$dev2"
+pvremove "$dev1" "$dev2" 2>&1 | tee pvremove.txt
+not grep "No physical" pvremove.txt


