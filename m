From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 15 Oct 2018 11:55:55 -0400
Subject: master - cov: log failing unlink
Message-ID: <201810151555.w9FFttxd020693@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=70950bbd977020593b19ac704fd7571b4b2826cd
Commit:        70950bbd977020593b19ac704fd7571b4b2826cd
Parent:        f1ac130dc10ba22eaafd31e906b347a12b8cea16
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Oct 15 16:21:01 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Oct 15 17:49:44 2018 +0200

cov: log failing unlink

---
 tools/pvscan.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/tools/pvscan.c b/tools/pvscan.c
index 6e80e3c..613a4c4 100644
--- a/tools/pvscan.c
+++ b/tools/pvscan.c
@@ -225,7 +225,8 @@ static void _online_pvid_file_remove_devno(int major, int minor)
 
 		if (!strncmp(buf, buf_in, strlen(buf))) {
 			log_debug("Unlink pv online %s %s", buf, path);
-			unlink(path);
+			if (unlink(path))
+				log_sys_debug("unlink", path);
 			break;
 		}
 	}
@@ -248,7 +249,8 @@ static void _online_pvid_files_remove(void)
 
 		memset(path, 0, sizeof(path));
 		snprintf(path, sizeof(path), "%s/%s", _pvs_online_dir, de->d_name);
-		unlink(path);
+		if (unlink(path))
+			log_sys_debug("unlink", path);
 	}
 	if (closedir(dir))
 		log_sys_debug("closedir", _pvs_online_dir);


