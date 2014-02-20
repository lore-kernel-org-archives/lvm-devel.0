From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu, 20 Feb 2014 08:08:53 +0000 (UTC)
Subject: master - cleanup: missing header file
Message-ID: <20140220080853.B861D6151A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=08116a4962bef2a36549c5496b3230862d3c93ca
Commit:        08116a4962bef2a36549c5496b3230862d3c93ca
Parent:        5e83682ccf1862289ed2f3bcbe03cfa1c190e1e0
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Feb 20 09:07:38 2014 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Feb 20 09:07:38 2014 +0100

cleanup: missing header file

---
 lib/format_text/format-text.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index 6cedc99..b4f96f8 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -29,6 +29,7 @@
 #include "label.h"
 #include "lvmcache.h"
 #include "lvmetad.h"
+#include "memlock.h"
 
 #include <unistd.h>
 #include <sys/param.h>


