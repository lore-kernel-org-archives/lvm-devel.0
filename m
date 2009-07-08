From: Petr Rockai <prockai@redhat.com>
Date: Wed, 08 Jul 2009 11:18:55 +0200
Subject: [PATCH] unknown segment types, part 1
Message-ID: <87ljmzcz28.fsf@twilight.int.mornfall.net.>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

the attached patch makes LVM handle unknown segment types by a simple
copy-through mechanism, i.e. whenever an unknown segment is encountered, it is
left intact (and preserved) by LVM. We may still want to limit changes to LVs
that contain unknown segments, and maybe even some heuristic to find LV
references in unknown segments (hard to tell).

There's also one thread-unsafe bit in the patch, that's not so hard to fix, but
I'll do that when we know that this is the right direction we want to take.

(The patch itself will probably need another iteration. Consider this to be a
draft.)

Yours,
   Petr.

-------------- next part --------------
A non-text attachment was scrubbed...
Name: lvm-unknown-segments.diff
Type: text/x-diff
Size: 13574 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20090708/e77bc47c/attachment.bin>
