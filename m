From: meyering@sourceware.org <meyering@sourceware.org>
Date: 21 Sep 2007 10:16:49 -0000
Subject: LVM2 ./Makefile.in ./configure.in ./make.tmpl. ...
Message-ID: <20070921101649.29059.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	meyering at sourceware.org	2007-09-21 10:16:45

Modified files:
	.              : Makefile.in configure.in make.tmpl.in 
	daemons        : Makefile.in 
	daemons/clvmd  : Makefile.in 
	dmeventd       : Makefile.in 
	dmeventd/mirror: Makefile.in 
	doc            : Makefile.in 
	include        : Makefile.in 
	lib            : Makefile.in 
	lib/format1    : Makefile.in 
	lib/format_pool: Makefile.in 
	lib/locking    : Makefile.in 
	lib/mirror     : Makefile.in 
	lib/snapshot   : Makefile.in 
	man            : Makefile.in 
	old-tests/device: Makefile.in 
	old-tests/filters: Makefile.in 
	old-tests/format1: Makefile.in 
	old-tests/mm   : Makefile.in 
	old-tests/regex: Makefile.in 
	po             : Makefile.in 
	scripts        : Makefile.in 
	tools          : Makefile.in 
	tools/fsadm    : Makefile.in 

Log message:
	Correct typo in comments: s/is part of the LVM2/is part of LVM2/.
	
	Signed-off-by: Jim Meyering <jim@meyering.net>
	
	Author: Jim Meyering <jim@meyering.net>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/Makefile.in.diff?cvsroot=lvm2&r1=1.19&r2=1.20
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.in.diff?cvsroot=lvm2&r1=1.62&r2=1.63
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/make.tmpl.in.diff?cvsroot=lvm2&r1=1.49&r2=1.50
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/Makefile.in.diff?cvsroot=lvm2&r1=1.2&r2=1.3
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/Makefile.in.diff?cvsroot=lvm2&r1=1.20&r2=1.21
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/dmeventd/Makefile.in.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/dmeventd/mirror/Makefile.in.diff?cvsroot=lvm2&r1=1.4&r2=1.5
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/doc/Makefile.in.diff?cvsroot=lvm2&r1=1.3&r2=1.4
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/include/Makefile.in.diff?cvsroot=lvm2&r1=1.7&r2=1.8
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/Makefile.in.diff?cvsroot=lvm2&r1=1.83&r2=1.84
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format1/Makefile.in.diff?cvsroot=lvm2&r1=1.8&r2=1.9
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_pool/Makefile.in.diff?cvsroot=lvm2&r1=1.4&r2=1.5
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/Makefile.in.diff?cvsroot=lvm2&r1=1.2&r2=1.3
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/mirror/Makefile.in.diff?cvsroot=lvm2&r1=1.3&r2=1.4
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/snapshot/Makefile.in.diff?cvsroot=lvm2&r1=1.3&r2=1.4
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/Makefile.in.diff?cvsroot=lvm2&r1=1.20&r2=1.21
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/old-tests/device/Makefile.in.diff?cvsroot=lvm2&r1=1.3&r2=1.4
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/old-tests/filters/Makefile.in.diff?cvsroot=lvm2&r1=1.4&r2=1.5
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/old-tests/format1/Makefile.in.diff?cvsroot=lvm2&r1=1.8&r2=1.9
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/old-tests/mm/Makefile.in.diff?cvsroot=lvm2&r1=1.5&r2=1.6
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/old-tests/regex/Makefile.in.diff?cvsroot=lvm2&r1=1.3&r2=1.4
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/po/Makefile.in.diff?cvsroot=lvm2&r1=1.4&r2=1.5
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/scripts/Makefile.in.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/Makefile.in.diff?cvsroot=lvm2&r1=1.81&r2=1.82
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/fsadm/Makefile.in.diff?cvsroot=lvm2&r1=1.2&r2=1.3

--- LVM2/Makefile.in	2007/09/18 14:00:41	1.19
+++ LVM2/Makefile.in	2007/09/21 10:16:43	1.20
@@ -2,7 +2,7 @@
 # Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
 # Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
 #
-# This file is part of the LVM2.
+# This file is part of LVM2.
 #
 # This copyrighted material is made available to anyone wishing to use,
 # modify, copy, or redistribute it subject to the terms and conditions
