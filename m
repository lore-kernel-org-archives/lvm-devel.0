From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 19 Aug 2022 12:58:50 +0000 (GMT)
Subject: main - dmsetup: check also for ouf of range value
Message-ID: <20220819125850.B80273858C83@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=718e38d5faf3a3ca23690d2f4203df1df65eba77
Commit:        718e38d5faf3a3ca23690d2f4203df1df65eba77
Parent:        a3eb6ba425773224076c41aabc3c490a6a016ee6
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Aug 18 13:56:03 2022 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Aug 19 14:56:57 2022 +0200

dmsetup: check also for ouf of range value

Check errno result from strtoull().
---
 libdm/dm-tools/dmsetup.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/libdm/dm-tools/dmsetup.c b/libdm/dm-tools/dmsetup.c
index 8502d9adc..42eeead68 100644
--- a/libdm/dm-tools/dmsetup.c
+++ b/libdm/dm-tools/dmsetup.c
@@ -5106,8 +5106,9 @@ static int _size_from_string(char *argptr, uint64_t *size, const char *name)
 	if (!argptr)
 		return_0;
 
+	errno = 0;
 	*size = strtoull(argptr, &endptr, 10);
-	if (endptr == argptr) {
+	if (errno || endptr == argptr) {
 		*size = 0;
 		log_error("Invalid %s argument: \"%s\"",
 			  name, (*argptr) ? argptr : "");

