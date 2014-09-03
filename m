From: Peter Rajnoha <prajnoha@redhat.com>
Date: Wed, 03 Sep 2014 12:21:15 +0200
Subject: [PATCH] lvconvert: limit lv types for cache use
In-Reply-To: <5406DC10.9020108@redhat.com>
References: <20140902205600.GF374@redhat.com> <5406DC10.9020108@redhat.com>
Message-ID: <5406EB9B.5030806@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 09/03/2014 11:14 AM, Zdenek Kabelac wrote:
> Dne 2.9.2014 v 22:56 David Teigland napsal(a):
>> +static const char *lv_is_name(struct logical_volume *lv)
>> +{
>> +    if (lv_is_external_origin(lv))
>> +        return "external_origin";
>> +
> 
> There is already a reporting function for this with new Petr's patches.
> 
> 

That's the lv_layout_and_role fn. However, this one produces two lists
of strings, not single concatenated string (for both "layout" and "role").
It was designed for reporting lv_layout and lv_role fields originally.
So this would need to be patched a little bit to produce a single string
that is suitable for issuing messages.

But yes, to keep the consistency here, the same identification should be
used for messages too. I'll add a patch for that.

-- 
Peter


