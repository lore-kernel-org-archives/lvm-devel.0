From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 11 Jun 2018 16:39:44 -0400
Subject: master - build: ensure configure.h comes first
Message-ID: <201806112039.w5BKdiuY031207@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=1c79cf9830390cfbe31d3146da66cbe36ac3e72a
Commit:        1c79cf9830390cfbe31d3146da66cbe36ac3e72a
Parent:        77d5caae90a898888d32603bc7823de40f426c06
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Jun 11 22:38:51 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jun 11 22:38:51 2018 +0200

build: ensure configure.h comes first

Fix header order so configure.h is 1st. included header.
---
 device_mapper/libdm-report.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/device_mapper/libdm-report.c b/device_mapper/libdm-report.c
index e437e4c..cbd0d16 100644
--- a/device_mapper/libdm-report.c
+++ b/device_mapper/libdm-report.c
@@ -13,8 +13,8 @@
  * Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
  */
 
-#include "base/memory/zalloc.h"
 #include "misc/dmlib.h"
+#include "base/memory/zalloc.h"
 
 #include <ctype.h>
 #include <math.h>  /* fabs() */


