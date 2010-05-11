From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 11 May 2010 08:54:12 -0000
Subject: LVM2 ./WHATS_NEW libdm/libdevmapper.pc.in libl ...
Message-ID: <20100511085412.12206.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-05-11 08:54:11

Modified files:
	.              : WHATS_NEW 
	libdm          : libdevmapper.pc.in 
	liblvm         : liblvm2app.pc.in 

Log message:
	Switch to use Requires.private for devmapper.pc and lvm2app.pc
	
	Use Requires.private: instead of Libs.private:
	Use UDEV_PC and SELINUX_PC for Require.private:
	
	It looks like usage of Requires.private is prefered from Libs.private.
	However pkg-config documentation is really poor here. But here is
	short outcome:
	
	There is a difference in Libs.private: and Requires.private: where
	we specify libselinux instead of  -lselinux -lsepol.
	
	We leave resolving of query like 'pkg-config --libs --static devmapper'
	on taking proper selinux and udev libs to their .pc files instead of
	hardcoding them into our .pc file which is might give incorrect answer.
	- i.e. dependency of libselinux package might change and we may return
	wrong list of linked libraries.
	
	http://bugs.freedesktop.org/show_bug.cgi?id=4738
	http://err.no/personal/blog/tech/2008-03-25-18-07_pkg-config,_sonames_and_Requires.private

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1553&r2=1.1554
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdevmapper.pc.in.diff?cvsroot=lvm2&r1=1.4&r2=1.5
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/liblvm2app.pc.in.diff?cvsroot=lvm2&r1=1.1&r2=1.2

--- LVM2/WHATS_NEW	2010/05/11 08:47:02	1.1553
+++ LVM2/WHATS_NEW	2010/05/11 08:54:11	1.1554
@@ -1,5 +1,6 @@
 Version 2.02.65 - 
 =================================
+  Switch usage of Libs.private: to Requires.private: in devmapper.pc, lvm2app.pc.
   Use field Requires.private: for devmapper-event.pc.
   Add devmapper library to linked libdevmapper-event.so.
   Link liblvm2cmd.so with devmapper-event and devmapper libs.
--- LVM2/libdm/libdevmapper.pc.in	2010/04/26 09:05:51	1.4
+++ LVM2/libdm/libdevmapper.pc.in	2010/05/11 08:54:11	1.5
@@ -8,4 +8,4 @@
 Version: @DM_LIB_PATCHLEVEL@
 Cflags: -I${includedir} 
 Libs: -L${libdir} -ldevmapper
-Libs.private: @SELINUX_LIBS@ @UDEV_LIBS@
+Requires.private: @SELINUX_PC@ @UDEV_PC@
--- LVM2/liblvm/liblvm2app.pc.in	2009/07/23 01:41:53	1.1
+++ LVM2/liblvm/liblvm2app.pc.in	2010/05/11 08:54:11	1.2
@@ -8,4 +8,4 @@
 Version: @LVM_MAJOR at .@LVM_LIBAPI@
 Cflags: -I${includedir} 
 Libs: -L${libdir} -llvm2app
-Libs.private: -ldevmapper
+Requires.private: devmapper


