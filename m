From: Peter Rajnoha <prajnoha@redhat.com>
Date: Mon, 30 Aug 2010 16:22:21 +0200
Subject: [PATCH] Add timestamp in addition to index number for VG archive file names
Message-ID: <4C7BBE9D.5030708@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

In certain configurations, we're not under a VG rw lock while trying to write
a new archive file with VG metadata. A common example is using "vgs" while
having the content of backup and archive directories empty. The code scans the
content of these directories and tries to determine the final index that should
be used in archive name. Since we're not under a lock, we can get into a race
while choosing the index which could end up showing errors about not being able
to rename to final archive name. Let's add simple timestamps to these archive
names so we can avoid the race.

This should resolve part of the problem reported here:
https://bugzilla.redhat.com/show_bug.cgi?id=615907

Though, I still haven't found the exact cause of the other problem mentioned in
the bug report - the appeareance of blank temporary files. I'd need more log
information to see what happened exactly - whether the export of the vg failed
or whatever...

Peter
---
diff --git a/lib/format_text/archive.c b/lib/format_text/archive.c
index 95ac49d..d12ac4d 100644
--- a/lib/format_text/archive.c
+++ b/lib/format_text/archive.c
@@ -26,6 +26,7 @@
 #include <unistd.h>
 #include <sys/stat.h>
 #include <sys/file.h>
+#include <sys/time.h>
 #include <fcntl.h>
 #include <time.h>
 
@@ -232,6 +233,7 @@ int archive_vg(struct volume_group *vg,
 	FILE *fp = NULL;
 	char temp_file[PATH_MAX], archive_name[PATH_MAX];
 	struct dm_list *archives;
+	struct timeval t;
 
 	/*
 	 * Write the vg out to a temporary file.
@@ -264,6 +266,11 @@ int archive_vg(struct volume_group *vg,
 	if (!(archives = _scan_archive(vg->cmd->mem, vg->name, dir)))
 		return_0;
 
+	if (gettimeofday(&t, NULL)) {
+		log_sys_error("gettimeofday", "archive_vg");
+		return 0;
+	}
+
 	if (dm_list_empty(archives))
 		ix = 0;
 	else {
@@ -273,7 +280,8 @@ int archive_vg(struct volume_group *vg,
 
 	for (i = 0; i < 10; i++) {
 		if (dm_snprintf(archive_name, sizeof(archive_name),
-				 "%s/%s_%05u.vg", dir, vg->name, ix) < 0) {
+				 "%s/%s_%05u-%ld-%ld.vg", dir, vg->name,
+				  ix, t.tv_sec, t.tv_usec) < 0) {
 			log_error("Archive file name too long.");
 			return 0;
 		}


