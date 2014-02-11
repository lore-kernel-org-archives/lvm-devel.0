From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Tue, 11 Feb 2014 11:25:07 +0100
Subject: RAID: Allow implicit stripe (and parity) when creating RAID LVs
In-Reply-To: <1392074848.17667.3.camel@f16>
References: <1392074848.17667.3.camel@f16>
Message-ID: <52F9FA83.3060300@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 11.2.2014 00:27, Jonathan Brassow napsal(a):
> There are typically 2 functions for the more advanced segment types that
> deal with parameters in lvcreate.c: _get_*_params() and _check_*_params().
> (Not all segment types name their functions according to this scheme.)
> The former function is responsible for reading parameters before the VG
> has been read.  The latter is for sanity checking and possibly setting
> parameters after the VG has been read.
>
> This patch adds a _check_raid_parameters() function that will determine
> if the user has specified 'stripe' or 'mirror' parameters.  If not, the
> proper number is computed from the list of PVs the user has supplied or
> the number that are available in the VG.  Now that _check_raid_parameters()
> is available, we move the check for proper number of stripes from
> _get_* to _check_*.
>
> This gives the user the ability to create RAID LVs as follows:
> # 5-device RAID5, 4-data, 1-parity (i.e. implicit '-i 4')
> ~> lvcreate --type raid5 -L 100G -n lv vg /dev/sd[abcde]1
>
> # 5-device RAID6, 3-data, 2-parity (i.e. implicit '-i 3')
> ~> lvcreate --type raid6 -L 100G -n lv vg /dev/sd[abcde]1
>
> # If 5 PVs in VG, 5-device RAID5
> ~> lvcreate --type raid5 -L 100G -n lv vg
>

I guess you can't change the stable command line API - since you would break
all existing scripts.

What you could probably do is to add new  command line option like i.e.:

--bestfit

or something similar with this meaning.

Zdenek


