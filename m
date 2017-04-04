From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Tue, 4 Apr 2017 17:53:44 -0400
Subject: master - man: '-pool' regexp
Message-ID: <201704042153.v34Lri4n016471@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=e7ec9aab8a9a546e1b6ef7dc49e8012373691c3b
Commit:        e7ec9aab8a9a546e1b6ef7dc49e8012373691c3b
Parent:        76b70d5058cbbe41b60b99f11cda5e698b3c62e9
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Tue Apr 4 23:53:28 2017 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Tue Apr 4 23:53:28 2017 +0200

man: '-pool' regexp

---
 man/Makefile.in |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/man/Makefile.in b/man/Makefile.in
index defa9b3..25b1c95 100644
--- a/man/Makefile.in
+++ b/man/Makefile.in
@@ -216,6 +216,7 @@ $(SED) -i -e "s+\([ [:alpha:]]\)-\{7\}+\1\\\-\\\-\\\-\\\-\\\-\\\-\\\-+g" \
 	  -e "s+\([[:alnum:]]\{2,\}\)\\\-\([[:alnum:]]\{2,\}\)+\1-\2+g" \
 	  -e "s+\(\\\-\\\-[[:alnum:]]\{2,\}\)-+\1\\\-+g" \
 	  -e "s+\(lvm2\-activation\)+lvm2\\\-activation+" \
+	  -e "s+\([^\\]\)-pool+\1\\\-pool+g" \
 	  -e "s+\([[:digit:]]\)-\([[:digit:]]\)+\1\\\-\2+g" \
 	  -e "s+\\\-git+\-git+g" \
 	  -e "s+\(vg.*\)\-lv+\1\\\-lv+g" \


