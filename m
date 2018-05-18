From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 18 May 2018 10:27:58 -0400
Subject: master - python: use python3 paths directly
Message-ID: <201805181427.w4IERwgw012360@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=43fb32e761a2c4d1ebaec5eff9d9f0f372563cf9
Commit:        43fb32e761a2c4d1ebaec5eff9d9f0f372563cf9
Parent:        5b86b0e3dca804fce7c3e6adcd636c0a6d341a9b
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu May 17 23:03:36 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri May 18 16:25:44 2018 +0200

python: use python3 paths directly

Do not use /usr/bin/env for path of python3 as this is seen
as 'unwanted' and should be avoided.
---
 test/dbus/lvmdbustest.py   |    2 +-
 test/dbus/testlib.py       |    2 +-
 test/dbus/validatestate.py |    2 +-
 3 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/test/dbus/lvmdbustest.py b/test/dbus/lvmdbustest.py
index 0914b7a..bab9986 100755
--- a/test/dbus/lvmdbustest.py
+++ b/test/dbus/lvmdbustest.py
@@ -1,4 +1,4 @@
-#!/usr/bin/env python3
+#!/usr/bin/python3
 
 # Copyright (C) 2015-2016 Red Hat, Inc. All rights reserved.
 #
diff --git a/test/dbus/testlib.py b/test/dbus/testlib.py
index 34ff33a..08f612c 100644
--- a/test/dbus/testlib.py
+++ b/test/dbus/testlib.py
@@ -1,4 +1,4 @@
-#!/usr/bin/env python3
+#!/usr/bin/python3
 
 # Copyright (C) 2015-2016 Red Hat, Inc. All rights reserved.
 #
diff --git a/test/dbus/validatestate.py b/test/dbus/validatestate.py
index faa2083..ae999ad 100755
--- a/test/dbus/validatestate.py
+++ b/test/dbus/validatestate.py
@@ -1,4 +1,4 @@
-#!/usr/bin/env python3
+#!/usr/bin/python3
 
 # Copyright (C) 2015-2016 Red Hat, Inc. All rights reserved.
 #


