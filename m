From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 16 Jan 2023 11:39:18 +0000 (GMT)
Subject: main - libdm: correcting ifdef possition
Message-ID: <20230116113918.982583858D32@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=3bedceec3882e00caf62df6fbeb946aeafea9df2
Commit:        3bedceec3882e00caf62df6fbeb946aeafea9df2
Parent:        aa09232dc4fb825f4e643bbe87a95e2318dd5a93
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Jan 15 21:42:13 2023 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jan 16 12:37:40 2023 +0100

libdm: correcting ifdef possition

Fix building without ioctl support.
---
 device_mapper/ioctl/libdm-iface.c | 4 +++-
 libdm/ioctl/libdm-iface.c         | 4 +++-
 2 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/device_mapper/ioctl/libdm-iface.c b/device_mapper/ioctl/libdm-iface.c
index 738807f8f..d25b07800 100644
--- a/device_mapper/ioctl/libdm-iface.c
+++ b/device_mapper/ioctl/libdm-iface.c
@@ -139,7 +139,6 @@ static char *_align(char *ptr, unsigned int a)
 	return (char *) (((unsigned long) ptr + agn) & ~agn);
 }
 
-#ifdef DM_IOCTLS
 static unsigned _kernel_major = 0;
 static unsigned _kernel_minor = 0;
 static unsigned _kernel_release = 0;
@@ -182,6 +181,9 @@ int get_uname_version(unsigned *major, unsigned *minor, unsigned *release)
 
 	return 1;
 }
+
+#ifdef DM_IOCTLS
+
 /*
  * Set number to NULL to populate _dm_bitset - otherwise first
  * match is returned.
diff --git a/libdm/ioctl/libdm-iface.c b/libdm/ioctl/libdm-iface.c
index 0fba79ce4..dfa91b866 100644
--- a/libdm/ioctl/libdm-iface.c
+++ b/libdm/ioctl/libdm-iface.c
@@ -138,7 +138,6 @@ static char *_align(char *ptr, unsigned int a)
 	return (char *) (((unsigned long) ptr + agn) & ~agn);
 }
 
-#ifdef DM_IOCTLS
 static unsigned _kernel_major = 0;
 static unsigned _kernel_minor = 0;
 static unsigned _kernel_release = 0;
@@ -181,6 +180,9 @@ int get_uname_version(unsigned *major, unsigned *minor, unsigned *release)
 
 	return 1;
 }
+
+#ifdef DM_IOCTLS
+
 /*
  * Set number to NULL to populate _dm_bitset - otherwise first
  * match is returned.

