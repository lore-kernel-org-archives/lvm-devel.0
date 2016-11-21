From: Heinz Mauelshagen <heinzm@redhat.com>
Date: Mon, 21 Nov 2016 17:55:08 +0100
Subject: LVM RAID man page (lvmraid.7)
In-Reply-To: <5ECBB141-6118-4C80-8710-7D7243CA38AB@redhat.com>
References: <5ECBB141-6118-4C80-8710-7D7243CA38AB@redhat.com>
Message-ID: <a04e619d-b8aa-5a06-e140-918099ca757c@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


Jon,

correction to "RAID Synchronization":

MD RAID does not need nor use a write intent bitmap for intial/later
requested resychronization. The array_resync_offset in the dm-raid
superblock is used for dealing with the initial/later resynchronization
(i.e. a moving pointer), not the write intent bitmap.

The purpose of the optional write intent bitmap in MD is to allow
for (temporarily) disappearing component devices avoiding to
resynchronize those completely.
This is handy to cope with transient device absence quicker and
to split/merge a raid1 leg tracking changes.


Addition to "RAID Scrubbing":

one example related to "this may not always be what you want"
would be triggering a scrub which leads to recerating parity
in  raid5 arrays stripe when a data chunk was flawed and
could have been recovered from parity. To be fair: this can't
be discovered without disk sector parity mechnisms such
as DIF (or PI).


Correction to "lvcreate":

s/--type stripe/--type striped/

Heinz


On 05/14/2016 01:23 AM, Brassow Jonathan wrote:
> Before I get to far on this, I?m hoping for some comments.  Feel free to gripe about syntax, but I?m looking especially for feedback on additional topics that may be desired or comments on the general approach (I?m modeling it after lvmthin.7).
>
> Thanks,
>   brassow
>
> Index: lvm2/man/lvmraid.7.in
> ===================================================================
> --- /dev/null
> +++ lvm2/man/lvmraid.7.in
<SNIP>


