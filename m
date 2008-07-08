From: Petr Rockai <prockai@redhat.com>
Date: Tue, 08 Jul 2008 15:22:34 +0200
Subject: [PATCH] (4/5) partial volume group activation without /dev/ioerror
Message-ID: <87tzf0ik85.fsf@eriador.mornfall.net>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

this patch is mostly orthogonal to the rest of the series. It uses the "error"
target of device-mapper to implement partial volume group activation. This used
to rely on /dev/ioerror, which is often not present on modern systems and is
generally cumbersome. The code will now create error maps of the right size for
each of the missing pieces of storage and use those.

-------------- next part --------------
A non-text attachment was scrubbed...
Name: lib-partial-activation.diff
Type: text/x-diff
Size: 2213 bytes
Desc: lib-partial-activation.diff
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20080708/8351de0b/attachment.bin>
-------------- next part --------------

-- 
Peter Rockai | me()mornfall!net | prockai()redhat!com
 http://blog.mornfall.net | http://web.mornfall.net

"In My Egotistical Opinion, most people's C programs should be
 indented six feet downward and covered with dirt."
     -- Blair P. Houghton on the subject of C program indentation
