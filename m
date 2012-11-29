From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu, 29 Nov 2012 13:42:38 +0000 (UTC)
Subject: master - udev: _udev_disabled var visible also for !UDEV_SYNC_SUPPORT
Message-ID: <20121129134238.E26631D51@hosted02.fedoraproject.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b13d45d21d616c5512593617bbf5ed4c623805ed
Commit:        b13d45d21d616c5512593617bbf5ed4c623805ed
Parent:        4891a735d343db26460f1b6218169c458d59f2a1
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Nov 29 14:40:12 2012 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Nov 29 14:40:12 2012 +0100

udev: _udev_disabled var visible also for !UDEV_SYNC_SUPPORT

---
 libdm/libdm-common.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/libdm/libdm-common.c b/libdm/libdm-common.c
index 2d79efa..527124f 100644
--- a/libdm/libdm-common.c
+++ b/libdm/libdm-common.c
@@ -74,8 +74,9 @@ static dm_string_mangling_t _name_mangling_mode = DEFAULT_DM_NAME_MANGLING;
 static struct selabel_handle *_selabel_handle = NULL;
 #endif
 
-#ifdef UDEV_SYNC_SUPPORT
 static int _udev_disabled = 0;
+
+#ifdef UDEV_SYNC_SUPPORT
 static int _semaphore_supported = -1;
 static int _udev_running = -1;
 static int _sync_with_udev = 1;


