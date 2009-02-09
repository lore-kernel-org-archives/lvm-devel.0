From: Dave Wysochanski <dwysocha@redhat.com>
Date: Sun,  8 Feb 2009 23:22:05 -0500
Subject: [PATCH 17/21] Update lvm_vg_open to take either a name or uuid.
In-Reply-To: <1234153329-2829-17-git-send-email-dwysocha@redhat.com>
References: <1234153329-2829-1-git-send-email-dwysocha@redhat.com>
	<1234153329-2829-2-git-send-email-dwysocha@redhat.com>
	<1234153329-2829-3-git-send-email-dwysocha@redhat.com>
	<1234153329-2829-4-git-send-email-dwysocha@redhat.com>
	<1234153329-2829-5-git-send-email-dwysocha@redhat.com>
	<1234153329-2829-6-git-send-email-dwysocha@redhat.com>
	<1234153329-2829-7-git-send-email-dwysocha@redhat.com>
	<1234153329-2829-8-git-send-email-dwysocha@redhat.com>
	<1234153329-2829-9-git-send-email-dwysocha@redhat.com>
	<1234153329-2829-10-git-send-email-dwysocha@redhat.com>
	<1234153329-2829-11-git-send-email-dwysocha@redhat.com>
	<1234153329-2829-12-git-send-email-dwysocha@redhat.com>
	<1234153329-2829-13-git-send-email-dwysocha@redhat.com>
	<1234153329-2829-14-git-send-email-dwysocha@redhat.com>
	<1234153329-2829-15-git-send-email-dwysocha@redhat.com>
	<1234153329-2829-16-git-send-email-dwysocha@redhat.com>
	<1234153329-2829-17-git-send-email-dwysocha@redhat.com>
Message-ID: <1234153329-2829-18-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

We attempt to verify whether the string given is a uuid or a name.
Do some uuid validation on it, if that passes, try to look it up in the
lvmcache.  If we can find the uuid in the cache, we return the
vgname from the cache entry and use that vgname in our vg_read()
call.  Note that the vgname lock was not obtained at the time of
reading the cache, but presumably vg_read will fail if the vgname,vgid
pair given does not match the disk?

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/lvm2.c              |   73 ++++++++++++++++++++++++++++++++++++++++------
 lib/lvm2.h              |    5 +++
 lib/metadata/metadata.c |    2 +-
 test/api/test.c         |   46 ++++++++++++++++++-----------
 4 files changed, 98 insertions(+), 28 deletions(-)

diff --git a/lib/lvm2.c b/lib/lvm2.c
index e58f7e8..e6b1a8e 100644
--- a/lib/lvm2.c
+++ b/lib/lvm2.c
@@ -21,6 +21,12 @@
 #include "metadata-exported.h"
 #include "report.h"
 
+/* FIXME: these need to be #included */
+extern const char *vgname_from_vgid(struct dm_pool *mem, const char *vgid);
+extern int vgname_is_locked(const char *vgname);
+
+
+
 struct lib_context {
 	struct cmd_context *cmd;
 	int lvm_errno;
@@ -41,31 +47,78 @@ char *lvm_strerror(lvm_handle_t libh)
 	return strerror(libh->lvm_errno);
 }
 
+struct dm_list *lvm_get_vgids(lvm_handle_t libh)
+{
+	return get_vgids(libh->cmd, 0);
+}
+
 /*
  * Open / read a VG.
- * FIXME: Only read access allowed.
+ * Parameters
+ * - name: either a vgname or a vg uuid
  */
