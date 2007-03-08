From: agk@sourceware.org <agk@sourceware.org>
Date: 8 Mar 2007 19:58:05 -0000
Subject: LVM2 ./WHATS_NEW lib/activate/dev_manager.c
Message-ID: <20070308195805.9948.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2007-03-08 19:58:04

Modified files:
	.              : WHATS_NEW 
	lib/activate   : dev_manager.c 

Log message:
	Remove no-longer-used uuid_out parameter from activation info functions.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.578&r2=1.579
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/dev_manager.c.diff?cvsroot=lvm2&r1=1.120&r2=1.121

--- LVM2/WHATS_NEW	2007/03/08 19:22:52	1.578
+++ LVM2/WHATS_NEW	2007/03/08 19:58:04	1.579
@@ -1,5 +1,6 @@
 Version 2.02.23 - 
 ====================================
+  Remove no-longer-used uuid_out parameter from activation info functions.
   Fix two more segfaults if an empty config file section encountered.
   Move .cache file into a new /etc/lvm/cache directory by default.
   Add devices/cache_dir & devices/cache_file_prefix, deprecating devices/cache.
--- LVM2/lib/activate/dev_manager.c	2007/01/25 23:03:47	1.120
+++ LVM2/lib/activate/dev_manager.c	2007/03/08 19:58:04	1.121
@@ -118,12 +118,10 @@
 }
 
 static int _info_run(const char *name, const char *dlid, struct dm_info *info,
-		     int mknodes, int with_open_count, struct dm_pool *mem,
-		     char **uuid_out)
+		     int mknodes, int with_open_count)
 {
 	int r = 0;
 	struct dm_task *dmt;
-	const char *u;
 	int dmtask;
 
 	dmtask = mknodes ? DM_DEVICE_MKNODES : DM_DEVICE_INFO;
@@ -143,11 +141,6 @@
 	if (!dm_task_get_info(dmt, info))
 		goto_out;
 
-	if (info->exists && uuid_out) {
-		if (!(u = dm_task_get_uuid(dmt)))
-			goto_out;
-		*uuid_out = dm_pool_strdup(mem, u);
-	}
 	r = 1;
 
       out:
@@ -208,23 +201,20 @@
 }
 
 static int _info(const char *name, const char *dlid, int mknodes,
-		 int with_open_count, struct dm_info *info,
-		 struct dm_pool *mem, char **uuid_out)
+		 int with_open_count, struct dm_info *info)
 {
 	if (!mknodes && dlid && *dlid) {
-		if (_info_run(NULL, dlid, info, 0, with_open_count, mem,
-			      uuid_out) &&
+		if (_info_run(NULL, dlid, info, 0, with_open_count) &&
 	    	    info->exists)
 			return 1;
 		else if (_info_run(NULL, dlid + sizeof(UUID_PREFIX) - 1, info,
-				   0, with_open_count, mem, uuid_out) &&
+				   0, with_open_count) &&
 			 info->exists)
 			return 1;
 	}
 
 	if (name)
-		return _info_run(name, NULL, info, mknodes, with_open_count,
-				 mem, uuid_out);
+		return _info_run(name, NULL, info, mknodes, with_open_count);
 
 	return 0;
 }
@@ -240,8 +230,7 @@
 		return 0;
 	}
 
-	return _info(name, dlid, with_mknodes, with_open_count, info,
-		     NULL, NULL);
+	return _info(name, dlid, with_mknodes, with_open_count, info);
 }
 
 /* FIXME Interface must cope with multiple targets */
@@ -646,7 +635,7 @@
 		return_0;
 
         log_debug("Getting device info for %s [%s]", name, dlid);
-        if (!_info(name, dlid, 0, 1, &info, dm->mem, NULL)) {
+        if (!_info(name, dlid, 0, 1, &info)) {
                 log_error("Failed to get info for %s [%s].", name, dlid);
                 return 0;
         }


