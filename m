From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri,  8 May 2015 13:16:40 +0000 (UTC)
Subject: master - cleanup: drop unneeded header file
Message-ID: <20150508131640.7BA7A60759@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=28f18404a7a2fe64f3c7918d8d543f913515651b
Commit:        28f18404a7a2fe64f3c7918d8d543f913515651b
Parent:        3c46428fcde05c3126ac2a505580cadb792f8997
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu May 7 10:58:35 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri May 8 15:15:10 2015 +0200

cleanup: drop unneeded header file

Does not resolves any symbols (Coverity).
---
 lib/misc/lvm-file.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/lib/misc/lvm-file.c b/lib/misc/lvm-file.c
index 2e896ec..6fc31cd 100644
--- a/lib/misc/lvm-file.c
+++ b/lib/misc/lvm-file.c
@@ -21,7 +21,6 @@
 #include <sys/file.h>
 #include <fcntl.h>
 #include <dirent.h>
-#include <sys/time.h>
 
 /*
  * Creates a temporary filename, and opens a descriptor to the


