From: Petr Rockai <prockai@redhat.com>
Date: Tue, 29 Jul 2008 15:52:26 +0200
Subject: [PATCH] (6/6) new handling for --partial flag
Message-ID: <87prow23xh.fsf@eriador.mornfall.net>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

The last patch is a new one, removing partial_mode() altogether (the global
variable hack for enabling partial activation) which has never been quite
compatible with how we treat partial LVs and VGs now. This patch makes
--partial work again (to be more exact, it prevents partial activation from
happening when --partial is not passed).

-------------- next part --------------
A non-text attachment was scrubbed...
Name: hotspare-everything.diff
Type: text/x-diff
Size: 15480 bytes
Desc: partial_flag.diff
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20080729/33e6b9fe/attachment.bin>
-------------- next part --------------

-- 
Peter Rockai | me()mornfall!net | prockai()redhat!com
 http://blog.mornfall.net | http://web.mornfall.net

"In My Egotistical Opinion, most people's C programs should be
 indented six feet downward and covered with dirt."
     -- Blair P. Houghton on the subject of C program indentation
