From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed,  1 Aug 2012 11:58:34 +0000 (UTC)
Subject: master - Fix dependecy build for scripts dir
Message-ID: <20120801115834.1ABB031CB@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=286f298bb79a43b61baab36582481df93e84137b
Commit:        286f298bb79a43b61baab36582481df93e84137b
Parent:        e309586aebec5ab034c89536620c0b102b8a366c
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Aug 1 13:54:32 2012 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Aug 1 13:57:23 2012 +0200

Fix dependecy build for scripts dir

Since now scripts builds binaries, build needs to wait for libs.
---
 Makefile.in |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/Makefile.in b/Makefile.in
index 04746d1..d957e26 100644
--- a/Makefile.in
+++ b/Makefile.in
@@ -56,6 +56,7 @@ liblvm: lib
 daemons: lib libdaemon tools
 tools: lib libdaemon device-mapper
 po: tools daemons
+scripts: liblvm libdm
 
 lib.device-mapper: include.device-mapper
 libdm.device-mapper: include.device-mapper


