From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri, 17 Oct 2014 12:05:24 +0000 (UTC)
Subject: master - liblvm2cmd: recognize quotes properly when splitting cmd line string into argv array fields
Message-ID: <20141017120524.F0906606E4@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=4988d799a26032bfde4888d55080f5d42f5d55c1
Commit:        4988d799a26032bfde4888d55080f5d42f5d55c1
Parent:        a6c294c5d0b989c3a881c8d084291aaf97fa3ac8
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Fri Oct 17 13:55:06 2014 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri Oct 17 14:03:43 2014 +0200

liblvm2cmd: recognize quotes properly when splitting cmd line string into argv array fields

Fix lvm_split that is called when cmd line string is separated into
argv fields to recognize quote chars ('\'" and '"') properly and
when these quotes are used, consider the text within quotes as one
argument, do not separate it based on space characters inside.

The lvm_split is used during processing lvm shell command line or
when calling lvm commands through cmdlib (e.g. dmeventd plugins).

For example, the lvm shell scenario:

Before this patch:
$lvm
lvm> lvs --config 'global{ suffix=0 }'
  Parse error at byte 9 (line 1): unexpected token
  Failed to set overridden configuration entries.

With this patch applied:
$lvm
lvm> lvs --config 'global{ suffix=0 }'
  LV    VG     Attr       LSize   Pool Origin Data%  Meta%  Move Log  Cpy%Sync Convert
  root  fedora -wi-ao----   9.00g
  swap  fedora -wi-ao---- 512.00m

(Exactly the same problem is hit when calling LVM commands with
quoted arguments via lvm2cmd lib in dmeventd plugins.)
---
 WHATS_NEW          |    1 +
 tools/lvmcmdline.c |    9 ++++++++-
 2 files changed, 9 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index d7a00fe..0d4487e 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.112 - 
 =====================================
+  Fix liblvm2cmd and lvm shell to respect quotes around args in cmd line string.
   Permit extent sizes > 128KB that are not power of 2 with lvm2 format.
   Remove workaround for lvm2-monitor.service hang on stop if lvmetad stopped.
   Change vgremove to use process_each_lv_in_vg.
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 4697b24..4c61332 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -1407,6 +1407,7 @@ int lvm_split(char *str, int *argc, char **argv, int max)
 {
 	char *b = str, *e;
 	*argc = 0;
+	char quote = 0;
 
 	while (*b) {
 		while (*b && isspace(*b))
@@ -1415,14 +1416,20 @@ int lvm_split(char *str, int *argc, char **argv, int max)
 		if ((!*b) || (*b == '#'))
 			break;
 
+		if (*b == '\'' || *b == '"') {
+			quote = *b;
+			b++;
+		}
+
 		e = b;
-		while (*e && !isspace(*e))
+		while (*e && (quote ? *e != quote : !isspace(*e)))
 			e++;
 
 		argv[(*argc)++] = b;
 		if (!*e)
 			break;
 		*e++ = '\0';
+		quote = 0;
 		b = e;
 		if (*argc == max)
 			break;


