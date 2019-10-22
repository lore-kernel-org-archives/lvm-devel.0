From: Marian Csontos <mcsontos@sourceware.org>
Date: Tue, 22 Oct 2019 07:32:38 -0400
Subject: stable-2.02 - cov: Clarify the control flow
Message-ID: <201910221132.x9MBWcKG025380@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=c24fa7b7b714871950e0366ca4c35d0e601786ff
Commit:        c24fa7b7b714871950e0366ca4c35d0e601786ff
Parent:        3fe2610cff1afc1eaf9bc9c141950fe8ded73793
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Mon Oct 21 15:32:09 2019 +0200
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Mon Oct 21 15:32:09 2019 +0200

cov: Clarify the control flow

Return need a clean up but it is not bailing out due to an error.

Fix: 402b41f58dc14160ec21937d6308b0d9a1abba7d
---
 libdm/libdm-common.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/libdm/libdm-common.c b/libdm/libdm-common.c
index b06e678..32d052c 100644
--- a/libdm/libdm-common.c
+++ b/libdm/libdm-common.c
@@ -2013,7 +2013,7 @@ static int _sysfs_get_kernel_name(uint32_t major, uint32_t minor, char *buf, siz
 		else {
 			log_sys_debug("readlink", sysfs_path);
 			r = _sysfs_find_kernel_name(major, minor, buf, buf_size);
-			goto bad;
+			goto out;
 		}
 		goto bad;
 	}
@@ -2034,6 +2034,7 @@ static int _sysfs_get_kernel_name(uint32_t major, uint32_t minor, char *buf, siz
 	strcpy(buf, name);
 	r = 1;
 bad:
+out:
 	dm_free(temp_buf);
 	dm_free(sysfs_path);
 


