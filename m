From: Dave Wysochanski <dwysocha@redhat.com>
Date: Mon, 22 Nov 2010 23:14:05 -0500
Subject: wishlist: Two lvm2app pv and lv properties still needed
In-Reply-To: <201011221503.26030.benscott@nwlink.com>
References: <20101122213948.11757.qmail@sourceware.org>
	<201011221503.26030.benscott@nwlink.com>
Message-ID: <1290485645.31336.12.camel@f12-work>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Mon, 2010-11-22 at 15:03 -0800, ben wrote:
> When using lvm2app function calls to retrieve physical volume segment 
> properties there seems to be no way the get the "lv_name" to tie each segment 
> of the pv to an lv. For instance like this:
> 
> pvs --segments -o+lv_name
>   PV         VG    Fmt  Attr PSize   PFree   Start SSize LV   
>   /dev/sdh1  local lvm2 a-   768.00m 512.00m     0     1      
>   /dev/sdh1  local lvm2 a-   768.00m 512.00m     1     1 lvol1
>   /dev/sdh1  local lvm2 a-   768.00m 512.00m     2     1      
>   /dev/sdi1  local lvm2 a-   768.00m      0      0     3 lvol2
> 

Right - lvm2app currently doesn't cover every combination of fields
exactly like the reporting commands.  However, you should be able to get
the info in another way (see below).

Also, we may need some futher function "helpers" to enumerate certain
lvm objects from other objects (as the recent patches I submitted to
lookup a lv/pv handle from a name or uuid).  For instance, we may want
to provide a function to lookup an lv from a pv_segment.


> The same seems to apply to getting lv segments properties and their 
> asscociated devices.   Like this:
> 
>  lvs -o+devices
>   LV    VG    Attr   LSize    Devices
>   lvol1 local -wi-a- 256.00m  /dev/sdh1(1)
>   lvol2 local -wi-a- 768.00m  /dev/sdi1(0)
> 

Patches have been submitted to lvm-devel to cover 'devices' and
'seg_pe_ranges'.



