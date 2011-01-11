From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Tue, 11 Jan 2011 11:32:10 +0100
Subject: [PATCH 2 of 4] LVM: cleanup 2
In-Reply-To: <201101102056.p0AKucDj011961@hydrogen.msp.redhat.com>
References: <201101102056.p0AKucDj011961@hydrogen.msp.redhat.com>
Message-ID: <4D2C31AA.20106@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 10.1.2011 21:56, Jonathan Brassow napsal(a):
> Patch name: lvm-cleanup-2.patch
> 
> The check for segtype_is_virtual is done at the top of the function,
> no need to do it again at the bottom.
> 
> 
> Index: LVM2/lib/metadata/lv_manip.c
> ===================================================================
> --- LVM2.orig/lib/metadata/lv_manip.c
> +++ LVM2/lib/metadata/lv_manip.c
> @@ -1557,8 +1557,7 @@ struct alloc_handle *allocate_extents(st
>  			       parallel_areas)))
>  		return_NULL;
>  
> -	if (!segtype_is_virtual(segtype) &&
> -	    !_allocate(ah, vg, lv, 1, allocatable_pvs)) {
> +	if (!_allocate(ah, vg, lv, 1, allocatable_pvs)) {
>  		alloc_destroy(ah);
>  		return_NULL;
>  	}
> 

Ack

Zdenek


