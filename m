From: Takahiro Yasui <tyasui@redhat.com>
Date: Tue, 29 Sep 2009 20:28:09 -0400
Subject: [RFC][PATCH 1/5] support command string with space
Message-ID: <4AC2A619.50404@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Support escaped space by backslash in the command line string passed
through lvm2 command interface, lvm2_run(). This is used to handle
"--config" option which contains multiple parameters.

e.g. lvconvert --repair --use-policies --config \
     devices{ignore_suspended_devices=1\ filter=[...]} vg/lv


Signed-off-by: Takahiro Yasui <tyasui@redhat.com>
---
 tools/lvmcmdline.c |    9 ++++++++-
 1 file changed, 8 insertions(+), 1 deletion(-)

Index: LVM2.02.54-20090928/tools/lvmcmdline.c
===================================================================
--- LVM2.02.54-20090928.orig/tools/lvmcmdline.c
+++ LVM2.02.54-20090928/tools/lvmcmdline.c
@@ -1070,8 +1070,15 @@ int lvm_split(char *str, int *argc, char
 			break;
 
 		e = b;
-		while (*e && !isspace(*e))
+		while (*e && !isspace(*e)) {
+			/*
+			 * 'backslash' is treated as a escape character
+			 * and the string isn't split at 'backslash + space.'
+			 */
+			if (*e == '\\' && isspace(*(e+1)))
+				*e++ = ' ';
 			e++;
+		}
 
 		argv[(*argc)++] = b;
 		if (!*e)

-- 
Takahiro Yasui
Hitachi Computer Products (America), Inc.


