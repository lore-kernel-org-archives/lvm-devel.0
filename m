From: Milan Broz <mbroz@redhat.com>
Date: Thu, 09 Jul 2009 19:27:43 +0200
Subject: [PATCH] unknown segment types, part 1
In-Reply-To: <87ljmzcz28.fsf@twilight.int.mornfall.net.>
References: <87ljmzcz28.fsf@twilight.int.mornfall.net.>
Message-ID: <4A56288F.4080604@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Petr Rockai wrote:
> the attached patch makes LVM handle unknown segment types by a simple
> copy-through mechanism, i.e. whenever an unknown segment is encountered, it is
> left intact (and preserved) by LVM. We may still want to limit changes to LVs
> that contain unknown segments, and maybe even some heuristic to find LV
> references in unknown segments (hard to tell).
> 
> There's also one thread-unsafe bit in the patch, that's not so hard to fix, but
> I'll do that when we know that this is the right direction we want to take.
> 
> (The patch itself will probably need another iteration. Consider this to be a
> draft.)

After short testing (yes, there are nice bugs :-) I have several questions:

- Why activate "unknown" segment by replacing it by error segment?
I think that ignoring LV including unknown segment (with some error message)
but not activate is better.

Or use some configurable option? 

- Do we want code to preserve (read: kill unknown options) metadata when
segment handler is not loaded?

Isn't better just allow only read-only metadata operation
(so "unknown" segment will appear only in-memory metadata, never on-disk).

Possibly add some option to vgck to "fix" unknown segments.

Milan


