From: Stas Sergeev <stsp@aknet.ru>
Date: Fri, 05 Dec 2008 18:16:38 +0300
Subject: broken vg after vgconvert -M1
In-Reply-To: <20081205125711.GA26097@agk.fab.redhat.com>
References: <49391424.8090505@aknet.ru>
	<20081205125711.GA26097@agk.fab.redhat.com>
Message-ID: <493945D6.2080205@aknet.ru>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Alasdair G Kergon wrote:
> To recover, you should: update to a newer version such as 2.02.42 or 2.02.43,
> find a suitable metadata backup file, edit it to ensure the LV UUIDs are
> compatible with LVM1 (ie small consecutive numbers with leading zeroes)
> then use vgcfgrestore.
Thanks. The backup is hopefully still there
on that broken lvm partition. I'll try to
extract it from the raw partition dump.

> Yes - in that your metadata was incompatible with LVM1
> and the tool previously stopped you from doing the conversion,
> albeit by crashing instead of giving you a nice error.
I think this is just a coincidence. It
crashed not after the first invocation
of lvnum_from_lvid(). Most calls to it
used to return the large positive numbers.
Only one uuid was giving the negative,
hence the crash. Without that uuid, it
would convert even without the patch, I
think.
The patch only prevents the negative
values, but gives the huge positive
values instead - why it didn't complain
and let it to convert then? All the other
instances of lvnum are of uint32_t too.
Also, I think there can be the uuids that
will give the small positive numbers after
overflow, so expecting the large values
is probably unreliable.
So is this really an expected behaveour
to allow the conversion when lvnum is a
huge positive value? That's just what
happened in my case, and I am trying to
make sure there is no bug elsewhere and
that it was really just my patch.


