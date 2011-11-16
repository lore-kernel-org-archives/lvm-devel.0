From: Alasdair G Kergon <agk@redhat.com>
Date: Wed, 16 Nov 2011 01:20:39 +0000
Subject: [PATCH] Fix RHBZ 754198 (multiple dmeventd snapshot extensions)
In-Reply-To: <87pqgtxczr.fsf@aldalome.int.mornfall.net.>
References: <87pqgtxczr.fsf@aldalome.int.mornfall.net.>
Message-ID: <20111116012039.GB3294@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Tue, Nov 15, 2011 at 11:00:24PM +0100, Peter Rockai wrote:
> extending a snapshot. To this end, I have added a special exit code,
> ENO_ACTION_NEEDED -- however, this is not absolutely required, and is

Let's not add it then in response to a bug fix.

If the cmd exits OK, there's only really one code we should return for
shell scripts.  Splitting 'OK' into 'OK - something changed' and
'OK - but nothing was changed' doesn't seem worth the effort and
adding a new code for one special case is the thin end of the wedge.

(If there's nothing to do and use_policies was given, it can just return the
normal OK?)

> only an optimisation. On the other hand, it is likely an important
> optimisation, because without this, all snapshots filled above 50 % will
> run a LVM command (with all the associated overhead) every 10

Why does it loop every 10 seconds?  Is there another way to stop it?

1) Is there some problematic interaction between the configurable
(or even default) parameters that's causing problems?  Do some
parameters sometimes need overriding or constraining?
We should list the parameters and any constraints and make sure the
code deals with them.
(This might be going beyond the specific problem that Corey found,
but suggesting related problems to fix.)

2) One auto-extend should always be enough to deal with the notified
event.
  - It should pass in the minimum required extension and use_policies
should take account of that.

Alasdair


