From: Jonathan Brassow <jbrassow@redhat.com>
Date: Thu, 7 Apr 2011 16:36:24 -0500
Subject: LVM2 lib/metadata/lv_manip.c lib/metadata/meta ...
In-Reply-To: <4D9E2028.4030109@redhat.com>
References: <20110406213222.10912.qmail@sourceware.org>	<4D9DA98D.2000007@redhat.com>
	<7BF6E37A-25E5-4F8A-AC90-461D9AE26EF8@redhat.com>
	<4D9E2028.4030109@redhat.com>
Message-ID: <FF64CF2A-1514-44FC-AE50-A867C8CB2866@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


On Apr 7, 2011, at 3:35 PM, Zdenek Kabelac wrote:

> Dne 7.4.2011 17:20, Jonathan Brassow napsal(a):
>> 
>> On Apr 7, 2011, at 7:09 AM, Zdenek Kabelac wrote:
>> 
>>>> +
>>>> +	dm_pool_free(lv->vg->cmd->mem, img_name);
>>> 
>>> 
>>> Aren't you experiencing random crashes with this  dm_pool_free() ?
>>> It removes also all objects allocated past this img_name.
>>> (Also I think there is already an internal function for building such names)
>> 
>> No crashes so far... I haven't run into that while running through the test suite or my by-hand tests.  Why would I expect that kind of behavior?
> 
> See the comment for dm_pool_free() in libdevmapper.h
> As you are allocating LV after img_name - by this pool you are effectively
> removing all memory allocated in VG pool after.

Thank-you for mentioning this!  Gah.  Alright, I'll fix that.  I'm surprised too now that I haven't seen problems.

> 
>> 
>> Also, do you know what the name of the internal function would be to replace my 'alloc, fill with template name, create empty lv's, free' sequence?
>> 
> 
> Ok - it looks like for _mimage_ - there is not yet one - so as there are
> already 3 other placed - it might be forth to create one for this purpose.
> 
> (Also note - in other case we are already using simplier ,"%s_mimage_%%d",
> (see the _split_mirror_images() in mirror.c)

Well, there are a couple different things going on in _split_mirror_images.  In one case, the space is created at the time the variable is declared ('format' is allocated on the stack).  In the other, that string ("_mimage_%d") is passed to a function.

In this case, I could easily create the space for img_name on the stack, i think.

 brassow



