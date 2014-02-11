From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 11 Feb 2014 18:01:25 +0000 (UTC)
Subject: master - man: use some existing indentifier
Message-ID: <20140211180125.9BDC560FC3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=40a9c443a925ff2fbc7c12972c3cfa726b880580
Commit:        40a9c443a925ff2fbc7c12972c3cfa726b880580
Parent:        c1faa4048a7421c14456cb1761548f7907bfbf53
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Feb 11 18:04:05 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Feb 11 18:55:54 2014 +0100

man: use some existing indentifier

Avoid confusing user, since some may get impression there is
such variable (max_archives) in the config file.
Pick rather something existing.
---
 man/lvm.conf.5.in |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/man/lvm.conf.5.in b/man/lvm.conf.5.in
index 2786df2..73fcf47 100644
--- a/man/lvm.conf.5.in
+++ b/man/lvm.conf.5.in
@@ -102,7 +102,7 @@ e.g.	backup {
 .br
 An assignment associates a type with an identifier.
 .br
-e.g.	max_archives = 42
+e.g.	level = 7
 .br
 .TP
 .BR array " =  '" [ "' ( " type " '" , "')* " type " '" ] "' | '" [ "' '" ] '


