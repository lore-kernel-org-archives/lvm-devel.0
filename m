From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed, 10 Oct 2012 15:18:17 +0000 (UTC)
Subject: master - libdm: refactor internal mangling functions
Message-ID: <20121010151818.06DEA2335@hosted02.fedoraproject.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b0f48b9533b9fd13aaf0ad1bca4cbf68330e60b8
Commit:        b0f48b9533b9fd13aaf0ad1bca4cbf68330e60b8
Parent:        f65754e6fc0e7e1eb17f058fe92db1ea6eead809
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Oct 10 16:59:11 2012 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Oct 10 16:59:11 2012 +0200

libdm: refactor internal mangling functions

(un)mangle_name -> (un)mangle_string
check_multiple_mangled_name_allowed -> check_multiple_mangled_string_allowed

Just for clarity as the same functions will be reused to (un)mangle dm UUIDs.
---
 libdm/ioctl/libdm-iface.c |    4 +-
 libdm/libdm-common.c      |   55 +++++++++++++++++++++++----------------------
 libdm/libdm-common.h      |   11 +++++----
 3 files changed, 36 insertions(+), 34 deletions(-)

diff --git a/libdm/ioctl/libdm-iface.c b/libdm/ioctl/libdm-iface.c
index 9932aa9..526ec3f 100644
--- a/libdm/ioctl/libdm-iface.c
+++ b/libdm/ioctl/libdm-iface.c
@@ -1559,10 +1559,10 @@ static int _do_dm_ioctl_unmangle_name(char *name)
 	if (mode == DM_STRING_MANGLING_NONE)
 		return 1;
 
-	if (!check_multiple_mangled_name_allowed(mode, name))
+	if (!check_multiple_mangled_string_allowed(name, "name", mode))
 		return_0;
 
