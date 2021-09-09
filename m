From: Adrian Ratiu <adrian.ratiu@collabora.com>
Date: Thu,  9 Sep 2021 17:51:47 +0300
Subject: [PATCH] man-generator: initialize struct stat to avoid MSAN error
Message-ID: <20210909145147.1545231-1-adrian.ratiu@collabora.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

When building lvm2 in Gentoo/ChromeOS with the ASAN memory
sanitizer enabled, man-generator fails with the following
error. Initializing makes the error go away.

* SUMMARY: MemorySanitizer: use-of-uninitialized-value /build/amd64-generic/tmp/portage/sys-fs/lvm2-2.02.187-r3/work/LVM2.2.02.187/tools/man-generator.c:3316:6 in _include_description_file
* Exiting
* ASAN error detected:
* ==2548047==WARNING: MemorySanitizer: use-of-uninitialized-value
*     #0 0x558b00ab4730 in _include_description_file /build/amd64-generic/tmp/portage/sys-fs/lvm2-2.02.187-r3/work/LVM2.2.02.187/tools/man-generator.c:3316:6
*     #1 0x558b00ab4730 in _print_man /build/amd64-generic/tmp/portage/sys-fs/lvm2-2.02.187-r3/work/LVM2.2.02.187/tools/man-generator.c:3426:21
*     #2 0x558b00ab4730 in main /build/amd64-generic/tmp/portage/sys-fs/lvm2-2.02.187-r3/work/LVM2.2.02.187/tools/man-generator.c:3570:7
*     #0 0x7fa9b2cbb807 in find_derivation /var/tmp/portage/cross-x86_64-cros-linux-gnu/glibc-2.33-r8/work/glibc-2.33/iconv/gconv_db.c:583:15
*     #1 0x558b00a29559 in ?? ??:0
*
*   Uninitialized value was created by an allocation of 'statbuf.i.i' in the stack frame of function 'main'
*     #0 0x558b00ab1d4d in main /build/amd64-generic/tmp/portage/sys-fs/lvm2-2.02.187-r3/work/LVM2.2.02.187/tools/man-generator.c:3505
---
 tools/command.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/tools/command.c b/tools/command.c
index 7205969e1..c019045e7 100644
--- a/tools/command.c
+++ b/tools/command.c
@@ -3525,7 +3525,7 @@ static int _include_description_file(char *name, char *des_file)
 	char *buf;
 	int fd, r = 0;
 	ssize_t sz;
-	struct stat statbuf;
+	struct stat statbuf = {0};
 
 	if ((fd = open(des_file, O_RDONLY)) < 0) {
 		log_error("Failed to open description file %s.", des_file);
-- 
2.33.0



