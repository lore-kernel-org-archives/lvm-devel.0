From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 15 Oct 2018 11:55:52 -0400
Subject: master - cov: check closedir result
Message-ID: <201810151555.w9FFtqsa020683@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=f1ac130dc10ba22eaafd31e906b347a12b8cea16
Commit:        f1ac130dc10ba22eaafd31e906b347a12b8cea16
Parent:        668c9d0762fc6736a1e9372785544eda6a939806
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Oct 15 16:19:49 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Oct 15 17:49:44 2018 +0200

cov: check closedir result

Log problems around failing closedir().
---
 tools/pvscan.c |   12 ++++++++----
 1 files changed, 8 insertions(+), 4 deletions(-)

diff --git a/tools/pvscan.c b/tools/pvscan.c
index da63074..6e80e3c 100644
--- a/tools/pvscan.c
+++ b/tools/pvscan.c
@@ -229,7 +229,8 @@ static void _online_pvid_file_remove_devno(int major, int minor)
 			break;
 		}
 	}
-	closedir(dir);
+	if (closedir(dir))
+		log_sys_debug("closedir", _pvs_online_dir);
 }
 
 static void _online_pvid_files_remove(void)
@@ -249,7 +250,8 @@ static void _online_pvid_files_remove(void)
 		snprintf(path, sizeof(path), "%s/%s", _pvs_online_dir, de->d_name);
 		unlink(path);
 	}
-	closedir(dir);
+	if (closedir(dir))
+		log_sys_debug("closedir", _pvs_online_dir);
 }
 
 static void _online_pvid_file_create(struct device *dev)
@@ -338,10 +340,12 @@ static int _online_pvid_files_missing(void)
 	while ((de = readdir(dir))) {
 		if (de->d_name[0] == '.')
 			continue;
-		closedir(dir);
+		if (closedir(dir))
+			log_sys_debug("closedir", _pvs_online_dir);
 		return 0;
 	}
-	closedir(dir);
+	if (closedir(dir))
+		log_sys_debug("closedir", _pvs_online_dir);
 	return 1;
 }
 


