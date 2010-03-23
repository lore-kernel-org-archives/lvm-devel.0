From: Petr Rockai <prockai@redhat.com>
Date: Tue, 23 Mar 2010 19:03:33 +0100
Subject: [PATCH 2 of 12] LVM: testsuite fixes 2
In-Reply-To: <201003182053.o2IKr7AX024453@hydrogen.msp.redhat.com> (Jonathan
	Brassow's message of "Thu, 18 Mar 2010 15:53:07 -0500")
References: <201003182053.o2IKr7AX024453@hydrogen.msp.redhat.com>
Message-ID: <87bpee6hl6.fsf@twilight.int.mornfall.net.>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

Jonathan Brassow <jbrassow@redhat.com> writes:
> Flip the 'not' on a test that should be working.
>
> Index: LVM2/test/t-lvconvert-repair.sh
> ===================================================================
> --- LVM2.orig/test/t-lvconvert-repair.sh
> +++ LVM2/test/t-lvconvert-repair.sh
> @@ -69,5 +69,5 @@ vgextend $vg $dev3
>  lvcreate -m 2 -l 1 -n mirror2 $vg $dev1 $dev2 $dev3 $dev4
>  vgchange -a n $vg
>  pvremove -ff -y $dev4
> -echo 'y' | not lvconvert -y -i 1 --repair $vg/mirror2
> +echo 'y' | lvconvert -y -i 1 --repair $vg/mirror2
>  vgs
now, this is interesting. Any idea why the lvconvert used to fail and
now passes?  It seems there's $dev5 around, so this should be used for
the repair... I'll look at the later patches, maybe that'll explain...

Yours,
   Petr.


