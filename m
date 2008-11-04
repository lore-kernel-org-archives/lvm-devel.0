From: agk@sourceware.org <agk@sourceware.org>
Date: 4 Nov 2008 17:49:22 -0000
Subject: LVM2 INSTALL README CONTRIBUTORS
Message-ID: <20081104174922.20892.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-11-04 17:49:22

Modified files:
	.              : INSTALL README 
Removed files:
	.              : CONTRIBUTORS 

Log message:
	quick review of docs
	Note that we'll continue to use WHATS_NEW_DM for device-mapper changes
	until we can switch to unified version numbering.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/INSTALL.diff?cvsroot=lvm2&r1=1.3&r2=1.4
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/README.diff?cvsroot=lvm2&r1=1.7&r2=1.8
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/CONTRIBUTORS.diff?cvsroot=lvm2&r1=1.1&r2=NONE

--- LVM2/INSTALL	2002/11/18 13:52:12	1.3
+++ LVM2/INSTALL	2008/11/04 17:49:22	1.4
@@ -1,44 +1,30 @@
-LVM2 installation
-=================
+Installation
+============
 
-1) Install device-mapper
-
-   Ensure the device-mapper has been installed on the machine.
-
-   The device-mapper should be in the kernel (look for 'device-mapper'
-   messages in the kernel logs) and /usr/include/libdevmapper.h 
-   and libdevmapper.so should be present.
-
-   The device-mapper is available from:
-     ftp://ftp.sistina.com/pub/LVM2/device-mapper/
-
-
-2) Generate custom makefiles.
+1) Generate custom makefiles.
 
    Run the 'configure' script from the top directory.
 
-   If you wish to use the built-in LVM2 shell and have GNU readline 
-   installed (http://www.gnu.org/directory/readline.html) use:
-     ./configure --enable-readline
-
    If you don't want to include the LVM1 backwards-compatibility code use:
      ./configure --with-lvm1=none 
 
    To separate the LVM1 support into a shared library loaded by lvm.conf use:
      ./configure --with-lvm1=shared
 
+   Use ./configure --help to see other options.
 
-3) Build and install LVM2.
+2) Build and install.
 
-   Run 'make install' from the top directory.
+   Run 'make' from the top directory to build everything you configured.
+   Run 'make install' to build and install everything you configured.
 
+   If you only want the device-mapper libraries and tools use
+   'make device-mapper' or 'make install_device-mapper'.
 
-4) Create a configuration file
+3) If using LVM2, create a configuration file.
 
    The tools will work fine without a configuration file being
    present, but you ought to review the example file in doc/example.conf.
-   For example, specifying the devices that LVM2 is to use can
-   make the tools run more efficiently - and avoid scanning /dev/cdrom!
 
 Please also refer to the WHATS_NEW file and the manual pages for the 
 individual commands.
--- LVM2/README	2004/07/03 18:20:25	1.7
+++ LVM2/README	2008/11/04 17:49:22	1.8
@@ -1,23 +1,27 @@
-This directory contains LVM2, the new version of the userland LVM
-tools designed for the new device-mapper for the Linux kernel.
+This tree contains the LVM2 and device-mapper tools and libraries.
 
-The device-mapper needs to be installed before compiling these LVM2 tools.
-
-For more information about LVM2 read the WHATS_NEW file.
+For more information about LVM2 read the changelog in the WHATS_NEW file.
 Installation instructions are in INSTALL.
 
 There is no warranty - see COPYING and COPYING.LIB.
 
 Tarballs are available from:
   ftp://sources.redhat.com/pub/lvm2/
-  ftp://sources.redhat.com/pub/dm/
 
 To access the CVS tree use:
   cvs -d :pserver:cvs at sources.redhat.com:/cvs/lvm2 login
   CVS password: cvs
   cvs -d :pserver:cvs at sources.redhat.com:/cvs/lvm2 co LVM2
 
-Mailing list for discussion/bug reports etc.
+Mailing list for general discussion related to LVM2:
   linux-lvm at redhat.com
   Subscribe from https://www.redhat.com/mailman/listinfo/linux-lvm
 
+Mailing list for LVM2 development, patches and commits:
+  lvm-devel at redhat.com
+  Subscribe from https://www.redhat.com/mailman/listinfo/linux-lvm
+
+Mailing list for device-mapper development, including kernel patches
+and multipath-tools:
+  dm-devel at redhat.com
+  Subscribe from https://www.redhat.com/mailman/listinfo/dm-devel


