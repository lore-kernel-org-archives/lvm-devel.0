From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 23 Aug 2012 12:42:27 +0000 (UTC)
Subject: master - cleanup: use <> for system header file
Message-ID: <20120823124227.6CC4EA0D9A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b0b507b197588a25698cd876673f722b97bd18d8
Commit:        b0b507b197588a25698cd876673f722b97bd18d8
Parent:        286cd2006bd6426f19d2dd312441755624ed260e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Aug 17 01:12:10 2012 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Aug 23 14:37:20 2012 +0200

cleanup: use <> for system header file

---
 libdaemon/server/daemon-log.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/libdaemon/server/daemon-log.c b/libdaemon/server/daemon-log.c
index 21068bc..8eab917 100644
--- a/libdaemon/server/daemon-log.c
+++ b/libdaemon/server/daemon-log.c
@@ -1,7 +1,7 @@
 #include "daemon-server.h"
 #include "daemon-log.h"
 #include <syslog.h>
-#include "assert.h"
+#include <assert.h>
 
 struct backend {
 	int id;


