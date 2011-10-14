From: Peter Rajnoha <prajnoha@redhat.com>
Date: Fri, 14 Oct 2011 16:59:07 +0200
Subject: [PATCH 2/6][devname mangling] Define string mangle type in libdevmapper and prepare a configure to select default mangling
Message-ID: <4E984E3B.3040804@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Define new dm_string_mangle_t to select the string mangling used.
Possible values are:

  DM_STRING_MANGLE_NONE - do nothing, no mangling at all (current behaviour)
  DM_STRING_MANGLE_HEX - mangle each character not on a whitelist with \xNN
                         format, NN being a hex value of the character.
  DM_STRING_MANGLE_AUTO - if \xNN is detected in the string, do not mangle it
                          again, keep it as it and consider that the string is
                          already mangled. If we hit a character that is not
                          on a whitelist, mangle it. If we hit both - so we have
                          mixed mangled/not mangled part in the string, return
                          with error.

Also, this patch adds a configure option "--with-default-name-mangle" to select
default operation. Patches using it will follow...

Peter
---
 configure.in         |   14 ++++++++++++++
 libdm/libdevmapper.h |   13 +++++++++++++
 2 files changed, 27 insertions(+), 0 deletions(-)

diff --git a/configure.in b/configure.in
index 5275b95..392fb9b 100644
--- a/configure.in
+++ b/configure.in
@@ -227,6 +227,20 @@ esac
 AC_MSG_RESULT(on $ADD_NODE)
 AC_DEFINE_UNQUOTED([DEFAULT_DM_ADD_NODE], $add_on, [Define default node creation behavior with dmsetup create])
 
+AC_MSG_CHECKING(default name mangle)
+AC_ARG_WITH(default-name-mangle,
+	    AC_HELP_STRING([--with-default-name-mangle=MANGLE],
+			   [default name mangle: auto/disabled/hex [[MANGLE=auto]]]),
+	    MANGLE=$withval, MANGLE=auto)
+case "$MANGLE" in
+ auto) mangle=DM_STRING_MANGLE_AUTO;;
+ disabled) mangle=DM_STRING_MANGLE_NONE;;
+ hex) mangle=DM_STRING_MANGLE_HEX;;
+ *) AC_MSG_ERROR([--with-default-name-mangle parameter invalid]);;
+esac
+AC_MSG_RESULT($MANGLE)
+AC_DEFINE_UNQUOTED([DEFAULT_DM_NAME_MANGLE], $mangle, [Define default name mangle behaviour])
+
 ################################################################################
 dnl -- LVM1 tool fallback option
 AC_MSG_CHECKING(whether to enable lvm1 fallback)
diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index fdf8943..1b30069 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -250,6 +250,19 @@ int dm_task_run(struct dm_task *dmt);
 void dm_task_update_nodes(void);
 
 /*
+ * Mangling support
+ *
+ * Character whitelist: 0-9, A-Z, a-z, #+-.:=@_
+ * HEX mangle format: \xNN, NN being the hex value of the character.
+ * (whitelist and format supported by udev)
+*/
+typedef enum {
+	DM_STRING_MANGLE_NONE,	/* do not mangle at all */
+	DM_STRING_MANGLE_AUTO,	/* mangle only if not already mangled with hex, error when mixed */
+	DM_STRING_MANGLE_HEX	/* always mangle with hex encoding, no matter what the input is */
+} dm_string_mangle_t;
+
+/*
  * Configure the device-mapper directory
  */
 int dm_set_dev_dir(const char *dir);


