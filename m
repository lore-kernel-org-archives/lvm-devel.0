From: Milan Broz <mbroz@redhat.com>
Date: Mon, 09 Feb 2009 13:24:18 +0100
Subject: [PATCH] Fix segfault when using vgsplit in stacked environment
In-Reply-To: <498FE109.6000103@redhat.com>
References: <498FE109.6000103@redhat.com>
Message-ID: <49902072.2000507@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Peter Rajnoha wrote:
> diff --git a/lib/activate/activate.c b/lib/activate/activate.c
> index 2bc1db7..4ffd7bb 100644
> --- a/lib/activate/activate.c
> +++ b/lib/activate/activate.c
> @@ -1105,6 +1105,9 @@ int pv_uses_vg(struct physical_volume *pv,
>   	if (!activation())
>   		return 0;
> 
> +	if (!pv->dev || !pv->dev->dev)
> +		return 1;
> +

(answering myself - why "return 1". the function name is misleading for me...)
/*
 * Does PV use VG somewhere in its construction?
 * Returns 1 on failure.
 */
int pv_uses_vg(struct physical_volume *pv,
	       struct volume_group *vg)



Please add something like this to cover it by testsuite
(best add it to already existing vgsplit tests):

. ./test-utils.sh

aux prepare_devs 3

pvcreate $devs
vgcreate $vg1 $dev1 $dev2
lvcreate -n $lv1 -l 100%FREE $vg1

#top VG
pvcreate $G_dev_/$vg1/$lv1
vgcreate $vg $G_dev_/$vg1/$lv1 $dev3

vgchange -a n $vg
vgchange -a n $vg1

# this should fail but not segfault
not vgsplit $vg $vg1 $dev3


Acked-by: Milan Broz <mbroz@redhat.com>
Tested-by: Milan Broz <mbroz@redhat.com>

Milan
--
mbroz at redhat.com


