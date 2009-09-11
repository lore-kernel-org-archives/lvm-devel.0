From: Fabio M. Di Nitto <fdinitto@redhat.com>
Date: Fri, 11 Sep 2009 08:26:38 +0200
Subject: [PATCH 2/3] cmirror: add missing include
In-Reply-To: <1252650399-8983-1-git-send-email-fdinitto@redhat.com>
References: <1252650399-8983-1-git-send-email-fdinitto@redhat.com>
Message-ID: <46de2c9b507b51d31a8cab833949220ba4d0d3af.1252650266.git.fdinitto@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

otherwise the build fails because the pid file is not defined.

Signed-off-by: Fabio M. Di Nitto <fdinitto@redhat.com>
---
:100644 100644 bfb74fa... d277803... M	daemons/cmirrord/clogd.c
 daemons/cmirrord/clogd.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/daemons/cmirrord/clogd.c b/daemons/cmirrord/clogd.c
index bfb74fa..d277803 100644
--- a/daemons/cmirrord/clogd.c
+++ b/daemons/cmirrord/clogd.c
@@ -9,6 +9,9 @@
  * along with this program; if not, write to the Free Software Foundation,
  * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
+
+#include "configure.h"
+
 #include <stdio.h>
 #include <stdlib.h>
 #include <stdint.h>
-- 
1.5.4.3


