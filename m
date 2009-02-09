From: Dave Wysochanski <dwysocha@redhat.com>
Date: Sun,  8 Feb 2009 23:22:00 -0500
Subject: [PATCH 12/21] Add lvm-types.h to lvm2.h file.
In-Reply-To: <1234153329-2829-12-git-send-email-dwysocha@redhat.com>
References: <1234153329-2829-1-git-send-email-dwysocha@redhat.com>
	<1234153329-2829-2-git-send-email-dwysocha@redhat.com>
	<1234153329-2829-3-git-send-email-dwysocha@redhat.com>
	<1234153329-2829-4-git-send-email-dwysocha@redhat.com>
	<1234153329-2829-5-git-send-email-dwysocha@redhat.com>
	<1234153329-2829-6-git-send-email-dwysocha@redhat.com>
	<1234153329-2829-7-git-send-email-dwysocha@redhat.com>
	<1234153329-2829-8-git-send-email-dwysocha@redhat.com>
	<1234153329-2829-9-git-send-email-dwysocha@redhat.com>
	<1234153329-2829-10-git-send-email-dwysocha@redhat.com>
	<1234153329-2829-11-git-send-email-dwysocha@redhat.com>
	<1234153329-2829-12-git-send-email-dwysocha@redhat.com>
Message-ID: <1234153329-2829-13-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/lvm2.h |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/lib/lvm2.h b/lib/lvm2.h
index a47c0a5..f0fe0a3 100644
--- a/lib/lvm2.h
+++ b/lib/lvm2.h
@@ -18,6 +18,7 @@
 #include <stdint.h>
 #include <fcntl.h>
 #include "libdevmapper.h"
+#include "lvm-types.h" /* needed for str_list */
 
 /*
  * lvm_handle_t
-- 
1.6.0.5


