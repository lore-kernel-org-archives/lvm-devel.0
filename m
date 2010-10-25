From: Jim Meyering <jim@meyering.net>
Date: Mon, 25 Oct 2010 11:12:00 +0200
Subject: [PATCH 00/30] Fixes from clang
In-Reply-To: <cover.1287994529.git.zkabelac@redhat.com> (Zdenek Kabelac's
	message of "Mon, 25 Oct 2010 10:24:07 +0200")
References: <cover.1287994529.git.zkabelac@redhat.com>
Message-ID: <8762wqiqlb.fsf@meyering.net>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Zdenek Kabelac wrote:
> Patchset combines code cleanups for compiler warnings
> and code fixes found by static analyzer scan-build.
>
> Potentional NULL pointer dereferencies are mostly
> in very unusual code execution paths. I've tried to
> order them on their importance - the later ones are not
> event trigerable as surrounding code should not be to
> pass problematic values - but checks seems to be simple
> enough to keep static analysis happy.
>
> Last patches in this set add some instrumentation to
> function calls that might allow better code optimization
> or better static analysis.
>
> Zdenek Kabelac (30):
>   Fix clang warning for ntohl(*((uint32_t *)buf))
>   Use dm_pool_grow_object embeded strlen for 0 delta
>   Check (type) is not NULL before access
>   Fix NULL pointer dereference
>   Print vg_name and do not to access vg->name
>   Ensure we always have origin defined
>   Ensure seg is nonnull
>   Ensure  first is not NULL
>   Reuse result of previous strchr.
>   Fix potential NULL pointer dereference
>   Fix theoretical usage of NULL pointer dereference
>   Check for NULL pointer
>   Eliminate uninitialized_var
>   Fix missing initilisation to 0
>   Function pull_state cannot work with NULL buffer
>   Fix  void* pointer arithmetic
>   Use const pvid for device_from_pvid()
>   Use const pointer for return value of dm_basename
>   Fix constness warning
>   Fix constness warning
>   Fix constness warning
>   Fix constness warning
>   Using const config node
>   bufused is assigned 0 in preceding source line
>   Proper C declaration
>   Use static
>   Instrument compiler about code unreachability
>   Skip uninitialized macro for scan-build
>   Add some __attribute__ instrumentation
>   __attribute__((nonnull(1)))

Nice work!
Getting any project in good enough shape to pass clang's
tests is tedious but well worth it.


