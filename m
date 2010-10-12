From: Petr Rockai <prockai@redhat.com>
Date: Tue, 12 Oct 2010 12:51:03 +0200
Subject: [PATCH 11/14] Add lvm_vg_get_property() generic vg property function.
In-Reply-To: <4CB41EF8.9010706@redhat.com> (Zdenek Kabelac's message of "Tue, 
	12 Oct 2010 10:40:24 +0200")
References: <1286810078-25769-1-git-send-email-dwysocha@redhat.com>
	<1286810078-25769-12-git-send-email-dwysocha@redhat.com>
	<4CB41EF8.9010706@redhat.com>
Message-ID: <87d3rfwup4.fsf@twilight.int.mornfall.net.>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Zdenek Kabelac <zkabelac@redhat.com> writes:

>> +/**
>> + * Property Value
>> + *
>> + * This structure defines a single LVM property value for an LVM object.
>> + * The structures are returned by functions such as
>> + * lvm_vg_get_property() and lvm_vg_set_property().
>> + */
>> +typedef struct lvm_property_value {
>> +	unsigned is_writeable;
>> +	unsigned is_string;
>> +	union {
>> +		char *s_val;
>
> are we going to support return of modifiable strings - or const would fit here
> ?  (IMHO I still think, we are duplicating way too many things on return...)

I don't think duplication is the issue. We are stuck in C, which means
that memory management has to be explicit (no RAII here). So going for
consistency is a good goal, since we can't really win and have a neat
API. We can still have one that comes with as few surprises as possible,
though.

With the approach Dave is using, we can guarantee lifetime of objects
related to a VG to be the same as that of the VG handle. The other
consistent option is to not use pools at all, and allocate everything on
heap. Then, the objects can be explicitly cleaned up by the caller. This
would be a lot better for memory scalability.

Never allocating anything at all can't work, since some of the strings
that we return are not persistently stored in the VG structures. There
is the option to take a buffer/length parameter, but that makes for very
tedious client code.

>
>> +		uint64_t n_val;
>> +	} v;
>> +} lvm_property_value_t;
>> +
>
>
>> +int lvm_vg_get_property(const vg_t vg, const char *name,
>> +			struct lvm_property_value *value)
>> +{
>> +	struct lvm_property_type prop;
>> +
>> +	strncpy(prop.id, name, LVM_PROPERTY_NAME_LEN);
>
> Hmmm why doing a copy here instead of passing/assigning  'name' ptr somewhere?
>
>
>> +	if (!vg_get_property(vg, &prop))
>> +		return -1;
>
> As this is public interface - I'd add check for valid 'value' pointer.
>
> if (value) return 0;   // might indicate, property exists and is queriable,
> but user is not interested in the result.
You mean if (!value)?

>> +	value->is_writeable = prop.is_writeable;
>> +	value->is_string = prop.is_string;
>> +	if (value->is_string)
>> +		value->v.s_val = prop.v.s_val;
>> +	else
>> +		value->v.n_val = prop.v.n_val;
>> +	return 0;
>> +}


