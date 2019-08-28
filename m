From: Marian Csontos <mcsontos@sourceware.org>
Date: Wed, 28 Aug 2019 08:47:54 -0400
Subject: stable-2.02 - cov: Fix memory leak
Message-ID: <201908281247.x7SClsrE002193@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=402b41f58dc14160ec21937d6308b0d9a1abba7d
Commit:        402b41f58dc14160ec21937d6308b0d9a1abba7d
Parent:        560dd9c552f49de0298104a69538b574f018fa40
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Wed Aug 28 10:45:04 2019 +0200
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Wed Aug 28 14:47:23 2019 +0200

cov: Fix memory leak

---
 libdm/libdm-common.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/libdm/libdm-common.c b/libdm/libdm-common.c
index c300223..b06e678 100644
--- a/libdm/libdm-common.c
+++ b/libdm/libdm-common.c
@@ -2012,7 +2012,8 @@ static int _sysfs_get_kernel_name(uint32_t major, uint32_t minor, char *buf, siz
 			log_sys_error("readlink", sysfs_path);
 		else {
 			log_sys_debug("readlink", sysfs_path);
-			return _sysfs_find_kernel_name(major, minor, buf, buf_size);
+			r = _sysfs_find_kernel_name(major, minor, buf, buf_size);
+			goto bad;
 		}
 		goto bad;
 	}


