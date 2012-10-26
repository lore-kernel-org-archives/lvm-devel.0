From: Andy Grover <agrover@redhat.com>
Date: Fri, 26 Oct 2012 13:40:43 -0700
Subject: liblvm/python-lvm behavior
In-Reply-To: <5088566A.4080105@redhat.com>
References: <5088566A.4080105@redhat.com>
Message-ID: <508AF54B.9090302@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 10/24/2012 01:58 PM, Tony Asleson wrote:
> What should be done to make this all consistent?  If we want to continue
> with the implicit lvm_vg_write in all python methods we need to change
> the signature of lvm_vg_create to require at least 1 device.  Otherwise,
> we could remove all the implicit lvm_vg_write calls in the python
> bindings and expose it.  This would then require python users to make
> explicit calls to lvm_vg_write to make the changes persistent as the C
> library currently requires.

Yes I think we should not expose vg_write to library users. The fact
that it is created as an in-memory struct that is then extended to
include its first pv and then written, doesn't need to be exposed since
skipping any of those steps is incorrect.

So I'd like to see lvm_vg_create take a single path to a vg as a
required parameter. I don't think we need to take multiple pv paths, we
can extend to them after lvm_vg_create returns easily enough.

Regards -- Andy


