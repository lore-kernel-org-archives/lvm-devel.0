From: Eric Ren <renzhengeek@gmail.com>
Date: Sun, 14 Apr 2019 15:30:19 +0800
Subject: lvcreate hangs forever and udev work timeout
In-Reply-To: <00ae05c4-5ad8-1137-076d-57a24f093fd3@redhat.com>
References: <CAKM4AeyUFr1PQB8jSVR2iaa9tTozwij0cCOfFWdTaX+txru0mg@mail.gmail.com>
	<00ae05c4-5ad8-1137-076d-57a24f093fd3@redhat.com>
Message-ID: <CAKM4Aew4cNU0_8mBYCXjxPOzDMUt8eGtJP5mjq3g3vUUPw6-rA@mail.gmail.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

The reason is found out, as you've predicted.

> is it because of slow read operation (i.e. some raid arrays are known to
> wake-up slowly)

The udev worker is blocked until timeout before killed, cause the
"blkid" in /usr/lib/udev/rules.d/13-dm-disk.rules is too slow because
of high IO load on the thin pool.

After remove this rule:

IMPORT{builtin}="blkid"

for testing, the problem cannot be reproduced any more.

But, we tried to increate udevd timeout to 5 min, the problem still
happens; with 10 min timeout, can workaround this problem.

>From my understanding, the blkid will only read the fs superblock, why
it takes so long for a small IO to finish, even under high IO load?

Regards,
Eric


