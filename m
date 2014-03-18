From: Hannes Reinecke <hare@suse.de>
Date: Tue, 18 Mar 2014 09:24:01 +0100
Subject: [PATCH 1/2] Fix pvdisplay to refer to sectors, not KB
In-Reply-To: <1395131042-5015-1-git-send-email-hare@suse.de>
References: <1395131042-5015-1-git-send-email-hare@suse.de>
Message-ID: <1395131042-5015-2-git-send-email-hare@suse.de>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

From: Thomas Fehr <fehr@suse.de>

The size is displayed in sectors, not kilobytes.

Signed-off-by: Thomas Fehr <fehr@suse.de>
Acked-by: Hannes Reinecke <hare@suse.de>
---
 man/pvdisplay.8.in | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

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
-- 
1.8.1.4


