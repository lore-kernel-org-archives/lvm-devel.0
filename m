From: Tony Asleson <tasleson@sourceware.org>
Date: Thu, 9 Mar 2017 17:42:03 -0500
Subject: master - lvmdbusd: Add debug message to lvm ID lookup
Message-ID: <201703092242.v29Mg30e014263@int-mx13.intmail.prod.int.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=00143753ee4aec09eb40176ada5d34c3bde91884
Commit:        00143753ee4aec09eb40176ada5d34c3bde91884
Parent:        28754145d8cdad50bfa003fb13fc46af1cbadae8
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Thu Mar 9 16:03:20 2017 -0600
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Thu Mar 9 16:39:47 2017 -0600

lvmdbusd: Add debug message to lvm ID lookup

---
 daemons/lvmdbusd/manager.py |    9 +++++----
 1 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/daemons/lvmdbusd/manager.py b/daemons/lvmdbusd/manager.py
index 3c2bfcb..433473f 100644
--- a/daemons/lvmdbusd/manager.py
+++ b/daemons/lvmdbusd/manager.py
@@ -6,7 +6,7 @@
 #
 # You should have received a copy of the GNU General Public License
 # along with this program. If not, see <http://www.gnu.org/licenses/>.
-
+from utils import log_debug
 from .automatedproperties import AutomatedProperties
 
 from . import utils
@@ -143,9 +143,10 @@ class Manager(AutomatedProperties):
 	@staticmethod
 	def _lookup_by_lvm_id(key):
 		p = cfg.om.get_object_path_by_uuid_lvm_id(key, key)
-		if p:
-			return p
-		return '/'
+		if not p:
+			p = '/'
+		log_debug('LookUpByLvmId: key = %s, result = %s' % (key, p))
+		return p
 
 	@dbus.service.method(
 		dbus_interface=MANAGER_INTERFACE,


