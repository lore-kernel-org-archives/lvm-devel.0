From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 13 Sep 2021 10:36:22 +0000 (GMT)
Subject: main - man-generator: initialize struct stat to avoid MSAN error
Message-ID: <20210913103622.C51333858002@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=cd897e536fb69281d5d8e3e382a3827640913bd1
Commit:        cd897e536fb69281d5d8e3e382a3827640913bd1
Parent:        064979dc3238171cc4029ebfcbf63ad71cc7d9cd
Author:        Adrian Ratiu <adrian.ratiu@collabora.com>
AuthorDate:    Thu Sep 9 17:51:47 2021 +0300
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Sep 13 12:34:41 2021 +0200

man-generator: initialize struct stat to avoid MSAN error

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
index 0d37de7f6..37f6a6153 100644
--- a/tools/command.c
+++ b/tools/command.c
@@ -3526,7 +3526,7 @@ static int _include_description_file(char *name, char *des_file)
 	char *buf;
 	int fd, r = 0;
 	ssize_t sz;
-	struct stat statbuf;
+	struct stat statbuf = { 0 };
 
 	if ((fd = open(des_file, O_RDONLY)) < 0) {
 		log_error("Failed to open description file %s.", des_file);


