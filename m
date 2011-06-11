From: Amir G. <amir73il@users.sourceforge.net>
Date: Sat, 11 Jun 2011 12:44:16 +0300
Subject: LVM vs. Ext4 snapshots (was: [PATCH v1 00/30] Ext4 snapshots)
In-Reply-To: <843433D5F73C864182AC91B8@nimrod.local>
References: <BANLkTimyBGfg4+ovGsiGqpCz345qVmU_7A@mail.gmail.com>
	<BANLkTik20iYN4c9faKD9dzerehazWTwTFw@mail.gmail.com>
	<BANLkTikKRuPu_NX49vr0w-XeN0ZnWo+9vg@mail.gmail.com>
	<alpine.LFD.2.00.1106101101020.4502@dhcp-27-109.brq.redhat.com>
	<20110610101142.GA10144@ubuntu>
	<BANLkTi=zjU3-FV3AVpYsknzKFgaS7byb_Q@mail.gmail.com>
	<20110610150129.GA17585@ubuntu>
	<BANLkTikUZadpVJRcfX_MLMZ-p_G0bT_8uQ@mail.gmail.com>
	<20110611074908.GC2517@ubuntu>
	<843433D5F73C864182AC91B8@nimrod.local>
Message-ID: <BANLkTik8Oac+5Ci7Y9VvNUqv-DaYmPkWZA@mail.gmail.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Sat, Jun 11, 2011 at 11:18 AM, Alex Bligh <alex@alex.org.uk> wrote:
>
>
> --On 11 June 2011 08:49:08 +0100 Joe Thornber <thornber@redhat.com> wrote:
>
>> I am also convinced multisnap wont be suitable for every use case.
>
> I'm surprised by one thing ext 4 snapshots doesn't seem to do: I would have
> thought the "killer feature" for doing snapshots in the fs rather than in
> the block layer would be the ability to snapshot - and more importantly
> roll back - only parts of the directory hierarchy.
>
> (I've only read the URLs Amir sent, so apologies if I've missed this)
>

No need for apologies.
There is no per-directory snapshot nor rollback with ext4 snpshots.
It is possible to configure a part of the directory hierarchy to be excluded
from future snapshots, but not to delete it selectively from past snapshots.

Amir.


