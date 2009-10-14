From: Mikulas Patocka <mpatocka@redhat.com>
Date: Wed, 14 Oct 2009 10:13:07 -0400 (EDT)
Subject: [ANNOUNCE] shared snapshots for userspace
Message-ID: <Pine.LNX.4.64.0910141006460.30255@hs20-bc2-1.build.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi

I released userspace support for shared snapshots. It can be downloaded 
from
http://people.redhat.com/mpatocka/patches/userspace/new-snapshots/lvm-2.02.53/

It allows to create, delete, activate, deactivate the shared snapshots. It 
supports resize too but the kernel doesn't (so you can resize the store 
but it has no effect).

Use --sharedstore mikulas or --sharedstore fujita-daniel parameter to 
specify the shared store type, otherwise the syntax is the same as for 
nonshared snasphots.

It creates an lvm volume with suffix -shared that represents the shared 
volume. It can never be activated (the origin is activated instead). 
Individual snapshots are then placed into this -shared volume.

The kernel patches are at
http://people.redhat.com/mpatocka/patches/kernel/new-snapshots/devel/

Mikulas


