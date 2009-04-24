From: Alasdair G Kergon <agk@redhat.com>
Date: Fri, 24 Apr 2009 01:38:39 +0100
Subject: LVM2/lib/metadata mirror.c
In-Reply-To: <20090423164302.11615.qmail@sourceware.org>
References: <20090423164302.11615.qmail@sourceware.org>
Message-ID: <20090424003839.GC15019@agk.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Thu, Apr 23, 2009 at 04:43:02PM -0000, mornfall at sourceware.org wrote:
> 	A more thorough PV equality test (that also copes better with MISSING_PVs) in
> 	_is_mirror_image_removable.
 
>  			pv_found = 0;
>  			dm_list_iterate_items(pvl, removable_pvs) {
> -				if (pv->dev->dev == pvl->pv->dev->dev) {
> +				if (id_equal(&pv->id, &pvl->pv->id)) {
> +					pv_found = 1;
> +					break;
> +				}
> +				if (pvl->pv->dev && pv->dev &&
> +				    pv->dev->dev == pvl->pv->dev->dev) {
>  					pv_found = 1;
>  					break;
>  				}
 
I'm not at all sure about this: what is your test case that requires the
id_equal() check and fails without it?

(Is there a danger it could match the wrong device, if, say, someone
cloned a PV?)

Alasdair
-- 
agk at redhat.com


