From: Takahiro Yasui <takahiro.yasui@hds.com>
Date: Wed, 30 Jun 2010 12:25:00 -0400
Subject: [PATCH] Fix read-only warning for partial volume
In-Reply-To: <20100630004903.GM23989@agk-dp.fab.redhat.com>
References: <5C30BE7ED8B03E448B2E104602D4848A59228864C1@USINDEVS02.corp.hds.com>,
	<20100630004903.GM23989@agk-dp.fab.redhat.com>
Message-ID: <5C30BE7ED8B03E448B2E104602D4848A59228864C3@USINDEVS02.corp.hds.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Alasdair,

On 06/29/10 20:49, Alasdair G Kergon wrote:
>>  Partial mode. Incomplete volume groups will be activated read-only.
> We should probably replace that with a more-accurate description.

Incomplete volumes aren't be necessarily activated in read-only mode.
So just removing a word "read-only" is fine to me. Other point is this
message is displayed not only by "vgchange -ay" but also "lvchange -ay"
and a word "groups" is not necessary.

My suggestion is

  Partial mode. Incomplete volumes will be activated.

Appreciate your comments.

Thanks,
Taka


