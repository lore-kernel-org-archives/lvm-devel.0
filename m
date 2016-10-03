From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon,  3 Oct 2016 15:51:16 +0000 (UTC)
Subject: master - cleanup :drop unneeded header file
Message-ID: <20161003155116.1DB3260A70@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=43662fa081ccced622711aecfa21ef8d158a3dc3
Commit:        43662fa081ccced622711aecfa21ef8d158a3dc3
Parent:        77ffd39dfb4145e444fb9ab2394d807207db8083
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Oct 3 14:49:06 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Oct 3 17:49:56 2016 +0200

cleanup :drop unneeded header file

Not needed  (Coverity).
---
 lib/uuid/uuid.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/lib/uuid/uuid.c b/lib/uuid/uuid.c
index aa44dc4..1833f2c 100644
--- a/lib/uuid/uuid.c
+++ b/lib/uuid/uuid.c
@@ -19,7 +19,6 @@
 
 #include <assert.h>
 #include <sys/stat.h>
-#include <fcntl.h>
 #include <unistd.h>
 #include <ctype.h>
 


