From: Marian Csontos <mcsontos@sourceware.org>
Date: Fri, 26 May 2017 01:42:14 -0400
Subject: master - spec: Enable notify-dbus in builds with dbus
Message-ID: <201705260542.v4Q5gEd4023974@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=3745b52ed4ff28e553e1372e425491d11cc78031
Commit:        3745b52ed4ff28e553e1372e425491d11cc78031
Parent:        65b10281f8b10c51730ab74e2d384d5d03d32f96
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Fri May 26 07:40:09 2017 +0200
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Fri May 26 07:40:09 2017 +0200

spec: Enable notify-dbus in builds with dbus

---
 spec/build.inc |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/spec/build.inc b/spec/build.inc
index 5321a70..5fb38f7 100644
--- a/spec/build.inc
+++ b/spec/build.inc
@@ -34,6 +34,7 @@
 %enableif %{enable_python3} python3-bindings
 %enableif %{enable_python} applib
 %enableif %{enable_dbusd} dbus-service
+%enableif %{enable_dbusd} notify-dbus
 %enableif %{enable_dmfilemapd} dmfilemapd
 
 %build


