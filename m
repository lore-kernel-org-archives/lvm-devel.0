From: Peter Rajnoha <prajnoha@redhat.com>
Date: Mon, 21 Mar 2011 15:46:08 +0100
Subject: [PATCH 3/3] Use global libudev context in _set_udev_checking fn
Message-ID: <4D8764B0.6060706@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This is just a little cleanup - we use global libudev reference now,
so there's no need to call udev_new even in existing code. Udev library
reference is initialized at LVM2 start and finalized at its end
(see previous patch).

Peter
---
 tools/lvmcmdline.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index efe7f4e..aef9bf8 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -960,7 +960,7 @@ static int _set_udev_checking(struct cmd_context *cmd)
 	size_t udev_dev_dir_len;
 	int dirs_diff;
 
-	if (!(udev = udev_new()) ||
+	if (!(udev = udev_get_library_context()) ||
 	    !(udev_dev_dir = udev_get_dev_path(udev)) ||
 	    !*udev_dev_dir) {
 		log_error("Could not get udev dev path.");
@@ -988,7 +988,6 @@ static int _set_udev_checking(struct cmd_context *cmd)
 		init_udev_checking(0);
 	}
 
-	udev_unref(udev);
 #endif
 	return 1;
 }


