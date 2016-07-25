From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon, 25 Jul 2016 13:05:12 +0000 (UTC)
Subject: master - man: add note about 'lastlog' built-in command
Message-ID: <20160725130512.674C060D3C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=94141c7797caabe23607a554fa7c6f44a4d570fc
Commit:        94141c7797caabe23607a554fa7c6f44a4d570fc
Parent:        5397837a9f334fa91973e36acf38655a19b88b28
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Mon Jul 25 15:05:08 2016 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Jul 25 15:05:08 2016 +0200

man: add note about 'lastlog' built-in command

---
 WHATS_NEW    |    1 +
 man/lvm.8.in |    4 ++++
 2 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index ca12e8c..f5b8306 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.162 - 
 =================================
+  Add note about lastlog built-in command to lvm man page.
   Fix unrecognised segtype flag message.
   lvconvert reuse cachepool metadade now ONLY with -Zn and clear otherwise.
   Enabled lvconvert --uncache to work with partial VG.
diff --git a/man/lvm.8.in b/man/lvm.8.in
index f0d094d..0215783 100644
--- a/man/lvm.8.in
+++ b/man/lvm.8.in
@@ -68,6 +68,10 @@ Display recognised metadata formats.
 .B help
 Display the help text.
 .TP
+.B lastlog
+Display log report of last command run in LVM shell
+if command log reporting is enabled.
+.TP
 .B lvpoll
 Complete lvmpolld operations (Internal command).
 .TP


