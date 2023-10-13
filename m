From: Zdeněk Kabeláč (@zdenek.kabelac) <gitlab@mg.gitlab.com>
Date: Fri, 13 Oct 2023 14:36:01 +0000
Subject: [Git][lvmteam/lvm2][main] 2 commits: dmfilemapd: ensure program_id is initialized
Message-ID: <652955d18ad4c_2ca52f83086@gitlab-sidekiq-low-urgency-cpu-bound-v2-87b66f57b-l2vvf.mail>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit



Zden?k Kabel?? pushed to branch main at LVM team / lvm2


Commits:
0bbbe083 by Zdenek Kabelac at 2023-10-13T16:04:25+02:00
dmfilemapd: ensure program_id is initialized

Assing program_id before return 1,
and also stay C99 compatible with size_t declaration.

- - - - -
b1624753 by Zdenek Kabelac at 2023-10-13T16:34:48+02:00
makefiles: fix missing libs

Recent commit  dc8837f07982663add6c1f4d87fb79fa9b6c8857
became actually to strict - we always want to build lib.a files.

- - - - -


3 changed files:

- libdm/libdm-stats.c
- libdm/make.tmpl.in
- make.tmpl.in


Changes:

=====================================
libdm/libdm-stats.c
=====================================
@@ -140,7 +140,7 @@ static char *_stats_escape_aux_data(const char *aux_data)
 {
 	size_t aux_data_len = strlen(aux_data);
 	char *escaped = dm_malloc((3 * aux_data_len + 1) * sizeof(char));
-	size_t index = 0;
+	size_t index = 0, i;
 
 	if (!escaped) {
 		log_error("Could not allocate memory for escaped "
@@ -148,7 +148,7 @@ static char *_stats_escape_aux_data(const char *aux_data)
 		return NULL;
 	}
 
-	for (size_t i = 0; i < aux_data_len; i++) {
+	for (i = 0; i < aux_data_len; i++) {
 		if (aux_data[i] == ' ') {
 			escaped[index++] = '\\';
 			escaped[index++] = ' ';
@@ -952,13 +952,13 @@ static int _stats_parse_string_data(char *string_data, char **program_id,
 		(string_data)[len - 1] = '\0';
 	}
 	p = strchr(string_data, ' ');
+	*program_id = string_data;
 	if (!p) {
 		*aux_data = *stats_args = empty_string;
 		return 1;
 	}
 
 	*p = '\0';
-	*program_id = string_data;
 
 	p++;
 	if (strstr(p, DMS_GROUP_TAG)) {
@@ -995,12 +995,10 @@ static int _stats_parse_string_data(char *string_data, char **program_id,
 static int _stats_parse_list_region(struct dm_stats *dms,
 				    struct dm_stats_region *region, char *line)
 {
-	char string_data[STATS_ROW_BUF_LEN];
+	char string_data[STATS_ROW_BUF_LEN] = { 0 };
 	char *p, *program_id, *aux_data, *stats_args;
 	int r;
 
-	memset(string_data, 0, sizeof(string_data));
-
 	/*
 	 * Parse fixed fields, line format:
 	 *


=====================================
libdm/make.tmpl.in
=====================================
@@ -318,12 +318,10 @@ SUBDIRS.cflow := $(SUBDIRS:=.cflow)
 SUBDIRS.clean := $(SUBDIRS:=.clean)
 SUBDIRS.distclean := $(SUBDIRS:=.distclean)
 
+TARGETS += $(LIB_STATIC)
 ifeq ("@SHARED_LINK@", "yes")
   TARGETS += $(LIB_SHARED)
 endif
-ifeq ("@STATIC_LINK@", "yes")
-  TARGETS += $(LIB_STATIC)
-endif
 
 all: $(SUBDIRS) $(TARGETS)
 


=====================================
make.tmpl.in
=====================================
@@ -373,12 +373,10 @@ SUBDIRS.cflow := $(SUBDIRS:=.cflow)
 SUBDIRS.clean := $(SUBDIRS:=.clean)
 SUBDIRS.distclean := $(SUBDIRS:=.distclean)
 
+TARGETS += $(LIB_STATIC)
 ifeq ("@SHARED_LINK@", "yes")
   TARGETS += $(LIB_SHARED)
 endif
-ifeq ("@STATIC_LINK@", "yes")
-  TARGETS += $(LIB_STATIC)
-endif
 
 INTERNAL_LIBS = \
 	$(top_builddir)/libdaemon/client/libdaemonclient.a \



View it on GitLab: https://gitlab.com/lvmteam/lvm2/-/compare/0b11b08b6e9cd15eeaf1f591c2a3ddd2b8d2d98e...b16247539137964736c6274a80c603cc83c0faf3

-- 
View it on GitLab: https://gitlab.com/lvmteam/lvm2/-/compare/0b11b08b6e9cd15eeaf1f591c2a3ddd2b8d2d98e...b16247539137964736c6274a80c603cc83c0faf3
You're receiving this email because of your account on gitlab.com.


-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20231013/6fd35936/attachment-0001.htm>
