From: Petr Rockai <prockai@redhat.com>
Date: Tue, 23 Mar 2010 19:07:19 +0100
Subject: [PATCH 1 of 12] LVM: testsuite fixes
In-Reply-To: <201003182052.o2IKquKo024380@hydrogen.msp.redhat.com> (Jonathan
	Brassow's message of "Thu, 18 Mar 2010 15:52:56 -0500")
References: <201003182052.o2IKquKo024380@hydrogen.msp.redhat.com>
Message-ID: <877hp26hew.fsf@twilight.int.mornfall.net.>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

Jonathan Brassow <jbrassow@redhat.com> writes:
> [I still have my concerns about the way only one of the two
>  available policy specifications is stated when 'repair' is
>  called.  This means we really don't know what the policy is
>  for the one that isn't specified.]
Well, it means that if the default is flipped, tests start failing and
you explicitly have to confirm your defaults change. I think that's
reasonable.

> Index: LVM2/test/t-lvconvert-repair-policy.sh
> ===================================================================
> --- LVM2.orig/test/t-lvconvert-repair-policy.sh
> +++ LVM2/test/t-lvconvert-repair-policy.sh
> @@ -13,12 +13,15 @@
>  
>  prepare_vg 4
>  
> +# Clean-up and create a 2-way mirror, where the the
> +# leg devices are always on $dev[12] and the log
> +# is always on $dev3.  ($dev4 behaves as a spare)
>  cleanup() {
>  	vgreduce --removemissing $vg
>  	for d in "$@"; do enable_dev $d; done
>  	for d in "$@"; do vgextend $vg $d; done
>  	lvremove -ff $vg/mirror
> -	lvcreate -m 1 -L 1 -n mirror $vg
> +	lvcreate -m 1 -L 1 -n mirror $vg $dev1 $dev2 $dev3:0
Maybe it should say -l 2 or something, to make it more explicit that
$dev3:0 means that $dev3 ends up holding the log.

[cut]
> -disable_dev $dev2 $dev4
> -# no room for new log, corelog conversion should happen
> +# Fail the log device of a mirror w/ no available spare
> +# Expected result: mirror w/ corelog
> +disable_dev $dev3 $dev4
>  repair 'activation { mirror_image_fault_policy = "replace" }'
>  lvs
>  lvs | grep -- mwi-a-
>  lvs | not grep mirror_mlog
> -cleanup $dev2 $dev4
> +cleanup $dev3 $dev4

ACK (also, can go in right away)

Yours,
   Petr.


