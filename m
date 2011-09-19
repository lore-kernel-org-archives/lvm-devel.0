From: Alasdair G Kergon <agk@redhat.com>
Date: Mon, 19 Sep 2011 02:01:51 +0100
Subject: LVM2/daemons Makefile.in lvmetad/Makefile.in
In-Reply-To: <20110919002912.12809.qmail@sourceware.org>
References: <20110919002912.12809.qmail@sourceware.org>
Message-ID: <20110919010151.GA1842@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Mon, Sep 19, 2011 at 12:29:12AM -0000, zkabelac at sourceware.org wrote:
> 	It seem lvmetad deps must be expressed after the include.
> 	Also adding lvmetad deps to device-mapper target in daemons dir.
 
There's a contradiction here that must be resolved.

As you know, our tree is basically divided into dm and lvm.

The name of the daemon starts with 'lvm' so it must be considered to be
part of lvm and built as part of lvm.
However the Makefiles are referring to 'device-mapper'.

So resolve this either by renaming the daemon to dm (and ensure it does not use
any bits of the lvm part of the tree a la dmeventd etc.) OR removing it from
'device-mapper' makefile targets and build it as part of the lvm pass.  If it
was only meant for lvm's use, as I thought was intended, then the second
alternative is the one that needs to be done.

(This problem must be resolved before I can consider including the code in
any release tarball.)

Alasdair


