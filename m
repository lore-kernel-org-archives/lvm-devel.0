From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon,  3 Nov 2014 13:23:21 +0000 (UTC)
Subject: master - libdm: init char array
Message-ID: <20141103132321.C6EF2602D9@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ed2a0560ad23f3de0b63e4c48ce91e6d5c744c23
Commit:        ed2a0560ad23f3de0b63e4c48ce91e6d5c744c23
Parent:        e09ee21fd46287ed245ea086ddcf06140a83431a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Oct 31 13:04:46 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Nov 3 14:19:31 2014 +0100

libdm: init char array

When non-root uses dm_check_version() it's been printing some unit
values from stack. So always init those vars.
---
 WHATS_NEW_DM              |    1 +
 libdm/ioctl/libdm-iface.c |    2 +-
 2 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 6981f8f..6b5ee3a 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.91 - 
 ====================================
+  Don't print uninitialized stack bytes when non-root uses dm_check_version().
   Fix selection criteria to not match reserved values when using >, <, >=, <.
   Add DM_LIST_HEAD_INIT macro to libdevmapper.h
   Fix dm_is_dm_major to not issue error about missing /proc lines for dm module.
diff --git a/libdm/ioctl/libdm-iface.c b/libdm/ioctl/libdm-iface.c
index c308fd2..4c37a53 100644
--- a/libdm/ioctl/libdm-iface.c
+++ b/libdm/ioctl/libdm-iface.c
@@ -544,7 +544,7 @@ static int _check_version(char *version, size_t size, int log_suppress)
  */
 int dm_check_version(void)
 {
-	char libversion[64], dmversion[64];
+	char libversion[64] = "", dmversion[64] = "";
 	const char *compat = "";
 
 	if (_version_checked)


