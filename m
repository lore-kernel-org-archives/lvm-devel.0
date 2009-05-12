From: Milan Broz <mbroz@redhat.com>
Date: Tue, 12 May 2009 17:12:22 +0200
Subject: [PATCH 5/7] Introduce lv_set_visible & lv_set_hidden and use lv_is_visible always.
In-Reply-To: <878wl4u5hz.fsf@eriador.mornfall.net>
References: <cover.1241620083.git.mbroz@redhat.com>	<cover.1241620083.git.mbroz@redhat.com>	<a69d7e8ab6e48759349210e94d8f96495af3f660.1241620083.git.mbroz@redhat.com>
	<878wl4u5hz.fsf@eriador.mornfall.net>
Message-ID: <4A0991D6.5040904@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Petr Rockai wrote:
>> diff --git a/lib/metadata/snapshot_manip.c b/lib/metadata/snapshot_manip.c
>> index cc57aeb..852ad76 100644
>> --- a/lib/metadata/snapshot_manip.c
>> +++ b/lib/metadata/snapshot_manip.c
>> @@ -30,8 +30,11 @@ int lv_is_cow(const struct logical_volume *lv)
>>  
>>  int lv_is_visible(const struct logical_volume *lv)
>>  {
>> +	if (lv->status & SNAPSHOT)
>> +		return 0;
>> +
>>  	if (lv_is_cow(lv))
>> -		return lv_is_visible(find_cow(lv)->lv);
>> +		return lv_is_visible(origin_from_cow(lv));
>>  
>>  	return lv->status & VISIBLE_LV ? 1 : 0;
>>  }
> Why is the latter change included here? Doesn't seem to be directly related to
> the rest of the patch (although I might just be missing something).

This is kind of bugfix, I'll move it to separate patch.

If the query LV is COW, ut returns visibility status of its origin because
the virtual LV (which find_cow(lv)->lv points to) is never set visible in metadata.

But with virtual origin is this assumption wrong, I'll fix it somehow.

Milan


