From: Bastian Blank <bastian@waldi.eu.org>
Date: Fri, 6 Nov 2009 18:12:53 +0100
Subject: [PATCH] Use bash
Message-ID: <20091106171253.GA15526@wavehammer.waldi.eu.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Use bash for vgimportclone.sh, it uses bash extensions.

--- a/scripts/vgimportclone.sh
+++ b/scripts/vgimportclone.sh
@@ -1,4 +1,4 @@
-#!/bin/sh
+#!/bin/bash
 
 # Copyright (C) 2009 Chris Procter All rights reserved.
 # Copyright (C) 2009 Red Hat, Inc. All rights reserved.
-- 
Kirk to Enterprise -- beam down yeoman Rand and a six-pack.


