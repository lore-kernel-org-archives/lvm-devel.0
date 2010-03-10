From: Petr Rockai <prockai@redhat.com>
Date: Wed, 10 Mar 2010 18:04:15 +0100
Subject: [PATCH DRAFT] Automatic testing with locking_type = 3.
Message-ID: <87mxygglbk.fsf@twilight.int.mornfall.net.>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

this patch adds the option to run our automatic testsuite with a clvmd
configured for single-machine operation. There are still couple things
that need to be done for this patch before checkin though:

- rename fake to (probably) singlenode
- clean up and double-check the _resource_(un)lock implementation

Currently, we only keep the locks in memory. This is wholly appropriate
as long as clvmd is running and being used -- since all locking goes
through this clvmd instance, there's no need for external coordination.

As things are (with the current locking implementation) the full
testsuite passes. You can try with yourself with 

# LVM_TEST_LOCKING=3 make check

The next step, other than above, is to integrate this into make check,
so make check will run all the tests twice, once with locking_type 1 and
once with locking_type 3.

I will send a revised patch later.

Yours,
   Petr.

-------------- next part --------------
A non-text attachment was scrubbed...
Name: clvmd-fake.diff
Type: text/x-diff
Size: 10627 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20100310/21e45f80/attachment.bin>
