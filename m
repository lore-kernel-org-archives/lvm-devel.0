From: tasleson <tasleson@fedoraproject.org>
Date: Fri, 12 Jul 2013 21:52:53 +0000 (UTC)
Subject: master - lvm-percent.c: Add #include "lib.h"
Message-ID: <20130712215253.B0EC86155A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=79eb40a2c8249e9e425f5950d1e9ec275da2d121
Commit:        79eb40a2c8249e9e425f5950d1e9ec275da2d121
Parent:        5227b65588cb45d27bb6841617970e73903c0b9f
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Fri Jul 12 17:47:16 2013 -0400
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Fri Jul 12 16:52:16 2013 -0500

lvm-percent.c: Add #include "lib.h"

This standard include for library files was missing,
adding it.

Signed-off-by: Tony Asleson <tasleson@redhat.com>
---
 lib/misc/lvm-percent.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/lib/misc/lvm-percent.c b/lib/misc/lvm-percent.c
index 1dafa57..013544f 100644
--- a/lib/misc/lvm-percent.c
+++ b/lib/misc/lvm-percent.c
@@ -12,6 +12,7 @@
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
 
+#include "lib.h"
 #include "lvm-percent.h"
 
 float percent_to_float(percent_t v)


