From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed,  2 Nov 2022 13:00:17 +0000 (GMT)
Subject: main - configure: update use_devicesfile in example.conf
Message-ID: <20221102130017.F075B385734A@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=17baeb65a913fb1793d0142b20087b10a7f88e37
Commit:        17baeb65a913fb1793d0142b20087b10a7f88e37
Parent:        81f10c1d1e844dd3ad9918a31a0d7c00fed36c94
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Oct 24 18:03:42 2022 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Nov 2 13:59:34 2022 +0100

configure: update use_devicesfile in example.conf

Example.conf missed to properly replace default value for
use_devicesfile setting and left there @VAR at .
---
 configure    | 2 ++
 configure.ac | 1 +
 2 files changed, 3 insertions(+)

diff --git a/configure b/configure
index 742012569..ccd5a5938 100755
--- a/configure
+++ b/configure
@@ -747,6 +747,7 @@ DLM_CFLAGS
 DEVMAPPER
 DEFAULT_USE_LVMLOCKD
 DEFAULT_USE_LVMPOLLD
+DEFAULT_USE_DEVICES_FILE
 DEFAULT_USE_BLKID_WIPING
 DEFAULT_SYS_LOCK_DIR
 DEFAULT_SYS_DIR
@@ -15497,6 +15498,7 @@ printf "%s\n" "#define LVM_CONFIGURE_LINE \"$CONFIGURE_LINE\"" >>confdefs.h
 
 
 
+
 
 
 ################################################################################
diff --git a/configure.ac b/configure.ac
index e0593aba0..704772b62 100644
--- a/configure.ac
+++ b/configure.ac
@@ -1877,6 +1877,7 @@ AC_SUBST(DEFAULT_SPARSE_SEGTYPE)
 AC_SUBST(DEFAULT_SYS_DIR)
 AC_SUBST(DEFAULT_SYS_LOCK_DIR)
 AC_SUBST(DEFAULT_USE_BLKID_WIPING)
+AC_SUBST(DEFAULT_USE_DEVICES_FILE)
 AC_SUBST(DEFAULT_USE_LVMPOLLD)
 AC_SUBST(DEFAULT_USE_LVMLOCKD)
 AC_SUBST(DEVMAPPER)

