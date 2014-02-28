From: Petr Rockai <mornfall@fedoraproject.org>
Date: Fri, 28 Feb 2014 10:25:53 +0000 (UTC)
Subject: master - spec: Add lvm2-pvscan@.service to filelist.
Message-ID: <20140228102553.82AE860F3B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=13d5c78a8d5f09b91e26cd49fffa05313d2f6c82
Commit:        13d5c78a8d5f09b91e26cd49fffa05313d2f6c82
Parent:        49ea253aafb518ce12b70637978372768737a168
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Tue Nov 19 09:24:17 2013 +0100
Committer:     Petr Rockai <me@mornfall.net>
CommitterDate: Fri Feb 28 11:23:51 2014 +0100

spec: Add lvm2-pvscan at .service to filelist.

---
 spec/packages.inc |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/spec/packages.inc b/spec/packages.inc
index 34dc130..4c00617 100644
--- a/spec/packages.inc
+++ b/spec/packages.inc
@@ -154,6 +154,7 @@ fi
  %if %{have_service lvmetad}
   %{_unitdir}/lvm2-lvmetad.socket
   %{_unitdir}/lvm2-lvmetad.service
+  %{_unitdir}/lvm2-pvscan at .service
   %{_unitdir}/blk-availability.service
  %endif
 %else


