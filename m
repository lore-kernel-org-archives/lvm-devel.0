From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Sat, 13 Jul 2013 10:49:24 +0200
Subject: number conversion in lvm
In-Reply-To: <alpine.LRH.2.02.1307121904020.15166@file01.intranet.prod.int.rdu2.redhat.com>
References: <alpine.LRH.2.02.1307121904020.15166@file01.intranet.prod.int.rdu2.redhat.com>
Message-ID: <51E11494.2080505@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 13.7.2013 01:11, Mikulas Patocka napsal(a):
> Hi
>
> I found some strange code in _get_int_arg in ./tools/lvmcmdline.c:
>
> v = strtol(val, ptr, 10);
>
> if (*ptr == val)
>          return 0;
>
> av->i_value = (int32_t) v;
> av->ui_value = (uint32_t) v;
> av->i64_value = (int64_t) v;
> av->ui64_value = (uint64_t) v;
>
> It is taking 32-bit long value and then casting it to 64 bits. Should
> there be strtoull instead of strtol?

It used to read only 32bit values.
For 64bit other functions are used - i.e.  _size_arg

>
> BTW. how is that function supposed to handle integer overflow - it doesn't
> seem to do that.
>

it returns  LONG_MIN/MAX for underflow/overflow - but assuming errno could
be checked for ERANGE and fail command for this case instead.

Zdenek



