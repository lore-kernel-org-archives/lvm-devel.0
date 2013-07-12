From: Mikulas Patocka <mpatocka@redhat.com>
Date: Fri, 12 Jul 2013 19:11:41 -0400 (EDT)
Subject: number conversion in lvm
Message-ID: <alpine.LRH.2.02.1307121904020.15166@file01.intranet.prod.int.rdu2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi

I found some strange code in _get_int_arg in ./tools/lvmcmdline.c:

v = strtol(val, ptr, 10);

if (*ptr == val)
        return 0;

av->i_value = (int32_t) v;
av->ui_value = (uint32_t) v;
av->i64_value = (int64_t) v;
av->ui64_value = (uint64_t) v;

It is taking 32-bit long value and then casting it to 64 bits. Should 
there be strtoull instead of strtol?

BTW. how is that function supposed to handle integer overflow - it doesn't 
seem to do that.

Mikulas


