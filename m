From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu, 26 Jun 2014 13:16:32 +0000 (UTC)
Subject: master - man: do not mention '(i)nherited' for alloc policy in vg_attr field
Message-ID: <20140626131632.3FFF0606F5@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b41aa985d7f93ba9e2db6fab032e0cf3d7180cf8
Commit:        b41aa985d7f93ba9e2db6fab032e0cf3d7180cf8
Parent:        ed3c2537b82be4e326a53c7e3e6d5eccdd833800
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Jun 26 15:14:54 2014 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Jun 26 15:15:10 2014 +0200

man: do not mention '(i)nherited' for alloc policy in vg_attr field

VG has nothing to inherit from...
---
 man/vgs.8.in |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/man/vgs.8.in b/man/vgs.8.in
index 2d4946f..de0ef9b 100644
--- a/man/vgs.8.in
+++ b/man/vgs.8.in
@@ -85,7 +85,7 @@ E(x)ported
 (p)artial: one or more physical volumes belonging to the volume group
 are missing from the system
 .IP 5 3
-Allocation policy: (c)ontiguous, c(l)ing, (n)ormal, (a)nywhere, (i)nherited
+Allocation policy: (c)ontiguous, c(l)ing, (n)ormal, (a)nywhere
 .IP 6 3
 (c)lustered
 .RE


