From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 27 Mar 2014 12:15:21 +0000 (UTC)
Subject: master - debug: avoid warning when compiled with valgrind
Message-ID: <20140327121521.C368760040@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=5076456a735163243a8593870fed44fb0cc1c20e
Commit:        5076456a735163243a8593870fed44fb0cc1c20e
Parent:        356fdda46d673015446e8a0410e9dfe7fa67c66e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Mar 27 11:21:05 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Mar 27 13:13:08 2014 +0100

debug: avoid warning when compiled with valgrind

Declare 'c' only when compiling without valgrind.
This cleans compiler warning about unused var when
compiled with valgrind pool support.
---
 libdm/mm/dbg_malloc.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/libdm/mm/dbg_malloc.c b/libdm/mm/dbg_malloc.c
index a2a6b76..e26f05e 100644
--- a/libdm/mm/dbg_malloc.c
+++ b/libdm/mm/dbg_malloc.c
@@ -205,7 +205,6 @@ int dm_dump_memory_debug(void)
 	unsigned long tot = 0;
 	struct memblock *mb;
 	char str[32];
-	size_t c;
 
 	if (_head)
 		log_very_verbose("You have a memory leak:");
@@ -218,6 +217,8 @@ int dm_dump_memory_debug(void)
 		 */
 		str[0] = '\0';
 #else
+		size_t c;
+
 		for (c = 0; c < sizeof(str) - 1; c++) {
 			if (c >= mb->length)
 				str[c] = ' ';


