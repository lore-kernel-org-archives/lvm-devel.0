From: Alasdair Kergon <agk@fedoraproject.org>
Date: Wed,  5 Aug 2015 04:04:27 +0000 (UTC)
Subject: master - dmsetup: Tidy whitespace.
Message-ID: <20150805040427.922E4607A5@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=362a1a5a820c07c94d0bf4b512b32a47141564d9
Commit:        362a1a5a820c07c94d0bf4b512b32a47141564d9
Parent:        ce1528359a3021e255fec59962f21b18d6bb027a
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Wed Aug 5 05:03:33 2015 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Wed Aug 5 05:03:33 2015 +0100

dmsetup: Tidy whitespace.

---
 tools/dmsetup.c |   26 +++++++++++++-------------
 1 files changed, 13 insertions(+), 13 deletions(-)

diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index bc71b35..25789dc 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -68,10 +68,10 @@ extern char *optarg;
 
 #ifndef TEMP_FAILURE_RETRY
 # define TEMP_FAILURE_RETRY(expression) \
-  (__extension__                                                              \
-    ({ long int __result;                                                     \
-       do __result = (long int) (expression);                                 \
-       while (__result == -1L && errno == EINTR);                             \
+  (__extension__					\
+    ({ long int __result;				\
+       do __result = (long int) (expression);		\
+       while (__result == -1L && errno == EINTR);	\
        __result; }))
 #endif
 
@@ -295,10 +295,10 @@ static int _parse_file(struct dm_task *dmt, const char *file)
 }
 
 struct dm_split_name {
-        char *subsystem;
-        char *vg_name;
-        char *lv_name;
-        char *lv_layer;
+	char *subsystem;
+	char *vg_name;
+	char *lv_name;
+	char *lv_layer;
 };
 
 struct dmsetup_report_obj {
@@ -391,7 +391,7 @@ static struct dm_split_name *_get_split_name(const char *uuid, const char *name,
 	if (!strcmp(split_name->subsystem, "LVM") &&
 	    (!(split_name->vg_name = dm_strdup(name)) ||
 	     !dm_split_lvm_name(NULL, NULL, &split_name->vg_name,
-			        &split_name->lv_name, &split_name->lv_layer)))
+				&split_name->lv_name, &split_name->lv_layer)))
 		log_error("Failed to allocate memory to split LVM name "
 			  "into components.");
 
@@ -678,7 +678,7 @@ static int _create(CMD_ARGS)
 		goto out;
 
 	if (!_set_task_add_node(dmt))
-                goto out;
+		goto out;
 
 	if (_udev_cookie)
 		cookie = _udev_cookie;
@@ -900,7 +900,7 @@ static int _splitname(CMD_ARGS)
 
 	if (!(obj.split_name = _get_split_name((argc == 3) ? argv[2] : "LVM",
 					       argv[1], '\0')))
-                return_0;
+		return_0;
 
 	r = dm_report_object(_report, &obj);
 	_destroy_split_name(obj.split_name);
@@ -1296,7 +1296,7 @@ static int _simple(int task, const char *name, uint32_t event_nr, int display)
 
 	/* FIXME: needs to coperate with udev */
 	if (!_set_task_add_node(dmt))
-                goto out;
+		goto out;
 
 	if (_switches[READAHEAD_ARG] &&
 	    !dm_task_set_read_ahead(dmt, _int_args[READAHEAD_ARG],
@@ -3353,7 +3353,7 @@ static int _loop_table(char *table, size_t tlen, char *file,
 #endif
 
 	if (close(fd))
-                log_sys_error("close", file);
+		log_sys_error("close", file);
 
 	if (dm_snprintf(table, tlen, "%llu %llu loop %s %llu\n", 0ULL,
 			(long long unsigned)sectors, file, (long long unsigned)off) < 0)


