From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 22 Nov 2013 20:09:11 +0000 (UTC)
Subject: master - fix missing header
Message-ID: <20131122200911.58B1D61133@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=30c127eaf8561c9fc4b0aecace2991d3551a5dd3
Commit:        30c127eaf8561c9fc4b0aecace2991d3551a5dd3
Parent:        b4fc397de6a456efb8b8cce1e7d0048d4573f7cc
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Nov 22 20:44:25 2013 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Nov 22 21:00:55 2013 +0100

fix missing header

---
 lib/metadata/pv_manip.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/lib/metadata/pv_manip.c b/lib/metadata/pv_manip.c
index bee7972..d0c3b44 100644
--- a/lib/metadata/pv_manip.c
+++ b/lib/metadata/pv_manip.c
@@ -19,6 +19,7 @@
 #include "toolcontext.h"
 #include "locking.h"
 #include "defaults.h"
+#include "lvmcache.h"
 #include "lvmetad.h"
 #include "display.h"
 #include "label.h"


