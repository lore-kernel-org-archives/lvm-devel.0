From: Alasdair Kergon <agk@fedoraproject.org>
Date: Tue, 13 May 2014 10:26:38 +0000 (UTC)
Subject: master - man: Fix man7 dir dependency.
Message-ID: <20140513102638.7BEC9612BC@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=422b3b0fb53d83bc3ffbd35f7d7505a1938cb24c
Commit:        422b3b0fb53d83bc3ffbd35f7d7505a1938cb24c
Parent:        85cf5a23d265c10af7e69b5f85e06e75105d8f14
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Tue May 13 11:18:13 2014 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Tue May 13 11:18:13 2014 +0100

man: Fix man7 dir dependency.

https://bugs.gentoo.org/510202
---
 man/Makefile.in |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/man/Makefile.in b/man/Makefile.in
index af108cf..c6a27d0 100644
--- a/man/Makefile.in
+++ b/man/Makefile.in
@@ -103,7 +103,7 @@ install_man5: $(MAN5)
 	$(INSTALL) -d $(MAN5DIR)
 	$(INSTALL_DATA) $(MAN5) $(MAN5DIR)/
 
-install_man7: $(MAN8)
+install_man7: $(MAN7)
 	$(INSTALL) -d $(MAN7DIR)
 	$(INSTALL_DATA) $(MAN7) $(MAN7DIR)/
 


