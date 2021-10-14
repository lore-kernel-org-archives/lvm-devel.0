From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 14 Oct 2021 22:09:58 +0000 (GMT)
Subject: main - gcc: archive reoder struct vars
Message-ID: <20211014220958.22EE23858427@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=14cf579263cb9121a8f06396c6257453492e043b
Commit:        14cf579263cb9121a8f06396c6257453492e043b
Parent:        438408de7dc3be6daed240ec52f0e0a09ae9b2f6
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Oct 14 23:41:47 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Oct 15 00:09:07 2021 +0200

gcc: archive reoder struct vars

Easier for automatic struct initialization = { 0 } without warns
from older gcc.
---
 lib/format_text/archive.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/lib/format_text/archive.c b/lib/format_text/archive.c
index c9c4f2265..09a472b4c 100644
--- a/lib/format_text/archive.c
+++ b/lib/format_text/archive.c
@@ -47,9 +47,8 @@
  * with the least recent at the head.
  */
 struct archive_file {
-	struct dm_list list;
-
 	const char *name;
+	struct dm_list list;
 	uint32_t index;
 };
 


