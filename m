From: Petr Rockai <mornfall@fedoraproject.org>
Date: Mon, 10 Jun 2013 13:26:56 +0000 (UTC)
Subject: master - test: Avoid hardcoding path to bash (not all systems have /bin/bash).
Message-ID: <20130610132656.13F0260D11@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c3b06ff55de5288a2ac4e351176c00404bc5a0fc
Commit:        c3b06ff55de5288a2ac4e351176c00404bc5a0fc
Parent:        a9fc137fd1de88d8713be53989e4a41ff9c9bac8
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Mon Jun 10 11:28:47 2013 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Mon Jun 10 15:24:55 2013 +0200

test: Avoid hardcoding path to bash (not all systems have /bin/bash).

---
 test/lib/aux.sh   |    2 +-
 test/lib/check.sh |    2 +-
 test/lib/test.sh  |    2 +-
 test/lib/utils.sh |    2 +-
 4 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index b92f428..dc8a823 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -1,4 +1,4 @@
-#!/bin/bash
+#!/usr/bin/env bash
 # Copyright (C) 2011-2012 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/lib/check.sh b/test/lib/check.sh
index 157434b..6cb33ac 100644
--- a/test/lib/check.sh
+++ b/test/lib/check.sh
@@ -1,4 +1,4 @@
-#!/bin/bash
+#!/usr/bin/env bash
 # Copyright (C) 2010-2012 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/lib/test.sh b/test/lib/test.sh
index 9a56a0f..7e0df73 100644
--- a/test/lib/test.sh
+++ b/test/lib/test.sh
@@ -1,4 +1,4 @@
-#!/bin/bash
+#!/usr/bin/env bash
 # Copyright (C) 2011-2012 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
diff --git a/test/lib/utils.sh b/test/lib/utils.sh
index ab5abc1..47e89bf 100644
--- a/test/lib/utils.sh
+++ b/test/lib/utils.sh
@@ -1,4 +1,4 @@
-#!/bin/bash
+#!/usr/bin/env bash
 # Copyright (C) 2011-2012 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,


