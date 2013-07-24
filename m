From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 24 Jul 2013 15:18:15 +0000 (UTC)
Subject: master - python: make clean removes build dir
Message-ID: <20130724151815.4E892612BB@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=7dc21c1597fe57cf7401e074feb8c507cf66aabc
Commit:        7dc21c1597fe57cf7401e074feb8c507cf66aabc
Parent:        a03609dee4770f2453b1f5cb851e2169c539b1e4
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Jul 24 13:57:49 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Jul 24 17:14:10 2013 +0200

python: make clean removes build dir

Cleanning compiled objects for clean: target.
---
 python/Makefile.in |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/python/Makefile.in b/python/Makefile.in
index 9f9046b..fd529b8 100644
--- a/python/Makefile.in
+++ b/python/Makefile.in
@@ -33,7 +33,9 @@ install_lvm2: install_python_bindings
 
 install: install_lvm2
 
+clean:
+	$(RM) -r build
+
 CLEAN_TARGETS += .liblvm_built liblvm_python.c
 
-DISTCLEAN_DIRS += build
 DISTCLEAN_TARGETS += setup.py


