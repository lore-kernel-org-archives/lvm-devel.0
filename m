From: Eric Ren <zren@suse.com>
Date: Wed, 10 May 2017 17:10:27 +0800
Subject: Is it reasonable to build lvmlockd in this way?
Message-ID: <87647df9-df19-8edd-1d60-7e99b9bcb12b@suse.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi David,

Firstly, I really appreciate your work on lvmlockd feature. I've enabled it for openSUSE,
and have testing on it, which works great.

But, we got a build problem on lvmlockd discussed here:
     https://bugzilla.suse.com/show_bug.cgi?id=1037309

This is caused by the way openSUSE tries to build cluster-relative packages separately
by splitting spec file into different ones, in order to avoid dependencies when building
basic lvm packages:
     https://build.opensuse.org/package/show/Base:System/lvm2

For cLVM, we can do it this way without problems. But, it cannot work for lvmlockd in this way,
because main lvm tools(like vgcreate) will link to the empty version of lvmlockd functions
(lockd_running_lock_type in lvmlockd.h).

Our package team insists that we should change lvmlockd to the clvm way so that we can
build lvmlockd separately.   Before doing useless work, I really like to hear your advice first.

Any comments would be appreciated!

Regards,
Eric


