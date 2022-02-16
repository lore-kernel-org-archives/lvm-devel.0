From: David Teigland <teigland@sourceware.org>
Date: Wed, 16 Feb 2022 21:40:07 +0000 (GMT)
Subject: main - man: update cachesettings option description
Message-ID: <20220216214007.21B253858431@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=96c99d647ef783abcd26a1f3f63f12e033195633
Commit:        96c99d647ef783abcd26a1f3f63f12e033195633
Parent:        ec2119beddde9e38681cb096b93048ee25034c1e
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Feb 16 15:36:44 2022 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Feb 16 15:37:54 2022 -0600

man: update cachesettings option description

to be more consistent with man page description
---
 tools/args.h | 13 +++++++------
 1 file changed, 7 insertions(+), 6 deletions(-)

diff --git a/tools/args.h b/tools/args.h
index 3f4580b8d..56669645d 100644
--- a/tools/args.h
+++ b/tools/args.h
@@ -862,12 +862,13 @@ arg(cachepolicy_ARG, '\0', "cachepolicy", string_VAL, 0, 0,
     "See \\fBlvmcache\\fP(7) for more information.\n")
 
 arg(cachesettings_ARG, '\0', "cachesettings", string_VAL, ARG_GROUPABLE, 0,
-    "Specifies tunable values for a cache LV in \"Key = Value\" form.\n"
-    "Repeat this option to specify multiple values.\n"
-    "(The default values should usually be adequate.)\n"
-    "The special string value \\fBdefault\\fP switches\n"
-    "settings back to their default kernel values and removes\n"
-    "them from the list of settings stored in LVM metadata.\n"
+    "Specifies tunable kernel options for dm-cache or dm-writecache LVs.\n"
+    "Use the form 'option=value' or 'option1=value option2=value', or\n"
+    "repeat --cachesettings for each option being set.\n"
+    "These settings override the default kernel behaviors which are\n"
+    "usually adequate. To remove cachesettings and revert to the default\n"
+    "kernel behaviors, use --cachesettings 'default' for dm-cache or\n"
+    "an empty string --cachesettings '' for dm-writecache.\n"
     "See \\fBlvmcache\\fP(7) for more information.\n")
 
 arg(unconfigured_ARG, '\0', "unconfigured", 0, 0, 0,


