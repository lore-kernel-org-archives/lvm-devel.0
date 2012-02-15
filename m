From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 15 Feb 2012 11:17:59 -0000
Subject: LVM2 ./WHATS_NEW_DM ./configure.in libdm/libde ...
Message-ID: <20120215111759.7239.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2012-02-15 11:17:58

Modified files:
	.              : WHATS_NEW_DM configure.in 
	libdm          : libdevmapper.h 

Log message:
	Add configure --with-default-name-mangling.
	
	This option configures the default name mangling mode used, one of:
	AUTO, NONE and HEX.
	
	The name mangling is primarily used to support udev character whitelist
	(0-9, A-Z, a-z, #*-.:=@_) so any character that is not on udev whitelist
	will get translated into an encoded form \xNN where NN is the hex value
	of the character.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.557&r2=1.558
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.in.diff?cvsroot=lvm2&r1=1.182&r2=1.183
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdevmapper.h.diff?cvsroot=lvm2&r1=1.178&r2=1.179

--- LVM2/WHATS_NEW_DM	2012/02/13 14:17:04	1.557
+++ LVM2/WHATS_NEW_DM	2012/02/15 11:17:57	1.558
@@ -1,5 +1,6 @@
 Version 1.02.71 - 
 ====================================
+  Add configure --with-default-name-mangling.
   Test for parsed words in _umount() dmeventd snapshot plugin.
   Fix memory leak in fail path of parse_loop_device_name() in dmsetup.
   Check for missing reply_uuid in dm_event_get_registered_device().
--- LVM2/configure.in	2012/02/13 13:02:48	1.182
+++ LVM2/configure.in	2012/02/15 11:17:57	1.183
@@ -229,6 +229,20 @@
 AC_MSG_RESULT(on $ADD_NODE)
 AC_DEFINE_UNQUOTED([DEFAULT_DM_ADD_NODE], $add_on, [Define default node creation behavior with dmsetup create])
 
+AC_MSG_CHECKING(default name mangling)
+AC_ARG_WITH(default-name-mangling,
+	    AC_HELP_STRING([--with-default-name-mangling=MANGLING],
+			   [default name mangling: auto/none/hex [[MANGLING=auto]]]),
+	    MANGLING=$withval, MANGLING=auto)
+case "$MANGLING" in
+ auto) mangling=DM_STRING_MANGLING_AUTO;;
+ disabled) mangling=DM_STRING_MANGLING_NONE;;
+ hex) mangling=DM_STRING_MANGLING_HEX;;
+ *) AC_MSG_ERROR([--with-default-name-mangling parameter invalid]);;
+esac
+AC_MSG_RESULT($MANGLING)
+AC_DEFINE_UNQUOTED([DEFAULT_DM_NAME_MANGLING], $mangling, [Define default name mangling behaviour])
+
 ################################################################################
 dnl -- LVM1 tool fallback option
 AC_MSG_CHECKING(whether to enable lvm1 fallback)
--- LVM2/libdm/libdevmapper.h	2012/02/13 20:13:40	1.178
+++ LVM2/libdm/libdevmapper.h	2012/02/15 11:17:58	1.179
@@ -274,6 +274,19 @@
 void dm_task_update_nodes(void);
 
 /*
+ * Mangling support
+ *
+ * Character whitelist: 0-9, A-Z, a-z, #+-.:=@_
+ * HEX mangling format: \xNN, NN being the hex value of the character.
+ * (whitelist and format supported by udev)
+*/
+typedef enum {
+	DM_STRING_MANGLING_NONE, /* do not mangle at all */
+	DM_STRING_MANGLING_AUTO, /* mangle only if not already mangled with hex, error when mixed */
+	DM_STRING_MANGLING_HEX	 /* always mangle with hex encoding, no matter what the input is */
+} dm_string_mangling_t;
+
+/*
  * Configure the device-mapper directory
  */
 int dm_set_dev_dir(const char *dir);


