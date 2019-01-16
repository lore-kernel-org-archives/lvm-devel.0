From: Tony Asleson <tasleson@sourceware.org>
Date: Wed, 16 Jan 2019 17:32:56 -0500
Subject: master - lvmdbusd: Spelling correction
Message-ID: <201901162232.x0GMWuiF027533@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=1ed4b3f23baf13e224d0c24735304f872c0930e8
Commit:        1ed4b3f23baf13e224d0c24735304f872c0930e8
Parent:        4c1fd827748a0b5a1a2c3e54c5fdc0478b45515f
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Mon Jan 14 09:11:06 2019 -0600
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Wed Jan 16 16:29:05 2019 -0600

lvmdbusd: Spelling correction

---
 daemons/lvmdbusd/vg.py |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/daemons/lvmdbusd/vg.py b/daemons/lvmdbusd/vg.py
index c00084d..b9a23c2 100644
--- a/daemons/lvmdbusd/vg.py
+++ b/daemons/lvmdbusd/vg.py
@@ -216,7 +216,7 @@ class Vg(AutomatedProperties):
 	# TODO: This should be broken into a number of different methods
 	# instead of having one method that takes a hash for parameters.  Some of
 	# the changes that vgchange does works on entire system, not just a
-	# specfic vg, thus that should be in the Manager interface.
+	# specific vg, thus that should be in the Manager interface.
 	@dbus.service.method(
 		dbus_interface=VG_INTERFACE,
 		in_signature='ia{sv}',


