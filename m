From: Alasdair Kergon <agk@fedoraproject.org>
Date: Thu,  7 May 2015 11:08:30 +0000 (UTC)
Subject: master - man: Fix recursive lvm-config man page.
Message-ID: <20150507110830.8E16A6031B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=87578b5d94a733b4b57b353c2430df32497a87a4
Commit:        87578b5d94a733b4b57b353c2430df32497a87a4
Parent:        6d35c69b06ebe4b51edf277610eb803d23aba11d
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Thu May 7 12:07:40 2015 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Thu May 7 12:07:40 2015 +0100

man: Fix recursive lvm-config man page.

---
 WHATS_NEW           |    1 +
 man/lvm-config.8.in |    2 +-
 2 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 94851aa..41f8739 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.120 -
 ===============================
+  Fix recursive lvm-config man page. (2.02.119)
   Refactor polldaemon interfaces to poll every operation by VG/LV couple
   Skip wait after testing in _wait_for_single_lv when polling finished
   lvm2app closes locking on lvm_quit().
diff --git a/man/lvm-config.8.in b/man/lvm-config.8.in
index 3d1bec9..5050d77 100644
--- a/man/lvm-config.8.in
+++ b/man/lvm-config.8.in
@@ -1 +1 @@
-.so man8/lvm-config.8
+.so man8/lvmconfig.8


