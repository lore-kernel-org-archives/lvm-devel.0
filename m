From: tasleson <tasleson@fedoraproject.org>
Date: Mon, 19 Sep 2016 20:38:33 +0000 (UTC)
Subject: master - lvmdbusd: Correct imports
Message-ID: <20160919203833.9CC9E60D98@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ec821d37a845f448230d114188f2a0d7623976dc
Commit:        ec821d37a845f448230d114188f2a0d7623976dc
Parent:        c23d5f63fdc7c56b41d8863e4bb4c20bfc1950f3
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Mon Sep 19 10:29:26 2016 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Mon Sep 19 15:32:47 2016 -0500

lvmdbusd: Correct imports

Place the imports in the files where they are directly needed.
---
 daemons/lvmdbusd/automatedproperties.py |    1 +
 daemons/lvmdbusd/main.py                |    1 +
 daemons/lvmdbusd/utils.py               |    2 --
 3 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/daemons/lvmdbusd/automatedproperties.py b/daemons/lvmdbusd/automatedproperties.py
index aff920c..5e14d61 100644
--- a/daemons/lvmdbusd/automatedproperties.py
+++ b/daemons/lvmdbusd/automatedproperties.py
@@ -8,6 +8,7 @@
 # along with this program. If not, see <http://www.gnu.org/licenses/>.
 
 import dbus
+import dbus.service
 from . import cfg
 from .utils import get_properties, add_properties, get_object_property_diff, \
 	log_debug
diff --git a/daemons/lvmdbusd/main.py b/daemons/lvmdbusd/main.py
index 65a66db..9f7b928 100644
--- a/daemons/lvmdbusd/main.py
+++ b/daemons/lvmdbusd/main.py
@@ -16,6 +16,7 @@ from . import cmdhandler
 import time
 import signal
 import dbus
+import dbus.mainloop.glib
 from . import lvmdb
 # noinspection PyUnresolvedReferences
 from gi.repository import GLib
diff --git a/daemons/lvmdbusd/utils.py b/daemons/lvmdbusd/utils.py
index 4fb6a6c..ef7e61f 100644
--- a/daemons/lvmdbusd/utils.py
+++ b/daemons/lvmdbusd/utils.py
@@ -16,8 +16,6 @@ import string
 import datetime
 
 import dbus
-import dbus.service
-import dbus.mainloop.glib
 from lvmdbusd import cfg
 
 


