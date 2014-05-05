From: Jonathan Brassow <jbrassow@fedoraproject.org>
Date: Mon,  5 May 2014 19:34:30 +0000 (UTC)
Subject: master - logging: Add LCK_REVERT_MODE to flags printed by decode_flags()
Message-ID: <20140505193430.4663C60F12@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=8b49d61d8337cedddf65c35fb4de83cb01b1cdf4
Commit:        8b49d61d8337cedddf65c35fb4de83cb01b1cdf4
Parent:        09064cc2db00a5da593aa9be61572aa643e4b035
Author:        Jonathan Brassow <jbrassow@redhat.com>
AuthorDate:    Mon May 5 14:27:10 2014 -0500
Committer:     Jonathan Brassow <jbrassow@redhat.com>
CommitterDate: Mon May 5 14:30:09 2014 -0500

logging: Add LCK_REVERT_MODE to flags printed by decode_flags()

The decode_flags() function does not yet know about the
LCK_REVERT_MODE flag.
---
 daemons/clvmd/lvm-functions.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/daemons/clvmd/lvm-functions.c b/daemons/clvmd/lvm-functions.c
index 2ecf7d7..e36e206 100644
--- a/daemons/clvmd/lvm-functions.c
+++ b/daemons/clvmd/lvm-functions.c
@@ -131,14 +131,15 @@ static const char *decode_flags(unsigned char flags)
 	static char buf[128];
 	int len;
 
-	len = sprintf(buf, "0x%x ( %s%s%s%s%s%s%s)", flags,
+	len = sprintf(buf, "0x%x ( %s%s%s%s%s%s%s%s)", flags,
 		flags & LCK_PARTIAL_MODE	  ? "PARTIAL_MODE|" : "",
 		flags & LCK_MIRROR_NOSYNC_MODE	  ? "MIRROR_NOSYNC|" : "",
 		flags & LCK_DMEVENTD_MONITOR_MODE ? "DMEVENTD_MONITOR|" : "",
 		flags & LCK_ORIGIN_ONLY_MODE ? "ORIGIN_ONLY|" : "",
 		flags & LCK_TEST_MODE ? "TEST|" : "",
 		flags & LCK_CONVERT ? "CONVERT|" : "",
-		flags & LCK_DMEVENTD_MONITOR_IGNORE ? "DMEVENTD_MONITOR_IGNORE|" : "");
+		flags & LCK_DMEVENTD_MONITOR_IGNORE ? "DMEVENTD_MONITOR_IGNORE|" : "",
+		flags & LCK_REVERT_MODE ? "REVERT|" : "");
 
 	if (len > 1)
 		buf[len - 2] = ' ';


