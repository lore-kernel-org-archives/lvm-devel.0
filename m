From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 30 Nov 2018 07:11:02 -0500
Subject: master - rpm: install lvm2-pvscan again
Message-ID: <201811301211.wAUCB2Y9014615@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=6a4a6a7cd7ef83b6283284637e3b28476fbc7712
Commit:        6a4a6a7cd7ef83b6283284637e3b28476fbc7712
Parent:        c0c318e4f2ea362a4eb0207ee7b77ef2d8425dc5
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Nov 30 13:09:09 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Nov 30 13:10:00 2018 +0100

rpm: install lvm2-pvscan again

Let's repeat history once more 13d5c78a8d5f09b91e26cd49fffa05313d2f6c82.
---
 spec/packages.inc |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/spec/packages.inc b/spec/packages.inc
index a1065a6..0be4f2e 100644
--- a/spec/packages.inc
+++ b/spec/packages.inc
@@ -175,6 +175,7 @@ fi
  %{_tmpfilesdir}/%{name}.conf
  %{_unitdir}/blk-availability.service
  %{_unitdir}/lvm2-monitor.service
+ %{_unitdir}/lvm2-pvscan at .service
  %attr(555, -, -) %{_prefix}/lib/systemd/system-generators/lvm2-activation-generator
  %if %{have_service lvmpolld}
   %{_unitdir}/lvm2-lvmpolld.service


