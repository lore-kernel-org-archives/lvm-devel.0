From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 27 Sep 2021 16:57:55 +0000 (GMT)
Subject: main - cleanup: use first parameter uint
Message-ID: <20210927165755.8660B3858408@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=9668427fe8d08f2c0e3f778c53bc00181478f71c
Commit:        9668427fe8d08f2c0e3f778c53bc00181478f71c
Parent:        614d150a8c7387744804b90fddea99c7fb4511f2
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Sep 24 22:16:07 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Sep 27 18:56:14 2021 +0200

cleanup: use first parameter uint

Easier with struct zeroing and matching assing of type uint.
---
 tools/lvcreate.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index 0def23639..0121c09a8 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -18,9 +18,9 @@
 #include <fcntl.h>
 
 struct lvcreate_cmdline_params {
-	percent_type_t percent;
 	uint64_t size;
 	uint64_t virtual_size; /* snapshot, thin */
+	percent_type_t percent;
 	char **pvs;
 	uint32_t pv_count;
 };


