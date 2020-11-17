From: David Teigland <teigland@sourceware.org>
Date: Tue, 17 Nov 2020 17:02:23 +0000 (GMT)
Subject: master - man: vgsplit source and destination VGs
Message-ID: <20201117170223.9AA763896807@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=9c0253d930103c33784fac5b303da20104a314b6
Commit:        9c0253d930103c33784fac5b303da20104a314b6
Parent:        aba9652e584b6f6a422233dea951eb59326a3de2
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Nov 17 11:00:40 2020 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Nov 17 11:00:40 2020 -0600

man: vgsplit source and destination VGs

make clearer which is source and which is destination
---
 man/vgsplit.8_des | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/man/vgsplit.8_des b/man/vgsplit.8_des
index 29eb5c5cb..d42ff1628 100644
--- a/man/vgsplit.8_des
+++ b/man/vgsplit.8_des
@@ -1,6 +1,7 @@
-vgsplit moves one or more PVs from a source VG to a destination VG. The
-PVs can be specified explicitly or implicitly by naming an LV, in which
-case on PVs underlying the LV are moved.
+vgsplit moves one or more PVs from a source VG (the first VG arg) to a
+destination VG (the second VG arg).  The PV(s) to move are named after the
+source and destination VGs, or an LV is named, in which case the PVs
+underlying the LV are moved.
 
 If the destination VG does not exist, a new VG is created (command options
 can be used to specify properties of the new VG, also see


