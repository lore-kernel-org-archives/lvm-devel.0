From: Jonathan Brassow <jbrassow@redhat.com>
Date: Thu, 17 Dec 2009 09:19:55 -0600
Subject: [PATCH] Fix removal of multiple devices from a mirror.
In-Reply-To: <3A47411F-602F-4977-9DC1-15807E32284B@redhat.com>
References: <871vitg13y.fsf@twilight.int.mornfall.net.>
	<3A47411F-602F-4977-9DC1-15807E32284B@redhat.com>
Message-ID: <F4B3A3FF-2135-47E7-9A49-25A6416187C0@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This new patch achieves the same result as the old one in a simpler way.

ACK.

  brassow

On Dec 17, 2009, at 8:50 AM, Jonathan Brassow wrote:

> Is this problem still present after applying the previous patch:
> https://www.redhat.com/archives/lvm-devel/2009-November/msg00043.html
>
> The above patch was posted to fix a problem with specified PVs not  
> being handled properly.
> brassow
>
> On Dec 17, 2009, at 7:51 AM, Petr Rockai wrote:
>
>> Hi,
>>
>> the code for removing mirror images, as it is, shifts the first  
>> failed
>> leg twice and fails to shift the second failed one at all, which
>> reorders the mirror image array in such a way that a wrong leg is
>> removed as a result.
>>
>> The trivial patch below fixes that behaviour by adjusting the array
>> pointer to accommodate for the shift. Fixes RHBZ 543225.
>>
>> Yours,
>>  Petr.
>>
>> Index: lib/metadata/mirror.c
>> ===================================================================
>> RCS file: /cvs/lvm2/LVM2/lib/metadata/mirror.c,v
>> retrieving revision 1.99
>> diff -u -p -r1.99 mirror.c
>> --- lib/metadata/mirror.c	9 Dec 2009 19:53:39 -0000	1.99
>> +++ lib/metadata/mirror.c	17 Dec 2009 13:43:30 -0000
>> @@ -533,6 +533,7 @@ static int _remove_mirror_images(struct
>> 			    _is_mirror_image_removable(sub_lv, removable_pvs)) {
>> 				if (!shift_mirror_images(mirrored_seg, s))
>> 					return_0;
>> +				s--; /* adjust counter after shifting */
>> 				new_area_count--;
>> 			}
>> 		}
>>
>> --
>> lvm-devel mailing list
>> lvm-devel at redhat.com
>> https://www.redhat.com/mailman/listinfo/lvm-devel
>
> --
> lvm-devel mailing list
> lvm-devel at redhat.com
> https://www.redhat.com/mailman/listinfo/lvm-devel


