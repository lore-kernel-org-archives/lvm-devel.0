From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Mon, 15 Jul 2013 22:22:54 +0200
Subject: number conversion in lvm
In-Reply-To: <alpine.LRH.2.02.1307151556340.11390@file01.intranet.prod.int.rdu2.redhat.com>
References: <alpine.LRH.2.02.1307121904020.15166@file01.intranet.prod.int.rdu2.redhat.com>
	<51E11494.2080505@redhat.com>
	<alpine.LRH.2.02.1307151556340.11390@file01.intranet.prod.int.rdu2.redhat.com>
Message-ID: <51E45A1E.2090105@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 15.7.2013 22:10, Mikulas Patocka napsal(a):
>
>
> On Sat, 13 Jul 2013, Zdenek Kabelac wrote:
>
>> Dne 13.7.2013 01:11, Mikulas Patocka napsal(a):
>>> Hi
>>>
>>> I found some strange code in _get_int_arg in ./tools/lvmcmdline.c:
>>>
>>> v = strtol(val, ptr, 10);
>>>
>>> if (*ptr == val)
>>>           return 0;
>>>
>>> av->i_value = (int32_t) v;
>>> av->ui_value = (uint32_t) v;
>>> av->i64_value = (int64_t) v;
>>> av->ui64_value = (uint64_t) v;
>>>
>>> It is taking 32-bit long value and then casting it to 64 bits. Should
>>> there be strtoull instead of strtol?
>>
>> It used to read only 32bit values.
>> For 64bit other functions are used - i.e.  _size_arg
>
> In tools/pvck.c there is "arg_uint64_value(cmd, labelsector_ARG,", but
> labelsector_ARG is declared with "arg(labelsector_ARG, '\0',
> "labelsector", int_arg, 0)", so there is loss of values that do not fit
> into long type.
>

Yep - could be some inconsistency which may need implementation of
function like   sector_arg which will accept full 64bit value.
(See args.h for labelsector_ARG)
int_arg should be left to accept only 32bit values.

Seems like noone so far tried to specify sectors reaching past 1TB when 
seeking for lvm header ;)

>>> BTW. how is that function supposed to handle integer overflow - it doesn't
>>> seem to do that.
>>>
>>
>> it returns  LONG_MIN/MAX for underflow/overflow - but assuming errno could
>> be checked for ERANGE and fail command for this case instead.
>>
>> Zdenek
>
> The major problem is that the same function _get_int_arg parses both
> 32-bit and 64-bit arguments. It would be natural to return error on
> integer overflow but you can't because you don't know if the caller will
> use the 32-bit value or the 64-bit value.
>
> Another question is why there is av->i_value and av->ui_value when the
> values are the same and not dependent on the sign? What if the value fits

There are separate function for checking sign and accepting signed ints 
(int_arg_with_sign) - otherwise if SIGN_MINUS is detect - log error
is reported.

Zdenek