-vg_t *lvm_vg_open(lvm_handle_t libh, const char *vg_name, mode_t mode)
+vg_t *lvm_vg_open(lvm_handle_t libh, const char *name_or_uuid, mode_t mode)
 {
-	vg_t *vg;
-
+	vg_t *vg = NULL;
+	struct id id;
+	int found_id = 0;
+	uint32_t flags;
+	const char *vg_name;
+	
 	if ((mode & O_ACCMODE) == O_RDONLY) {
-		vg = vg_read(libh->cmd, vg_name, NULL, 0);
+		flags = 0;
 	} else if ((mode & O_ACCMODE) == O_RDWR) {
-		vg = vg_read(libh->cmd, vg_name, NULL, READ_FOR_UPDATE);
+		flags = READ_FOR_UPDATE;
 	} else {
 		log_error("Invalid access mode 0x%x for lvm_vg_read()\n",
 			  mode);
 		libh->lvm_errno = EPERM;
 		return NULL;
 	}
-	
+
+	/*
+	 * First assume we've been passed a UUID in 'name_or_uuid'.
+	 * If the string passes the uuid validation in id_read_format(), and
+	 * lvmcache's vgname_from_vgid() returns a vgname based on the string
+	 * being a uuid, try to read the vg with the string as uuid.
+	 * If any of these checks fail, or the vg_read() fails, we'll re-try
+	 * the vg_read() later assuming the string was a vgname.
+	 */
+	log_suppress(2);
+	found_id = id_read_format(&id, name_or_uuid);
+	log_suppress(0);
+
+	if (found_id && (vg_name = vgname_from_vgid(libh->cmd->mem, name_or_uuid))) {
+		/*
+		 * Try the read with the uuid - if it succeeds, great.
+		 */
+		vg = vg_read(libh->cmd, vg_name, name_or_uuid, flags);
+	}
+
 	if (vg_read_error(vg)) {
-		/* FIXME: fill in vg->errno */
-		return NULL;
+		/*
+		 * Something went wrong trying the uuid.
+		 * Attempt the read assuming we have a vgname.
+		 */
+		vg = vg_read(libh->cmd, name_or_uuid, NULL, flags);
+		if (vg_read_error(vg))
+			return NULL;
 	}
+
 	vg->mode = mode;
-	return vg;
+
+	/*
+	 * Something went wrong trying the uuid.
+	 * Attempt the read assuming we have a vgname.
+	 */
+	vg = vg_read(libh->cmd, name_or_uuid, NULL, flags);
+	if (!vg_read_error(vg)) {
+		vg->mode = mode;
+		return vg;
+	}
+
+	/* FIXME: set errno */
+	return NULL;
 }
 
 /*
diff --git a/lib/lvm2.h b/lib/lvm2.h
index 1c1763b..cc57574 100644
--- a/lib/lvm2.h
+++ b/lib/lvm2.h
@@ -155,4 +155,9 @@ int lvm_pv_obj_get_attr_value(lvm_pv_obj_t *obj, const char *attr_name,
 int lvm_errno(lvm_handle_t libh);
 char *lvm_strerror(lvm_handle_t libh);
 mode_t lvm_vg_mode(vg_t *vg);
+
+struct dm_list *lvm_get_vgids(lvm_handle_t libh);
+/* FIXME: some of these might be ok as is, some might need cleanup */
+extern const char *vgname_from_vgid(struct dm_pool *mem, const char *vgid);
+extern uint32_t vg_read_error(vg_t *vg_handle);
 #endif
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 9405754..75e4c9e 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -2574,7 +2574,7 @@ static vg_t *_vg_lock_and_read(struct cmd_context *cmd, const char *vg_name,
 	if (misc_flags & READ_ALLOW_INCONSISTENT || !(lock_flags & LCK_WRITE))
 		consistent = 0;
 
-	if (!validate_name(vg_name) && !is_orphan_vg(vg_name)) {
+	if (vg_name && !validate_name(vg_name) && !is_orphan_vg(vg_name)) {
 		log_error("Volume group name %s has invalid characters",
 			  vg_name);
 		return NULL;
diff --git a/test/api/test.c b/test/api/test.c
index 08daf30..0255a00 100644
--- a/test/api/test.c
+++ b/test/api/test.c
@@ -79,6 +79,7 @@ static void _show_help(void)
 	printf("'quit': exit the program\n");
 }
 
+static struct dm_hash_table *_vgid_hash = NULL;
 static struct dm_hash_table *_vgname_hash = NULL;
 static struct dm_hash_table *_pvname_hash = NULL;
 static struct dm_hash_table *_lvname_hash = NULL;
@@ -94,6 +95,7 @@ static void _hash_destroy_single(struct dm_hash_table **htable)
 static void _hash_destroy(void)
 {
 	_hash_destroy_single(&_vgname_hash);
+	_hash_destroy_single(&_vgid_hash);
 	_hash_destroy_single(&_pvname_hash);
 	_hash_destroy_single(&_lvname_hash);
 }
@@ -111,6 +113,12 @@ static int _hash_create(void)
 		_hash_destroy_single(&_pvname_hash);
 		return 0;
 	}
+	if (!(_vgid_hash = dm_hash_create(128))) {
+		_hash_destroy_single(&_vgname_hash);
+		_hash_destroy_single(&_pvname_hash);
+		_hash_destroy_single(&_lvname_hash);
+		return 0;
+	}
 	return 1;
 }
 
@@ -122,7 +130,8 @@ static vg_t *_lookup_vg_by_name(char **argv, int argc)
 		printf ("Please enter vg_name\n");
 		return NULL;
 	}
