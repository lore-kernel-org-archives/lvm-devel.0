From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue,  8 Apr 2014 09:02:34 +0000 (UTC)
Subject: master - libdm: check for size when opening control node
Message-ID: <20140408090234.6341D60CE2@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=2c2819763083d3c2e6b011117d8fa27c77a4d4e8
Commit:        2c2819763083d3c2e6b011117d8fa27c77a4d4e8
Parent:        583fbdba84afae3a045915603c6c057c76fcf485
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Apr 4 21:46:45 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Apr 8 11:00:13 2014 +0200

libdm: check for size when opening control node

Use dm_snprintf() to detect fail if open_control node would
not have fit into buffer.
---
 WHATS_NEW_DM              |    1 +
 libdm/ioctl/libdm-iface.c |    3 ++-
 2 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 49a7812..1c0843e 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.85 - 
 ===================================
+  Check for sprintf error when creating path for dm control node.
   When buffer for dm_get_library_version() is too small, return error code.
   Always reinitialize _name_mangling_mode in dm_lib_init().
   Add tracking flag about implicitly added devices into dm_tree.
diff --git a/libdm/ioctl/libdm-iface.c b/libdm/ioctl/libdm-iface.c
index 7b1fead..25f1d90 100644
--- a/libdm/ioctl/libdm-iface.c
+++ b/libdm/ioctl/libdm-iface.c
@@ -380,7 +380,8 @@ static int _open_control(void)
 	if (!_uname())
 		return 0;
 
-	snprintf(control, sizeof(control), "%s/%s", dm_dir(), DM_CONTROL_NODE);
+	if (dm_snprintf(control, sizeof(control), "%s/%s", dm_dir(), DM_CONTROL_NODE) < 0)
+		goto_bad;
 
 	/*
 	 * Prior to 2.6.36 the minor number should be looked up in /proc.


