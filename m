From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Thu, 20 Jan 2011 11:29:52 +0100
Subject: LVM2/test t-lvconvert-repair-policy.sh
In-Reply-To: <20110119192207.5486.qmail@sourceware.org>
References: <20110119192207.5486.qmail@sourceware.org>
Message-ID: <4D380EA0.60108@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 19.1.2011 20:22, jbrassow at sourceware.org napsal(a):
> CVSROOT:	/cvs/lvm2
> Module name:	LVM2
> Changes by:	jbrassow at sourceware.org	2011-01-19 19:22:07
> 
> Modified files:
> 	test           : t-lvconvert-repair-policy.sh 
> 
> Log message:
> 	Add test to make sure that a log device is retained when a
> 	mirror image fails and the policies are set to:
> 	mirror_image_fault_policy = "replace"
> 	mirror_log_fault_policy = "remove"
> 
> Patches:
> http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-lvconvert-repair-policy.sh.diff?cvsroot=lvm2&r1=1.7&r2=1.8
> 
> --- LVM2/test/t-lvconvert-repair-policy.sh	2011/01/11 17:05:09	1.7
> +++ LVM2/test/t-lvconvert-repair-policy.sh	2011/01/19 19:22:07	1.8
> @@ -39,6 +39,14 @@
>  cleanup $dev1
>  
>  # Fail a leg of a mirror.
> +# Expected result: Mirror (leg replaced, should retain log)
> +aux disable_dev $dev1
> +repair 'activation { mirror_image_fault_policy = "replace" mirror_log_fault_policy = "remove" }'
> +check mirror $vg mirror
> +lvs | grep mirror_mlog

This will not work properly on systems which are already running lvm. (i.e.
even second test running in parallel).

Test needs to check explicitly for devices it has created - so always add VGs
or PVs on its command line.

Please check more lib/check.sh functions - I assume you want to use active().


>  check mirror $vg mirror
>  lvs | grep mirror_mlog

Same

Zdenek


