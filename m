From: Milan Broz <mbroz@redhat.com>
Date: Wed, 08 Apr 2009 13:15:09 +0200
Subject: [PATCH 4/6] vg mempool: fix archiver code
In-Reply-To: <87skkk9hlk.fsf@eriador.mornfall.net>
References: <49D9BE34.4010308@redhat.com> <87skkk9hlk.fsf@eriador.mornfall.net>
Message-ID: <49DC873D.6010301@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Petr Rockai wrote:
> Milan Broz <mbroz@redhat.com> writes:
>> +	vg_release(vg);
> Check. Actually looks much more robust. While looking through the code, I have
> noticed that there is likely still a leak in there though, since
> create_text_context will call dm_pool_alloc/dm_pool_strdup a few times. If I
> understand dm_pool_free correctly, this only frees the part of the pool from
> the "vg" pointer till end of the pool, so the leak has been there even
> before. You might want to fix that by calling dm_pool_free(cmd->mem, context)
> besides the vg_release. (This all needs double-checking though.)

There are more such places in code for sure, some structures are even allocated
from global mempool still. (I have at least one more patch in my queue).

But this can be fixed in subsequent patches - my main intention was to put
vg_release to correct places in code (otherwise it will leak the whole pool).

Milan


