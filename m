From: Marian Csontos <mcsontos@sourceware.org>
Date: Wed, 23 Oct 2019 04:02:40 -0400
Subject: master - cov: Fix memory leak
Message-ID: <201910230802.x9N82efp012305@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=23cc7ddc50e2800a6dc248de897a4c88c1514160
Commit:        23cc7ddc50e2800a6dc248de897a4c88c1514160
Parent:        3e3c78a6b0285448ca1f96567bc25d8013e97b45
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Wed Aug 28 10:45:04 2019 +0200
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Wed Oct 23 09:51:55 2019 +0200

cov: Fix memory leak

---
 libdm/libdm-common.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/libdm/libdm-common.c b/libdm/libdm-common.c
index d17c284..d75c704 100644
--- a/libdm/libdm-common.c
+++ b/libdm/libdm-common.c
@@ -2011,7 +2011,8 @@ static int _sysfs_get_kernel_name(uint32_t major, uint32_t minor, char *buf, siz
 			log_sys_error("readlink", sysfs_path);
 		else {
 			log_sys_debug("readlink", sysfs_path);
-			return _sysfs_find_kernel_name(major, minor, buf, buf_size);
+			r = _sysfs_find_kernel_name(major, minor, buf, buf_size);
+			goto out;
 		}
 		goto bad;
 	}
@@ -2032,6 +2033,7 @@ static int _sysfs_get_kernel_name(uint32_t major, uint32_t minor, char *buf, siz
 	strcpy(buf, name);
 	r = 1;
 bad:
+out:
 	dm_free(temp_buf);
 	dm_free(sysfs_path);
 


