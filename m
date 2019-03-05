From: Marian Csontos <mcsontos@sourceware.org>
Date: Tue, 5 Mar 2019 08:53:47 -0500
Subject: stable-2.02 - libdm: add memory barrier
Message-ID: <201903051353.x25DrlxZ006797@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=8d44cd3e47a05db4983bcb8e8e1c08cfe80708ab
Commit:        8d44cd3e47a05db4983bcb8e8e1c08cfe80708ab
Parent:        40f57155a308bcefedb1ec6dc482b8c719b56750
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Nov 16 16:01:03 2018 +0100
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Tue Mar 5 12:48:15 2019 +0100

libdm: add memory barrier

Just for case ensure compiler is not able to optimize
memset() away for resources that are released.

This idea of using memory barrier is taken from openssl.

Other options would be to check for 'explicit_bzero' function.

(cherry picked from commit 55a8d6c86b4c6c6c707cfcc3dd887bca0632114f)

Conflicts:
	device_mapper/ioctl/libdm-iface.c
---
 libdm/ioctl/libdm-iface.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/libdm/ioctl/libdm-iface.c b/libdm/ioctl/libdm-iface.c
index 3a48c9b..79ea51d 100644
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


