From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sat, 22 Nov 2014 09:01:26 +0000 (UTC)
Subject: master - dev_manager: fix mknodes
Message-ID: <20141122090126.7C95C60E11@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=4dc602f79bd6579eef15a9227aee99fe832a7610
Commit:        4dc602f79bd6579eef15a9227aee99fe832a7610
Parent:        6ce8e579897929fceb9da7865160f2e7921ddc6a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Nov 21 19:36:51 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Nov 22 09:57:31 2014 +0100

dev_manager: fix mknodes

Fix regression introduced with a2c1024f6ac7e22ac5c010a267d0c1df331ee416

_setup_task(mknodes ? name : NULL...

has been replaced with:

_setup_task(type != MKNODES ? name : NULL....

Use '=='
---
 WHATS_NEW                  |    1 +
 lib/activate/dev_manager.c |    2 +-
 2 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 31a1f3e..3b3e414 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.113 - 
 =====================================
+  Fix regression in vgscan --mknodes usage (2.02.112).
   Respect --prefix when setting CLMVD_PATH configure (2.02.89).
   Default to configure --enable-udev-systemd-background-jobs for systemd>=205.
   Fix ignore_vg() to properly react on various vg_read errors (2.02.112).
diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 44b273d..e336933 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -206,7 +206,7 @@ static int _info_run(info_type_t type, const char *name, const char *dlid,
 			return 0;
 	}
 
-	if (!(dmt = _setup_task(type != MKNODES ? name : NULL, dlid, 0, dmtask,
+	if (!(dmt = _setup_task((type == MKNODES) ? name : NULL, dlid, 0, dmtask,
 				major, minor, with_open_count)))
 		return_0;
 


