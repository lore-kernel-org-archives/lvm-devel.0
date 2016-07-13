From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 13 Jul 2016 19:56:21 +0000 (UTC)
Subject: master - coverity: easier to follow set-up of vsn variable
Message-ID: <20160713195621.67E6C60370@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=bbf574ab90a82f636a5f5e66c9523484492da946
Commit:        bbf574ab90a82f636a5f5e66c9523484492da946
Parent:        0b773eecd967599b38214fe321fc7e493046c880
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Jul 12 16:41:25 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Jul 13 21:52:14 2016 +0200

coverity: easier to follow set-up of vsn variable

Helping coverity to see 'vsn' really can't be NULL.
---
 tools/dumpconfig.c |    7 ++-----
 1 files changed, 2 insertions(+), 5 deletions(-)

diff --git a/tools/dumpconfig.c b/tools/dumpconfig.c
index 3da04f0..e387e60 100644
--- a/tools/dumpconfig.c
+++ b/tools/dumpconfig.c
@@ -20,11 +20,8 @@ static int _get_vsn(struct cmd_context *cmd, uint16_t *version_int)
 	const char *vsn;
 	unsigned int major, minor, patchlevel;
 
-	if (arg_is_set(cmd, atversion_ARG))
-		vsn = arg_str_value(cmd, atversion_ARG, NULL);
-	else if (arg_is_set(cmd, sinceversion_ARG))
-		vsn = arg_str_value(cmd, sinceversion_ARG, NULL);
-	else
+	if (!(vsn = arg_str_value(cmd, atversion_ARG, NULL)) &&
+	    !(vsn = arg_str_value(cmd, sinceversion_ARG, NULL)))
 		vsn = LVM_VERSION;
 
 	if (sscanf(vsn, "%u.%u.%u", &major, &minor, &patchlevel) != 3) {


