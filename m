From: Petr Rockai <mornfall@fedoraproject.org>
Date: Tue,  6 Jan 2015 13:29:08 +0000 (UTC)
Subject: master - pvremove: Avoid metadata re-reads & related error messages.
Message-ID: <20150106132908.BC1C160522@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e97023804a8aa94d723025506fa23cf4a5c323e9
Commit:        e97023804a8aa94d723025506fa23cf4a5c323e9
Parent:        0987f290a7b53840c2811392868f050d9a632ea3
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Tue Jan 6 14:17:53 2015 +0100
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Tue Jan 6 14:27:30 2015 +0100

pvremove: Avoid metadata re-reads & related error messages.

---
 WHATS_NEW                        |    1 +
 lib/metadata/metadata-exported.h |    4 ++-
 lib/metadata/pv_manip.c          |   61 +++++++++++++++++++++++++++----------
 liblvm/lvm_pv.c                  |    9 +++++-
 test/shell/pvremove-warnings.sh  |    5 +++
 tools/pvremove.c                 |   15 +++++----
 6 files changed, 69 insertions(+), 26 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index c1a38c7..37611da 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.115 -
 =====================================
+  Avoid excessive re-reading of metadata and related error messages in pvremove.
   Check for cmirror availability during cluster mirror creation and activation.
   Add cache_policy and cache_settings reporting fields.
   Add missing recognition for --binary option with {pv,vg,lv}display -C.
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index b8946ba..14a5ef5 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -635,7 +635,9 @@ struct physical_volume *pv_create(const struct cmd_context *cmd,
 
 int pvremove_single(struct cmd_context *cmd, const char *pv_name,
 		    void *handle __attribute__((unused)), unsigned force_count,
-		    unsigned prompt);
+		    unsigned prompt, struct dm_list *pvslist);
+int pvremove_many(struct cmd_context *cmd, struct dm_list *pv_names,
+		  unsigned force_count, unsigned prompt);
 
 int pv_resize_single(struct cmd_context *cmd,
 			     struct volume_group *vg,
diff --git a/lib/metadata/pv_manip.c b/lib/metadata/pv_manip.c
index 6499e36..ce7f661 100644
--- a/lib/metadata/pv_manip.c
+++ b/lib/metadata/pv_manip.c
@@ -24,6 +24,7 @@
 #include "display.h"
 #include "label.h"
 #include "archiver.h"
+#include "lvm-signal.h"
 
 static struct pv_segment *_alloc_pv_segment(struct dm_pool *mem,
 					    struct physical_volume *pv,
@@ -694,12 +695,11 @@ const char _really_wipe[] =
  * 0 indicates we may not.
  */
 static int pvremove_check(struct cmd_context *cmd, const char *name,
-		unsigned force_count, unsigned prompt)
+			  unsigned force_count, unsigned prompt, struct dm_list *pvslist)
 {
 	struct device *dev;
 	struct label *label;
 	struct pv_list *pvl;
-	struct dm_list *pvslist;
 
 	struct physical_volume *pv = NULL;
 	int r = 0;
@@ -720,10 +720,6 @@ static int pvremove_check(struct cmd_context *cmd, const char *name,
 		return 0;
 	}
 
-	lvmcache_seed_infos_from_lvmetad(cmd);
-	if (!(pvslist = get_pvs(cmd)))
-		return_0;
-
 	dm_list_iterate_items(pvl, pvslist)
 		if (pvl->pv->dev == dev)
 			pv = pvl->pv;
@@ -765,26 +761,18 @@ static int pvremove_check(struct cmd_context *cmd, const char *name,
 
 	r = 1;
 out:
-	if (pvslist)
-		dm_list_iterate_items(pvl, pvslist)
-			free_pv_fid(pvl->pv);
 	return r;
 }
 
 int pvremove_single(struct cmd_context *cmd, const char *pv_name,
 		    void *handle __attribute__((unused)), unsigned force_count,
-	            unsigned prompt)
+	            unsigned prompt, struct dm_list *pvslist)
 {
 	struct device *dev;
 	struct lvmcache_info *info;
 	int r = 0;
 
-	if (!lock_vol(cmd, VG_ORPHANS, LCK_VG_WRITE, NULL)) {
-		log_error("Can't get lock for orphan PVs");
-		return 0;
-	}
-
-	if (!pvremove_check(cmd, pv_name, force_count, prompt))
+	if (!pvremove_check(cmd, pv_name, force_count, prompt, pvslist))
 		goto out;
 
 	if (!(dev = dev_cache_get(pv_name, cmd->filter))) {
@@ -820,9 +808,48 @@ int pvremove_single(struct cmd_context *cmd, const char *pv_name,
 	r = 1;
 
 out:
+	return r;
+}
+
+int pvremove_many(struct cmd_context *cmd, struct dm_list *pv_names,
+		  unsigned force_count, unsigned prompt)
+{
+	int ret = 1;
+	struct dm_list *pvslist = NULL;
+	struct pv_list *pvl;
+	const struct dm_str_list *pv_name;
+
+	if (!lock_vol(cmd, VG_ORPHANS, LCK_VG_WRITE, NULL)) {
+		log_error("Can't get lock for orphan PVs");
+		return 0;
+	}
+
+	lvmcache_seed_infos_from_lvmetad(cmd);
+
+	if (!(pvslist = get_pvs(cmd))) {
+		ret = 0;
+		goto_out;
+	}
+
+	dm_list_iterate_items(pv_name, pv_names) {
+		if (!pvremove_single(cmd, pv_name->str, NULL, force_count, prompt, pvslist)) {
+			stack;
+			ret = 0;
+		}
+		if (sigint_caught()) {
+			ret = 0;
+			goto_out;
+		}
+	}
+
+out:
 	unlock_vg(cmd, VG_ORPHANS);
 
-	return r;
+	if (pvslist)
+		dm_list_iterate_items(pvl, pvslist)
+			free_pv_fid(pvl->pv);
+
+	return ret;
 }
 
 int pvcreate_single(struct cmd_context *cmd, const char *pv_name,
diff --git a/liblvm/lvm_pv.c b/liblvm/lvm_pv.c
index 64b01d5..24b2732 100644
--- a/liblvm/lvm_pv.c
+++ b/liblvm/lvm_pv.c
@@ -16,6 +16,7 @@
 #include "lib.h"
 #include "metadata.h"
 #include "lvm-string.h"
+#include "str_list.h"
 #include "lvm_misc.h"
 #include "lvm2app.h"
 #include "locking.h"
@@ -118,8 +119,14 @@ int lvm_pv_remove(lvm_t libh, const char *pv_name)
 	int rc = 0;
 	struct cmd_context *cmd = (struct cmd_context *)libh;
 	struct saved_env e = store_user_env(cmd);
+	struct dm_list pv_names;
 
-	if (!pvremove_single(cmd, pv_name, NULL, 0, 0))
+	dm_list_init(&pv_names);
+
+	if (!str_list_add(cmd->mem, &pv_names, pv_name))
+		rc = -1;
+
+	if (rc >= 0 && !pvremove_many(cmd, &pv_names, 0, 0))
 		rc = -1;
 
 	restore_user_env(&e);
diff --git a/test/shell/pvremove-warnings.sh b/test/shell/pvremove-warnings.sh
index f9d2737..865a31e 100644
--- a/test/shell/pvremove-warnings.sh
+++ b/test/shell/pvremove-warnings.sh
@@ -14,3 +14,8 @@ aux prepare_devs 2
 pvcreate "$dev1" "$dev2"
 pvremove "$dev1" "$dev2" 2>&1 | tee pvremove.txt
 not grep "No physical" pvremove.txt
+
+pvcreate "$dev1" "$dev2"
+vgcreate bla $dev1 $dev2
+pvremove -ff -y $dev1 $dev2 2>&1 | tee pvremove.txt
+not grep "device missing" pvremove.txt
diff --git a/tools/pvremove.c b/tools/pvremove.c
index 035d4fd..b40ff79 100644
--- a/tools/pvremove.c
+++ b/tools/pvremove.c
@@ -18,9 +18,9 @@
 int pvremove(struct cmd_context *cmd, int argc, char **argv)
 {
 	int i;
-	int ret = ECMD_PROCESSED;
 	unsigned force_count;
 	unsigned prompt;
+	struct dm_list pv_names;
 
 	if (!argc) {
 		log_error("Please enter a physical volume path");
@@ -30,15 +30,16 @@ int pvremove(struct cmd_context *cmd, int argc, char **argv)
 	force_count = arg_count(cmd, force_ARG);
 	prompt = arg_count(cmd, yes_ARG);
 
+	dm_list_init(&pv_names);
+
 	for (i = 0; i < argc; i++) {
 		dm_unescape_colons_and_at_signs(argv[i], NULL, NULL);
-		if (!pvremove_single(cmd, argv[i], NULL, force_count, prompt)) {
-			stack;
-			ret = ECMD_FAILED;
-		}
-		if (sigint_caught())
+		if (!str_list_add(cmd->mem, &pv_names, argv[i]))
 			return_ECMD_FAILED;
 	}
 
-	return ret;
+	if (!pvremove_many(cmd, &pv_names, force_count, prompt))
+		return_ECMD_FAILED;
+
+	return ECMD_PROCESSED;
 }


