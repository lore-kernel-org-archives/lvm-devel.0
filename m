From: Marian Csontos <mcsontos@redhat.com>
Date: Thu, 15 Mar 2018 11:11:34 +0100
Subject: make: Non standard CLDFLAGS used for some targets
Message-ID: <e4f55d1f-773d-2167-d0e3-c0b85e4196fa@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

I am looking into Bug 1548715 - lvm2: Partial build flags injection

https://bugzilla.redhat.com/show_bug.cgi?id=1548715

I have found most of our code uses "standard" variables CFLAGS, LDFLAGS, 
but at few places (e.g. dmeventd) CLDFLAGS is used for whatever reason.

The purpose is not clear to me... Anything to do with versioned symbols:

     CLDFLAGS="$CLDFLAGS -Wl,--version-script,.export.sym"

Whatever the purpose is, this ignores set LDFLAGS variable.
1. Shall this be set to LDFLAGS as default, and extended with additional 
options?
2. Shall this be used together with LDFLAGS, like ELDFLAGS?

-- Martian


