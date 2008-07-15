From: Petr Rockai <prockai@redhat.com>
Date: Tue, 15 Jul 2008 17:26:46 +0200
Subject: [PATCH] partial activation revisited
Message-ID: <87fxqbyxqh.fsf@eriador.mornfall.net>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

I have added backward compatibility for missing_stripe_filler. We will almost
surely want to flip the value to "error" in default configuration file, as the
tools will cry bloody murder if it is set to an invalid device (which
/dev/ioerror is, in most setups). I'll likely make it only print the warning if
partial activation is actually used, but I need to rework some more code first
(since right now, partial activation is determined by partial_mode(), which I
want to get rid of... since it is not compatible with how we now treat volume
groups with missing PVs nowadays).

The patch now actually passes tests, and merged with my experimental lvconvert
code yields working combination (now, that those bugs have been
addressed). I'll give lvconvert a little more time and post revised version as
well.

User documentation is TBD (that includes the default configuration change).

-------------- next part --------------
A non-text attachment was scrubbed...
Name: a.diff
Type: text/x-diff
Size: 6819 bytes
Desc: lib-partial_activation.diff
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20080715/903f8088/attachment.bin>
-------------- next part --------------

-- 
Peter Rockai | me()mornfall!net | prockai()redhat!com
 http://blog.mornfall.net | http://web.mornfall.net

"In My Egotistical Opinion, most people's C programs should be
 indented six feet downward and covered with dirt."
     -- Blair P. Houghton on the subject of C program indentation
