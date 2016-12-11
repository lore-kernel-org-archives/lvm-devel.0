From: Bryn Reeves <bmr@fedoraproject.org>
Date: Sun, 11 Dec 2016 13:32:55 +0000 (UTC)
Subject: master - scripts: add lvmdump.sh to .gitignore
Message-ID: <20161211133255.CDF5A60E13@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=383683ffd390e1936474c3bced850ea887223478
Commit:        383683ffd390e1936474c3bced850ea887223478
Parent:        b311122a5666489f5dbeae09952dfbcd533f5a36
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Sat Dec 10 17:56:56 2016 +0000
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Sat Dec 10 17:56:56 2016 +0000

scripts: add lvmdump.sh to .gitignore

---
 scripts/.gitignore |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/scripts/.gitignore b/scripts/.gitignore
index 3a668ae..ed0d945 100644
--- a/scripts/.gitignore
+++ b/scripts/.gitignore
@@ -22,3 +22,4 @@ lvm2_monitoring_init_red_hat
 lvm2_monitoring_systemd_red_hat.service
 lvm2_pvscan_systemd_red_hat at .service
 lvm2_tmpfiles_red_hat.conf
+lvmdump.sh


