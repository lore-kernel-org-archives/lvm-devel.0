From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 23 Apr 2021 21:05:41 +0000 (GMT)
Subject: main - cov: ensure there is space for 0 at eol
Message-ID: <20210423210541.5CB2C393BC13@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=d1f9845c96284ee72692b7701a2dd1b86006524e
Commit:        d1f9845c96284ee72692b7701a2dd1b86006524e
Parent:        cfe26470e350580249f03025ae6bafbf2ab8e60b
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Apr 22 15:08:34 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Apr 23 22:58:45 2021 +0200

cov: ensure there is space for 0 at eol

Reserve 1 char for \0.
---
 tools/command.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/tools/command.c b/tools/command.c
index 6431e2a50..1de739aaa 100644
--- a/tools/command.c
+++ b/tools/command.c
@@ -2522,7 +2522,7 @@ static const char *_man_long_opt_name(const char *cmdname, int opt_enum)
 	}
 
 	if (strchr(long_opt, '[')) {
-		for (i = 0; i < sizeof(long_opt_name); ++long_opt, ++i) {
+		for (i = 0; i < sizeof(long_opt_name) - 1; ++long_opt, ++i) {
 			if (i < (sizeof(long_opt_name) - 8))
 				switch(*long_opt) {
 				case '[':


