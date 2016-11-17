From: tasleson <tasleson@fedoraproject.org>
Date: Thu, 17 Nov 2016 17:36:42 +0000 (UTC)
Subject: master - lvmdbusd: Remove un-used import
Message-ID: <20161117173642.8B25960D85@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=4f1171466fc6c18aa22c639a09a98de2e911c16f
Commit:        4f1171466fc6c18aa22c639a09a98de2e911c16f
Parent:        2fbb90e4033518f2fbd6d2de45125381f01e1cbe
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Wed Nov 16 10:46:27 2016 -0600
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Thu Nov 17 11:35:16 2016 -0600

lvmdbusd: Remove un-used import

---
 daemons/lvmdbusd/job.py |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/daemons/lvmdbusd/job.py b/daemons/lvmdbusd/job.py
index 3c3bba0..ec6d6b6 100644
--- a/daemons/lvmdbusd/job.py
+++ b/daemons/lvmdbusd/job.py
@@ -8,11 +8,12 @@
 # along with this program. If not, see <http://www.gnu.org/licenses/>.
 
 from .automatedproperties import AutomatedProperties
-from .utils import job_obj_path_generate, mt_async_result, log_debug
+from .utils import job_obj_path_generate, mt_async_result
 from . import cfg
 from .cfg import JOB_INTERFACE
 import dbus
 import threading
+# noinspection PyUnresolvedReferences
 from gi.repository import GLib
 
 


