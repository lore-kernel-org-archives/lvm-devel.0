From: Petr Rockai <prockai@redhat.com>
Date: Tue, 29 Jul 2008 15:36:46 +0200
Subject: [PATCH] (3/6) partial activation
Message-ID: <874p683j81.fsf@eriador.mornfall.net>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

User documentation should be no longer TBD, as the example config and manual
page have been updated for this incarnation of the patch. It is still way more
verbose than anyone would like, when you have "invalid" configuration. That
should be addressed separately in 6/6, where we rework the --partial flag
handling.

(The table names have been fixed to be unique in presence of multiple segments
as well, since the last incarnation of the patch.)

-------------- next part --------------
A non-text attachment was scrubbed...
Name: lib-partial_activation.diff
Type: text/x-diff
Size: 10048 bytes
Desc: lib-partial_activation.diff
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20080729/9a983c62/attachment.bin>
-------------- next part --------------

-- 
Peter Rockai | me()mornfall!net | prockai()redhat!com
 http://blog.mornfall.net | http://web.mornfall.net

"In My Egotistical Opinion, most people's C programs should be
 indented six feet downward and covered with dirt."
     -- Blair P. Houghton on the subject of C program indentation
