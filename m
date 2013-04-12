From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Fri, 12 Apr 2013 17:51:31 +0200
Subject: [PATCH 1/2] lvm2app: Add function to retrieve the origin.
In-Reply-To: <51682BCB.6070504@redhat.com>
References: <1365713931-12666-1-git-send-email-tasleson@redhat.com>
	<5167C42E.4000407@redhat.com> <51682BCB.6070504@redhat.com>
Message-ID: <51682D83.4090506@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 12.4.2013 17:44, Tony Asleson napsal(a):
> On 04/12/2013 03:22 AM, Zdenek Kabelac wrote:
>> If you need just 'const' pointer - it would be probably better,
>> to directly return the name - instead of duplication.
>
> Agreed.
>
>> i.e. lv_origin_dup() ->  rewrite to  'const char *lv_get_origin(.)' ->
>> and use it for  lv_name_dup() in lv_origin_dup() which returns char *.
>> as well as for  lvm_lv_get_origin().
>
> I ran into at least 2 different implementations of *get_origin.  There
> is lv_origin_dup() and _origin_disp.  Both utilize the same logic with
> slightly different output.  I haven't looked around it see if there are
> others.
>
> To clean this up correctly I would want to write what you are suggesting
> and then use it in all the different places.
>

Yep, that would be very useful - since we already do a tons of useless string 
duplication - we should try to avoid a new set of those ;)

There are many more places, where we could be happy with just const reference,
since the lifetime of object is clearly defined and parent object cannot be 
removed/changed, so there is no benefit of using duplicate copies.

Regards

Zdenek


