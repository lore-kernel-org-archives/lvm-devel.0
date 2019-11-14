From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 14 Nov 2019 12:07:10 -0500
Subject: master - cov: fix memory leak
Message-ID: <70013.119111412070602458@us-mta-378.us.mimecast.lan>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=33c8e4de33b2b2fced148e04f725af9d350a989a
Commit:        33c8e4de33b2b2fced148e04f725af9d350a989a
Parent:        13c254fc05386d05ab6bbda2806f9ca4d3358a0c
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Nov 14 16:23:38 2019 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Nov 14 18:05:41 2019 +0100

cov: fix memory leak

Reapply 23cc7ddc50e2800a6dc248de897a4c88c1514160 to internal version
of libdm.
---
 device_mapper/libdm-common.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/device_mapper/libdm-common.c b/device_mapper/libdm-common.c
index 1cb29f1..bc691d6 100644
--- a/device_mapper/libdm-common.c
+++ b/device_mapper/libdm-common.c
@@ -2012,7 +2012,8 @@ static int _sysfs_get_kernel_name(uint32_t major, uint32_t minor, char *buf, siz
 			log_sys_error("readlink", sysfs_path);
 		else {
 			log_sys_debug("readlink", sysfs_path);
-			return _sysfs_find_kernel_name(major, minor, buf, buf_size);
+			r = _sysfs_find_kernel_name(major, minor, buf, buf_size);
+			goto out;
 		}
 		goto bad;
 	}
@@ -2033,6 +2034,7 @@ static int _sysfs_get_kernel_name(uint32_t major, uint32_t minor, char *buf, siz
 	strcpy(buf, name);
 	r = 1;
 bad:
+out:
 	free(temp_buf);
 	free(sysfs_path);
 



