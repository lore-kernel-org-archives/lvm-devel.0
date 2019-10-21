From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 21 Oct 2019 09:33:35 -0400
Subject: master - gcc: avoid warning: declaration of xxx shadows a global declaration
Message-ID: <201910211333.x9LDXZYd019655@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=0c01a4c2a6bee3faaffe301ea74d76fa75eb8f91
Commit:        0c01a4c2a6bee3faaffe301ea74d76fa75eb8f91
Parent:        644186e9204bfca21a6b3ca9dcc8256b93a74c15
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Oct 21 12:32:11 2019 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Oct 21 15:32:35 2019 +0200

gcc: avoid warning: declaration of xxx shadows a global declaration

Fix some gcc complaints again shadowing global declarations
---
 lib/cache/lvmcache.c    |   10 +++++-----
 lib/metadata/metadata.c |   14 +++++++-------
 2 files changed, 12 insertions(+), 12 deletions(-)

diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index f6e7924..99818de 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -527,7 +527,7 @@ static void _choose_duplicates(struct cmd_context *cmd,
 	struct lvmcache_info *info;
 	struct device *dev1, *dev2;
 	uint32_t dev1_major, dev1_minor, dev2_major, dev2_minor;
-	uint64_t dev1_size, dev2_size, pv_size;
+	uint64_t dev1_size, dev2_size, pvsummary_size;
 	int in_subsys1, in_subsys2;
 	int is_dm1, is_dm2;
 	int has_fs1, has_fs2;
@@ -655,9 +655,9 @@ next:
 		if (!dev_get_size(dev2, &dev2_size))
 			dev2_size = 0;
 
-		pv_size = _get_pvsummary_size(devl->dev->pvid);
-		same_size1 = (dev1_size == pv_size);
-		same_size2 = (dev2_size == pv_size);
+		pvsummary_size = _get_pvsummary_size(devl->dev->pvid);
+		same_size1 = (dev1_size == pvsummary_size);
+		same_size2 = (dev2_size == pvsummary_size);
 
 		if ((device_hint = _get_pvsummary_device_hint(devl->dev->pvid))) {
 			same_name1 = !strcmp(device_hint, dev_name(dev1));
@@ -684,7 +684,7 @@ next:
 
 		log_debug_cache("PV %s: size %llu. %s is %llu. %s is %llu.",
 				devl->dev->pvid,
-				(unsigned long long)pv_size,
+				(unsigned long long)pvsummary_size,
 				dev_name(dev1), (unsigned long long)dev1_size,
 				dev_name(dev2), (unsigned long long)dev2_size);
 
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 3174ae0..45a83bd 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -4884,7 +4884,7 @@ out:
 }
 
 struct volume_group *vg_read(struct cmd_context *cmd, const char *vg_name, const char *vgid,
-			     uint32_t read_flags, uint32_t lockd_state,
+			     uint32_t vg_read_flags, uint32_t lockd_state,
 			     uint32_t *error_flags, struct volume_group **error_vg)
 {
 	char uuidstr[64] __attribute__((aligned(8)));
@@ -4894,8 +4894,8 @@ struct volume_group *vg_read(struct cmd_context *cmd, const char *vg_name, const
 	int missing_pv_dev = 0;
 	int missing_pv_flag = 0;
 	uint32_t failure = 0;
-	int writing = (read_flags & READ_FOR_UPDATE);
-	int activating = (read_flags & READ_FOR_ACTIVATE);
+	int writing = (vg_read_flags & READ_FOR_UPDATE);
+	int activating = (vg_read_flags & READ_FOR_ACTIVATE);
 
 	if (is_orphan_vg(vg_name)) {
 		log_very_verbose("Reading orphan VG %s", vg_name);
@@ -4921,7 +4921,7 @@ struct volume_group *vg_read(struct cmd_context *cmd, const char *vg_name, const
 	 * of needing to write to them.
 	 */
 
-	if (!(read_flags & READ_WITHOUT_LOCK) &&
+	if (!(vg_read_flags & READ_WITHOUT_LOCK) &&
 	    !lock_vol(cmd, vg_name, (writing || activating) ? LCK_VG_WRITE : LCK_VG_READ, NULL)) {
 		log_error("Can't get lock for %s", vg_name);
 		failure |= FAILED_LOCKING;
@@ -4930,7 +4930,7 @@ struct volume_group *vg_read(struct cmd_context *cmd, const char *vg_name, const
 
 	if (!(vg = _vg_read(cmd, vg_name, vgid, 0, writing))) {
 		/* Some callers don't care if the VG doesn't exist and don't want an error message. */
-		if (!(read_flags & READ_OK_NOTFOUND))
+		if (!(vg_read_flags & READ_OK_NOTFOUND))
 			log_error("Volume group \"%s\" not found", vg_name);
 		failure |= FAILED_NOTFOUND;
 		goto_bad;
@@ -5164,12 +5164,12 @@ bad:
  * so vg_read should acquire an exclusive file lock on the vg.
  */
 struct volume_group *vg_read_for_update(struct cmd_context *cmd, const char *vg_name,
-			 const char *vgid, uint32_t read_flags, uint32_t lockd_state)
+			 const char *vgid, uint32_t vg_read_flags, uint32_t lockd_state)
 {
 	struct volume_group *vg;
 	uint32_t error_flags = 0;
 
-	vg = vg_read(cmd, vg_name, vgid, read_flags | READ_FOR_UPDATE, lockd_state, &error_flags, NULL);
+	vg = vg_read(cmd, vg_name, vgid, vg_read_flags | READ_FOR_UPDATE, lockd_state, &error_flags, NULL);
 
 	return vg;
 }


