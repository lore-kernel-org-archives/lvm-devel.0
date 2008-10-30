From: Petr Rockai <prockai@redhat.com>
Date: Thu, 30 Oct 2008 19:23:11 +0100
Subject: [PATCH] (9/11) bring vgreduce up to date with API changes
Message-ID: <87r65y2b8w.fsf@eriador.mornfall.net>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

this here accumulates the changes over vgreduce, since those had some conflicts
with the hotspare branch that has been running sort of parallel to this. It
should be fairly straightforward here. Mostly just removes uses of
vg_read_internal and replaces them with new-style API.

Yours,
   Petr.

-------------- next part --------------
A non-text attachment was scrubbed...
Name: lvm2-lvmlib-vgreduce.diff
Type: text/x-diff
Size: 6955 bytes
Desc: lvmlib-vgreduce.diff
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20081030/2c80977c/attachment.bin>
-------------- next part --------------

-- 
Peter Rockai | me()mornfall!net | prockai()redhat!com
 http://blog.mornfall.net | http://web.mornfall.net

"In My Egotistical Opinion, most people's C programs should be
 indented six feet downward and covered with dirt."
     -- Blair P. Houghton on the subject of C program indentation