--- LVM2/configure.in	2007/09/18 18:26:32	1.62
+++ LVM2/configure.in	2007/09/21 10:16:43	1.63
@@ -2,7 +2,7 @@
 ## Copyright (C) 2000-2004 Sistina Software, Inc. All rights reserved.
 ## Copyright (C) 2004, 2007 Red Hat, Inc. All rights reserved.
 ##
-## This file is part of the LVM2.
+## This file is part of LVM2.
 ##
 ## This copyrighted material is made available to anyone wishing to use,
 ## modify, copy, or redistribute it subject to the terms and conditions
--- LVM2/make.tmpl.in	2007/04/27 19:26:56	1.49
+++ LVM2/make.tmpl.in	2007/09/21 10:16:43	1.50
@@ -3,7 +3,7 @@
 # Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
 # Copyright (C) 2004 Red Hat, Inc. All rights reserved.
 #
-# This file is part of the LVM2.
+# This file is part of LVM2.
 #
 # This copyrighted material is made available to anyone wishing to use,
 # modify, copy, or redistribute it subject to the terms and conditions
--- LVM2/daemons/Makefile.in	2004/11/03 10:45:07	1.2
+++ LVM2/daemons/Makefile.in	2007/09/21 10:16:43	1.3
@@ -1,7 +1,7 @@
 #
 # Copyright (C) 2004 Red Hat, Inc. All rights reserved.
 #
-# This file is part of the LVM2.
+# This file is part of LVM2.
 #
 # This copyrighted material is made available to anyone wishing to use,
 # modify, copy, or redistribute it subject to the terms and conditions
--- LVM2/daemons/clvmd/Makefile.in	2007/06/25 09:02:37	1.20
+++ LVM2/daemons/clvmd/Makefile.in	2007/09/21 10:16:43	1.21
@@ -1,7 +1,7 @@
 #
 # Copyright (C) 2004 Red Hat, Inc. All rights reserved.
 #
-# This file is part of the LVM2.
+# This file is part of LVM2.
 #
 # This copyrighted material is made available to anyone wishing to use,
 # modify, copy, or redistribute it subject to the terms and conditions
--- LVM2/dmeventd/Makefile.in	2005/12/02 19:52:06	1.1
+++ LVM2/dmeventd/Makefile.in	2007/09/21 10:16:43	1.2
@@ -2,7 +2,7 @@
 # Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
 # Copyright (C) 2004-2005 Red Hat, Inc. All rights reserved.
 #
-# This file is part of the LVM2.
+# This file is part of LVM2.
 #
 # This copyrighted material is made available to anyone wishing to use,
 # modify, copy, or redistribute it subject to the terms and conditions
--- LVM2/dmeventd/mirror/Makefile.in	2006/02/08 23:23:19	1.4
+++ LVM2/dmeventd/mirror/Makefile.in	2007/09/21 10:16:43	1.5
@@ -2,7 +2,7 @@
 # Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
 # Copyright (C) 2004-2005 Red Hat, Inc. All rights reserved.
 #
-# This file is part of the LVM2.
+# This file is part of LVM2.
 #
 # This copyrighted material is made available to anyone wishing to use,
 # modify, copy, or redistribute it subject to the terms and conditions
--- LVM2/doc/Makefile.in	2004/06/15 17:25:04	1.3
+++ LVM2/doc/Makefile.in	2007/09/21 10:16:43	1.4
@@ -1,7 +1,7 @@
 #
 # Copyright (C) 2004 Red Hat, Inc. All rights reserved.
 #
-# This file is part of the LVM2.
+# This file is part of LVM2.
 #
 # This copyrighted material is made available to anyone wishing to use,
 # modify, copy, or redistribute it subject to the terms and conditions
--- LVM2/include/Makefile.in	2006/04/19 15:33:05	1.7
+++ LVM2/include/Makefile.in	2007/09/21 10:16:43	1.8
@@ -2,7 +2,7 @@
 # Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
 # Copyright (C) 2004 Red Hat, Inc. All rights reserved.
 #
-# This file is part of the LVM2.
+# This file is part of LVM2.
 #
 # This copyrighted material is made available to anyone wishing to use,
 # modify, copy, or redistribute it subject to the terms and conditions
