From: Fabio M. Di Nitto <fdinitto@redhat.com>
Date: Thu, 10 Sep 2009 16:25:18 +0200
Subject: [PATCH 2/3] cmirror: add missing include
In-Reply-To: <1252592719-7061-1-git-send-email-fdinitto@redhat.com>
References: <1252592719-7061-1-git-send-email-fdinitto@redhat.com>
Message-ID: <3d0d9fc1e79e170b6a95ef4fdaf22df03b26258c.1252591904.git.fdinitto@redhat.com>
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


