From: David Teigland <teigland@sourceware.org>
Date: Thu, 4 May 2017 15:05:17 -0400
Subject: master - man lvmconfig: add descriptions for typeconfig and ignorelocal
Message-ID: <201705041905.v44J5Hsj005539@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=c56d8535a722b4b7d8303e7aede627d8b0246e23
Commit:        c56d8535a722b4b7d8303e7aede627d8b0246e23
Parent:        20026c9c223550633da73c5978686db389f19a17
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu May 4 14:04:10 2017 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu May 4 14:04:10 2017 -0500

man lvmconfig: add descriptions for typeconfig and ignorelocal

---
 tools/args.h |   38 ++++++++++++++++++++++++++++++++++++--
 1 files changed, 36 insertions(+), 2 deletions(-)

diff --git a/tools/args.h b/tools/args.h
index 23eaf5c..f5e864f 100644
--- a/tools/args.h
+++ b/tools/args.h
@@ -135,7 +135,38 @@ arg(configreport_ARG, '\0', "configreport", configreport_VAL, ARG_GROUPABLE, 1,
     "See \\fBlvmreport\\fP(7).\n")
 
 arg(configtype_ARG, '\0', "typeconfig", configtype_VAL, 0, 0,
-    "See \\fBlvmreport\\fP(7).\n")
+    "\\fBcurrent\\fP prints the config settings that would be applied\n"
+    "to an lvm command (assuming the command does not override them\n"
+    "on the command line.) This includes:\n"
+    "settings that have been modified in lvm config files,\n"
+    "settings that get their default values from config files,\n"
+    "and default settings that have been uncommented in config files.\n"
+    "\\fBdefault\\fP prints all settings with their default values.\n"
+    "Changes made in lvm config files are not reflected in the output.\n"
+    "Some settings get their default values internally,\n"
+    "and these settings are printed as comments.\n"
+    "Other settings get their default values from config files,\n"
+    "and these settings are not printed as comments.\n"
+    "\\fBdiff\\fP prints only config settings that have been modified\n"
+    "from their default values in config files (the difference between\n"
+    "current and default.)\n"
+    "\\fBfull\\fP prints every setting uncommented and set to the\n"
+    "current value, i.e. how it would be used by an lvm command.\n"
+    "This includes settings modified in config files, settings that usually\n"
+    "get defaults internally, and settings that get defaults from config files.\n"
+    "\\fBlist\\fP prints all config names without values.\n"
+    "\\fBmissing\\fP prints settings that are missing from the\n"
+    "lvm config files. A missing setting that usually gets its default\n"
+    "from config files is printed uncommented and set to the internal default.\n"
+    "Settings that get their default internally and are not set in config files\n"
+    "are printed commented with the internal default.\n"
+    "\\fBnew\\fP prints config settings that have been added since\n"
+    "the lvm version specified by --sinceversion. They are printed\n"
+    "with their default values.\n"
+    "\\fBprofilable\\fP prints settings with their default values that can be set from a profile.\n"
+    "\\fBprofilable-command\\fP prints settings with their default values that can be set from a command profile.\n"
+    "\\fBprofilable-metadata\\fP prints settings with their default values that can be set from a metadata profile.\n"
+    "Also see \\fBlvm.conf\\fP(5).\n")
 
 arg(dataalignment_ARG, '\0', "dataalignment", sizekb_VAL, 0, 0,
     "Align the start of the data to a multiple of this number.\n"
@@ -198,7 +229,10 @@ arg(ignoreadvanced_ARG, '\0', "ignoreadvanced", 0, 0, 0,
     "Exclude advanced configuration settings from the output.\n")
 
 arg(ignorelocal_ARG, '\0', "ignorelocal", 0, 0, 0,
-    "Ignore local section.\n")
+    "Ignore the local section. The local section should be defined in\n"
+    "the lvmlocal.conf file, and should contain config settings\n"
+    "specific to the local host which should not be copied to\n"
+    "other hosts.\n")
 
 arg(ignorelockingfailure_ARG, '\0', "ignorelockingfailure", 0, 0, 0,
     "Allows a command to continue with read-only metadata\n"


