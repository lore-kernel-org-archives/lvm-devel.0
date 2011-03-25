From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Fri, 25 Mar 2011 23:10:38 +0100
Subject: LVM2/lib/metadata lv_manip.c
In-Reply-To: <20110325220227.12947.qmail@sourceware.org>
References: <20110325220227.12947.qmail@sourceware.org>
Message-ID: <4D8D12DE.1000306@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 25.3.2011 23:02, jbrassow at sourceware.org napsal(a):
> CVSROOT:	/cvs/lvm2
> Module name:	LVM2
> Changes by:	jbrassow at sourceware.org	2011-03-25 22:02:27
> 
> Modified files:
> 	lib/metadata   : lv_manip.c 
> 
> Log message:
> 	Fix unhandled condition in _move_lv_segments
> 	
> 	If _move_lv_segments is passed a 'lv_from' that does not yet
> 	have any segments, it will screw things up because the code
> 	that does the segment copy assumes there is at least one
> 	segment.  See copy code here:
> 	lv_to->segments = lv_from->segments;
> 	lv_to->segments.n->p = &lv_to->segments;
> 	lv_to->segments.p->n = &lv_to->segments;
> 	
> 	If 'segments' is an empty list, the first statement copies over
> 	the values, but the next two reset those values to point to the
> 	other LV's list structure.  'lv_to' now appears to have one
> 	segment, but it is really an ill-set pointer.
> 
> Patches:
> http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.251&r2=1.252
> 
> --- LVM2/lib/metadata/lv_manip.c	2011/02/28 19:53:03	1.251
> +++ LVM2/lib/metadata/lv_manip.c	2011/03/25 22:02:27	1.252
> @@ -2950,7 +2950,8 @@
>  		}
>  	}
>  
> -	lv_to->segments = lv_from->segments;
> +	if (!dm_list_empty(&lv_from->segments))
> +		lv_to->segments = lv_from->segments;
>  	lv_to->segments.n->p = &lv_to->segments;
>  	lv_to->segments.p->n = &lv_to->segments;
>  

Sounds like you actually want to use:
  dm_list_splice(&lv_to->segments, &lv_from->segments);

(there are probably more area where splice should be use for move operations
in the code).


Zdenek