-	if ((r = unmangle_name(name, DM_NAME_LEN, buf, sizeof(buf), mode)) < 0) {
+	if ((r = unmangle_string(name, "name", DM_NAME_LEN, buf, sizeof(buf), mode)) < 0) {
 		log_debug("_do_dm_ioctl_unmangle_name: failed to "
 			  "unmangle \"%s\"", name);
 		return 0;
diff --git a/libdm/libdm-common.c b/libdm/libdm-common.c
index 7929889..982fd3e 100644
--- a/libdm/libdm-common.c
+++ b/libdm/libdm-common.c
@@ -326,11 +326,12 @@ static int _is_whitelisted_char(char c)
         return 0;
 }
 
-int check_multiple_mangled_name_allowed(dm_string_mangling_t mode, const char *name)
+int check_multiple_mangled_string_allowed(const char *str, const char *str_name,
+					 dm_string_mangling_t mode)
 {
-	if (mode == DM_STRING_MANGLING_AUTO && strstr(name, "\\x5cx")) {
-		log_error("The name \"%s\" seems to be mangled more than once. "
-			  "This is not allowed in auto mode.", name);
+	if (mode == DM_STRING_MANGLING_AUTO && strstr(str, "\\x5cx")) {
+		log_error("The %s \"%s\" seems to be mangled more than once. "
+			  "This is not allowed in auto mode.", str_name, str);
 		return 0;
 	}
 
@@ -341,8 +342,8 @@ int check_multiple_mangled_name_allowed(dm_string_mangling_t mode, const char *n
  * Mangle all characters in the input string which are not on a whitelist
  * with '\xNN' format where NN is the hex value of the character.
  */
-int mangle_name(const char *str, size_t len, char *buf,
-		size_t buf_len, dm_string_mangling_t mode)
+int mangle_string(const char *str, const char *str_name, size_t len,
+		  char *buf, size_t buf_len, dm_string_mangling_t mode)
 {
 	int need_mangling = -1; /* -1 don't know yet, 0 no, 1 yes */
 	size_t i, j;
@@ -355,7 +356,7 @@ int mangle_name(const char *str, size_t len, char *buf,
 		return 0;
 
 	if (buf_len < DM_NAME_LEN) {
-		log_error(INTERNAL_ERROR "mangle_name: supplied buffer too small");
+		log_error(INTERNAL_ERROR "mangle_string: supplied buffer too small");
 		return -1;
 	}
 
@@ -417,11 +418,11 @@ int mangle_name(const char *str, size_t len, char *buf,
 	return need_mangling;
 
 bad1:
-	log_error("The name \"%s\" contains mixed mangled and unmangled "
-		  "characters or it's already mangled improperly.", str);
+	log_error("The %s \"%s\" contains mixed mangled and unmangled "
+		  "characters or it's already mangled improperly.", str_name, str);
 	return -1;
 bad2:
-	log_error("Mangled form of the name too long for \"%s\".", str);
+	log_error("Mangled form of the %s too long for \"%s\".", str_name, str);
 	return -1;
 }
 
@@ -429,8 +430,8 @@ bad2:
  * Try to unmangle supplied string.
  * Return value: -1 on error, 0 when no unmangling needed, 1 when unmangling applied
  */
-int unmangle_name(const char *str, size_t len, char *buf,
-		  size_t buf_len, dm_string_mangling_t mode)
+int unmangle_string(const char *str, const char *str_name, size_t len,
+		    char *buf, size_t buf_len, dm_string_mangling_t mode)
 {
 	int strict = mode != DM_STRING_MANGLING_NONE;
 	char str_rest[DM_NAME_LEN];
@@ -446,22 +447,22 @@ int unmangle_name(const char *str, size_t len, char *buf,
 		return 0;
 
 	if (buf_len < DM_NAME_LEN) {
-		log_error(INTERNAL_ERROR "unmangle_name: supplied buffer too small");
+		log_error(INTERNAL_ERROR "unmangle_string: supplied buffer too small");
 		return -1;
 	}
 
 	for (i = 0, j = 0; str[i]; i++, j++) {
 		if (strict && !(_is_whitelisted_char(str[i]) || str[i]=='\\')) {
-			log_error("The name \"%s\" should be mangled but "
-				  "it contains blacklisted characters.", str);
+			log_error("The %s \"%s\" should be mangled but "
+				  "it contains blacklisted characters.", str_name, str);
 			j=0; r=-1;
 			goto out;
 		}
 
 		if (str[i] == '\\' && str[i+1] == 'x') {
 			if (!sscanf(&str[i+2], "%2x%s", &code, str_rest)) {
-				log_debug("Hex encoding mismatch detected in \"%s\" "
-					  "while trying to unmangle it.", str);
+				log_debug("Hex encoding mismatch detected in %s \"%s\" "
+					  "while trying to unmangle it.", str_name, str);
 				goto out;
 			}
 			buf[j] = (unsigned char) code;
@@ -496,12 +497,12 @@ static int _dm_task_set_name(struct dm_task *dmt, const char *name,
 		return 0;
 	}
 
-	if (!check_multiple_mangled_name_allowed(mangling_mode, name))
+	if (!check_multiple_mangled_string_allowed(name, "name", mangling_mode))
 		return_0;
 
 	if (mangling_mode != DM_STRING_MANGLING_NONE &&
-	    (r = mangle_name(name, strlen(name), mangled_name,
-			     sizeof(mangled_name), mangling_mode)) < 0) {
+	    (r = mangle_string(name, "name", strlen(name), mangled_name,
+			       sizeof(mangled_name), mangling_mode)) < 0) {
 		log_error("Failed to mangle device name \"%s\".", name);
 		return 0;
 	}
@@ -588,8 +589,8 @@ char *dm_task_get_name_mangled(const struct dm_task *dmt)
 	char *rs = NULL;
 	int r;
 
-	if ((r = mangle_name(s, strlen(s), buf, sizeof(buf),
-			     dm_get_name_mangling_mode())) < 0)
+	if ((r = mangle_string(s, "name", strlen(s), buf, sizeof(buf),
+			       dm_get_name_mangling_mode())) < 0)
 		log_error("Failed to mangle device name \"%s\".", s);
 	else if (!(rs = r ? dm_strdup(buf) : dm_strdup(s)))
 		log_error("dm_task_get_name_mangled: dm_strdup failed");
@@ -609,8 +610,8 @@ char *dm_task_get_name_unmangled(const struct dm_task *dmt)
 	 * is *already* unmangled on ioctl return!
 	 */
 	if (dm_get_name_mangling_mode() == DM_STRING_MANGLING_NONE &&
-	    (r = unmangle_name(s, strlen(s), buf, sizeof(buf),
-			       dm_get_name_mangling_mode())) < 0)
+	    (r = unmangle_string(s, "name", strlen(s), buf, sizeof(buf),
+				 dm_get_name_mangling_mode())) < 0)
 		log_error("Failed to unmangle device name \"%s\".", s);
 	else if (!(rs = r ? dm_strdup(buf) : dm_strdup(s)))
 		log_error("dm_task_get_name_unmangled: dm_strdup failed");
@@ -634,12 +635,12 @@ int dm_task_set_newname(struct dm_task *dmt, const char *newname)
 		return 0;
 	}
 
-	if (!check_multiple_mangled_name_allowed(mangling_mode, newname))
+	if (!check_multiple_mangled_string_allowed(newname, "new name", mangling_mode))
 		return_0;
 
 	if (mangling_mode != DM_STRING_MANGLING_NONE &&
-	    (r = mangle_name(newname, strlen(newname), mangled_name,
-			     sizeof(mangled_name), mangling_mode)) < 0) {
+	    (r = mangle_string(newname, "new name", strlen(newname), mangled_name,
+			       sizeof(mangled_name), mangling_mode)) < 0) {
 		log_error("Failed to mangle new device name \"%s\"", newname);
 		return 0;
 	}
diff --git a/libdm/libdm-common.h b/libdm/libdm-common.h
index b57bae9..75ee60e 100644
--- a/libdm/libdm-common.h
+++ b/libdm/libdm-common.h
@@ -22,13 +22,14 @@
 
 #define DEV_NAME(dmt) (dmt->mangled_dev_name ? : dmt->dev_name)
 
-int mangle_name(const char *str, size_t len, char *buf,
-		size_t buf_len, dm_string_mangling_t mode);
+int mangle_string(const char *str, const char *str_name, size_t len,
+		  char *buf, size_t buf_len, dm_string_mangling_t mode);
 
-int unmangle_name(const char *str, size_t len, char *buf,
-		  size_t buf_len, dm_string_mangling_t mode);
+int unmangle_string(const char *str, const char *str_name, size_t len,
+		    char *buf, size_t buf_len, dm_string_mangling_t mode);
 
-int check_multiple_mangled_name_allowed(dm_string_mangling_t mode, const char *name);
+int check_multiple_mangled_string_allowed(const char *str, const char *str_name,
+					  dm_string_mangling_t mode);
 
 struct target *create_target(uint64_t start,
 			     uint64_t len,


