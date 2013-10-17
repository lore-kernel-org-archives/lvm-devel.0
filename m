From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 17 Oct 2013 09:58:19 +0000 (UTC)
Subject: master - libdm: do not show holders missing error
Message-ID: <20131017095819.4C11361313@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=3ac7f927e1e587089bbbbae04ecad1906af55485
Commit:        3ac7f927e1e587089bbbbae04ecad1906af55485
Parent:        efd1dc6bd3e38f9a98f67db28537c5655992c6f9
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Oct 17 11:12:02 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Oct 17 11:55:21 2013 +0200

libdm: do not show holders missing error

On older system this may not be present, so skip this error message.
---
 WHATS_NEW_DM         |    1 +
 libdm/libdm-common.c |    3 ++-
 2 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index cf1cb18..b59a39e 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.83
 ==================================
+  Skip error message when holders are not present in sysfs.
   Use __linux__ instead of linux define to make libdevmapper.h C compliant.
 
 Version 1.02.82 - 4th October 2013
diff --git a/libdm/libdm-common.c b/libdm/libdm-common.c
index b66911c..52be405 100644
--- a/libdm/libdm-common.c
+++ b/libdm/libdm-common.c
@@ -1795,7 +1795,8 @@ int dm_device_has_holders(uint32_t major, uint32_t minor)
 	}
 
 	if (stat(sysfs_path, &st)) {
-		log_sys_error("stat", sysfs_path);
+		if (errno != ENOENT)
+			log_sys_error("stat", sysfs_path);
 		return 0;
 	}
 


