From: Milan Broz <mbroz@redhat.com>
Date: Thu, 05 Feb 2009 13:52:33 +0100
Subject: [PATCH] A different implementation of --ignorelockingfailure.
In-Reply-To: <871vuva9yn.fsf@eriador.mornfall.net>
References: <871vuva9yn.fsf@eriador.mornfall.net>
Message-ID: <498AE111.90009@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Petr Rockai wrote:
> two ends are addressed by this patch: getting rid of some global state and also
> restricting --ignorelockingfailure to only allow what it is supposed to allow
> (instead of a few hacked-in checks at some places and our belief that the users
> will be well-behaved).

Acked-by: Milan Broz <mbroz@redhat.com>

--ignorelockingfailure should be used only to activate base volumes during boot,
(e.g. when /var/lock/lvm is read-only, locking is clustered but we just starting
clvmd or /var is on activated volumes itself etc)


Tested-by: Milan Broz <mbroz@redhat.com>

Some warnings (both are trivial)

locking/no_locking.c: In function '_boottime_lock_resource':
locking/no_locking.c:73: warning: suggest parentheses around comparison in operand of &

tools/toollib.c:1134: undefined reference to `lockingfailed'


If anyone want write test script for testsuite

- a) commands with locking_type = 1, /etc/lvm/lock mounted read only
- b) locking type 3 without clvmd running

 without --ignorelockingfailure it must fail,
 with that parm only vgchange, lvchange -a y/n should work

- transition from clustered->local->ignorefailure still works
(test combination of fallback_to_clustered_locking, fallback_to_local_locking)

Milan
--
mbroz at redhat.com


