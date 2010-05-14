From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Fri, 14 May 2010 10:28:25 +0200
Subject: [PATCH 1/1] Use /bin/bash instead of /bin/sh
In-Reply-To: <cover.1273825538.git.zkabelac@redhat.com>
References: <cover.1273825538.git.zkabelac@redhat.com>
Message-ID: <68fd26e48c7d6d792d4d1af9551a0ba070e022d4.1273825538.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Use /bin/bash for scripts using bashisms.
For all of them 'checkbashisms' command reports miscelanous things
available only in nonstandard shell extensions like bash.

For more details check i.e.: https://wiki.ubuntu.com/DashAsBinSh

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 scripts/clvmd_fix_conf.sh       |    2 +-
 scripts/fsadm.sh                |    2 +-
 scripts/last_cvs_update.sh      |    2 +-
 scripts/lvmconf.sh              |    2 +-
 scripts/lvmconf_lockingtype2.sh |    2 +-
 scripts/vgimportclone.sh        |    2 +-
 6 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/scripts/clvmd_fix_conf.sh b/scripts/clvmd_fix_conf.sh
index a00263c..cc2c50d 100644
--- a/scripts/clvmd_fix_conf.sh
+++ b/scripts/clvmd_fix_conf.sh
@@ -1,4 +1,4 @@
-#!/bin/sh
+#!/bin/bash
 #
 # Edit an lvm.conf file to enable cluster locking.
 #
diff --git a/scripts/fsadm.sh b/scripts/fsadm.sh
index 13b48a0..90a93ee 100644
--- a/scripts/fsadm.sh
+++ b/scripts/fsadm.sh
@@ -1,4 +1,4 @@
-#!/bin/sh
+#!/bin/bash
 #
 # Copyright (C) 2007-2009 Red Hat, Inc. All rights reserved.
 #
diff --git a/scripts/last_cvs_update.sh b/scripts/last_cvs_update.sh
index e38d0ec..7b5afea 100755
--- a/scripts/last_cvs_update.sh
+++ b/scripts/last_cvs_update.sh
@@ -1,4 +1,4 @@
-#!/bin/sh
+#!/bin/bash
 #$Header$
 ################################################################################
 ##
diff --git a/scripts/lvmconf.sh b/scripts/lvmconf.sh
index bf1494b..3caaf91 100644
--- a/scripts/lvmconf.sh
+++ b/scripts/lvmconf.sh
@@ -1,4 +1,4 @@
-#!/bin/sh
+#!/bin/bash
 #
 # Copyright (C) 2004-2009 Red Hat, Inc. All rights reserved.
 #
diff --git a/scripts/lvmconf_lockingtype2.sh b/scripts/lvmconf_lockingtype2.sh
index f5c4313..b823a43 100644
--- a/scripts/lvmconf_lockingtype2.sh
+++ b/scripts/lvmconf_lockingtype2.sh
@@ -1,4 +1,4 @@
-#!/bin/sh
+#!/bin/bash
 #
 # Copyright (C) 2004-2006 Red Hat, Inc. All rights reserved.
 #
diff --git a/scripts/vgimportclone.sh b/scripts/vgimportclone.sh
index ecf0546..731b860 100755
--- a/scripts/vgimportclone.sh
+++ b/scripts/vgimportclone.sh
@@ -1,4 +1,4 @@
-#!/bin/sh
+#!/bin/bash
 
 # Copyright (C) 2009 Chris Procter All rights reserved.
 # Copyright (C) 2009 Red Hat, Inc. All rights reserved.
-- 
1.7.0.1


