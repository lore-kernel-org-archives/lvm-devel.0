From: Petr Rockai <prockai@redhat.com>
Date: Thu, 22 Jan 2009 11:53:04 +0100
Subject: [PATCH] A different implementation of --ignorelockingfailure.
Message-ID: <871vuva9yn.fsf@eriador.mornfall.net>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

two ends are addressed by this patch: getting rid of some global state and also
restricting --ignorelockingfailure to only allow what it is supposed to allow
(instead of a few hacked-in checks at some places and our belief that the users
will be well-behaved).

Yours,
   Petr.

-------------- next part --------------
A non-text attachment was scrubbed...
Name: ignorelockingfailure.diff
Type: text/x-diff
Size: 6281 bytes
Desc: ignorelockingfailure.diff
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20090122/709daf42/attachment.bin>
-------------- next part --------------

-- 
Peter Rockai | me()mornfall!net | prockai()redhat!com
 http://blog.mornfall.net | http://web.mornfall.net

"In My Egotistical Opinion, most people's C programs should be
 indented six feet downward and covered with dirt."
     -- Blair P. Houghton on the subject of C program indentation
