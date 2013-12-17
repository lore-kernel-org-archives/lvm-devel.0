From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 17 Dec 2013 13:09:05 +0000 (UTC)
Subject: master - cleanup: skip double assign
Message-ID: <20131217130905.D63996004F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=760714829bfd6f3cc6e0f23f029baf4cc9ed441d
Commit:        760714829bfd6f3cc6e0f23f029baf4cc9ed441d
Parent:        904a02335ffe831dfedc32d074f5b659189aaa76
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Dec 17 13:57:13 2013 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Dec 17 14:08:54 2013 +0100

cleanup: skip double assign

Assing NULL to type only in defaut: switch.
Debug print '--'  for  unlocked and unused resource (-1)
---
 daemons/clvmd/lvm-functions.c |   15 ++++++++-------
 1 files changed, 8 insertions(+), 7 deletions(-)

diff --git a/daemons/clvmd/lvm-functions.c b/daemons/clvmd/lvm-functions.c
index b15732f..fb3a95c 100644
--- a/daemons/clvmd/lvm-functions.c
+++ b/daemons/clvmd/lvm-functions.c
@@ -483,18 +483,19 @@ static int do_deactivate_lv(char *resource, unsigned char command, unsigned char
 const char *do_lock_query(char *resource)
 {
 	int mode;
-	const char *type = NULL;
+	const char *type;
 
 	mode = get_current_lock(resource);
 	switch (mode) {
-		case LCK_NULL: type = "NL"; break;
-		case LCK_READ: type = "CR"; break;
-		case LCK_PREAD:type = "PR"; break;
-		case LCK_WRITE:type = "PW"; break;
-		case LCK_EXCL: type = "EX"; break;
+	case LCK_NULL: type = "NL"; break;
+	case LCK_READ: type = "CR"; break;
+	case LCK_PREAD:type = "PR"; break;
+	case LCK_WRITE:type = "PW"; break;
+	case LCK_EXCL: type = "EX"; break;
+	default: type = NULL;
 	}
 
-	DEBUGLOG("do_lock_query: resource '%s', mode %i (%s)\n", resource, mode, type ?: "?");
+	DEBUGLOG("do_lock_query: resource '%s', mode %i (%s)\n", resource, mode, type ?: "--");
 
 	return type;
 }


