From: Takahiro Yasui <takahiro.yasui@hds.com>
Date: Wed, 30 Jun 2010 15:37:11 -0400
Subject: [PATCH] Fix read-only warning for partial volume
In-Reply-To: <20100630164624.GP23989@agk-dp.fab.redhat.com>
References: <20100630004903.GM23989@agk-dp.fab.redhat.com>
	<5C30BE7ED8B03E448B2E104602D4848A59228864C3@USINDEVS02.corp.hds.com>,
	<20100630164624.GP23989@agk-dp.fab.redhat.com>
Message-ID: <5C30BE7ED8B03E448B2E104602D4848A59228864C7@USINDEVS02.corp.hds.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 06/30/10 12:46, Alasdair G Kergon wrote:
> On Wed, Jun 30, 2010 at 12:25:00PM -0400, Takahiro Yasui wrote:
>>   Partial mode. Incomplete volumes will be activated.
> 
> log_print("Partial mode. Incomplete logical volumes will be processed.");
> 
> Yes, the focus is on LVs not VGs

Thank you for committing it.

> As MISSING_PV handling has become default behaviour, what *extra* does
> --partial offer?

The latest lvm command works as you mentioned only when a logical volume
is on valid physical volumes, but lvchange or vgchange fails if a logical volume
contains invalid devices. In that case, we still  need --partial option.

For example, LV is on PV1 and PV2 for linear, stripe or mirror, and PV2 is
missing. With --partial option, we can activate LV and read/write it. This is
very important especially for mirror volume.

It is ideal that a logical volume can be activated without --partial option.
And in that case,  we don't need --partial option.

Thanks,
Taka


