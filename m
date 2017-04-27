From: Marian Csontos <mcsontos@sourceware.org>
Date: Thu, 27 Apr 2017 12:16:53 -0400
Subject: master - dbus: log_debug needs qualifier
Message-ID: <201704271616.v3RGGrY3022285@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=5cf51fb2f74ad43a2555bc391cf069caa1d99775
Commit:        5cf51fb2f74ad43a2555bc391cf069caa1d99775
Parent:        0e3c16af5699c000f1824c42c596fec58d019dfa
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Thu Apr 27 18:12:20 2017 +0200
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Thu Apr 27 18:16:17 2017 +0200

dbus: log_debug needs qualifier

Adding qualifier makes the only unqualified log_debug occurence
consistent with other uses in the same file.

Other possible ways to fix this:

- using `from .utils import log_debug`
- moving the line below `from . import utils` line
---
 daemons/lvmdbusd/manager.py |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/daemons/lvmdbusd/manager.py b/daemons/lvmdbusd/manager.py
index 1ae9c8b..d77c7b4 100644
--- a/daemons/lvmdbusd/manager.py
+++ b/daemons/lvmdbusd/manager.py
@@ -6,7 +6,6 @@
 #
 # You should have received a copy of the GNU General Public License
 # along with this program. If not, see <http://www.gnu.org/licenses/>.
-from utils import log_debug
 from .automatedproperties import AutomatedProperties
 
 from . import utils
@@ -145,7 +144,7 @@ class Manager(AutomatedProperties):
 		p = cfg.om.get_object_path_by_uuid_lvm_id(key, key)
 		if not p:
 			p = '/'
-		log_debug('LookUpByLvmId: key = %s, result = %s' % (key, p))
+		utils.log_debug('LookUpByLvmId: key = %s, result = %s' % (key, p))
 		return p
 
 	@dbus.service.method(


