From: Petr Rockai <prockai@redhat.com>
Date: Thu, 01 Jul 2010 12:07:58 +0200
Subject: [RFC][PATCH] lvm2: limit accesses to broken devices (v2)
In-Reply-To: <5C30BE7ED8B03E448B2E104602D4848A59228864C9@USINDEVS02.corp.hds.com>
	(Takahiro Yasui's message of "Wed, 30 Jun 2010 17:20:36 -0400")
References: <5C30BE7ED8B03E448B2E104602D4848A59228864BC@USINDEVS02.corp.hds.com>
	<8739w4lly6.fsf@twilight.int.mornfall.net.>
	<5C30BE7ED8B03E448B2E104602D4848A59228864C9@USINDEVS02.corp.hds.com>
Message-ID: <87wrtfikg1.fsf@twilight.int.mornfall.net.>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Takahiro Yasui <takahiro.yasui@hds.com> writes:

> As far as I understand, return_0 is for debugging of unexpected errors.
> This is not a logical error, so I didn't used "return_0" here.
Well, actually, return_0 is useful to track why something is failing. I
would say that situations may arise where someone will be wondering why
is that particular read failing (the notice about disabling the device
may be buried a long way ahead of the failing read).

>> Hmm. Should write errors count towards this? What happens if the device
>> just rejects writes -- could this break code by yanking the device
>> completely? This means, IIUIC, that any subsequent rescan that may
>> happen won't see the device even if the failure was due to failing
>> writes and the device reads just fine.
>
> I haven't seen the case that a device accepts read I/Os but rejects
> write I/Os, but the opposite case could happen. I heard that some
> devices re-allocated a bad sector when a write I/O came to devices.
You are probably right -- I was probably thinking of a device going
read-only for some reason, but if you say this does not happen in
practice, I won't oppose: you have certainly more experience with
real-life hardware.

> Again, thank you for reviewing this patch, Petr.
With the provision that the default stays to 0 (unlimited), I guess the
patch is OK to go in.

Reviewed-By: Petr Rockai <prockai@redhat.com>

Yours,
   Petr.


