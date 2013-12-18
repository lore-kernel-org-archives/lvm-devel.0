From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed, 18 Dec 2013 11:24:20 +0000 (UTC)
Subject: master - systemd: use only major:minor for pvscan in lvm2-pvscan@.service
Message-ID: <20131218112420.E689C60D14@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=359291b41cdeb1ca886e018aa44c67882da10252
Commit:        359291b41cdeb1ca886e018aa44c67882da10252
Parent:        3c818c89467f9b54bc94d9919a127dd912d96c24
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Dec 18 12:00:02 2013 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Dec 18 12:23:59 2013 +0100

systemd: use only major:minor for pvscan in lvm2-pvscan at .service

When using filters for the pvscan --cache (the global_filter),
there's a difference between:

  pvscan --cache -aay /dev/block/<major>:<minor>

and

  pvscan --cache -aay <major>:<minor> (or --major <major> --minor <minor>)

In the first case, we need to be sure to have an exact matching line
in the filter for the device to be used, no aliases are considered
So for example even if we have accept rule for "/dev/sda" present,
this won't apply for "/dev/block/8:0" even though it's the same device!
This is because we're comparing the path used on command line directly
with the path written in the rule.

For the second one, any alias mentioned in the filter will apply
as we're comparing the major and minor pair, not looking at actual
device names - so any alias mentioned in the rules will suffice for
the filtering rule to apply.

For the global_filter to be properly used, we need to call the
second one in the lvm2-pvscan at .service - nobody is able to tell
what value of major:minor the kernel assignes next time, hence
this bug makes the use of global_filter quite unusable!
---
 WHATS_NEW                                       |    1 +
 scripts/lvm2_pvscan_systemd_red_hat at .service.in |    2 +-
 2 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index fe8f1ea..1dac25e 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.105 -
 =====================================
+  Use major:minor in lvm2-pvscan at .service for proper global_filter application.
   Syntax and spelling fixes in some man pages.
   Dependency scan counts with snapshots and external origins.
   Make sure VG extent size is always greater or equal to PV phys. block size.
diff --git a/scripts/lvm2_pvscan_systemd_red_hat at .service.in b/scripts/lvm2_pvscan_systemd_red_hat at .service.in
index 6b21c75..cdbbe40 100644
--- a/scripts/lvm2_pvscan_systemd_red_hat at .service.in
+++ b/scripts/lvm2_pvscan_systemd_red_hat at .service.in
@@ -11,5 +11,5 @@ Conflicts=shutdown.target
 [Service]
 Type=oneshot
 RemainAfterExit=yes
-ExecStart=@sbindir@/pvscan --cache --activate ay /dev/block/%i
+ExecStart=@sbindir@/pvscan --cache --activate ay %i
 ExecStop=@sbindir@/pvscan --cache %i


