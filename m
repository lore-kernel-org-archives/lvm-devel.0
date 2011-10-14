From: Peter Rajnoha <prajnoha@redhat.com>
Date: Fri, 14 Oct 2011 16:59:46 +0200
Subject: [PATCH 5/6][devname mangling] Add support for decoding mangled strings and add a new field for "dmsetup info"
Message-ID: <4E984E62.90809@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Add support for decoding mangled string back to a human readable form
(at least if the character is printable :)), accomplished with a new
libdemapper helper function "dm_string_mangle_decode".

Use it to decode the "Name" and show also a new "Name (unmangled)" field
in dmsetup info/dmsetup info -c output. For dmsetup info -c -o, the
new column name is called "name_unmangled".

Peter
---
 libdm/libdevmapper.h |    3 +++
 libdm/libdm-common.c |   41 +++++++++++++++++++++++++++++++++++++++++
 tools/dmsetup.c      |   26 ++++++++++++++++++++++++--
 3 files changed, 68 insertions(+), 2 deletions(-)

diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index fb4b2cb..fb6ad22 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -270,6 +270,9 @@ dm_string_mangle_t dm_get_default_name_mangle(void);
 int dm_task_set_name_mangle(struct dm_task *dmt, dm_string_mangle_t name_mangle);
 dm_string_mangle_t dm_task_get_name_mangle(struct dm_task *dmt);
 
+int dm_string_mangle_decode(dm_string_mangle_t type, const char *mangled_str,
+			    char *buf, size_t buf_len);
+
 /*
  * Configure the device-mapper directory
  */
diff --git a/libdm/libdm-common.c b/libdm/libdm-common.c
index e836661..fe0003d 100644
--- a/libdm/libdm-common.c
+++ b/libdm/libdm-common.c
@@ -306,6 +306,47 @@ static int _is_whitelisted_char(char c)
         return 0;
 }
 
+int dm_string_mangle_decode(dm_string_mangle_t type, const char *mangled_str,
+			    char *buf, size_t buf_len)
+{
+	size_t i, j;
+	int code;
+	char str[DM_NAME_LEN];
+
+	if (buf_len < DM_NAME_LEN) {
+		log_error("dm_string_mangle_decode \"%s\": "
+			  "output buffer too small", mangled_str);
+		goto bad;
+	}
+
+	if (type == DM_STRING_MANGLE_NONE) {
+		strcpy(buf, mangled_str);
+		return 1;
+	}
+
+	for (i = 0, j = 0; mangled_str[i]; i++) {
+		if (mangled_str[i] == '\\' && mangled_str[i+1] == 'x') {
+			if (!sscanf(&mangled_str[i+2], "%2x%s", &code, str)) {
+				log_error("Improperly encoded string %s", mangled_str);
+				goto bad;
+			}
+			buf[j] = (unsigned char) code;
+			i+= 3; j++;
+		}
+		else {
+			buf[j] = mangled_str[i];
+			j++;
+		}
+	}
+
+	buf[j] = '\0';
+	return 1;
+
+bad:
+	buf[0] = '\0';
+	return 0;
+}
+
 /*
  * Encode all characters in the input string which are not on a whitelist
  * with '\xNN' format where NN is the hex value of the character.
diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index a733dcd..0187a2f 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -441,13 +441,20 @@ static void _display_info_long(struct dm_task *dmt, struct dm_info *info)
 {
 	const char *uuid;
 	uint32_t read_ahead;
+	char buf[PATH_MAX];
+	const char *name;
 
 	if (!info->exists) {
 		printf("Device does not exist.\n");
 		return;
 	}
 
-	printf("Name:              %s\n", dm_task_get_name(dmt));
+	name = dm_task_get_name(dmt);
+	printf("Name:              %s\n", name);
+
+	if (!dm_string_mangle_decode(DM_STRING_MANGLE_HEX, name, buf, PATH_MAX))
+		log_error("Could not unmangle device name");
+	printf("Name (unmangled):  %s\n", buf);
 
 	printf("State:             %s%s\n",
 	       info->suspended ? "SUSPENDED" : "ACTIVE",
@@ -475,7 +482,7 @@ static void _display_info_long(struct dm_task *dmt, struct dm_info *info)
 		printf("Number of targets: %d\n", info->target_count);
 
 	if ((uuid = dm_task_get_uuid(dmt)) && *uuid)
-		printf("UUID: %s\n", uuid);
+		printf("UUID:              %s\n", uuid);
 
 	printf("\n");
 }
@@ -2225,6 +2232,20 @@ static int _dm_name_disp(struct dm_report *rh,
 	return dm_report_field_string(rh, field, &name);
 }
 
+static int _dm_name_unmangled_disp(struct dm_report *rh,
+				   struct dm_pool *mem __attribute__((unused)),
+				   struct dm_report_field *field, const void *data,
+				   void *private __attribute__((unused)))
+{
+	const char *name = dm_task_get_name((const struct dm_task *) data);
+	char buf[PATH_MAX];
+	const char *p = buf;
+
+	dm_string_mangle_decode(DM_STRING_MANGLE_HEX, name, buf, PATH_MAX);
+
+	return dm_report_field_string(rh, field, &p);
+}
+
 static int _dm_uuid_disp(struct dm_report *rh,
 			 struct dm_pool *mem __attribute__((unused)),
 			 struct dm_report_field *field,
@@ -2605,6 +2626,7 @@ static const struct dm_report_object_type _report_types[] = {
 static const struct dm_report_field_type _report_fields[] = {
 /* *INDENT-OFF* */
 FIELD_F(TASK, STR, "Name", 16, dm_name, "name", "Name of mapped device.")
+FIELD_F(TASK, STR, "Name (unmangled)", 18, dm_name_unmangled, "name_unmangled", "Name of mapped device (unmangled).")
 FIELD_F(TASK, STR, "UUID", 32, dm_uuid, "uuid", "Unique (optional) identifier for mapped device.")
 
 /* FIXME Next one should be INFO */


