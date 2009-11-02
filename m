From: Petr Rockai <prockai@redhat.com>
Date: Mon, 02 Nov 2009 16:43:06 +0100
Subject: [PATCH] Un-export vg_read_internal.
Message-ID: <87eiohq6et.fsf@twilight.int.mornfall.net.>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

this was waiting a fairly long time for a round tuit, but here it is. This
should properly banish vg_read_internal into confinement in metadata.c. Should
be fairly obvious, I am just being paranoid here. (I made sure clvmd still
compiles this time, too.)

Yours,
   Petr.

-------------- next part --------------
A non-text attachment was scrubbed...
Name: unexport-vg_read_internal.diff
Type: text/x-diff
Size: 5412 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20091102/217e6e45/attachment.bin>
