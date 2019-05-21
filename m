From: David Teigland <teigland@sourceware.org>
Date: Tue, 21 May 2019 15:39:05 -0400
Subject: master - tests: pvscan-autoactivate.sh switch system_id_source
Message-ID: <201905211939.x4LJd5eY008346@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=cf3f46392940391d8a27d969125d7ca9c4c5bebc
Commit:        cf3f46392940391d8a27d969125d7ca9c4c5bebc
Parent:        99ca06ca4662ac43c09fb423bb26451ae5171d86
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue May 21 14:37:55 2019 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue May 21 14:37:55 2019 -0500

tests: pvscan-autoactivate.sh switch system_id_source

to machineid instead of uname which would break if
the test system had no proper uname set.
---
 test/shell/pvscan-autoactivate.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/shell/pvscan-autoactivate.sh b/test/shell/pvscan-autoactivate.sh
index 6ed35db..362a4ff 100644
--- a/test/shell/pvscan-autoactivate.sh
+++ b/test/shell/pvscan-autoactivate.sh
@@ -134,7 +134,7 @@ not ls "$RUNDIR/lvm/pvs_online/$PVID3"
 
 # pvscan cache ignores pv in a foreign vg
 
-aux lvmconf "global/system_id_source = uname"
+aux lvmconf "global/system_id_source = machineid"
 
 _clear_online_files
 


