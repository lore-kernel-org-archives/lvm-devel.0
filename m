From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 16 Nov 2018 18:33:04 -0500
Subject: master - libdm: add memory barrier
Message-ID: <201811162333.wAGNX4mf015933@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=55a8d6c86b4c6c6c707cfcc3dd887bca0632114f
Commit:        55a8d6c86b4c6c6c707cfcc3dd887bca0632114f
Parent:        43f8da76997a22be123e97b6d0f357d6ec2d0c7c
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Nov 16 16:01:03 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Nov 17 00:30:50 2018 +0100

libdm: add memory barrier

Just for case ensure compiler is not able to optimize
memset() away for resources that are released.

This idea of using memory barrier is taken from openssl.

Other options would be to check for 'explicit_bzero' function.
---
 device_mapper/ioctl/libdm-iface.c |    2 ++
 libdm/ioctl/libdm-iface.c         |    2 ++
 2 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/device_mapper/ioctl/libdm-iface.c b/device_mapper/ioctl/libdm-iface.c
index 1321dc0..eb6e9db 100644
--- a/device_mapper/ioctl/libdm-iface.c
+++ b/device_mapper/ioctl/libdm-iface.c
@@ -471,6 +471,7 @@ static void _dm_zfree_string(char *string)
 {
 	if (string) {
 		memset(string, 0, strlen(string));
+		asm volatile ("" ::: "memory"); /* Compiler barrier. */
 		free(string);
 	}
 }
@@ -479,6 +480,7 @@ static void _dm_zfree_dmi(struct dm_ioctl *dmi)
 {
 	if (dmi) {
 		memset(dmi, 0, dmi->data_size);
+		asm volatile ("" ::: "memory"); /* Compiler barrier. */
 		free(dmi);
 	}
 }
diff --git a/libdm/ioctl/libdm-iface.c b/libdm/ioctl/libdm-iface.c
index 002669e..b195c11 100644
--- a/libdm/ioctl/libdm-iface.c
+++ b/libdm/ioctl/libdm-iface.c
@@ -469,6 +469,7 @@ static void _dm_zfree_string(char *string)
 {
 	if (string) {
 		memset(string, 0, strlen(string));
+		asm volatile ("" ::: "memory"); /* Compiler barrier. */
 		dm_free(string);
 	}
 }
@@ -477,6 +478,7 @@ static void _dm_zfree_dmi(struct dm_ioctl *dmi)
 {
 	if (dmi) {
 		memset(dmi, 0, dmi->data_size);
+		asm volatile ("" ::: "memory"); /* Compiler barrier. */
 		dm_free(dmi);
 	}
 }


