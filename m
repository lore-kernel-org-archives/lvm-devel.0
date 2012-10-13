From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sat, 13 Oct 2012 17:22:05 +0000 (UTC)
Subject: master - cleanup: remove unneeded headers
Message-ID: <20121013172205.2600622CC@hosted02.fedoraproject.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=feea5003cc0af2647f45a46d7b1d449a2f75e99b
Commit:        feea5003cc0af2647f45a46d7b1d449a2f75e99b
Parent:        98124361ae19b049842d9c8263be6216ee5a6ed8
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Oct 13 19:13:25 2012 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Oct 13 19:13:25 2012 +0200

cleanup: remove unneeded headers

Header do not provide any needed symbols.
---
 lib/cache/lvmetad.c          |    1 -
 lib/device/dev-cache.c       |    1 -
 libdaemon/client/daemon-io.c |    1 -
 3 files changed, 0 insertions(+), 3 deletions(-)

diff --git a/lib/cache/lvmetad.c b/lib/cache/lvmetad.c
index 9c11329..64820d8 100644
--- a/lib/cache/lvmetad.c
+++ b/lib/cache/lvmetad.c
@@ -20,7 +20,6 @@
 #include "lvmcache.h"
 #include "lvmetad-client.h"
 #include "format-text.h" // TODO for disk_locn, used as a DA representation
-#include "filter.h"
 #include "assert.h"
 #include "crc.h"
 
diff --git a/lib/device/dev-cache.c b/lib/device/dev-cache.c
index 44a9e27..d08b07f 100644
--- a/lib/device/dev-cache.c
+++ b/lib/device/dev-cache.c
@@ -18,7 +18,6 @@
 #include "lvm-types.h"
 #include "btree.h"
 #include "filter.h"
-#include "filter-persistent.h"
 #include "toolcontext.h"
 
 #include <unistd.h>
diff --git a/libdaemon/client/daemon-io.c b/libdaemon/client/daemon-io.c
index 50ef9b2..37f2744 100644
--- a/libdaemon/client/daemon-io.c
+++ b/libdaemon/client/daemon-io.c
@@ -18,7 +18,6 @@
 #include <unistd.h>
 
 #include "daemon-io.h"
-#include "dm-logging.h"
 #include "libdevmapper.h"
 
 /*


