From: Petr Rockai <prockai@redhat.com>
Date: Wed, 20 Mar 2013 12:11:44 +0100
Subject: [Red Hat - Possible Forgery] Re: [PATCH] Pass parsed metadata to activation code.
In-Reply-To: <51497C6A.80500@redhat.com> (Zdenek Kabelac's message of "Wed, 20
	Mar 2013 10:07:54 +0100")
References: <8738vrc634.fsf@mornfall.net> <51497C6A.80500@redhat.com>
Message-ID: <87vc8mba1b.fsf@mornfall.net>
	(sfid-20130320_121144_738393_FC76BC72)
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi there,

Zdenek Kabelac <zkabelac@redhat.com> writes:
> I've went into very quick overview - would it be possible to split some
> patches into   'rename/clean old code'  'add new functionality' ?

I don't see any places where "cleaning old code" is being done. Can you
point out which bits you mean?

> Also - how does the new solution 'scales' in terms of having thousands of LVs
> in the metadata - I've noticed couple new linear scans 'dm_list_iterate()'. The
> trick with  lv_ondisk() code is not yet very clean to me - will need to find
> some time for this - it seems to be adding new complexity in the code.

lv_ondisk is trivial, it just finds the same LV you are using in the
"ondisk" version of its metadata; the "ondisk" version of VG is just
that: the struct volume_group that came pristine from vg_read, or after
you vg_commit, the version that has been committed.

For iteration, yes, it does a linear scan, but not a "new" one. You
either call lv_ondisk OR you call lv_from_lvid. Both do a single linear
scan through the list of LVs. In fact, for suspend, the old code does 2
such scans while the new code only does one. So the net result is quite
the opposite, there's one iteration less and no new ones.

Petr

-- 
id' Ash = Ash; id' Dust = Dust; id' _ = undefined


