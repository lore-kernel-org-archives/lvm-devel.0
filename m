From: Piter Punk <piterpunk@unitednerds.org>
Date: Fri, 4 Jun 2010 17:42:05 -0300
Subject: [PATCH] Clean up cluster lock mode and flags definition.
In-Reply-To: <1275664291-18424-1-git-send-email-mbroz@redhat.com>
References: <1275664291-18424-1-git-send-email-mbroz@redhat.com>
Message-ID: <0b317eee0dca47b32fca3586db6a5ee0.squirrel@webmail.unitednerds.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


On Fri, June 4, 2010 12:11 pm, Milan Broz wrote:
> Code is mixing up internal DLM and LVM definitions of lock
> modes and flags.
>
> OpenAIS and singlenode locking do not depend on DLM but
> code currently cannot be compiled without libdlm.h!
>
> LCK_* flags is LVM abstraction, used through all the code.
> Only low-level backend (clvmd-cmac etc) should use DLM definitions,
> also this code should do all needed conversions.
>
> Because there are two DLM flags used in generic code
> (NOQUEUE, CONVERT) we define it similar way like lock modes.
> (So all needed binary-compatible flags are on one place in locking.h)

Thanks!

When I send the patch to fix this issue:

https://www.redhat.com/archives/lvm-devel/2010-May/msg00180.html

I change all references to use <linux/dlm.h> avoiding <libdlm.h>.
I didn?t know we have the same definitions (with internal names) on
locking.h.

With your fix I can continue compiling clvmd+openais without the
need of libdlm and, now, without the need of patching the sources.

Thanks again!

Piter Punk


