From: Tony Asleson <tasleson@sourceware.org>
Date: Mon, 19 Sep 2022 15:58:21 +0000 (GMT)
Subject: main - lvmdbusd: Re-work error handling for run_cmd
Message-ID: <20220919155821.B33A4385843D@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=25abe41b00e1c9b525a1ff5e043b4b8507ba03cf
Commit:        25abe41b00e1c9b525a1ff5e043b4b8507ba03cf
Parent:        e6e874922e05e2b163b7f03b61cd4fb51e0858f6
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Fri Aug 26 13:01:05 2022 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Fri Sep 16 10:49:37 2022 -0500

lvmdbusd: Re-work error handling for run_cmd

Instead of lumping all the exceptions, break them out to handle the dbus
exceptions separately, to reduce the amount of debug information that ends
up in the journal that has questionable value.
---
 daemons/lvmdbusd/request.py | 13 ++++++++++---
 1 file changed, 10 insertions(+), 3 deletions(-)

diff --git a/daemons/lvmdbusd/request.py b/daemons/lvmdbusd/request.py
index d6024d99e..57d72d8af 100644
--- a/daemons/lvmdbusd/request.py
+++ b/daemons/lvmdbusd/request.py
@@ -7,6 +7,7 @@
 # You should have received a copy of the GNU General Public License
 # along with this program. If not, see <http://www.gnu.org/licenses/>.
 
+import dbus
 import threading
 # noinspection PyUnresolvedReferences
 from gi.repository import GLib
@@ -74,14 +75,20 @@ class RequestEntry(object):
 		except SystemExit as se:
 			self.register_error(-1, str(se), se)
 			raise se
+		except dbus.exceptions.DBusException as dbe:
+			# This is an expected error path when something goes awry that
+			# we handled
+			self.register_error(-1, str(dbe), dbe)
 		except Exception as e:
 			# Use the request entry to return the result as the client may
 			# have gotten a job by the time we hit an error
-			# Lets get the stacktrace and set that to the error message
-			st = traceback.format_exc()
+			# Lets set the exception text as the error message and log the
+			# exception in the journal for figuring out what went wrong.
 			cfg.debug.dump()
 			cfg.flightrecorder.dump()
-			log_error("Exception returned to client: \n%s" % st)
+			tb = ''.join(traceback.format_tb(e.__traceback__))
+			log_error("While processing %s: we encountered\n%s" % (str(self.method), tb))
+			log_error("Error returned to client: %s" % str(e))
 			self.register_error(-1, str(e), e)
 
 	def is_done(self):

