From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 25 Aug 2017 08:24:50 -0400
Subject: master - dmsetup: add missing -- for option
Message-ID: <201708251224.v7PCOoMP005084@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=47b7d4a7336fa60eb25ad15b2fc3fcb5b96ce1c2
Commit:        47b7d4a7336fa60eb25ad15b2fc3fcb5b96ce1c2
Parent:        26d97f179fabe0669dc10e7e16398803c323ca93
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Aug 25 11:47:36 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Aug 25 14:20:59 2017 +0200

dmsetup: add missing -- for option

---
 tools/dmsetup.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index 0fd2f2c..341522c 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -6157,7 +6157,7 @@ static struct command _dmsetup_commands[] = {
 	{"create", "<dev_name>\n"
 	  "\t    [-j|--major <major> -m|--minor <minor>]\n"
 	  "\t    [-U|--uid <uid>] [-G|--gid <gid>] [-M|--mode <octal_mode>]\n"
-	  "\t    [-u|uuid <uuid>] [--addnodeonresume|--addnodeoncreate]\n"
+	  "\t    [-u|--uuid <uuid>] [--addnodeonresume|--addnodeoncreate]\n"
 	  "\t    [--readahead {[+]<sectors>|auto|none}]\n"
 	  "\t    [-n|--notable|--table {<table>|<table_file>}]\n"
 	  "\tcreate --concise [<concise_device_spec_list>]", 0, 2, 0, 0, _create},


