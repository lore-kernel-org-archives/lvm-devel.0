From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 12 Mar 2014 18:47:30 +0000 (UTC)
Subject: master - cleanup: drop unused define
Message-ID: <20140312184730.8136661295@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b50b4471bd863304a78b194d1ef10b85cc9666f7
Commit:        b50b4471bd863304a78b194d1ef10b85cc9666f7
Parent:        8b14ebb2f153408f3ea4e6a1ca16e1e63bdfefe7
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Mar 12 19:12:34 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Mar 12 19:12:34 2014 +0100

cleanup: drop unused define

---
 lib/uuid/uuid.h |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/lib/uuid/uuid.h b/lib/uuid/uuid.h
index 60bec65..d39ad88 100644
--- a/lib/uuid/uuid.h
+++ b/lib/uuid/uuid.h
@@ -17,7 +17,6 @@
 #define _LVM_UUID_H
 
 #define ID_LEN 32
-#define ID_LEN_S "32"
 
 #include <inttypes.h>
 #include <sys/types.h>


