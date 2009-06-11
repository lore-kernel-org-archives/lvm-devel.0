From: Milan Broz <mbroz@redhat.com>
Date: Thu, 11 Jun 2009 11:57:46 +0200
Subject: [PATCH] Re-instate partial activation support in clustered mode.
In-Reply-To: <874ouom21n.fsf@mornfall.net>
References: <874ouom21n.fsf@mornfall.net>
Message-ID: <4A30D51A.4040808@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Petr Rockai wrote:
> the patch from September 2008 (partial activation revamp) broke clustered
> activation for the partial mode. This is currently more serious, since
> lvconvert --repair relies on this functionality (see BZ 504699).

I am going to test it now, just one thing: when introducing new lock flags
etc. please also fix debugging code, so in log new flags appear decoded.

I mean
@@ -145,7 +145,8 @@ static const char *decode_flags(unsigned char flags)
 {
 	static char buf[128];
 
-	sprintf(buf, "0x%x (%s%s)", flags,
+	sprintf(buf, "0x%x (%s%s%s)", flags,
+		flags & LCK_PARTIAL_MODE	  ? "PARTIAL_MODE " : "",
 		flags & LCK_MIRROR_NOSYNC_MODE	  ? "MIRROR_NOSYNC " : "",
 		flags & LCK_DMEVENTD_MONITOR_MODE ? "DMEVENTD_MONITOR " : "");


Also do_lock_lv() should clear cmd->partial_activation before releasing lvm_lock,
(all flags are handled that way, so better do not change logic here).

Milan


