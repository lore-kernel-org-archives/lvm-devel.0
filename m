From: David Teigland <teigland@sourceware.org>
Date: Tue, 10 Sep 2019 11:04:39 -0400
Subject: master - pvscan: allow use of noudevsync option
Message-ID: <201909101504.x8AF4dvj010464@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=3e5e7fd6c93517278b2451a08f47e16d052babbb
Commit:        3e5e7fd6c93517278b2451a08f47e16d052babbb
Parent:        aae2e872b4572ba72fa0321391f7eb77f569e5ff
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Sep 10 09:47:33 2019 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Sep 10 09:47:33 2019 -0500

pvscan: allow use of noudevsync option

When pvscan is used to activate a VG via an
asynchronous service (i.e. lvm2-pvscan), there
is no requirement that the command wait for
udev to create device nodes before returning.

It's possible that waiting for udev is slow
enough to cause the service running the command
to time out.  So, allow the --noudevsync option
to be given to pvscan to skip waiting for udev.

(This commit is not changing the lvm2-pvscan
service itself to use --noudevsync.)

Still unknown is whether there are any complex
LV activation cases in which lvm itself requires
access to a device node, in which case the udev
wait could be needed by lvm itself.

(When running an activation command directly
from the command line, it's generally expected
that the activated LVs are ready to use when
the command is finished, so lvm waits for
udev to finish creating the dev nodes.)
---
 tools/command-lines.in |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/tools/command-lines.in b/tools/command-lines.in
index 1169224..65221c0 100644
--- a/tools/command-lines.in
+++ b/tools/command-lines.in
@@ -1498,7 +1498,7 @@ DESC: Display PV information.
 
 pvscan --cache_long
 OO: --ignorelockingfailure, --reportformat ReportFmt,
---activate ay, --major Number, --minor Number
+--activate ay, --major Number, --minor Number, --noudevsync
 OP: PV|String ...
 IO: --background
 ID: pvscan_cache


