From: Tony Asleson <tasleson@sourceware.org>
Date: Fri, 30 Sep 2022 16:52:56 +0000 (GMT)
Subject: main - lvmdbusd: Correct env. variable
Message-ID: <20220930165256.3550E385802D@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=599cbd7dd37ba50b44579f64207cc1e47e004899
Commit:        599cbd7dd37ba50b44579f64207cc1e47e004899
Parent:        b09de683c72b62167fbbd64491708ede652c32a1
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Fri Sep 30 11:49:49 2022 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Fri Sep 30 11:51:23 2022 -0500

lvmdbusd: Correct env. variable

Make this match the unit test expectation and the form we use for
other env. variables.
---
 daemons/lvmdbusd/main.py   | 2 +-
 test/dbus/validatestate.py | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/daemons/lvmdbusd/main.py b/daemons/lvmdbusd/main.py
index e4531526c..662d7569f 100644
--- a/daemons/lvmdbusd/main.py
+++ b/daemons/lvmdbusd/main.py
@@ -146,7 +146,7 @@ def running_under_systemd():
 
 def main():
 	start = time.time()
-	use_session = os.getenv('LVMDBUSD_USE_SESSION', False)
+	use_session = os.getenv('LVM_DBUSD_USE_SESSION', False)
 
 	# Ensure that we get consistent output for parsing stdout/stderr and that we
 	# are using the lvmdbusd profile.
diff --git a/test/dbus/validatestate.py b/test/dbus/validatestate.py
index ae999ad17..1af303f15 100755
--- a/test/dbus/validatestate.py
+++ b/test/dbus/validatestate.py
@@ -21,7 +21,7 @@ import os
 
 if __name__ == "__main__":
 
-	use_session = os.getenv('LVMDBUSD_USE_SESSION', False)
+	use_session = os.getenv('LVMD_BUSD_USE_SESSION', False)
 
 	if use_session:
 		bus = dbus.SessionBus(mainloop=DBusGMainLoop())