--- LVM2/lib/Makefile.in	2007/08/20 20:55:24	1.83
+++ LVM2/lib/Makefile.in	2007/09/21 10:16:44	1.84
@@ -2,7 +2,7 @@
 # Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
 # Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
 #
-# This file is part of the LVM2.
+# This file is part of LVM2.
 #
 # This copyrighted material is made available to anyone wishing to use,
 # modify, copy, or redistribute it subject to the terms and conditions
--- LVM2/lib/format1/Makefile.in	2004/08/18 18:57:40	1.8
+++ LVM2/lib/format1/Makefile.in	2007/09/21 10:16:44	1.9
@@ -2,7 +2,7 @@
 # Copyright (C) 2002-2004 Sistina Software, Inc. All rights reserved.
 # Copyright (C) 2004 Red Hat, Inc. All rights reserved.
 #
-# This file is part of the LVM2.
+# This file is part of LVM2.
 #
 # This copyrighted material is made available to anyone wishing to use,
 # modify, copy, or redistribute it subject to the terms and conditions
--- LVM2/lib/format_pool/Makefile.in	2004/08/18 18:57:40	1.4
+++ LVM2/lib/format_pool/Makefile.in	2007/09/21 10:16:44	1.5
@@ -2,7 +2,7 @@
 # Copyright (C) 2003-2004 Sistina Software, Inc. All rights reserved.
 # Copyright (C) 2004 Red Hat, Inc. All rights reserved.
 #
-# This file is part of the LVM2.
+# This file is part of LVM2.
 #
 # This copyrighted material is made available to anyone wishing to use,
 # modify, copy, or redistribute it subject to the terms and conditions
--- LVM2/lib/locking/Makefile.in	2004/08/18 18:57:40	1.2
+++ LVM2/lib/locking/Makefile.in	2007/09/21 10:16:44	1.3
@@ -2,7 +2,7 @@
 # Copyright (C) 2003-2004 Sistina Software, Inc. All rights reserved.
 # Copyright (C) 2004 Red Hat, Inc. All rights reserved.
 #
-# This file is part of the LVM2.
+# This file is part of LVM2.
 #
 # This copyrighted material is made available to anyone wishing to use,
 # modify, copy, or redistribute it subject to the terms and conditions
--- LVM2/lib/mirror/Makefile.in	2004/08/18 18:57:40	1.3
+++ LVM2/lib/mirror/Makefile.in	2007/09/21 10:16:44	1.4
@@ -2,7 +2,7 @@
 # Copyright (C) 2003-2004 Sistina Software, Inc. All rights reserved.
 # Copyright (C) 2004 Red Hat, Inc. All rights reserved.
 #
-# This file is part of the LVM2.
+# This file is part of LVM2.
 #
 # This copyrighted material is made available to anyone wishing to use,
 # modify, copy, or redistribute it subject to the terms and conditions
--- LVM2/lib/snapshot/Makefile.in	2004/08/18 18:57:40	1.3
+++ LVM2/lib/snapshot/Makefile.in	2007/09/21 10:16:44	1.4
@@ -2,7 +2,7 @@
 # Copyright (C) 2002-2004 Sistina Software, Inc. All rights reserved.
 # Copyright (C) 2004 Red Hat, Inc. All rights reserved.
 #
-# This file is part of the LVM2.
+# This file is part of LVM2.
 #
 # This copyrighted material is made available to anyone wishing to use,
 # modify, copy, or redistribute it subject to the terms and conditions
--- LVM2/man/Makefile.in	2007/08/20 20:55:29	1.20
+++ LVM2/man/Makefile.in	2007/09/21 10:16:44	1.21
@@ -2,7 +2,7 @@
 # Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
 # Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
 #
-# This file is part of the LVM2.
+# This file is part of LVM2.
 #
 # This copyrighted material is made available to anyone wishing to use,
 # modify, copy, or redistribute it subject to the terms and conditions
--- LVM2/old-tests/device/Makefile.in	2004/06/15 17:25:06	1.3
+++ LVM2/old-tests/device/Makefile.in	2007/09/21 10:16:44	1.4
@@ -2,7 +2,7 @@
 # Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
 # Copyright (C) 2004 Red Hat, Inc. All rights reserved.
 #
