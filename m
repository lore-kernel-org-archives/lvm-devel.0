From: David Teigland <teigland@sourceware.org>
Date: Tue, 14 Dec 2021 18:02:43 +0000 (GMT)
Subject: main - man lvmautoactivation: replace systemctl with journalctl
Message-ID: <20211214180243.C829E385800B@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=0f71183f9434d513733d38fb7f9619421d8afaf5
Commit:        0f71183f9434d513733d38fb7f9619421d8afaf5
Parent:        fbd8b0cf43dc67f51f86f060dce748f446985855
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Dec 14 12:02:08 2021 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Dec 14 12:02:08 2021 -0600

man lvmautoactivation: replace systemctl with journalctl

---
 man/lvmautoactivation.7_main | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/man/lvmautoactivation.7_main b/man/lvmautoactivation.7_main
index bf885991d..54dab718b 100644
--- a/man/lvmautoactivation.7_main
+++ b/man/lvmautoactivation.7_main
@@ -107,7 +107,7 @@ vgchange -aay --autoactivation event <vgname>
 .
 .IP \[bu] 2
 the activation command output can be seen from
-systemctl status lvm-activate-<vgname>
+journalctl -u lvm-activate-<vgname>
 .P
 .
 .SS pvscan options


