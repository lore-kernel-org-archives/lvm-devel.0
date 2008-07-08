From: Petr Rockai <prockai@redhat.com>
Date: Tue, 08 Jul 2008 15:23:28 +0200
Subject: [PATCH] (5/5) (experimental) lvconvert --repair
Message-ID: <87r6a4ik6n.fsf@eriador.mornfall.net>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

this last patch implements a (somewhat) experimental lvconvert extension that
presents basis for further hotspare work. It needs user documentation, but
otherwise it seems to work well in my (somewhat limited) testing.

Running lvconvert --repair on a partially broken mirror will remove the missing
legs and/or log. Furthermore, if supplied with a PV list on commandline, it
will replace missing pieces with freshly allocated ones, when enough
allocatable space is available in the supplied PVs.

There is no special "hotspare" allocation policy yet, but when we have one in
place, it should be easy to add automatic hotspare allocation capability to
--repair.

-------------- next part --------------
A non-text attachment was scrubbed...
Name: lvconvert-repair.diff
Type: text/x-diff
Size: 14022 bytes
Desc: lvconvert-repair.diff
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20080708/bf15cb4a/attachment.bin>
-------------- next part --------------

-- 
Peter Rockai | me()mornfall!net | prockai()redhat!com
 http://blog.mornfall.net | http://web.mornfall.net

"In My Egotistical Opinion, most people's C programs should be
 indented six feet downward and covered with dirt."
     -- Blair P. Houghton on the subject of C program indentation
