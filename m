From: Tony Asleson <tasleson@redhat.com>
Date: Wed, 24 Oct 2012 15:58:18 -0500
Subject: liblvm/python-lvm behavior
Message-ID: <5088566A.4080105@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

In liblvm the user is required to follow any changes with a lvm_vg_write
to make the change persistent.  Internally, lvm_vg_write does a vg_write
and vg_commit.  In the python bindings most of the modification methods
do this automatically.  Currently the python bindings do not expose the
lvm_vg_write functionality.  For those methods that don't implicitly
call lvm_vg_write we appear to have no way to make those changes
persistent unless you call another vg modification method that does an
implicit lvm_vg_write.  This needs to be corrected.

A further complication is that in the C API the user could do:

vg = lvm_vg_create( library_handle, "vg_name");
lvm_vg_write(vg);
lvm_vg_close(vg);
lvm_quit(library_handle);

expecting that the newly created vg will exist, but it doesn't until you
have at least added one PV via lvm_vg_extend.  Currently a user does not
get any errors in this use case either.

What should be done to make this all consistent?  If we want to continue
with the implicit lvm_vg_write in all python methods we need to change
the signature of lvm_vg_create to require at least 1 device.  Otherwise,
we could remove all the implicit lvm_vg_write calls in the python
bindings and expose it.  This would then require python users to make
explicit calls to lvm_vg_write to make the changes persistent as the C
library currently requires.

Note: Please remember that eventually we want to support "dry run" mode
too, so that may factor into some of the design decisions on how we want
to deal with this.

Thanks!

Regards,
Tony


