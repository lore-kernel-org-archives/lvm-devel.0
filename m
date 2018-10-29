From: Marian Csontos <mcsontos@sourceware.org>
Date: Mon, 29 Oct 2018 11:50:40 -0400
Subject: 2018-06-01-stable - spec: Fix python and applib interactions
Message-ID: <201810291550.w9TFoeZV032262@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=bd872064a25a95dd8f51927efeb83762d442f975
Commit:        bd872064a25a95dd8f51927efeb83762d442f975
Parent:        d1b652143abc9c0c02eea62dd424d0285ab8fb52
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Mon Oct 29 16:48:42 2018 +0100
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Mon Oct 29 16:48:42 2018 +0100

spec: Fix python and applib interactions

When python3 is not present, macro expends to --disable-applib.
---
 spec/build.inc |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/spec/build.inc b/spec/build.inc
index f317892..d91c981 100644
--- a/spec/build.inc
+++ b/spec/build.inc
@@ -32,8 +32,10 @@
 %endif
 %enableif %{enable_python} python2-bindings
 %enableif %{enable_python3} python3-bindings
-%enableif %{enable_python} applib
-%enableif %{enable_python3} applib
+# Must use this, or applib will be enabled and disabled depending in python[23] availability
+%if %{enable_python3} || %{enable_python}
+%enableif 1 applib
+%endif
 %enableif %{enable_dbusd} dbus-service
 %enableif %{enable_dbusd} notify-dbus
 %enableif %{enable_dmfilemapd} dmfilemapd


