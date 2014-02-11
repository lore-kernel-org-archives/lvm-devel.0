From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Tue, 11 Feb 2014 11:28:27 +0100
Subject: [PATCH] allocation: Allow "fuzzy" allocation when specifying size in percent
In-Reply-To: <1392074997.17667.6.camel@f16>
References: <1392074997.17667.6.camel@f16>
Message-ID: <52F9FB4B.80400@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 11.2.2014 00:29, Jonathan Brassow napsal(a):
> This patch is still a bit rough around the edges and needs accompanying
> tests before in can be checked-in.  If there are no objections to it,
> I'll clean it up a bit more and add the tests.
>
>   brassow
>
>
> Introduce a new parameter called "fuzzy_alloc" that is set when the
> desired size of a new LV is specified in percentage terms.  If set,
> the allocation code tries to get as much space as it can but does not
> fail if can at least get some.
>
> One of the practical implications is that users can now specify 100%FREE
> when creating RAID LVs, like this:
> ~> lvcreate --type raid5 -l 100%FREE -n lv vg
>
> (The stripe count is computed implicitly due to a previous patch, and
> the full size of the PVs in the VG is used.)
>

I wouldn't call it  'fuzzy' - I guess we've discussed something like -
extent exact or up-to given number of extents allocation


Zdenek