-# This file is part of the LVM2.
+# This file is part of LVM2.
 #
 # This copyrighted material is made available to anyone wishing to use,
 # modify, copy, or redistribute it subject to the terms and conditions
--- LVM2/old-tests/filters/Makefile.in	2004/06/15 17:25:07	1.4
+++ LVM2/old-tests/filters/Makefile.in	2007/09/21 10:16:45	1.5
@@ -2,7 +2,7 @@
 # Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
 # Copyright (C) 2004 Red Hat, Inc. All rights reserved.
 #
-# This file is part of the LVM2.
+# This file is part of LVM2.
 #
 # This copyrighted material is made available to anyone wishing to use,
 # modify, copy, or redistribute it subject to the terms and conditions
--- LVM2/old-tests/format1/Makefile.in	2004/06/15 17:25:07	1.8
+++ LVM2/old-tests/format1/Makefile.in	2007/09/21 10:16:45	1.9
@@ -2,7 +2,7 @@
 # Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
 # Copyright (C) 2004 Red Hat, Inc. All rights reserved.
 #
-# This file is part of the LVM2.
+# This file is part of LVM2.
 #
 # This copyrighted material is made available to anyone wishing to use,
 # modify, copy, or redistribute it subject to the terms and conditions
--- LVM2/old-tests/mm/Makefile.in	2004/06/15 17:25:07	1.5
+++ LVM2/old-tests/mm/Makefile.in	2007/09/21 10:16:45	1.6
@@ -2,7 +2,7 @@
 # Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
 # Copyright (C) 2004 Red Hat, Inc. All rights reserved.
 #
-# This file is part of the LVM2.
+# This file is part of LVM2.
 #
 # This copyrighted material is made available to anyone wishing to use,
 # modify, copy, or redistribute it subject to the terms and conditions
--- LVM2/old-tests/regex/Makefile.in	2004/06/15 17:25:07	1.3
+++ LVM2/old-tests/regex/Makefile.in	2007/09/21 10:16:45	1.4
@@ -2,7 +2,7 @@
 # Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
 # Copyright (C) 2004 Red Hat, Inc. All rights reserved.
 #
-# This file is part of the LVM2.
+# This file is part of LVM2.
 #
 # This copyrighted material is made available to anyone wishing to use,
 # modify, copy, or redistribute it subject to the terms and conditions
--- LVM2/po/Makefile.in	2004/06/15 17:25:06	1.4
+++ LVM2/po/Makefile.in	2007/09/21 10:16:45	1.5
@@ -1,7 +1,7 @@
 #
 # Copyright (C) 2004 Red Hat, Inc. All rights reserved.
 #
-# This file is part of the LVM2.
+# This file is part of LVM2.
 #
 # This copyrighted material is made available to anyone wishing to use,
 # modify, copy, or redistribute it subject to the terms and conditions
--- LVM2/scripts/Makefile.in	2006/11/20 20:03:26	1.1
+++ LVM2/scripts/Makefile.in	2007/09/21 10:16:45	1.2
@@ -1,7 +1,7 @@
 #
 # Copyright (C) 2006 Red Hat, Inc. All rights reserved.
 #
-# This file is part of the LVM2.
+# This file is part of LVM2.
 #
 # This copyrighted material is made available to anyone wishing to use,
 # modify, copy, or redistribute it subject to the terms and conditions
--- LVM2/tools/Makefile.in	2007/09/12 16:54:23	1.81
+++ LVM2/tools/Makefile.in	2007/09/21 10:16:45	1.82
@@ -2,7 +2,7 @@
 # Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
 # Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
 #
-# This file is part of the LVM2.
+# This file is part of LVM2.
 #
 # This copyrighted material is made available to anyone wishing to use,
 # modify, copy, or redistribute it subject to the terms and conditions
--- LVM2/tools/fsadm/Makefile.in	2007/01/11 17:12:27	1.2
+++ LVM2/tools/fsadm/Makefile.in	2007/09/21 10:16:45	1.3
@@ -2,7 +2,7 @@
 # Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
 # Copyright (C) 2004 Red Hat, Inc. All rights reserved.
 #
-# This file is part of the LVM2.
+# This file is part of LVM2.
 #
 # This copyrighted material is made available to anyone wishing to use,
 # modify, copy, or redistribute it subject to the terms and conditions


