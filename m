From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 17 Oct 2013 09:58:23 +0000 (UTC)
Subject: master - tests: use bash for bash script
Message-ID: <20131017095823.7E9D261313@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f9725503f86593512e9472152ce2642f4b2f414f
Commit:        f9725503f86593512e9472152ce2642f4b2f414f
Parent:        ed30145f4ad030b751b529590ab0f6f41afa17bc
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Oct 17 11:11:24 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Oct 17 11:57:34 2013 +0200

tests: use bash for bash script

This script needs bash
---
 test/lib/get.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/lib/get.sh b/test/lib/get.sh
index 7b97c06..5dd5451 100644
--- a/test/lib/get.sh
+++ b/test/lib/get.sh
@@ -1,4 +1,4 @@
-#!/bin/sh
+#!/usr/bin/env bash
 # Copyright (C) 2011-2013 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,


