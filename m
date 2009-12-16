From: chris procter <chris-procter@talk21.com>
Date: Wed, 16 Dec 2009 17:52:34 +0000 (GMT)
Subject: [PATCH] match only full vg names not substrings when importing clones
Message-ID: <400787.58804.qm@web87102.mail.ird.yahoo.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


Currently if you have a vg CDSUATL and use vgimportclone.sh to rename a clone to CDSUAT it will decide CDSUAT==CDSUATL and append a number to ensure uniqueness. This is annoying. Heres a patch fix it. I've also changed the interpreter line to /bin/bash because =~ is a bash extension not supported by anything else that might be symlinked from /bin/sh.



diff -r 09e6fb927a7f -r 2114b6a959b8 scripts/vgimportclone.sh
--- a/scripts/vgimportclone.sh    Tue Dec 15 20:07:26 2009 +0000
+++ b/scripts/vgimportclone.sh    Tue Dec 15 20:35:19 2009 +0000
@@ -1,4 +1,4 @@
-#!/bin/sh
+#!/bin/bash
 
 # Copyright (C) 2009 Chris Procter All rights reserved.
 # Copyright (C) 2009 Red Hat, Inc. All rights reserved.
@@ -52,7 +52,7 @@
     NAME="${BNAME}"
     I=0
 
-    while [[ "${VGLIST}" =~ "${NAME}" ]]
+    while [[ "${VGLIST}" =~ "[[:space:]]${NAME}[[:space:]]" ]]
     do
         I=$(($I+1))
         NAME="${BNAME}$I"


      


