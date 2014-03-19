From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 19 Mar 2014 00:02:10 +0000 (UTC)
Subject: master - pvdisplay: fix man to refer to sectors, not KB
Message-ID: <20140319000210.8277C60FD8@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=5b69bfb6f867944e7831a653f6aa4b17853fbbe5
Commit:        5b69bfb6f867944e7831a653f6aa4b17853fbbe5
Parent:        52525bde04e72245224546caaacde2a3b15cad9d
Author:        Thomas Fehr <fehr@suse.de>
AuthorDate:    Tue Mar 18 09:24:01 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Mar 19 00:49:32 2014 +0100

pvdisplay: fix man to refer to sectors, not KB

The PV size is displayed in sectors, not kilobytes
for 'pvdisplay -c'

Signed-off-by: Thomas Fehr <fehr@suse.de>
Acked-by: Hannes Reinecke <hare@suse.de>
---
 WHATS_NEW          |    1 +
 man/pvdisplay.8.in |    2 +-
 2 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 08d5b1d..adf446a 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.106 - 
 ====================================
+  Fix pvdisplay -c man page referencing KB instead of sectors.
   Skip redundant synchronization calls on local clvmd.
   Use correct PATH_MAX for locking dir path.
   Do not check for backups when when its creation is disabled.
diff --git a/man/pvdisplay.8.in b/man/pvdisplay.8.in
index 03c12c4..13c26b5 100644
--- a/man/pvdisplay.8.in
+++ b/man/pvdisplay.8.in
@@ -65,7 +65,7 @@ The values are:
 
 * physical volume device name
 * volume group name
-* physical volume size in kilobytes
+* physical volume size in sectors
 * internal physical volume number (obsolete)
 * physical volume status
 * physical volume (not) allocatable


