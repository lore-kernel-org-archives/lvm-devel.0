From: Jonathan Brassow <jbrassow@redhat.com>
Date: Thu, 6 Oct 2011 11:48:38 -0500
Subject: [PATCH] LVM RAID: Add ability to convert linear to RAID1
In-Reply-To: <1317915480.21095.1.camel@f14.redhat.com>
References: <1317915480.21095.1.camel@f14.redhat.com>
Message-ID: <33FAD028-D1B5-48CC-B224-2D93C3FCF2A3@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


On Oct 6, 2011, at 10:38 AM, Jonathan Brassow wrote:

> The ability to reserve LV names was added to prevent generate_lv_name from
> choosing a name which we want to use in the future.  The need for this comes
> from the required order of steps when converting linear LVs to RAID1, and
> the following constraints:
> 1) We want the linear LV to occupy the first position in the array (*_rimage_0)
> 2) We must allocate the new metadata/data LVs in pairs to allow the allocator
>   to group them together on the same device cleanly.
> 3) The linear LV does not aquire its sub-lv name until insert_layer_for_lv is
>   called.
> 'generate_lv_name' is used in all the above cases to create names for the
> rimage and rmeta LVs.  If we can't reserve the *_rimage_0 name, then the
> rmeta and rimage LV pair names would not match, nor would the converting LV's
> rimage name be correct.

To address some confusion on what it means to 'reserve' a name...

A reserved name is not somehow logged in the LVM metadata.  It is not reserved across commands.

When converting from linear to RAID1, new data images need to be allocated and new metadata images need to be allocated.  (Remember, a new metadata image will be needed as a counterpart to the current linear LV as well.)  For a 3-way RAID1, that would mean allocating 3 metadata areas and 2 data areas.  The convert from linear to a 3-way RAID1 happens in the following way:
1) Start out with a linear LV, "lv"
2) Reserve the name "lv_rimage_0", so that it isn't taken when generate_lv_name is used to allocate the new data images
3) allocate the metadata area that will pair with the current linear LV
4) allocate the metadata/data pairs that will make up the additional images of the RAID1 array.
*) Now we have "lv", "lv_rmeta_[012]", "lv_rimage_[12]", and a in-core reserved name "lv_rimage_0" which isn't yet used.  If we hadn't reserved "lv_rimage_0", the data LVs allocated would have been "lv_rimage_[01]", which would conflict with the name we want for the linear LV that we are going to call 'insert_layer_for_lv' on later.
5) We COMMIT THE METADATA for the sole purpose of allowing us to activate the metadata LVs and clear them
6) clear metadata LVs
7) Create the RAID layer with 'insert_layer_for_lv'.  We specify the reserved name here ("lv_rimage_0") as the name desired for the sub-LV that will result from this function call.
8) Add the metadata and data LVs allocated above to the RAID1 array
9) COMMIT THE METADATA to instantiate the array.

We must not build the RAID before clearing the metadata.  That means not calling 'insert_layer_for_lv' before creating the other images.  That means we must reserve the "lv_rimage_0" name to allow for proper names to be given by 'generate_lv_name' to the new images before using this reserved name in 'insert_layer_for_lv'.

There are three methods to solving this naming problem.  They are:
1) Allow a name to be avoided by generate_lv_name.  This is the method described above.
2) Reorder all the name pointers before committing the final metadata.  This means the intermediate stage will have the wrong names for the data images and they will not match their metadata counterpart.
3) Create a dummy LV with the name "lv_rimage_0" for the sole purpose of reserving the name and deleting it before forming the RAID.  This is essentially the same as #1, but doing it with existing functions and in a much more shitty way.

I'm willing to do #2 if I have to, but I'd prefer #1.

 brassow
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20111006/e2f273a7/attachment.htm>