-	if (!(vg = dm_hash_lookup(_vgname_hash, argv[1]))) {
+	if (!(vg = dm_hash_lookup(_vgid_hash, argv[1])) &&
+	    !(vg = dm_hash_lookup(_vgname_hash, argv[1]))) {
 		printf ("Can't find %s in open VGs - run vg_open first\n",
 			argv[1]);
 		return NULL;
@@ -134,6 +143,7 @@ static vg_t *_lookup_vg_by_name(char **argv, int argc)
 	return vg;
 }
 
+#if 0
 static pv_t *_lookup_pv_by_name(char **argv, int argc)
 {
 	pv_t *pv;
@@ -149,6 +159,7 @@ static pv_t *_lookup_pv_by_name(char **argv, int argc)
 	}
 	return pv;
 }
+#endif
 
 static lv_t *_lookup_lv_by_name(char *lv_name)
 {
@@ -220,7 +231,8 @@ static void _vg_open(char **argv, int argc, lvm_handle_t libh)
 		printf ("Please enter vg_name\n");
 		return;
 	}
-	if ((vg = dm_hash_lookup(_vgname_hash, argv[1]))) {
+	if ((vg = dm_hash_lookup(_vgid_hash, argv[1])) ||
+	    (vg = dm_hash_lookup(_vgname_hash, argv[1]))) {
 		printf ("VG already open\n");
 		return;
 	}
@@ -237,6 +249,7 @@ static void _vg_open(char **argv, int argc, lvm_handle_t libh)
 
 	printf("Success opening vg %s\n", argv[1]);
 	dm_hash_insert(_vgname_hash, lvm_vg_name(vg), vg);
+	dm_hash_insert(_vgid_hash, lvm_vg_uuid(vg), vg);
 
 	/*
 	 * Add the LVs and PVs into the hashes for lookups
@@ -256,24 +269,21 @@ static void _vg_close(char **argv, int argc)
 {
 	vg_t *vg;
 
-	if (!(vg = _lookup_vg_by_name(argv, argc)))
-		return;
 	if (argc < 2) {
 		printf ("Please enter vg_name\n");
 		return;
 	}
-	if (!(vg = dm_hash_lookup(_vgname_hash, argv[1]))) {
-		printf ("Can't find %s in open VGs - run vg_open first\n",
-			argv[1]);
+	if (!(vg = _lookup_vg_by_name(argv, argc)))
 		return;
-	}
+	dm_hash_remove(_vgid_hash, lvm_vg_uuid(vg));
 	dm_hash_remove(_vgname_hash, lvm_vg_name(vg));
 	lvm_vg_close(vg);
 }	
 
 static void _show_one_vg(vg_t *vg)
 {
-	printf("%s: uuid = %s, mode = %s\n", lvm_vg_name(vg),
+	/* FIXME: uuid is not null terminated */
+	printf("%s (%s): mode = %s\n", lvm_vg_name(vg),
 	       lvm_vg_uuid(vg),
 	       lvm_vg_mode(vg) == O_RDWR ? "READ/WRITE" :
 	       lvm_vg_mode(vg) == O_RDONLY ? "READ" :
@@ -281,18 +291,20 @@ static void _show_one_vg(vg_t *vg)
 }
 static void _list_open_vgs(void)
 {
-	dm_hash_iter(_vgname_hash, (dm_hash_iterate_fn) _show_one_vg);
+	dm_hash_iter(_vgid_hash, (dm_hash_iterate_fn) _show_one_vg);
 }
 
-static void _list_all_vgs(lvm_handle_t libh)
+void _list_all_vgs(lvm_handle_t libh)
 {
-	struct dm_list *vgnames;
-	struct str_list *vgname;
+	struct dm_list *vgids;
+	struct str_list *vgid;
+	const char *vgname;
 
 	/* FIXME: properly export str_list and API function */
-	vgnames = get_vgnames(libh, 0);
-	dm_list_iterate_items(vgname, vgnames) {
-		printf("%s\n", vgname->str);
+	vgids = lvm_get_vgids(libh);
+	dm_list_iterate_items(vgid, vgids) {
+		vgname = vgname_from_vgid(NULL, vgid->str);
+		printf("%s, %s\n", vgname, vgid->str);
 	}
 }
 
@@ -500,7 +512,7 @@ static void _lv_get_attr_value(char **argv, int argc)
 }
 
 
-int lvmapi_test_shell(lvm_handle_t libh)
+static int lvmapi_test_shell(lvm_handle_t libh)
 {
 	int argc;
 	char *input = NULL, *args[MAX_ARGS], **argv;
-- 
1.6.0.5


