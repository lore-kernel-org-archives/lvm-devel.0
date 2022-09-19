From: Tony Asleson <tasleson@sourceware.org>
Date: Mon, 19 Sep 2022 15:58:38 +0000 (GMT)
Subject: main - lvmdbusd: Correct undefined var
Message-ID: <20220919155838.C575E3858295@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=ed9072dad8316e65c22ad4530984174fd488b56c
Commit:        ed9072dad8316e65c22ad4530984174fd488b56c
Parent:        a326e35cda10b922dfa29d27e9c03e3b56282ba5
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Thu Sep 8 15:37:34 2022 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Fri Sep 16 10:49:37 2022 -0500

lvmdbusd: Correct undefined var

---
 daemons/lvmdbusd/fetch.py | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/daemons/lvmdbusd/fetch.py b/daemons/lvmdbusd/fetch.py
index 199b86073..9da62590a 100644
--- a/daemons/lvmdbusd/fetch.py
+++ b/daemons/lvmdbusd/fetch.py
@@ -6,6 +6,7 @@
 #
 # You should have received a copy of the GNU General Public License
 # along with this program. If not, see <http://www.gnu.org/licenses/>.
+import errno
 
 from .pv import load_pvs
 from .vg import load_vgs
@@ -167,7 +168,7 @@ class StateUpdate(object):
 				log_error("Too many errors in update_thread, exiting daemon")
 				cfg.debug.dump()
 				cfg.flightrecorder.dump()
-				bailing(e)
+				bailing(errno.EFAULT)
 				cfg.exit_daemon()
 			else:
 				# Slow things down when encountering errors

