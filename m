From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon,  9 Nov 2015 09:29:00 +0000 (UTC)
Subject: master - cleanup: drop unneeded header file
Message-ID: <20151109092900.214BE60F67@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f6d2528f648b2cfad0d516fc6f0444a2570579f2
Commit:        f6d2528f648b2cfad0d516fc6f0444a2570579f2
Parent:        5ba219e87a37cd18aa75971370254ed1fbdfde53
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Nov 7 17:16:32 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Nov 9 10:22:51 2015 +0100

cleanup: drop unneeded header file

---
 lib/datastruct/str_list.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/lib/datastruct/str_list.c b/lib/datastruct/str_list.c
index 73b5534..f056b85 100644
--- a/lib/datastruct/str_list.c
+++ b/lib/datastruct/str_list.c
@@ -16,8 +16,6 @@
 #include "lib.h"
 #include "str_list.h"
 
-#include <ctype.h>
-
 struct dm_list *str_list_create(struct dm_pool *mem)
 {
 	struct dm_list *sl;


