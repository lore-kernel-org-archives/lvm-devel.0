From: Bryn Reeves <bmr@fedoraproject.org>
Date: Mon,  4 Jul 2016 11:17:14 +0000 (UTC)
Subject: master - docs: remove obsolete note from dmstats.8.in
Message-ID: <20160704111714.6BC9761D92@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f27e95b25a639ca5cf8329f6f26f6a040706bf57
Commit:        f27e95b25a639ca5cf8329f6f26f6a040706bf57
Parent:        d8c2677ab92c3c3bd35ccab0d486ebce8db4fbb4
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Sun Jun 19 21:48:29 2016 +0100
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Mon Jul 4 12:16:50 2016 +0100

docs: remove obsolete note from dmstats.8.in

---
 man/dmstats.8.in |    5 -----
 1 files changed, 0 insertions(+), 5 deletions(-)

diff --git a/man/dmstats.8.in b/man/dmstats.8.in
index 9776aa7..1b7a499 100644
--- a/man/dmstats.8.in
+++ b/man/dmstats.8.in
@@ -192,11 +192,6 @@ The second argument is the \fIdevice name\fP,
 Further options permit the selection of regions, output format
 control, and reporting behaviour.
 
-When the program is run using the '\fBdmstats\fP' alias, the command
-\fBmust\fP be the first argument and any switches and options should be
-specified following the command itself. This limitation is not present
-when run as '\fBdmsetup stats\fP'.
-
 When no device argument is given dmstats will by default operate on all
 device-mapper devices present. The \fBcreate\fP and \fBdelete\fP
 commands require the use of \fB\-\-alldevices\fP when used in this way.


